


import 'dart:io'; 
import 'dart:convert'; 
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; 
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:my_first_flutter_app/services/restaurant_service.dart';
import 'package:my_first_flutter_app/widgets/custom_text_field.dart';

const Color primaryBlack = Colors.black;
const Color primaryWhite = Colors.white;
const Color lightGray = Colors.grey;
const double borderRadius = 30.0;

class AddRestaurantScreen extends StatefulWidget {
  const AddRestaurantScreen({super.key});

  @override
  State<AddRestaurantScreen> createState() => _AddRestaurantScreenState();
}

class _AddRestaurantScreenState extends State<AddRestaurantScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  final _tableCountController = TextEditingController(text: '1');

  // MODIFIED: Changed from File? to String? to hold the Base64 encoded image
  String? _base64ImageString; 
  bool _isLoading = false;
  bool _isGettingLocation = false;
  Position? _currentPosition;
  final List<String> _timeSlots = [];
  final TextEditingController _timeController = TextEditingController();
  String? _selectedCategory;
  bool _isAddingNewCategory = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _tableCountController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  bool _validateTimeFormat(String time) {
    final timeRegex = RegExp(r'^([01]?[0-9]|2[0-3]):[0-5][0-9]\s*([aApP][mM])?\s*$');
    if (!timeRegex.hasMatch(time)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid time format (HH:MM AM/PM)'), duration: Duration(seconds: 2)),
      );
      return false;
    }

    if (_timeSlots.contains(time)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This time slot is already added'), duration: Duration(seconds: 2)),
      );
      return false;
    }

    return true;
  }

  Future<void> _showTimePicker() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
            primary: primaryBlack,
            onPrimary: primaryWhite,
            surface: primaryWhite,
            onSurface: primaryBlack,
          ),
          dialogTheme: const DialogThemeData(backgroundColor: primaryWhite),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      final timeString =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      if (_validateTimeFormat(timeString)) {
        setState(() {
          _timeSlots.add(timeString);
          _timeSlots.sort();
        });
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isGettingLocation = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location services are disabled')),
          );
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permissions are denied')),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are permanently denied')),
          );
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      setState(() => _currentPosition = position);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting location: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGettingLocation = false);
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
          source: source, 
          imageQuality: 50, 
          maxWidth: 300,   
        ); 

      if (pickedFile != null) {
        // Read the file as bytes
        final imageFile = File(pickedFile.path);
        Uint8List imageBytes = await imageFile.readAsBytes();

        // Encode the bytes into a Base64 string
        final encodedImage = base64Encode(imageBytes);

        // Update the state with the Base64 string
        setState(() {
          _base64ImageString = encodedImage;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking or encoding image: $e')),
        );
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please get your location first')),
      );
      return;
    }

    if (_timeSlots.length != 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please add exactly 5 time slots (${_timeSlots.length}/5)')),
      );
      return;
    }
    
    final base64Image = _base64ImageString; 

    setState(() => _isLoading = true);

    try {
      final restaurantService = context.read<RestaurantService>();

      // Determine final category
      String category = _isAddingNewCategory ? _categoryController.text.trim() : _selectedCategory ?? '';
      if (category.isEmpty) {
        throw Exception('Please select or enter a category');
      }

      // Add new category to Firestore if needed
      if (_isAddingNewCategory) {
        await restaurantService.addCategory(category);
      }

      final tableCount = int.tryParse(_tableCountController.text) ?? 1;
     
      await restaurantService.addRestaurant(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        
        category: category,
        tableCount: tableCount,
        location: {
          'latitude': _currentPosition!.latitude,
          'longitude': _currentPosition!.longitude,
          'address': 'Current Location',
        },
        timeSlots: _timeSlots,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Restaurant added successfully')),
        );
        if (mounted) {
          Navigator.of(context).pop(true); // Return success
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding restaurant: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Container(
          color: primaryWhite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library, color: primaryBlack),
                title: const Text('Choose from Gallery', style: TextStyle(color: primaryBlack)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: primaryBlack),
                title: const Text('Take a Photo', style: TextStyle(color: primaryBlack)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryWhite,
      appBar: AppBar(
        title: const Text(
          'Add New Restaurant',
          style: TextStyle(color: primaryBlack, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryWhite,
        foregroundColor: primaryBlack,
        elevation: 0,
        actions: [
          // Add Restaurant button with + icon
          IconButton(
            onPressed: _isLoading ? null : _submitForm,
            icon: const Icon(Icons.add, color: primaryBlack, size: 28),
            tooltip: 'Add Restaurant',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // MODIFIED: Restaurant image display using Base64 string
            GestureDetector(
              onTap: _showImagePickerOptions,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: primaryBlack.withOpacity(0.5), width: 1),
                ),
                child: _base64ImageString != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(
                          base64Decode(_base64ImageString!), 
                          fit: BoxFit.cover, 
                          width: double.infinity,
                        ),
                      )
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate, size: 48, color: lightGray),
                          SizedBox(height: 8),
                          Text('Add Restaurant Photo', style: TextStyle(color: primaryBlack)),
                        ],
                      ),
              ),
            ),
            // REST OF THE UI REMAINS UNCHANGED...
            const SizedBox(height: 24),
            CustomTextField(
              controller: _nameController,
              label: 'Restaurant Name',
              hintText: 'Enter restaurant name',
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please enter a restaurant name';
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Category dropdown/new category
            FutureBuilder<List<String>>(
              future: context.read<RestaurantService>().getCategories(),
              builder: (context, snapshot) {
                final categories = snapshot.data ?? [];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!_isAddingNewCategory)
                      DropdownButtonFormField<String>(
                        initialValue: _selectedCategory,
                        decoration: InputDecoration(
                          labelText: 'Select Category',
                          labelStyle: const TextStyle(color: lightGray),
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(borderRadius), borderSide: const BorderSide(color: lightGray)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(borderRadius), borderSide: const BorderSide(color: primaryBlack, width: 2)),
                          prefixIcon: const Icon(Icons.category, color: primaryBlack),
                        ),
                        isExpanded: true,
                        dropdownColor: primaryWhite,
                        style: const TextStyle(color: primaryBlack),
                        icon: const Icon(Icons.arrow_drop_down, color: primaryBlack),
                        items: [
                          if (_selectedCategory == null)
                            const DropdownMenuItem(value: null, child: Text('Select a category', style: TextStyle(color: lightGray))),
                          ...categories.map((category) => DropdownMenuItem(value: category, child: Text(category, style: const TextStyle(color: primaryBlack)))),
                          if (_selectedCategory == null)
                            const DropdownMenuItem(value: 'add_new', child: Text('+ Add New Category', style: TextStyle(color: primaryBlack, fontWeight: FontWeight.bold))),
                        ],
                        onChanged: (value) {
                          if (value == 'add_new') {
                            setState(() {
                              _isAddingNewCategory = true;
                              _selectedCategory = null;
                              _categoryController.clear();
                            });
                          } else {
                            setState(() {
                              _selectedCategory = value;
                              _isAddingNewCategory = false;
                            });
                          }
                        },
                        validator: (value) {
                          if (!_isAddingNewCategory && (value == null || value.isEmpty)) return 'Please select or add a category';
                          return null;
                        },
                      ),
                    if (_isAddingNewCategory)
                      TextFormField(
                        controller: _categoryController,
                        decoration: InputDecoration(
                          labelText: 'New Category',
                          hintText: 'Enter new category name',
                          labelStyle: const TextStyle(color: lightGray),
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(borderRadius), borderSide: const BorderSide(color: lightGray)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(borderRadius), borderSide: const BorderSide(color: primaryBlack, width: 2)),
                          prefixIcon: const Icon(Icons.add_circle_outline, color: primaryBlack),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.close, color: primaryBlack),
                            onPressed: () {
                              setState(() {
                                _isAddingNewCategory = false;
                                _selectedCategory = null;
                                _categoryController.clear();
                              });
                            },
                          ),
                        ),
                        style: const TextStyle(color: primaryBlack),
                        validator: (value) {
                          if (_isAddingNewCategory && (value == null || value.isEmpty)) return 'Please enter a category name';
                          return null;
                        },
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _descriptionController,
              label: 'Description',
              hintText: 'Tell us about your restaurant',
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please enter a description';
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _tableCountController,
              label: 'Number of Tables',
              hintText: 'e.g., 10',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Required';
                final count = int.tryParse(value);
                if (count == null || count <= 0) return 'Invalid number';
                return null;
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.chair, color: primaryBlack),
              title: const Text('Seats per Table', style: TextStyle(color: primaryBlack)),
              subtitle: const Text('6 (Fixed)', style: TextStyle(color: lightGray)),
              dense: true,
            ),
            const SizedBox(height: 24),
            Text('Available Time Slots (HH:MM format, 24-hour)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: primaryBlack, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Add Time Slot',
                      hintText: 'e.g., 14:30',
                      labelStyle: const TextStyle(color: lightGray),
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(borderRadius), borderSide: const BorderSide(color: lightGray)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(borderRadius), borderSide: const BorderSide(color: primaryBlack, width: 2)),
                    ),
                    style: const TextStyle(color: primaryBlack),
                    controller: _timeController,
                    onFieldSubmitted: (value) {
                      if (value.trim().isNotEmpty && _validateTimeFormat(value)) {
                        setState(() {
                          _timeSlots.add(value);
                          _timeSlots.sort();
                          _timeController.clear();
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: _showTimePicker,
                  icon: const Icon(Icons.access_time, color: primaryBlack),
                  label: const Text('Pick Time', style: TextStyle(color: primaryBlack)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_timeSlots.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _timeSlots
                    .map((slot) => Chip(
                          label: Text(slot),
                          onDeleted: () => setState(() => _timeSlots.remove(slot)),
                          backgroundColor: primaryBlack,
                          labelStyle: const TextStyle(color: primaryWhite, fontWeight: FontWeight.bold),
                          deleteIcon: const Icon(Icons.close, size: 16, color: primaryWhite),
                        ))
                    .toList(),
              ),
            const SizedBox(height: 16),
            Text('Location',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: primaryBlack, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _currentPosition != null
                        ? 'Location captured (${_currentPosition!.latitude.toStringAsFixed(4)}, ${_currentPosition!.longitude.toStringAsFixed(4)})'
                        : 'No location set',
                    style: TextStyle(color: _currentPosition != null ? primaryBlack : lightGray),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _isGettingLocation ? null : _getCurrentLocation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlack,
                    foregroundColor: primaryWhite,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
                  ),
                  icon: _isGettingLocation
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(primaryWhite)))
                      : const Icon(Icons.location_on, size: 18),
                  label: Text(_isGettingLocation ? 'Getting Location...' : 'Get Location'),
                ),
              ],
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlack,
                foregroundColor: primaryWhite,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
              ),
              child: _isLoading
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(primaryWhite)))
                  : const Text('ADD RESTAURANT', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}