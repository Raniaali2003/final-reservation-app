// import 'package:flutter/material.dart';
// import 'package:my_first_flutter_app/models/restaurant.dart';

// class RestaurantCard extends StatelessWidget {
//   final Restaurant restaurant;
//   final VoidCallback? onTap;
//   final bool showCategory;
//   final bool showTableCount;
//   final bool showSeatsPerTable;
//   final bool showViewBookings;

//   const RestaurantCard({
//     super.key,
//     required this.restaurant,
//     this.onTap,
//     this.showCategory = true,
//     this.showTableCount = true,
//     this.showSeatsPerTable = true,
//     this.showViewBookings = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(12),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             // Restaurant Image
//             ClipRRect(
//               borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
//               child: AspectRatio(
//                 aspectRatio: 16 / 9,
//                 child: restaurant.imagePath.isNotEmpty
//                     ? Image.asset(
//                         restaurant.imagePath,
//                         fit: BoxFit.cover,
//                         errorBuilder: (context, error, stackTrace) =>
//                             _buildPlaceholderImage(),
//                       )
//                     : _buildPlaceholderImage(),
//               ),
//             ),
//             // Restaurant Info
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Name and Rating
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Text(
//                           restaurant.name,
//                           style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                                 fontWeight: FontWeight.bold,
//                               ),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                       // Add rating widget here if needed
//                     ],
//                   ),
//                   const SizedBox(height: 8),
//                   // Category
//                   if (showCategory && restaurant.category.isNotEmpty)
//                     Padding(
//                       padding: const EdgeInsets.only(bottom: 4),
//                       child: Row(
//                         children: [
//                           Icon(
//                             Icons.category,
//                             size: 16,
//                             color: Theme.of(context).hintColor,
//                           ),
//                           const SizedBox(width: 4),
//                           Text(
//                             restaurant.category,
//                             style: Theme.of(context).textTheme.bodySmall,
//                           ),
//                         ],
//                       ),
//                     ),
//                   // Description
//                   if (restaurant.description.isNotEmpty)
//                     Padding(
//                       padding: const EdgeInsets.only(bottom: 8, top: 4),
//                       child: Text(
//                         restaurant.description,
//                         style: Theme.of(context).textTheme.bodyMedium,
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                   // Available Time Slots
//                   if (restaurant.timeSlots.isNotEmpty)
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const SizedBox(height: 4),
//                         Text(
//                           'Available Times:',
//                           style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                                 color: Theme.of(context).hintColor,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                         ),
//                         const SizedBox(height: 4),
//                         Wrap(
//                           spacing: 4,
//                           runSpacing: 4,
//                           children: restaurant.timeSlots.take(3).map((time) => Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 8,
//                               vertical: 4,
//                             ),
//                             decoration: BoxDecoration(
//                               color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: Text(
//                               time,
//                               style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                                 color: Theme.of(context).colorScheme.primary,
//                                 fontSize: 12,
//                               ),
//                             ),
//                           )).toList(),
//                         ),
//                         if (restaurant.timeSlots.length > 3)
//                           Padding(
//                             padding: const EdgeInsets.only(top: 4),
//                             child: Text(
//                               '+${restaurant.timeSlots.length - 3} more',
//                               style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                                 color: Theme.of(context).hintColor,
//                                 fontSize: 12,
//                               ),
//                             ),
//                           ),
//                       ],
//                     ),
//                   // Stats
//                   Row(
//                     children: [
//                       if (showTableCount)
//                         _buildStat(
//                           context,
//                           Icons.table_restaurant,
//                           '${restaurant.tableCount} Tables',
//                         ),
//                       if (showTableCount && showSeatsPerTable)
//                         const SizedBox(width: 16),
//                       if (showSeatsPerTable)
//                         _buildStat(
//                           context,
//                           Icons.people,
//                           '${restaurant.seatsPerTable} Seats/Table',
//                         ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             // View Bookings Button (for vendors)
//             if (showViewBookings) ...[
//               const SizedBox(height: 12),
//               SizedBox(
//                 width: double.infinity,
//                 child: OutlinedButton.icon(
//                   onPressed: () {
//                     Navigator.pushNamed(
//                       context,
//                       '/vendor/booked-tables',
//                       arguments: restaurant.id,
//                     );
//                   },
//                   icon: const Icon(Icons.calendar_today, size: 16),
//                   label: const Text('View Bookings'),
//                   style: OutlinedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                     side: BorderSide(color: Theme.of(context).primaryColor),
//                   ),
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildStat(BuildContext context, IconData icon, String text) {
//     return Row(
//       children: [
//         Icon(
//           icon,
//           size: 16,
//           color: Theme.of(context).hintColor,
//         ),
//         const SizedBox(width: 4),
//         Text(
//           text,
//           style: Theme.of(context).textTheme.bodySmall,
//         ),
//       ],
//     );
//   }

//   Widget _buildPlaceholderImage() {
//     return Container(
//       color: Colors.grey[200],
//       child: const Center(
//         child: Icon(
//           Icons.restaurant,
//           size: 48,
//           color: Colors.grey,
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:my_first_flutter_app/models/restaurant.dart';
import 'dart:convert'; // REQUIRED for Base64 decoding

class RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;
  final VoidCallback? onTap;
  final bool showCategory;
  final bool showTableCount;
  final bool showSeatsPerTable;
  final bool showViewBookings;

  const RestaurantCard({
    super.key,
    required this.restaurant,
    this.onTap,
    this.showCategory = true,
    this.showTableCount = true,
    this.showSeatsPerTable = true,
    this.showViewBookings = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Restaurant Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                // MODIFIED: Use the safe image widget
                child: restaurant.imagePath.isNotEmpty
                    ? _buildImageWidget(context)
                    : _buildPlaceholderImage(),
              ),
            ),
            // Restaurant Info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and Rating
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          restaurant.name,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Add rating widget here if needed
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Category
                  if (showCategory && restaurant.category.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Icon(
                            Icons.category,
                            size: 16,
                            color: Theme.of(context).hintColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            restaurant.category,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  // Description
                  if (restaurant.description.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8, top: 4),
                      child: Text(
                        restaurant.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  // Available Time Slots
                  if (restaurant.timeSlots.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          'Available Times:',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).hintColor,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: restaurant.timeSlots.take(3).map((time) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  time,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Theme.of(context).colorScheme.primary,
                                        fontSize: 12,
                                      ),
                                ),
                              )).toList(),
                        ),
                        if (restaurant.timeSlots.length > 3)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              '+${restaurant.timeSlots.length - 3} more',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).hintColor,
                                    fontSize: 12,
                                  ),
                            ),
                          ),
                      ],
                    ),
                  // Stats
                  Row(
                    children: [
                      if (showTableCount)
                        _buildStat(
                          context,
                          Icons.table_restaurant,
                          '${restaurant.tableCount} Tables',
                        ),
                      if (showTableCount && showSeatsPerTable)
                        const SizedBox(width: 16),
                      if (showSeatsPerTable)
                        _buildStat(
                          context,
                          Icons.people,
                          '${restaurant.seatsPerTable} Seats/Table',
                        ),
                    ],
                  ),
                ],
              ),
            ),
            // View Bookings Button (for vendors)
            if (showViewBookings) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/vendor/booked-tables',
                      arguments: restaurant.id,
                    );
                  },
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: const Text('View Bookings'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: Theme.of(context).primaryColor),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // MODIFIED: This function handles both Base64 and asset placeholders safely.
  Widget _buildImageWidget(BuildContext context) {
    final imagePath = restaurant.imagePath;

    // 1. Check if the path is a known asset placeholder (e.g., for default data)
    if (imagePath.startsWith('assets/') || imagePath.length < 100) {
      return Image.asset(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
      );
    }

    // 2. Assume it's a Base64 string and attempt to decode safely
    try {
      return Image.memory(
        base64Decode(imagePath), // Decode the Base64 string
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          // Fallback if the Base64 string is corrupted or invalid
          return _buildPlaceholderImage();
        },
      );
    } catch (e) {
      // 3. Catch decoding errors (e.g., if the string isn't valid Base64)
      debugPrint('Error decoding Base64 image for ${restaurant.name}: $e');
      return _buildPlaceholderImage();
    }
  }

  Widget _buildStat(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).hintColor,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Icon(
          Icons.restaurant,
          size: 48,
          color: Colors.grey,
        ),
      ),
    );
  }
}