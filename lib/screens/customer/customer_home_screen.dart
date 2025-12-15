import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_first_flutter_app/services/auth_service.dart';
import 'package:my_first_flutter_app/services/restaurant_service.dart';
import 'package:my_first_flutter_app/services/category_service.dart';
import 'package:my_first_flutter_app/models/restaurant.dart';
import 'package:my_first_flutter_app/screens/customer/restaurant_detail_screen.dart';
import 'dart:convert'; // REQUIRED for Base64 decoding

// Define common colors for consistency
const Color primaryBlack = Colors.black;
const Color primaryWhite = Colors.white;
const Color lightGray = Colors.grey;

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  List<Restaurant> _restaurants = [];
  List<String> _categories = [];
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategory;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final restaurantService = context.read<RestaurantService>();
      // NOTE: Assuming CategoryService is implemented to fetch categories
      final categoryService = CategoryService();

      // Load restaurants and categories in parallel
      // NOTE: Ensure getAllRestaurants is either synchronous or properly awaited if it's async
      final restaurants = restaurantService.getAllRestaurants();
      final categories = await categoryService.getCategories();

      if (mounted) {
        setState(() {
          _restaurants = restaurants;
          _categories = categories;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<Restaurant> get _filteredRestaurants {
    if (_searchQuery.isEmpty && _selectedCategory == null) {
      return _restaurants;
    }

    return _restaurants.where((restaurant) {
      final name = restaurant.name.toLowerCase();
      final description = restaurant.description.toLowerCase();
      final category = restaurant.category.toLowerCase();
      final query = _searchQuery.toLowerCase();

      final matchesSearch =
          query.isEmpty || name.contains(query) || description.contains(query);

      final matchesCategory = _selectedCategory == null ||
          category == _selectedCategory?.toLowerCase();

      return matchesSearch && matchesCategory;
    }).toList();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.trim();
    });
  }

  void _onCategorySelected(String? category) {
    setState(() {
      _selectedCategory = category == _selectedCategory ? null : category;
      // Clear search when changing categories for better UX
      if (_searchController.text.isNotEmpty) {
        _searchController.clear();
        _searchQuery = '';
      }
    });
  }

  Future<void> _handleLogout() async {
    final authService = context.read<AuthService>();
    try {
      await authService.logout();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error logging out: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryWhite, // Set background to white
      appBar: AppBar(
        title: const Text(
          'Restaurants',
          style: TextStyle(color: primaryBlack, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryWhite, // Set AppBar background to white
        foregroundColor: primaryBlack, // Set icon/text color to black
        elevation: 0, // Remove shadow
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(primaryBlack)))
          : Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    style: const TextStyle(
                        color: primaryBlack), // Input text color
                    decoration: InputDecoration(
                      hintText: 'Search restaurants...',
                      hintStyle: TextStyle(color: lightGray),
                      prefixIcon: const Icon(Icons.search, color: primaryBlack),
                      filled: true,
                      fillColor: primaryWhite,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: const BorderSide(color: primaryBlack),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide:
                            const BorderSide(color: lightGray, width: 1.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide:
                            const BorderSide(color: primaryBlack, width: 2.0),
                      ),
                    ),
                  ),
                ),

                // Categories
                SizedBox(
                  height: 50,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    children: [
                      const SizedBox(width: 8.0),
                      FilterChip(
                        label: const Text('All'),
                        selected: _selectedCategory == null,
                        onSelected: (_) => _onCategorySelected(null),
                        // Black/White Theme for Chips
                        selectedColor: primaryBlack,
                        backgroundColor: primaryWhite,
                        labelStyle: TextStyle(
                            color: _selectedCategory == null
                                ? primaryWhite
                                : primaryBlack,
                            fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                                color: _selectedCategory == null
                                    ? primaryBlack
                                    : lightGray)),
                      ),
                      ..._categories.map((category) => Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            child: FilterChip(
                              label: Text(category),
                              selected: _selectedCategory == category,
                              onSelected: (_) => _onCategorySelected(category),
                              // Black/White Theme for Chips
                              selectedColor: primaryBlack,
                              backgroundColor: primaryWhite,
                              labelStyle: TextStyle(
                                  color: _selectedCategory == category
                                      ? primaryWhite
                                      : primaryBlack,
                                  fontWeight: FontWeight.bold),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(
                                      color: _selectedCategory == category
                                          ? primaryBlack
                                          : lightGray)),
                            ),
                          )),
                    ],
                  ),
                ),
                const Divider(color: lightGray), // Black/White divider

                // Restaurants List
                Expanded(
                  child: _filteredRestaurants.isEmpty
                      ? Center(
                          child: Text(
                            'No restaurants found',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(color: primaryBlack),
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(8.0),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.8,
                            crossAxisSpacing: 8.0,
                            mainAxisSpacing: 8.0,
                          ),
                          itemCount: _filteredRestaurants.length,
                          itemBuilder: (context, index) {
                            final restaurant = _filteredRestaurants[index];
                            return Card(
                              color: primaryWhite, // Card background
                              elevation: 2,
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          RestaurantDetailScreen(
                                        restaurantId: restaurant.id,
                                      ),
                                    ),
                                  );
                                },
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    // Image Display (Base64 Decode)
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius:
                                            const BorderRadius.vertical(
                                                top: Radius.circular(8.0)),
                                        child:
                                            restaurant.imagePath.isNotEmpty ==
                                                    true
                                                ? Image.memory(
                                                    base64Decode(
                                                        restaurant.imagePath),
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context,
                                                            error,
                                                            stackTrace) =>
                                                        Container(
                                                      color: Colors.grey[200],
                                                      child: const Icon(
                                                          Icons.broken_image,
                                                          size: 50,
                                                          color: lightGray),
                                                    ),
                                                  )
                                                : Container(
                                                    color: Colors.grey[200],
                                                    child: const Icon(
                                                        Icons.restaurant,
                                                        size: 50,
                                                        color: lightGray),
                                                  ),
                                      ),
                                    ),
                                    // Text Info
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            restaurant.name.isNotEmpty == true
                                                ? restaurant.name
                                                : 'Unnamed Restaurant',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: primaryBlack, // Text color
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            restaurant.category.isNotEmpty ==
                                                    true
                                                ? restaurant.category
                                                : 'No Category',
                                            style: TextStyle(
                                              color: lightGray, // Text color
                                              fontSize: 14,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
