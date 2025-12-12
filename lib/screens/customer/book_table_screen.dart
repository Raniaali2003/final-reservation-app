

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:table_calendar/table_calendar.dart';
// import 'package:my_first_flutter_app/models/restaurant.dart';
// import 'package:my_first_flutter_app/services/restaurant_service.dart';
// import 'package:my_first_flutter_app/services/auth_service.dart';

// // Define common colors for consistency
// const Color primaryBlack = Colors.black;
// const Color primaryWhite = Colors.white;
// const Color lightGray = Colors.grey;

// class BookTableScreen extends StatefulWidget {
//   final String restaurantId;
//   final String restaurantName;

//   const BookTableScreen({
//     super.key,
//     required this.restaurantId,
//     required this.restaurantName,
//   });

//   @override
//   State<BookTableScreen> createState() => _BookTableScreenState();
// }

// class _BookTableScreenState extends State<BookTableScreen> {
//   late Restaurant _restaurant;
//   bool _isLoading = true;
//   DateTime _selectedDate = DateTime.now();
//   String? _selectedTimeSlot;
//   int _selectedPeople = 2;
//   String? _selectedTableId;
//   final List<int> _peopleOptions = [1, 2, 3, 4, 5, 6];
//   bool _isBooking = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadRestaurant();
//   }

//   Future<void> _loadRestaurant() async {
//     setState(() => _isLoading = true);

//     try {
//       final restaurantService = context.read<RestaurantService>();
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
//         setState(() => _isLoading = false);
//       }
//     }
//   }

//   void _onDaySelected(DateTime selectedDate, DateTime focusedDate) {
//     setState(() {
//       _selectedDate = selectedDate;
//       _selectedTimeSlot = null;
//       _selectedTableId = null; // Reset table selection when date changes
//     });
//   }

//   Future<void> _onBookTable() async {
//     if (_selectedTimeSlot == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please select a time slot')),
//       );
//       return;
//     }
    
//     if (_selectedTableId == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please select a table')),
//       );
//       return;
//     }

//     final authService = context.read<AuthService>();
//     if (authService.currentUser == null) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Please sign in to book a table')),
//         );
//       }
//       return;
//     }

//     setState(() => _isBooking = true);

//     try {
//       final restaurantService = context.read<RestaurantService>();
      
//       // Find the selected table
//       final table = _restaurant.tables.firstWhere(
//         (table) => table.id == _selectedTableId,
//         orElse: () => throw Exception('Selected table not found')
//       );
      
//       // Verify the table is still available
//       if (!table.isAvailable(_selectedDate, _selectedTimeSlot!)) {
//         throw Exception('The selected table is no longer available');
//       }
      
//       await restaurantService.makeReservation(
//         restaurantId: _restaurant.id,
//         tableId: table.id,
//         userId: authService.currentUser!.id,
//         date: _selectedDate,
//         timeSlot: _selectedTimeSlot!,
//         numberOfPeople: _selectedPeople,
//       );

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Table booked successfully!')),
//         );
//         Navigator.of(context).pop(true);
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to book table: $e')),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _isBooking = false);
//       }
//     }
//   }

//   List<String> _getAvailableTimeSlots() {
//     if (_restaurant.timeSlots.isEmpty) return [];
    
//     return _restaurant.timeSlots.where((slot) {
//       // Check if any table is available for this slot
//       return _restaurant.tables.any((table) => 
//         table.maxSeats >= _selectedPeople && 
//         table.isAvailable(_selectedDate, slot)
//       );
//     }).toList();
//   }
  
//   List<TableModel> _getAvailableTables() {
//     if (_selectedTimeSlot == null) return [];
    
//     final authService = context.read<AuthService>();
//     final currentUserId = authService.currentUser?.id;
    
//     return _restaurant.tables.where((table) => 
//       table.maxSeats >= _selectedPeople && 
//       table.isAvailable(
//         _selectedDate, 
//         _selectedTimeSlot!,
//         currentUserId: currentUserId,
//       )
//     ).toList();
//   }
  
//   Widget _buildTableSelection() {
//     if (_selectedTimeSlot == null) return const SizedBox.shrink();
    
//     final availableTables = _getAvailableTables();
//     final allTables = _restaurant.tables;
//     final authService = context.read<AuthService>();
//     final currentUserId = authService.currentUser?.id;
    
//     if (allTables.isEmpty) {
//       return const Padding(
//         padding: EdgeInsets.symmetric(vertical: 16.0),
//         child: Text('No tables available in this restaurant', style: TextStyle(color: primaryBlack)),
//       );
//     }
    
//     // Sort tables by number for consistent display
//     allTables.sort((a, b) => a.number.compareTo(b.number));
    
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const SizedBox(height: 16),
//         Row(
//           children: [
//             Text(
//               'Available Tables • ',
//               style: Theme.of(context).textTheme.titleMedium?.copyWith(color: primaryBlack),
//             ),
//             Text(
//               '${availableTables.length} of ${allTables.length} available',
//               style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                 color: primaryBlack, // Use black for consistency
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 8),
//         GridView.builder(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: 4,
//             childAspectRatio: 1.0,
//             crossAxisSpacing: 12.0,
//             mainAxisSpacing: 12.0,
//           ),
//           itemCount: allTables.length,
//           itemBuilder: (context, index) {
//             final table = allTables[index];
//             final isAvailable = availableTables.contains(table);
//             final isBookedByCurrentUser = !isAvailable && 
//                 table.reservations.any((r) => 
//                     r.userId == currentUserId && 
//                     r.timeSlot == _selectedTimeSlot &&
//                     r.date.year == _selectedDate.year &&
//                     r.date.month == _selectedDate.month &&
//                     r.date.day == _selectedDate.day);
            
//             Color tableBackgroundColor;
//             Color tableForegroundColor;
//             Color tableBorderColor;

//             if (_selectedTableId == table.id) {
//               // Selected
//               tableBackgroundColor = primaryBlack;
//               tableForegroundColor = primaryWhite;
//               tableBorderColor = primaryBlack;
//             } else if (isAvailable) {
//               // Available
//               tableBackgroundColor = primaryWhite;
//               tableForegroundColor = primaryBlack;
//               tableBorderColor = primaryBlack; 
//             } else if (isBookedByCurrentUser) {
//               // Booked by User
//               tableBackgroundColor = primaryBlack;
//               tableForegroundColor = primaryWhite;
//               tableBorderColor = primaryBlack;
//             } else {
//               // Unavailable
//               tableBackgroundColor = lightGray;
//               tableForegroundColor = primaryWhite;
//               tableBorderColor = lightGray;
//             }
            
//             return GestureDetector(
//               onTap: isAvailable
//                   ? () {
//                       setState(() {
//                         _selectedTableId = table.id;
//                       });
//                     }
//                   : null,
//               child: Tooltip(
//                 message: isBookedByCurrentUser 
//                     ? 'You have already booked this table' 
//                     : !isAvailable ? 'This table is already booked' : 'Table ${table.number} (${table.maxSeats} seats)',
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: tableBackgroundColor,
//                     borderRadius: BorderRadius.circular(8.0),
//                     border: Border.all(
//                       color: tableBorderColor,
//                       width: _selectedTableId == table.id || isBookedByCurrentUser ? 2.0 : 1.0,
//                     ),
//                     boxShadow: [
//                       if (_selectedTableId == table.id || isBookedByCurrentUser)
//                         const BoxShadow(
//                           color: Colors.black12,
//                           blurRadius: 4,
//                           offset: Offset(0, 2),
//                         ),
//                     ],
//                   ),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Stack(
//                         alignment: Alignment.center,
//                         children: [
//                           Icon(
//                             Icons.table_restaurant,
//                             size: 32,
//                             color: tableForegroundColor,
//                           ),
//                           if (isBookedByCurrentUser)
//                             const Positioned(
//                               top: 0,
//                               right: 4,
//                               child: Icon(
//                                 Icons.check_circle,
//                                 color: primaryWhite,
//                                 size: 16,
//                               ),
//                             ),
//                         ],
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         'Table ${table.number}',
//                         style: TextStyle(
//                           color: tableForegroundColor,
//                           fontWeight: _selectedTableId == table.id || isBookedByCurrentUser
//                               ? FontWeight.bold
//                               : FontWeight.normal,
//                         ),
//                       ),
//                       if (!isAvailable) ...[
//                         const SizedBox(height: 2),
//                         Text(
//                           isBookedByCurrentUser ? 'Your Booking' : 'Booked',
//                           style: TextStyle(
//                             color: primaryWhite,
//                             fontSize: 10,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ],
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
    
//     return Scaffold(
//       backgroundColor: primaryWhite,
//       appBar: AppBar(
//         title: Text(
//           'Book Table at ${widget.restaurantName}',
//           style: const TextStyle(color: primaryBlack, fontWeight: FontWeight.bold),
//         ),
//         backgroundColor: primaryWhite,
//         foregroundColor: primaryBlack,
//         elevation: 1, // Keep a slight elevation for separation
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(primaryBlack)))
//           : SingleChildScrollView(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   // Calendar
//                   Card(
//                     color: primaryWhite,
//                     elevation: 1,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       side: const BorderSide(color: lightGray),
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: TableCalendar(
//                         firstDay: DateTime.now(),
//                         lastDay: DateTime.now().add(const Duration(days: 30)),
//                         focusedDay: _selectedDate,
//                         selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
//                         onDaySelected: _onDaySelected,
//                         headerStyle: const HeaderStyle(
//                           formatButtonVisible: false,
//                           titleCentered: true,
//                           titleTextStyle: TextStyle(color: primaryBlack, fontWeight: FontWeight.bold),
//                           leftChevronIcon: Icon(Icons.chevron_left, color: primaryBlack),
//                           rightChevronIcon: Icon(Icons.chevron_right, color: primaryBlack),
//                         ),
//                         calendarStyle: CalendarStyle(
//                           selectedDecoration: const BoxDecoration(color: primaryBlack, shape: BoxShape.circle),
//                           todayDecoration: BoxDecoration(color: lightGray.withOpacity(0.5), shape: BoxShape.circle),
//                           defaultTextStyle: const TextStyle(color: primaryBlack),
//                           weekendTextStyle: const TextStyle(color: primaryBlack),
//                           outsideTextStyle: TextStyle(color: lightGray.withOpacity(0.7)),
//                         ),
//                         daysOfWeekStyle: const DaysOfWeekStyle(
//                           weekdayStyle: TextStyle(color: primaryBlack, fontWeight: FontWeight.bold),
//                           weekendStyle: TextStyle(color: primaryBlack, fontWeight: FontWeight.bold),
//                         ),
//                       ),
//                     ),
//                   ),
                  
//                   const SizedBox(height: 20),
                  
//                   // Number of People
//                   Text(
//                     'Number of People',
//                     style: theme.textTheme.titleMedium?.copyWith(color: primaryBlack),
//                   ),
//                   const SizedBox(height: 8),
//                   DropdownButtonFormField<int>(
//                     initialValue: _selectedPeople,
//                     style: const TextStyle(color: primaryBlack),
//                     items: _peopleOptions
//                         .map((count) => DropdownMenuItem(
//                               value: count,
//                               child: Text(
//                                 '$count ${count == 1 ? 'person' : 'people'}',
//                                 style: const TextStyle(color: primaryBlack),
//                               ),
//                             ))
//                         .toList(),
//                     onChanged: (value) {
//                       if (value != null) {
//                         setState(() {
//                           _selectedPeople = value;
//                           _selectedTimeSlot = null; // Reset time slot when people count changes
//                         });
//                       }
//                     },
//                     decoration: InputDecoration(
//                       border: const OutlineInputBorder(borderSide: BorderSide(color: primaryBlack)),
//                       enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: lightGray)),
//                       focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: primaryBlack, width: 2.0)),
//                       contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                       isDense: true,
//                     ),
//                   ),
                  
//                   const SizedBox(height: 20),
                  
//                   // Available Time Slots
//                   Text(
//                     'Available Time Slots',
//                     style: theme.textTheme.titleMedium?.copyWith(color: primaryBlack),
//                   ),
//                   const SizedBox(height: 8),
//                   _buildTimeSlotsGrid(),
                  
//                   if (_selectedTimeSlot != null) _buildTableSelection(),
                  
//                   const SizedBox(height: 20),
                  
//                   // Book Now Button
//                   ElevatedButton(
//                     onPressed: _isBooking ? null : _onBookTable,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: primaryBlack, // Black button background
//                       foregroundColor: primaryWhite, // White text
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                         side: const BorderSide(color: primaryBlack),
//                       ),
//                     ),
//                     child: _isBooking
//                         ? const SizedBox(
//                             height: 20,
//                             width: 20,
//                             child: CircularProgressIndicator(
//                               strokeWidth: 2,
//                               valueColor: AlwaysStoppedAnimation<Color>(primaryWhite),
//                             ),
//                           )
//                         : const Text(
//                             'Book Now', 
//                             style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
//                           ),
//                   ),
//                 ],
//               ),
//             ),
//     );
//   }

//   Widget _buildTimeSlotsGrid() {
//     final availableSlots = _getAvailableTimeSlots();
    
//     if (availableSlots.isEmpty) {
//       return const Padding(
//         padding: EdgeInsets.symmetric(vertical: 16.0),
//         child: Text('No available time slots for the selected date', style: TextStyle(color: primaryBlack)),
//       );
//     }

//     return Wrap(
//       spacing: 8,
//       runSpacing: 8,
//       children: availableSlots.map((slot) {
//         final isSelected = _selectedTimeSlot == slot;
//         return FilterChip(
//           label: Text(slot),
//           selected: isSelected,
//           onSelected: (selected) {
//             setState(() {
//               // Reset table selection when time slot changes
//               _selectedTimeSlot = selected ? slot : null;
//               _selectedTableId = null;
//             });
//           },
//           backgroundColor: primaryWhite,
//           selectedColor: primaryBlack,
//           labelStyle: TextStyle(
//             color: isSelected ? primaryWhite : primaryBlack,
//           ),
//           shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(20),
//               side: BorderSide(color: isSelected ? primaryBlack : lightGray)),
//         );
//       }).toList(),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
// Ensure these imports are correct based on your project structure
import 'package:my_first_flutter_app/models/restaurant.dart';
import 'package:my_first_flutter_app/services/restaurant_service.dart';
import 'package:my_first_flutter_app/services/auth_service.dart';
// Ensure User model is accessible

// Define common colors for consistency
const Color primaryBlack = Colors.black;
const Color primaryWhite = Colors.white;
const Color lightGray = Colors.grey;

class BookTableScreen extends StatefulWidget {
    final String restaurantId;
    final String restaurantName;

    const BookTableScreen({
        super.key,
        required this.restaurantId,
        required this.restaurantName,
    });

    @override
    State<BookTableScreen> createState() => _BookTableScreenState();
}

class _BookTableScreenState extends State<BookTableScreen> {
    late Restaurant _restaurant;
    bool _isLoading = true;
    DateTime _selectedDate = DateTime.now();
    String? _selectedTimeSlot;
    int _selectedPeople = 2;
    String? _selectedTableId;
    final List<int> _peopleOptions = [1, 2, 3, 4, 5, 6];
    bool _isBooking = false;

    @override
    void initState() {
        super.initState();
        // Set initial selected date to today, without time components
        _selectedDate = DateTime.utc(DateTime.now().year, DateTime.now().month, DateTime.now().day);
        _loadRestaurant();
    }

    Future<void> _loadRestaurant() async {
        setState(() => _isLoading = true);

        try {
            // Ensure RestaurantService is initialized before reading
            // NOTE: In a complex app, initialization should happen higher up (e.g., in main/wrapper)
            // but we keep it here for robustness.
            await context.read<RestaurantService>().init();
            
            final restaurantService = context.read<RestaurantService>();
            final restaurant = restaurantService.getRestaurantById(widget.restaurantId);
            
            if (restaurant == null) {
                throw Exception('Restaurant not found');
            }
            
            setState(() {
                _restaurant = restaurant;
            });
        } catch (e) {
            if (mounted) {
                // Use a more generic message for better user experience
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to load restaurant details.')),
                );
            }
        } finally {
            if (mounted) {
                setState(() => _isLoading = false);
            }
        }
    }

    void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
        // Only allow booking for today or future dates (up to 30 days, as defined by TableCalendar)
        final today = DateTime.utc(DateTime.now().year, DateTime.now().month, DateTime.now().day);
        if (selectedDay.isBefore(today)) return; 

        setState(() {
            _selectedDate = selectedDay;
            _selectedTimeSlot = null;
            _selectedTableId = null; // Reset table selection when date changes
        });
    }

    Future<void> _onBookTable() async {
        if (_selectedTimeSlot == null) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please select a time slot')),
            );
            return;
        }
        
        if (_selectedTableId == null) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please select a table')),
            );
            return;
        }

        final authService = context.read<AuthService>();
        final user = authService.currentUser; // Get the user object

        if (user == null) {
            if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please sign in to book a table')),
                );
            }
            return;
        }

        setState(() => _isBooking = true);

        try {
            final restaurantService = context.read<RestaurantService>();
            
            // Find the selected table
            final table = _restaurant.tables.firstWhere(
                (table) => table.id == _selectedTableId,
                orElse: () => throw Exception('Selected table not found')
            );
            
            // Re-verify the table is still available *before* the final booking call
            if (!table.isAvailable(_selectedDate, _selectedTimeSlot!)) {
                throw Exception('The selected table is no longer available');
            }
            
            // CRITICAL FIX HERE: Pass the full user object, not just the ID.
            await restaurantService.makeReservation(
                restaurantId: _restaurant.id,
                tableId: table.id,
                customer: user, // 🌟 FIX APPLIED HERE
                date: _selectedDate,
                timeSlot: _selectedTimeSlot!,
                numberOfPeople: _selectedPeople,
                // specialRequests is optional and omitted for brevity
            );

            if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Table booked successfully!')),
                );
                // Pop the screen and return true to indicate success
                Navigator.of(context).pop(true);
            }
        } catch (e) {
            if (mounted) {
                // Display only the error message text
                String errorText = e is Exception ? e.toString().replaceFirst('Exception: ', '') : e.toString();
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to book table: $errorText')),
                );
            }
        } finally {
            if (mounted) {
                setState(() => _isBooking = false);
            }
        }
    }

    List<String> _getAvailableTimeSlots() {
        if (_isLoading || !mounted) return [];
        if (_restaurant.timeSlots.isEmpty) return [];
        
        final authService = context.read<AuthService>();
        final currentUserId = authService.currentUser?.id;

        // Reset selected time slot if it's no longer available for the new date/people count
        final isCurrentSlotStillAvailable = _selectedTimeSlot != null && _restaurant.tables.any((table) => 
            table.maxSeats >= _selectedPeople && 
            table.isAvailable(_selectedDate, _selectedTimeSlot!, currentUserId: currentUserId)
        );

        if (_selectedTimeSlot != null && !isCurrentSlotStillAvailable) {
            // Optional: You could show a local warning here.
            // For now, we just reset the slot to force a new selection.
            WidgetsBinding.instance.addPostFrameCallback((_) {
                 if (mounted) {
                    setState(() {
                        _selectedTimeSlot = null;
                        _selectedTableId = null;
                    });
                }
            });
        }

        // Return all slots where at least one table is available for the selected party size
        return _restaurant.timeSlots.where((slot) {
            return _restaurant.tables.any((table) => 
                table.maxSeats >= _selectedPeople && 
                table.isAvailable(
                    _selectedDate, 
                    slot,
                    currentUserId: currentUserId, // Passed to ensure user doesn't book same slot twice
                )
            );
        }).toList();
    }
    
    List<TableModel> _getAvailableTables() {
        if (_selectedTimeSlot == null || _isLoading || !mounted) return [];
        
        final authService = context.read<AuthService>();
        final currentUserId = authService.currentUser?.id;
        
        // Filter tables by capacity and availability at the selected time
        return _restaurant.tables.where((table) => 
            table.maxSeats >= _selectedPeople && 
            table.isAvailable(
                _selectedDate, 
                _selectedTimeSlot!,
                currentUserId: currentUserId, 
            )
        ).toList();
    }
    
    Widget _buildTableSelection() {
        if (_selectedTimeSlot == null) return const SizedBox.shrink();
        
        final availableTables = _getAvailableTables();
        final allTables = _restaurant.tables;
        final authService = context.read<AuthService>();
        final currentUserId = authService.currentUser?.id;
        
        if (allTables.isEmpty) {
            return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text('No tables configured for this restaurant', style: TextStyle(color: primaryBlack)),
            );
        }
        
        // Sort tables by number for consistent display
        allTables.sort((a, b) => a.number.compareTo(b.number));
        
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                const SizedBox(height: 16),
                Row(
                    children: [
                        Text(
                            'Available Tables • ',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: primaryBlack),
                        ),
                        Text(
                            '${availableTables.length} of ${allTables.length} available',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: primaryBlack,
                                fontWeight: FontWeight.bold,
                            ),
                        ),
                    ],
                ),
                const SizedBox(height: 8),
                GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        childAspectRatio: 1.0,
                        crossAxisSpacing: 12.0,
                        mainAxisSpacing: 12.0,
                    ),
                    itemCount: allTables.length,
                    itemBuilder: (context, index) {
                        final table = allTables[index];
                        
                        // Check if the table is currently available for booking *for anyone* matching the party size
                        final isAvailableForBooking = table.maxSeats >= _selectedPeople && table.isAvailable(
                            _selectedDate, 
                            _selectedTimeSlot!, 
                            // The currentUserId is only passed to isAvailable to check for a *prior* booking
                            // by the user, but for general table coloring, we check without it first.
                            // However, we rely on the logic in isAvailable/reservation handling.
                            currentUserId: currentUserId
                        );
                        
                        // Check if the table is currently booked by the logged-in user
                        final isBookedByCurrentUser = table.reservations.any((r) => 
                                r.userId == currentUserId && 
                                r.timeSlot == _selectedTimeSlot &&
                                isSameDay(r.date, _selectedDate)
                            );
                        
                        // If it's booked by the current user, it should appear as booked, not available for *new* selection.
                        final isAvailableToSelect = isAvailableForBooking && !isBookedByCurrentUser;

                        // Check if the table is simply booked by someone else
                        final isBookedBySomeoneElse = !isAvailableToSelect && !isBookedByCurrentUser && 
                            table.reservations.any((r) => 
                                r.timeSlot == _selectedTimeSlot && isSameDay(r.date, _selectedDate)
                            );
                        
                        Color tableBackgroundColor;
                        Color tableForegroundColor;
                        Color tableBorderColor;

                        if (isBookedByCurrentUser) {
                            // User's own current booking (show as selected/booked)
                            tableBackgroundColor = primaryBlack;
                            tableForegroundColor = primaryWhite;
                            tableBorderColor = primaryBlack;
                        } else if (_selectedTableId == table.id) {
                            // Currently selected for booking
                            tableBackgroundColor = primaryBlack;
                            tableForegroundColor = primaryWhite;
                            tableBorderColor = primaryBlack;
                        } else if (isAvailableToSelect) {
                            // Available for selection
                            tableBackgroundColor = primaryWhite;
                            tableForegroundColor = primaryBlack;
                            tableBorderColor = primaryBlack; 
                        } else {
                            // Unavailable/Booked by someone else, or too small for party
                            tableBackgroundColor = lightGray;
                            tableForegroundColor = primaryWhite;
                            tableBorderColor = lightGray;
                        }
                        
                        return GestureDetector(
                            onTap: isAvailableToSelect
                                ? () {
                                    setState(() {
                                        _selectedTableId = table.id;
                                    });
                                }
                                : null,
                            child: Tooltip(
                                message: isBookedByCurrentUser 
                                    ? 'Your Current Booking' 
                                    : isBookedBySomeoneElse ? 'Booked by Others' : 'Table ${table.number} (${table.maxSeats} seats)',
                                child: Container(
                                    decoration: BoxDecoration(
                                        color: tableBackgroundColor,
                                        borderRadius: BorderRadius.circular(8.0),
                                        border: Border.all(
                                            color: tableBorderColor,
                                            width: _selectedTableId == table.id || isBookedByCurrentUser ? 2.0 : 1.0,
                                        ),
                                        boxShadow: [
                                            if (_selectedTableId == table.id || isBookedByCurrentUser)
                                                const BoxShadow(
                                                    color: Colors.black12,
                                                    blurRadius: 4,
                                                    offset: Offset(0, 2),
                                                ),
                                        ],
                                    ),
                                    child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                            Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                    Icon(
                                                        Icons.table_restaurant,
                                                        size: 32,
                                                        color: tableForegroundColor,
                                                    ),
                                                    if (isBookedByCurrentUser)
                                                        const Positioned(
                                                            top: 0,
                                                            right: 4,
                                                            child: Icon(
                                                                Icons.check_circle,
                                                                color: Colors.green, // Use a distinct color for your own booking checkmark
                                                                size: 16,
                                                            ),
                                                        ),
                                                ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                                'Table ${table.number}',
                                                style: TextStyle(
                                                    color: tableForegroundColor,
                                                    fontWeight: _selectedTableId == table.id || isBookedByCurrentUser
                                                         ? FontWeight.bold
                                                         : FontWeight.normal,
                                                ),
                                            ),
                                            if (!isAvailableToSelect && !isBookedByCurrentUser) ...[
                                                const SizedBox(height: 2),
                                                Text(
                                                    'Booked',
                                                    style: TextStyle(
                                                        color: primaryWhite,
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.bold,
                                                    ),
                                                ),
                                            ],
                                        ],
                                    ),
                                ),
                            ),
                        );
                    },
                ),
            ],
        );
    }

    @override
    Widget build(BuildContext context) {
        final theme = Theme.of(context);
        
        return Scaffold(
            backgroundColor: primaryWhite,
            appBar: AppBar(
                title: Text(
                    'Book Table at ${widget.restaurantName}',
                    style: const TextStyle(color: primaryBlack, fontWeight: FontWeight.bold),
                ),
                backgroundColor: primaryWhite,
                foregroundColor: primaryBlack,
                elevation: 1, // Keep a slight elevation for separation
            ),
            body: _isLoading
                ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(primaryBlack)))
                : SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                                // Calendar
                                Card(
                                    color: primaryWhite,
                                    elevation: 1,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        side: const BorderSide(color: lightGray),
                                    ),
                                    child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: TableCalendar(
                                            firstDay: DateTime.utc(DateTime.now().year, DateTime.now().month, DateTime.now().day), // Start from today
                                            lastDay: DateTime.now().add(const Duration(days: 30)), // Book up to 30 days out
                                            focusedDay: _selectedDate,
                                            selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
                                            onDaySelected: _onDaySelected,
                                            headerStyle: const HeaderStyle(
                                                formatButtonVisible: false,
                                                titleCentered: true,
                                                titleTextStyle: TextStyle(color: primaryBlack, fontWeight: FontWeight.bold),
                                                leftChevronIcon: Icon(Icons.chevron_left, color: primaryBlack),
                                                rightChevronIcon: Icon(Icons.chevron_right, color: primaryBlack),
                                            ),
                                            calendarStyle: CalendarStyle(
                                                selectedDecoration: const BoxDecoration(color: primaryBlack, shape: BoxShape.circle),
                                                todayDecoration: BoxDecoration(color: lightGray.withOpacity(0.5), shape: BoxShape.circle),
                                                defaultTextStyle: const TextStyle(color: primaryBlack),
                                                weekendTextStyle: const TextStyle(color: primaryBlack),
                                                outsideTextStyle: TextStyle(color: lightGray.withOpacity(0.7)),
                                                disabledTextStyle: TextStyle(color: lightGray.withOpacity(0.7)), // Disable past dates
                                            ),
                                            daysOfWeekStyle: const DaysOfWeekStyle(
                                                weekdayStyle: TextStyle(color: primaryBlack, fontWeight: FontWeight.bold),
                                                weekendStyle: TextStyle(color: primaryBlack, fontWeight: FontWeight.bold),
                                            ),
                                        ),
                                    ),
                                ),
                                
                                const SizedBox(height: 20),
                                
                                // Number of People
                                Text(
                                    'Number of People',
                                    style: theme.textTheme.titleMedium?.copyWith(color: primaryBlack),
                                ),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<int>(
                                    initialValue: _selectedPeople,
                                    style: const TextStyle(color: primaryBlack),
                                    items: _peopleOptions
                                        .map((count) => DropdownMenuItem(
                                                value: count,
                                                child: Text(
                                                    '$count ${count == 1 ? 'person' : 'people'}',
                                                    style: const TextStyle(color: primaryBlack),
                                                ),
                                            ))
                                        .toList(),
                                    onChanged: (value) {
                                        if (value != null) {
                                            setState(() {
                                                _selectedPeople = value;
                                                _selectedTimeSlot = null; // Reset time slot when people count changes
                                                _selectedTableId = null; // Reset table selection
                                            });
                                        }
                                    },
                                    decoration: InputDecoration(
                                        border: const OutlineInputBorder(borderSide: BorderSide(color: primaryBlack)),
                                        enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: lightGray)),
                                        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: primaryBlack, width: 2.0)),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        isDense: true,
                                    ),
                                ),
                                
                                const SizedBox(height: 20),
                                
                                // Available Time Slots
                                Text(
                                    'Available Time Slots',
                                    style: theme.textTheme.titleMedium?.copyWith(color: primaryBlack),
                                ),
                                const SizedBox(height: 8),
                                _buildTimeSlotsGrid(),
                                
                                if (_selectedTimeSlot != null) _buildTableSelection(),
                                
                                const SizedBox(height: 20),
                                
                                // Book Now Button
                                ElevatedButton(
                                    onPressed: _isBooking || _selectedTableId == null ? null : _onBookTable,
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: primaryBlack, // Black button background
                                        foregroundColor: primaryWhite, // White text
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                            side: const BorderSide(color: primaryBlack),
                                        ),
                                    ),
                                    child: _isBooking
                                        ? const SizedBox(
                                                height: 20,
                                                width: 20,
                                                child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor: AlwaysStoppedAnimation<Color>(primaryWhite),
                                                ),
                                            )
                                        : const Text(
                                                'Book Now', 
                                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                                            ),
                                ),
                            ],
                        ),
                    ),
        );
    }

    Widget _buildTimeSlotsGrid() {
        final availableSlots = _getAvailableTimeSlots();
        
        if (availableSlots.isEmpty) {
            return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text('No available time slots for the selected date and party size', style: TextStyle(color: primaryBlack)),
            );
        }

        return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: availableSlots.map((slot) {
                final isSelected = _selectedTimeSlot == slot;
                return FilterChip(
                    label: Text(slot),
                    selected: isSelected,
                    onSelected: (selected) {
                        setState(() {
                            // Reset table selection when time slot changes
                            _selectedTimeSlot = selected ? slot : null;
                            _selectedTableId = null;
                        });
                    },
                    backgroundColor: primaryWhite,
                    selectedColor: primaryBlack,
                    labelStyle: TextStyle(
                        color: isSelected ? primaryWhite : primaryBlack,
                    ),
                    shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(color: isSelected ? primaryBlack : lightGray)),
                );
            }).toList(),
        );
    }
}