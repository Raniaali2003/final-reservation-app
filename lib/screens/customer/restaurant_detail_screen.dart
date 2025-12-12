


// // Flutter and Third Party Packages
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:my_first_flutter_app/models/restaurant.dart';
// import 'package:my_first_flutter_app/services/restaurant_service.dart';
// import 'package:my_first_flutter_app/screens/customer/book_table_screen.dart';
// import 'dart:convert'; // ⭐️ MODIFICATION 1: REQUIRED for Base64 decoding

// class RestaurantDetailScreen extends StatefulWidget {
//   final String restaurantId;

//   const RestaurantDetailScreen({
//     super.key,
//     required this.restaurantId,
//   });

//   @override
//   State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
// }

// class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
//   late Restaurant _restaurant;
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadRestaurant();
//   }

//   Future<void> _loadRestaurant() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final restaurantService = context.read<RestaurantService>();
//       // ⚠️ IMPORTANT: Assuming getRestaurantById is asynchronous, 
//       // it should be 'final restaurant = await restaurantService.getRestaurantById(widget.restaurantId);'
//       // but keeping it synchronous here to match your original code structure, 
//       // assuming your service handles the synchronous retrieval correctly.
//       final restaurant = restaurantService.getRestaurantById(widget.restaurantId);
      
//       if (restaurant == null) {
//         throw Exception('Restaurant not found');
//       }
      
//       setState(() {
//         _restaurant = restaurant;
//       });
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to load restaurant: $e')),
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

//   void _onBookTable() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => BookTableScreen(
//           restaurantId: _restaurant.id,
//           restaurantName: _restaurant.name,
//         ),
//       ),
//     ).then((_) {
//       // Refresh restaurant data when returning from booking
//       _loadRestaurant();
//     });
//   }

//   // ⭐️ MODIFICATION 2: NEW HELPER WIDGET FOR BASE64 DECODING
//   Widget _buildRestaurantImage(String imageString) {
//     // If the path starts with 'assets/', treat it as a placeholder/asset path
//     if (imageString.startsWith('assets/')) {
//       // You might use Image.asset or the placeholder image here
//       return Image.asset(imageString, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _buildPlaceholderImage());
//     }
    
//     // Otherwise, assume it's a Base64 string and attempt decoding
//     try {
//       return Image.memory(
//         base64Decode(imageString),
//         fit: BoxFit.cover,
//         width: double.infinity,
//         errorBuilder: (context, error, stackTrace) {
//           // Fallback if the Base64 string is corrupted
//           return _buildPlaceholderImage();
//         },
//       );
//     } catch (e) {
//       // Catch general decoding errors and use placeholder
//       return _buildPlaceholderImage();
//     }
//   }

//   Widget _buildPlaceholderImage() {
//     return Container(
//       color: Colors.grey[200],
//       child: const Center(
//         child: Icon(
//           Icons.restaurant,
//           size: 64,
//           color: Colors.grey,
//         ),
//       ),
//     );
//   }
  
//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }

//     return Scaffold(
//       body: CustomScrollView(
//         slivers: [
//           SliverAppBar(
//             expandedHeight: 250,
//             pinned: true,
//             flexibleSpace: FlexibleSpaceBar(
//               title: Text(_restaurant.name),
//               // ⭐️ MODIFICATION 3: CALL THE NEW HELPER METHOD
//               background: _restaurant.imagePath.isNotEmpty
//                   ? _buildRestaurantImage(_restaurant.imagePath)
//                   : _buildPlaceholderImage(),
//             ),
//             actions: [
//               IconButton(
//                 icon: const Icon(Icons.favorite_border),
//                 onPressed: () {
//                   // Add to favorites
//                 },
//               ),
//             ],
//           ),
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     _restaurant.name,
//                     style: Theme.of(context).textTheme.headlineSmall,
//                   ),
//                   const SizedBox(height: 8),
//                   Row(
//                     children: [
//                       const Icon(Icons.location_on, size: 16),
//                       const SizedBox(width: 4),
//                       Text(
//                         _restaurant.location['address'] ?? 'No address',
//                         style: Theme.of(context).textTheme.bodyMedium,
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     'About',
//                     style: Theme.of(context).textTheme.titleMedium,
//                   ),
//                   const SizedBox(height: 8),
//                   Text(_restaurant.description),
//                   const SizedBox(height: 24),
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       onPressed: _onBookTable,
//                       child: const Text('Book a Table'),
//                     ),
//                   ),
//                   const SizedBox(height: 24),
//                   Text(
//                     'Available Tables: ${_restaurant.tables.length}',
//                     style: Theme.of(context).textTheme.titleMedium,
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     'Seats per Table: ${_restaurant.seatsPerTable}',
//                     style: Theme.of(context).textTheme.bodyMedium,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }



// Flutter and Third Party Packages
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_first_flutter_app/models/restaurant.dart';
import 'package:my_first_flutter_app/services/restaurant_service.dart';
import 'package:my_first_flutter_app/screens/customer/book_table_screen.dart';
import 'dart:convert'; // ⭐️ MODIFICATION 1: REQUIRED for Base64 decoding

// Define common colors for consistency (copied from previous screen)
const Color primaryBlack = Colors.black;
const Color primaryWhite = Colors.white;
const Color lightGray = Colors.grey;

class RestaurantDetailScreen extends StatefulWidget {
  final String restaurantId;

  const RestaurantDetailScreen({
    super.key,
    required this.restaurantId,
  });

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  late Restaurant _restaurant;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRestaurant();
  }

  Future<void> _loadRestaurant() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final restaurantService = context.read<RestaurantService>();
      // ⚠️ IMPORTANT: Assuming getRestaurantById is asynchronous, 
      // it should be 'final restaurant = await restaurantService.getRestaurantById(widget.restaurantId);'
      // but keeping it synchronous here to match your original code structure, 
      // assuming your service handles the synchronous retrieval correctly.
      final restaurant = restaurantService.getRestaurantById(widget.restaurantId);
      
      if (restaurant == null) {
        throw Exception('Restaurant not found');
      }
      
      setState(() {
        _restaurant = restaurant;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load restaurant: $e')),
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

  void _onBookTable() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookTableScreen(
          restaurantId: _restaurant.id,
          restaurantName: _restaurant.name,
        ),
      ),
    ).then((_) {
      // Refresh restaurant data when returning from booking
      _loadRestaurant();
    });
  }

  // ⭐️ MODIFICATION 2: NEW HELPER WIDGET FOR BASE64 DECODING
  Widget _buildRestaurantImage(String imageString) {
    // If the path starts with 'assets/', treat it as a placeholder/asset path
    if (imageString.startsWith('assets/')) {
      // You might use Image.asset or the placeholder image here
      return Image.asset(imageString, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _buildPlaceholderImage());
    }
    
    // Otherwise, assume it's a Base64 string and attempt decoding
    try {
      return Image.memory(
        base64Decode(imageString),
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          // Fallback if the Base64 string is corrupted
          return _buildPlaceholderImage();
        },
      );
    } catch (e) {
      // Catch general decoding errors and use placeholder
      return _buildPlaceholderImage();
    }
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: lightGray, // Use a light gray for the placeholder background
      child: const Center(
        child: Icon(
          Icons.restaurant,
          size: 64,
          color: primaryBlack, // Black icon for contrast
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(primaryBlack))),
      );
    }

    return Scaffold(
      backgroundColor: primaryWhite,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: primaryWhite,
            foregroundColor: primaryBlack, // For back button and icons
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                _restaurant.name,
                style: const TextStyle(
                  color: primaryBlack,
                  shadows: [
                    // Add a slight shadow for readability over the image/background
                    Shadow(
                      blurRadius: 2.0,
                      color: Color.fromRGBO(255, 255, 255, 0.5),
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              ),
              // ⭐️ MODIFICATION 3: CALL THE NEW HELPER METHOD
              background: Stack(
                fit: StackFit.expand,
                children: [
                  _restaurant.imagePath.isNotEmpty
                      ? _buildRestaurantImage(_restaurant.imagePath)
                      : _buildPlaceholderImage(),
                  // Add a subtle overlay for better text readability on images
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.1),
                          Colors.black.withOpacity(0.4),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.favorite_border, color: primaryBlack),
                onPressed: () {
                  // Add to favorites
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _restaurant.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: primaryBlack, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: primaryBlack),
                      const SizedBox(width: 4),
                      Text(
                        _restaurant.location['address'] ?? 'No address',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: primaryBlack),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'About',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: primaryBlack, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(_restaurant.description, style: const TextStyle(color: primaryBlack)),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _onBookTable,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlack, // Black button background
                        foregroundColor: primaryWhite, // White text
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: primaryBlack),
                        ),
                      ),
                      child: const Text('Book a Table', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Available Tables: ${_restaurant.tables.length}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: primaryBlack, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Seats per Table: ${_restaurant.seatsPerTable}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: primaryBlack),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}