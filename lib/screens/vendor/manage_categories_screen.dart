import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/restaurant_service.dart';


// Color constants for B&W theme consistency
const Color primaryBlack = Colors.black;
const Color primaryWhite = Colors.white;
const Color lightGray = Colors.grey;
const Color errorRed = Color(0xFFC70039); // A darker red for visibility

class ManageCategoriesScreen extends StatefulWidget {
  const ManageCategoriesScreen({super.key});

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  final _categoryController = TextEditingController();
  bool _isLoading = false;
  final double borderRadius = 30.0; // Consistent border radius

  @override
  void dispose() {
    _categoryController.dispose();
    super.dispose();
  }

  // --- Logic Methods (Unchanged) ---

  Future<void> _addCategory(RestaurantService restaurantService) async {
    final category = _categoryController.text.trim();
    if (category.isEmpty) return;

    setState(() => _isLoading = true);
    
    try {
      final success = await restaurantService.addCategory(category);
      if (success && mounted) {
        _categoryController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding category: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _confirmDeleteCategory(String category, RestaurantService restaurantService) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        // ⭐️ UI CHANGE: B&W AlertDialog
        backgroundColor: primaryWhite,
        title: const Text('Delete Category', style: TextStyle(color: primaryBlack)),
        content: Text('Are you sure you want to delete "$category"?', style: const TextStyle(color: primaryBlack)),
        actions: [
          // ⭐️ UI CHANGE: B&W Cancel Button
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: primaryBlack)),
          ),
          // ⭐️ UI CHANGE: Red Delete Button
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: errorRed), // Use a bold red for deletion
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isLoading = true);
      try {
        final success = await restaurantService.removeCategory(category);
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Category removed successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error removing category: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }
  
  // --- Build Method (Theming Applied) ---

  @override
  Widget build(BuildContext context) {
    final restaurantService = context.watch<RestaurantService>();
    
    return Scaffold(
      backgroundColor: primaryWhite, // ⭐️ UI CHANGE: White background
      appBar: AppBar(
        // ⭐️ UI CHANGE: B&W AppBar
        title: const Text('Manage Categories', style: TextStyle(color: primaryBlack, fontWeight: FontWeight.bold)),
        backgroundColor: primaryWhite,
        foregroundColor: primaryBlack,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryBlack)) // ⭐️ UI CHANGE: Black indicator
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _categoryController,
                          style: const TextStyle(color: primaryBlack),
                          // ⭐️ UI CHANGE: B&W Input Decoration
                          decoration: InputDecoration(
                            labelText: 'New Category',
                            labelStyle: const TextStyle(color: lightGray),
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(borderRadius),
                              borderSide: const BorderSide(color: lightGray),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(borderRadius),
                              borderSide: const BorderSide(color: primaryBlack, width: 2),
                            ),
                            suffixIcon: _categoryController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, color: primaryBlack),
                                    onPressed: () {
                                      _categoryController.clear();
                                      setState(() {});
                                    },
                                  )
                                : null,
                          ),
                          onChanged: (_) {
                            setState(() {}); // Trigger rebuild to show/hide clear icon
                          },
                          onSubmitted: (_) => _addCategory(restaurantService),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // ⭐️ UI CHANGE: Black Add Button
                      ElevatedButton(
                        onPressed: () => _addCategory(restaurantService),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlack,
                          foregroundColor: primaryWhite,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(borderRadius),
                          ),
                        ),
                        child: const Text('Add', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                const Divider(color: lightGray, height: 1), // ⭐️ UI CHANGE: Grey divider
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Current Categories',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryBlack, // ⭐️ UI CHANGE: Black text
                    ),
                  ),
                ),
                Expanded(
                  child: FutureBuilder<List<String>>(
                    future: restaurantService.getCategories(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: primaryBlack)); // ⭐️ UI CHANGE: Black indicator
                      }
                      final categories = snapshot.data ?? [];
                      
                      if (categories.isEmpty) {
                        return const Center(
                          child: Text(
                            'No categories added yet.',
                            style: TextStyle(color: lightGray, fontStyle: FontStyle.italic), // ⭐️ UI CHANGE: Grey text
                          ),
                        );
                      }
                      
                      return ListView.builder(
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          return ListTile(
                            // ⭐️ UI CHANGE: B&W ListTile
                            title: Text(category, style: const TextStyle(color: primaryBlack)),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: errorRed), // Red for delete action
                              onPressed: () => _confirmDeleteCategory(category, restaurantService),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

