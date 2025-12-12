import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_first_flutter_app/models/restaurant.dart';
import 'package:my_first_flutter_app/services/restaurant_service.dart';
import 'package:my_first_flutter_app/widgets/custom_text_field.dart';

class BookingScreen extends StatefulWidget {
  final String restaurantId;
  final String tableId;
  final DateTime date;
  final String timeSlot;
  final int people;

  BookingScreen({
    super.key,
    required this.restaurantId,
    required this.tableId,
    DateTime? date,
    String? timeSlot,
    int? people,
  })  : date = date ?? DateTime.now(),
        timeSlot = timeSlot ?? '',
        people = people ?? 2;

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _specialRequestsController = TextEditingController();
  bool _isLoading = false;
  bool _isSubmitting = false;
  Restaurant? _restaurant;
  TableModel? _table;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _specialRequestsController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final restaurantService = context.read<RestaurantService>();
      final restaurant = restaurantService.getRestaurantById(widget.restaurantId);
      
      if (restaurant == null) {
        throw Exception('Restaurant not found');
      }
      
      final table = restaurant.tables.firstWhere(
        (t) => t.id == widget.tableId,
        orElse: () => throw Exception('Table not found'),
      );
      
      setState(() {
        _restaurant = restaurant;
        _table = table;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final restaurantService = context.read<RestaurantService>();
      final user = restaurantService.currentUser;
      
      if (user == null) {
        throw Exception('User not logged in');
      }

      await restaurantService.makeReservation(
        restaurantId: widget.restaurantId,
        tableId: widget.tableId,
        customer: user,
        date: widget.date,
        timeSlot: widget.timeSlot,
        numberOfPeople: widget.people,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reservation confirmed!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate to booking confirmation or home screen
        Navigator.pushReplacementNamed(context, '/customer');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to book: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _restaurant == null || _table == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Confirm Booking',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        iconTheme: IconThemeData(color: theme.primaryColor),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Booking Summary Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                    side: BorderSide(
                      color: theme.dividerColor.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Booking Summary',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                          ),
                        ),
                        const Divider(height: 30, thickness: 1),
                        Text(
                          _restaurant!.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow(Icons.table_restaurant, 'Table ${_table!.number} (${_table!.maxSeats} seats)'),
                        const SizedBox(height: 12),
                        _buildInfoRow(Icons.calendar_today, _formatDate(widget.date)),
                        const SizedBox(height: 12),
                        _buildInfoRow(Icons.access_time, widget.timeSlot),
                        const SizedBox(height: 12),
                        _buildInfoRow(Icons.people, '${widget.people} ${widget.people == 1 ? 'Person' : 'People'}')
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Contact Information
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Contact Information',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  hintText: 'Enter your full name',
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  hintText: 'Enter your phone number',
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    // Basic phone number validation
                    if (!RegExp(r'^[0-9+\-\s()]{8,}$').hasMatch(value)) {
                      return 'Please enter a valid phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Special Requests
                Text(
                  'Special Requests (Optional)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: _specialRequestsController,
                  label: 'Special Requests',
                  hintText: 'Any special requests or notes',
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  validator: (value) {
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Terms and Conditions
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: true,
                      onChanged: (value) {},
                      activeColor: Theme.of(context).primaryColor,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'I agree to the Terms of Service and Privacy Policy',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Confirm Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    onPressed: _isSubmitting ? null : _submitBooking,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Confirm Booking',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        textDirection: TextDirection.rtl,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
                height: 1.4,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${_getWeekday(date.weekday)}, ${date.day} ${_getMonth(date.month)} ${date.year}';
  }

  String _getWeekday(int weekday) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return weekdays[weekday - 1];
  }

  String _getMonth(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }
}



