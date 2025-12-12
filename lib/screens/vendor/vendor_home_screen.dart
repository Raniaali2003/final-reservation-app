// import 'package:flutter/material.dart';

// import 'package:provider/provider.dart';
// import 'package:my_first_flutter_app/models/restaurant.dart';
// import 'package:my_first_flutter_app/services/restaurant_service.dart';
// import 'package:my_first_flutter_app/widgets/restaurant_card.dart';
// import 'package:my_first_flutter_app/screens/vendor/manage_categories_screen.dart';

// const Color primaryBlack = Colors.black;
// const Color primaryWhite = Colors.white;
// const Color lightGray = Colors.grey;

// class VendorHomeScreen extends StatefulWidget {
//   const VendorHomeScreen({super.key});

//   @override
//   State<VendorHomeScreen> createState() => _VendorHomeScreenState();
// }

// class _VendorHomeScreenState extends State<VendorHomeScreen> {
//   List<Restaurant> _restaurants = [];
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadRestaurants();
//   }

//   Future<void> _loadRestaurants() async {
//     if (!mounted) return;

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final restaurantService = Provider.of<RestaurantService>(context, listen: false);
//       // Force refresh from the service
//       await restaurantService.loadRestaurants();
//       final restaurants = restaurantService.getAllRestaurants();
//       if (mounted) {
//         setState(() {
//           _restaurants = restaurants;
//         });
//         // Show success message
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Restaurants refreshed successfully'),
//             duration: Duration(seconds: 2),
//           ),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Failed to refresh restaurants: $e'),
//             duration: const Duration(seconds: 3),
//           ),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         Navigator.pushReplacementNamed(context, '/role-selection');
//         return false;
//       },
//       child: Scaffold(
//         backgroundColor: primaryWhite,
//         appBar: AppBar(
//           backgroundColor: primaryWhite,
//           foregroundColor: primaryBlack,
//           elevation: 0,
//           title: const Text('My Restaurants', style: TextStyle(color: primaryBlack)),
//           leading: IconButton(
//             icon: const Icon(Icons.arrow_back, color: primaryBlack),
//             onPressed: () => Navigator.pushReplacementNamed(context, '/role-selection'),
//           ),
//           actions: [
//             IconButton(
//               icon: _isLoading 
//                   ? const SizedBox(
//                       width: 20,
//                       height: 20,
//                       child: CircularProgressIndicator(
//                         strokeWidth: 2,
//                         color: primaryBlack,
//                       ),
//                     )
//                   : const Icon(Icons.refresh, color: primaryBlack),
//               onPressed: _isLoading ? null : _loadRestaurants,
//               tooltip: 'Refresh restaurants',
//             ),
//             IconButton(
//               icon: const Icon(Icons.category, color: primaryBlack),
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => const ManageCategoriesScreen(),
//                   ),
//                 );
//               },
//               tooltip: 'Manage Categories',
//             ),
//             // Add Restaurant button
//             IconButton(
//               icon: const Icon(Icons.add, color: primaryBlack),
//               onPressed: () {
//                 Navigator.pushNamed(context, '/vendor/add-restaurant');
//               },
//               tooltip: 'Add Restaurant',
//             ),
//           ],
//         ),
//         body: _isLoading
//             ? const Center(child: CircularProgressIndicator(color: primaryBlack))
//             : _buildContent(),
//       ),
//     );
//   }

//   Widget _buildContent() {
//     if (_restaurants.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.restaurant_menu,
//               size: 64,
//               color: primaryBlack.withOpacity(0.5),
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'No Restaurants Yet',
//               style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                     color: primaryBlack,
//                     fontWeight: FontWeight.bold,
//                   ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Add your first restaurant to get started',
//               style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                     color: lightGray,
//                   ),
//             ),
//             const SizedBox(height: 24),
//             ElevatedButton.icon(
//               onPressed: () {
//                 Navigator.of(context).pushNamed('/vendor/add-restaurant');
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: primaryBlack,
//                 foregroundColor: primaryWhite,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//               icon: const Icon(Icons.add),
//               label: const Text('Add Restaurant', style: TextStyle(fontWeight: FontWeight.bold)),
//             ),
//           ],
//         ),
//       );
//     }

//     return RefreshIndicator(
//       color: primaryBlack,
//       onRefresh: _loadRestaurants,
//       child: _buildRestaurantList(),
//     );
//   }

//   Widget _buildRestaurantList() {
//     return ListView.builder(
//       padding: const EdgeInsets.all(16),
//       itemCount: _restaurants.length,
//       itemBuilder: (context, index) {
//         final restaurant = _restaurants[index];
//         return Padding(
//           padding: const EdgeInsets.only(bottom: 16),
//           child: RestaurantCard(
//             restaurant: restaurant,
//             showViewBookings: true,
//             onTap: () {
//               Navigator.pushNamed(
//                 context,
//                 '/vendor/edit-restaurant',
//                 arguments: restaurant.id,
//               );
//             },
//           ),
//         );
//       },
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_first_flutter_app/models/restaurant.dart';
import 'package:my_first_flutter_app/services/restaurant_service.dart';
import 'package:my_first_flutter_app/widgets/restaurant_card.dart';
import 'package:my_first_flutter_app/screens/vendor/manage_categories_screen.dart';

const Color primaryBlack = Colors.black;
const Color primaryWhite = Colors.white;
const Color lightGray = Colors.grey;
const Color primaryRed = Colors.red; // Added for delete action

class VendorHomeScreen extends StatefulWidget {
  const VendorHomeScreen({super.key});

  @override
  State<VendorHomeScreen> createState() => _VendorHomeScreenState();
}

class _VendorHomeScreenState extends State<VendorHomeScreen> {
  List<Restaurant> _restaurants = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Use Future.microtask to ensure the context is fully built before reading the service
    // This resolves the common 'setState during build' warning when provider is used in initState
    Future.microtask(() => _loadRestaurants());
  }

  Future<void> _loadRestaurants() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final restaurantService = Provider.of<RestaurantService>(context, listen: false);
      // Force refresh from the service
      await restaurantService.loadRestaurants();
      // The local service list is the source of truth
      final restaurants = restaurantService.getAllRestaurants();
      
      if (mounted) {
        setState(() {
          _restaurants = restaurants;
        });
        // Removed success snackbar here to avoid spamming the user on initial load
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load restaurants: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ------------------ NEW: Deletion Logic ------------------

  Future<void> _deleteRestaurant(String restaurantId) async {
    final service = context.read<RestaurantService>();
    
    // Optimistic UI update: remove from local list immediately
    setState(() {
      _restaurants.removeWhere((r) => r.id == restaurantId);
    });

    try {
      await service.deleteRestaurant(restaurantId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Restaurant deleted successfully')),
        );
      }
    } catch (e) {
      // Revert UI change if deletion fails in Firestore
      // To properly revert, we'd need to fetch the single restaurant back or store a snapshot,
      // but for simplicity, we'll just log and reload.
      debugPrint('Error deleting restaurant: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete restaurant: $e')),
        );
        // Force full reload to resync local list with Firestore state
        _loadRestaurants();
      }
    }
  }

  Future<bool?> _confirmDelete(BuildContext context, String restaurantName) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: primaryWhite,
        title: const Text('Confirm Deletion', style: TextStyle(color: primaryBlack)),
        content: Text('Are you sure you want to delete "$restaurantName"? This action cannot be undone.', style: const TextStyle(color: primaryBlack)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel', style: TextStyle(color: primaryBlack)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: primaryRed, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, '/role-selection');
        return false;
      },
      child: Scaffold(
        backgroundColor: primaryWhite,
        appBar: AppBar(
          backgroundColor: primaryWhite,
          foregroundColor: primaryBlack,
          elevation: 0,
          title: const Text('My Restaurants', style: TextStyle(color: primaryBlack)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: primaryBlack),
            onPressed: () => Navigator.pushReplacementNamed(context, '/role-selection'),
          ),
          actions: [
            // Refresh Button
            IconButton(
              icon: _isLoading 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: primaryBlack,
                      ),
                    )
                  : const Icon(Icons.refresh, color: primaryBlack),
              onPressed: _isLoading ? null : _loadRestaurants,
              tooltip: 'Refresh restaurants',
            ),
            // Manage Categories Button
            IconButton(
              icon: const Icon(Icons.category, color: primaryBlack),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ManageCategoriesScreen(),
                  ),
                );
              },
              tooltip: 'Manage Categories',
            ),
            // Add Restaurant button
            IconButton(
              icon: const Icon(Icons.add, color: primaryBlack),
              onPressed: () async {
                final result = await Navigator.pushNamed(context, '/vendor/add-restaurant');
                // Reload after adding a restaurant
                if (result == true) {
                  _loadRestaurants();
                }
              },
              tooltip: 'Add Restaurant',
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: primaryBlack))
            : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (_restaurants.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu,
              size: 64,
              color: primaryBlack.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No Restaurants Yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: primaryBlack,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first restaurant to get started',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: lightGray,
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.of(context).pushNamed('/vendor/add-restaurant');
                if (result == true) {
                  _loadRestaurants();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlack,
                foregroundColor: primaryWhite,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Add Restaurant', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: primaryBlack,
      onRefresh: _loadRestaurants,
      child: _buildRestaurantList(),
    );
  }

  Widget _buildRestaurantList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _restaurants.length,
      itemBuilder: (context, index) {
        final restaurant = _restaurants[index];
        
        // MODIFIED: Wrap RestaurantCard in a Dismissible widget for swipe-to-delete
        return Dismissible(
          key: ValueKey(restaurant.id), // Unique key for the Dismissible widget
          direction: DismissDirection.endToStart,
          // Background shown during swipe
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20.0),
            color: primaryRed,
            child: const Icon(Icons.delete_forever, color: primaryWhite),
          ),
          confirmDismiss: (direction) async {
            // Show confirmation dialog before executing the delete
            return await _confirmDelete(context, restaurant.name);
          },
          onDismissed: (direction) {
            // Execute the delete operation after confirmation
            _deleteRestaurant(restaurant.id);
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: RestaurantCard(
              restaurant: restaurant,
              showViewBookings: true,
              onTap: () async {
                // Navigate to edit screen and reload if data was potentially changed
                final result = await Navigator.pushNamed(
                  context,
                  '/vendor/edit-restaurant',
                  arguments: restaurant.id,
                );
                if (result == true) {
                  _loadRestaurants();
                }
              },
            ),
          ),
        );
      },
    );
  }
}