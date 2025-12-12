// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:my_first_flutter_app/models/restaurant.dart';
// import 'package:my_first_flutter_app/services/restaurant_service.dart';
// import 'package:intl/intl.dart';





// // Color constants for B&W theme consistency
// const Color primaryBlack = Colors.black;
// const Color primaryWhite = Colors.white;
// const Color lightGray = Color(0xFFE0E0E0); // Lighter gray for backgrounds/dividers
// const Color mediumGray = Colors.grey; // Medium gray for secondary text/icons
// const Color accentBlack = Color(0xFF1E1E1E); // Slightly off-black for card background
// const Color actionBlue = Color(0xFF007AFF); // A touch of color for action/notification

// class BookedTablesScreen extends StatefulWidget {
//   final String restaurantId;

//   const BookedTablesScreen({
//     super.key,
//     required this.restaurantId,
//   });

//   @override
//   State<BookedTablesScreen> createState() => _BookedTablesScreenState();
// }

// class _BookedTablesScreenState extends State<BookedTablesScreen> {
//   DateTime _selectedDate = DateTime.now();
//   String? _selectedTimeSlot;
//   List<Reservation> _reservations = [];
//   bool _isLoading = false;
//   Restaurant? _restaurant;
//   final double borderRadius = 8.0;

//   @override
//   void initState() {
//     super.initState();
//     _loadRestaurantAndReservations();
//   }

//   Future<void> _loadRestaurantAndReservations() async {
//     if (!mounted) return;
    
//     setState(() => _isLoading = true);
    
//     try {
//       final restaurantService = context.read<RestaurantService>();
//       // NOTE: Assuming getRestaurantById and models (Restaurant, TableModel, Reservation) are available in the project structure
//       // The implementation for getRestaurantById is not shown, but we assume it works.
//       _restaurant = restaurantService.getRestaurantById(widget.restaurantId);
      
//       if (_restaurant != null) {
//         // Get all reservations for this restaurant
//         _reservations = [];
//         for (var table in _restaurant!.tables) {
//           // This assumes `table` has a `reservations` property and is of type TableModel
//           // Since TableModel definition is missing, this is kept as-is, assuming it works.
//           _reservations.addAll(table.reservations); 
//         }
//         // Sort by date and time
//         _reservations.sort((a, b) => 
//             a.date.compareTo(b.date) != 0 
//                 ? a.date.compareTo(b.date) 
//                 : a.timeSlot.compareTo(b.timeSlot));
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to load reservations: $e')),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }

//   List<Reservation> get _filteredReservations {
//     // Filter logic remains unchanged
//     if (_selectedTimeSlot == null) {
//       return _reservations.where((r) => 
//           r.date.year == _selectedDate.year &&
//           r.date.month == _selectedDate.month &&
//           r.date.day == _selectedDate.day).toList();
//     }
//     return _reservations.where((r) => 
//         r.date.year == _selectedDate.year &&
//         r.date.month == _selectedDate.month &&
//         r.date.day == _selectedDate.day &&
//         r.timeSlot == _selectedTimeSlot).toList();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: primaryWhite, // ⭐️ UI CHANGE: White background
//       appBar: AppBar(
//         // ⭐️ UI CHANGE: B&W AppBar
//         title: const Text('Booked Tables', style: TextStyle(color: primaryBlack, fontWeight: FontWeight.bold)),
//         backgroundColor: primaryWhite,
//         foregroundColor: primaryBlack,
//         elevation: 1, // Slight elevation to separate from content
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh, color: primaryBlack),
//             onPressed: _loadRestaurantAndReservations,
//             tooltip: 'Refresh',
//           ),
//         ],
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator(color: primaryBlack)) // ⭐️ UI CHANGE: Black indicator
//           : _buildContent(),
//     );
//   }

//   Widget _buildContent() {
//     if (_restaurant == null) {
//       return const Center(child: Text('Restaurant not found', style: TextStyle(color: primaryBlack)));
//     }

//     return Column(
//       children: [
//         // Date Picker
//         _buildDateSelector(),
        
//         // Time Slot Filter
//         _buildTimeSlotFilter(),

//         const Divider(height: 1, color: lightGray), // ⭐️ UI CHANGE: Divider
        
//         // Reservations List
//         Expanded(
//           child: _filteredReservations.isEmpty
//               ? _buildEmptyState()
//               : _buildReservationsList(),
//         ),
//       ],
//     );
//   }

//   Widget _buildDateSelector() {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//       color: lightGray, // ⭐️ UI CHANGE: Light gray background for selector
//       child: Row(
//         children: [
//           const Icon(Icons.calendar_today, size: 20, color: primaryBlack), // ⭐️ UI CHANGE: Black icon
//           const SizedBox(width: 8),
//           Text(
//             DateFormat('EEEE, MMM d, y').format(_selectedDate),
//             style: Theme.of(context).textTheme.titleMedium?.copyWith(color: primaryBlack, fontWeight: FontWeight.bold),
//           ),
//           const Spacer(),
//           TextButton(
//             onPressed: () async {
//               final pickedDate = await showDatePicker(
//                 context: context,
//                 initialDate: _selectedDate,
//                 firstDate: DateTime.now().subtract(const Duration(days: 365)), // Allow looking back for bookings
//                 lastDate: DateTime.now().add(const Duration(days: 365)), // Allow looking far ahead
//                 // ⭐️ UI CHANGE: DatePicker Theme
//                 builder: (context, child) {
//                   return Theme(
//                     data: ThemeData.light().copyWith(
//                       colorScheme: const ColorScheme.light(
//                         primary: primaryBlack, // Header background/selected date color
//                         onPrimary: primaryWhite, // Header text/selected date text color
//                         onSurface: primaryBlack, // Picker text color
//                       ),
//                       textButtonTheme: TextButtonThemeData(
//                         style: TextButton.styleFrom(foregroundColor: primaryBlack), // Dialog button color
//                       ),
//                     ),
//                     child: child!,
//                   );
//                 },
//               );
//               if (pickedDate != null && pickedDate != _selectedDate) {
//                 setState(() {
//                   _selectedDate = pickedDate;
//                   _selectedTimeSlot = null;
//                 });
//               }
//             },
//             child: const Text('Change Date', style: TextStyle(color: primaryBlack, fontWeight: FontWeight.bold)),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTimeSlotFilter() {
//     if (_restaurant == null || _restaurant!.timeSlots.isEmpty) {
//       return Container();
//     }

//     return SizedBox(
//       height: 50,
//       child: ListView(
//         scrollDirection: Axis.horizontal,
//         padding: const EdgeInsets.symmetric(horizontal: 8),
//         children: [
//           // All time slots option
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 4),
//             child: ChoiceChip(
//               // ⭐️ UI CHANGE: B&W ChoiceChip for 'All'
//               label: const Text('All', style: TextStyle(color: primaryBlack)),
//               selected: _selectedTimeSlot == null,
//               selectedColor: primaryBlack, // Selected color is black
//               backgroundColor: lightGray, // Unselected color is light gray
//               labelStyle: TextStyle(
//                 color: _selectedTimeSlot == null ? primaryWhite : primaryBlack, // Text is white when selected
//                 fontWeight: FontWeight.bold,
//               ),
//               onSelected: (selected) {
//                 setState(() => _selectedTimeSlot = null);
//               },
//             ),
//           ),
//           // Time slot options
//           ..._restaurant!.timeSlots.map((slot) {
//             final isSelected = _selectedTimeSlot == slot;
//             return Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 4),
//               child: ChoiceChip(
//                 // ⭐️ UI CHANGE: B&W ChoiceChip for Slots
//                 label: Text(slot),
//                 selected: isSelected,
//                 selectedColor: primaryBlack, // Selected color is black
//                 backgroundColor: lightGray, // Unselected color is light gray
//                 labelStyle: TextStyle(
//                   color: isSelected ? primaryWhite : primaryBlack, // Text is white when selected
//                   fontWeight: FontWeight.bold,
//                 ),
//                 onSelected: (selected) {
//                   setState(() => _selectedTimeSlot = selected ? slot : null);
//                 },
//               ),
//             );
//           }),
//         ],
//       ),
//     );
//   }

//   Widget _buildReservationsList() {
//     return ListView.builder(
//       padding: const EdgeInsets.all(8),
//       itemCount: _filteredReservations.length,
//       itemBuilder: (context, index) {
//         final reservation = _filteredReservations[index];
//         // NOTE: This logic assumes TableModel exists and handles the fallback.
//         final table = _restaurant!.tables.firstWhere(
//           (t) => t.id == reservation.tableId,
//           // Assuming TableModel constructor needs id, number, and maxSeats
//           orElse: () => TableModel(id: 'unknown', number: 0, maxSeats: 0, reservations: []),
//         );
        
//         return Card(
//           // ⭐️ UI CHANGE: B&W Card
//           color: accentBlack, // Darker card background
//           elevation: 4,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
//           margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
//           child: ListTile(
//             leading: const Icon(Icons.table_restaurant, size: 32, color: primaryWhite), // ⭐️ UI CHANGE: White icon
//             title: Text(
//               'Table ${table.number}', 
//               style: const TextStyle(color: primaryWhite, fontWeight: FontWeight.bold), // ⭐️ UI CHANGE: White text
//             ),
//             subtitle: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text('Time: ${reservation.timeSlot}', style: const TextStyle(color: lightGray)),
//                 Text('Guests: ${reservation.numberOfPeople}', style: const TextStyle(color: lightGray)),
//                 Text(
//                   'Booked on: ${DateFormat('MMM d, y - h:mm a').format(reservation.createdAt)}',
//                   style: Theme.of(context).textTheme.bodySmall?.copyWith(color: mediumGray, fontStyle: FontStyle.italic),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.table_restaurant_outlined,
//             size: 64,
//             color: primaryBlack.withOpacity(0.3), // ⭐️ UI CHANGE: Faded black icon
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'No Bookings Found',
//             style: Theme.of(context).textTheme.titleMedium?.copyWith(color: primaryBlack, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 8),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 40.0),
//             child: Text(
//               'No tables are booked for the selected date${_selectedTimeSlot != null ? ' and time' : ''}.',
//               textAlign: TextAlign.center,
//               style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: mediumGray),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_first_flutter_app/models/restaurant.dart';
// 🌟 FIX 1: Import the User model with a prefix to resolve the name clash.
import 'package:my_first_flutter_app/models/user.dart' as user_model; 
import 'package:my_first_flutter_app/services/restaurant_service.dart';
import 'package:intl/intl.dart';

// Color constants for B&W theme consistency
const Color primaryBlack = Colors.black;
const Color primaryWhite = Colors.white;
const Color lightGray = Color(0xFFE0E0E0); // Lighter gray for backgrounds/dividers
const Color mediumGray = Colors.grey; // Medium gray for secondary text/icons
const Color accentBlack = Color(0xFF1E1E1E); // Slightly off-black for card background
const Color actionBlue = Color(0xFF007AFF); // A touch of color for action/notification

class BookedTablesScreen extends StatefulWidget {
    final String restaurantId;

    const BookedTablesScreen({
        super.key,
        required this.restaurantId,
    });

    @override
    State<BookedTablesScreen> createState() => _BookedTablesScreenState();
}

class _BookedTablesScreenState extends State<BookedTablesScreen> {
    DateTime _selectedDate = DateTime.now();
    String? _selectedTimeSlot;
    List<Reservation> _reservations = [];
    bool _isLoading = false;
    Restaurant? _restaurant;
    final double borderRadius = 8.0;

    @override
    void initState() {
        super.initState();
        WidgetsBinding.instance.addPostFrameCallback((_) {
            _loadRestaurantAndReservations();
        });
    }

    Future<void> _loadRestaurantAndReservations() async {
        if (!mounted) return;
        
        setState(() => _isLoading = true);
        
        try {
            final restaurantService = context.read<RestaurantService>();
            
            _restaurant = restaurantService.getRestaurantById(widget.restaurantId);
            
            if (_restaurant != null) {
                _reservations = [];
                for (var table in _restaurant!.tables) {
                    final activeReservations = table.reservations.where((r) => r.isCancelled == false).toList();
                    _reservations.addAll(activeReservations); 
                }
                
                _reservations.sort((a, b) {
                    final dateComparison = a.date.compareTo(b.date);
                    if (dateComparison != 0) return dateComparison;
                    return a.timeSlot.compareTo(b.timeSlot);
                });
            }
        } catch (e) {
            if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to load reservations: $e')),
                );
            }
        } finally {
            if (mounted) {
                setState(() => _isLoading = false);
            }
        }
    }

    // 🌟 FIX 2: Use the prefixed name 'user_model.User' to explicitly call the correct constructor.
    Map<String, String> _getCustomerDetails(String userId) {
        final restaurantService = context.read<RestaurantService>();
        
        // Use user_model.User for the orElse fallback constructor
        final user = restaurantService.users.firstWhere(
            (u) => u.id == userId,
            orElse: () => user_model.User(id: userId, name: 'Unknown User', email: 'N/A'),
        );
        
        return {
            'name': user.name,
            'email': user.email,
            'phone': user.phoneNumber ?? 'N/A',
        };
    }
    
    // Filtered reservations getter
    List<Reservation> get _filteredReservations {
        return _reservations.where((r) => 
            r.date.year == _selectedDate.year &&
            r.date.month == _selectedDate.month &&
            r.date.day == _selectedDate.day &&
            (_selectedTimeSlot == null || r.timeSlot == _selectedTimeSlot)
        ).toList();
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            backgroundColor: primaryWhite,
            appBar: AppBar(
                title: const Text('Booked Tables', style: TextStyle(color: primaryBlack, fontWeight: FontWeight.bold)),
                backgroundColor: primaryWhite,
                foregroundColor: primaryBlack,
                elevation: 1,
                actions: [
                    IconButton(
                        icon: const Icon(Icons.refresh, color: primaryBlack),
                        onPressed: _loadRestaurantAndReservations,
                        tooltip: 'Refresh',
                    ),
                ],
            ),
            body: _isLoading
                ? const Center(child: CircularProgressIndicator(color: primaryBlack))
                : _buildContent(),
        );
    }

    Widget _buildContent() {
        if (_restaurant == null) {
            return const Center(child: Text('Restaurant not found', style: TextStyle(color: primaryBlack)));
        }

        return Column(
            children: [
                // Date Picker
                _buildDateSelector(),
                
                // Time Slot Filter
                _buildTimeSlotFilter(),

                const Divider(height: 1, color: lightGray),
                
                // Reservations List
                Expanded(
                    child: _filteredReservations.isEmpty
                        ? _buildEmptyState()
                        : _buildReservationsList(),
                ),
            ],
        );
    }

    Widget _buildDateSelector() {
        return Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: lightGray,
            child: Row(
                children: [
                    const Icon(Icons.calendar_today, size: 20, color: primaryBlack),
                    const SizedBox(width: 8),
                    Text(
                        DateFormat('EEEE, MMM d, y').format(_selectedDate),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: primaryBlack, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    TextButton(
                        onPressed: () async {
                            final pickedDate = await showDatePicker(
                                context: context,
                                initialDate: _selectedDate,
                                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                                builder: (context, child) {
                                    return Theme(
                                        data: ThemeData.light().copyWith(
                                            colorScheme: const ColorScheme.light(
                                                primary: primaryBlack,
                                                onPrimary: primaryWhite,
                                                onSurface: primaryBlack,
                                            ),
                                            textButtonTheme: TextButtonThemeData(
                                                style: TextButton.styleFrom(foregroundColor: primaryBlack),
                                            ),
                                        ),
                                        child: child!,
                                    );
                                },
                            );
                            if (pickedDate != null && pickedDate != _selectedDate) {
                                setState(() {
                                    _selectedDate = pickedDate;
                                    _selectedTimeSlot = null;
                                });
                            }
                        },
                        child: const Text('Change Date', style: TextStyle(color: primaryBlack, fontWeight: FontWeight.bold)),
                    ),
                ],
            ),
        );
    }

    Widget _buildTimeSlotFilter() {
        if (_restaurant == null || _restaurant!.timeSlots.isEmpty) {
            return Container();
        }

        return SizedBox(
            height: 50,
            child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                children: [
                    // All time slots option
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                            label: const Text('All'),
                            selected: _selectedTimeSlot == null,
                            selectedColor: primaryBlack,
                            backgroundColor: lightGray,
                            labelStyle: TextStyle(
                                color: _selectedTimeSlot == null ? primaryWhite : primaryBlack,
                                fontWeight: FontWeight.bold,
                            ),
                            onSelected: (selected) {
                                setState(() => _selectedTimeSlot = null);
                            },
                        ),
                    ),
                    // Time slot options
                    ..._restaurant!.timeSlots.map((slot) {
                        final isSelected = _selectedTimeSlot == slot;
                        return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: ChoiceChip(
                                label: Text(slot),
                                selected: isSelected,
                                selectedColor: primaryBlack,
                                backgroundColor: lightGray,
                                labelStyle: TextStyle(
                                    color: isSelected ? primaryWhite : primaryBlack,
                                    fontWeight: FontWeight.bold,
                                ),
                                onSelected: (selected) {
                                    setState(() => _selectedTimeSlot = selected ? slot : null);
                                },
                            ),
                        );
                    }),
                ],
            ),
        );
    }

    Widget _buildReservationsList() {
        return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: _filteredReservations.length,
            itemBuilder: (context, index) {
                final reservation = _filteredReservations[index];
                
                // Look up table details
                final table = _restaurant!.tables.firstWhere(
                    (t) => t.id == reservation.tableId,
                    orElse: () => TableModel(id: 'unknown', number: 0, maxSeats: 0, reservations: []),
                );

                // Look up customer details
                final customerDetails = _getCustomerDetails(reservation.userId);
                
                return Card(
                    color: accentBlack,
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
                    margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                    child: ListTile(
                        leading: const Icon(Icons.table_restaurant, size: 32, color: primaryWhite),
                        title: Text(
                            'Table ${table.number} (${reservation.numberOfPeople} Guests)', 
                            style: const TextStyle(color: primaryWhite, fontWeight: FontWeight.bold),
                        ),
                        // Display Customer Name
                        subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                Text('Time: ${reservation.timeSlot}', style: const TextStyle(color: lightGray)),
                                Text('Customer: ${customerDetails['name']}', style: const TextStyle(color: primaryWhite, fontWeight: FontWeight.bold)),
                                Text(
                                    'Booked on: ${DateFormat('MMM d, y - h:mm a').format(reservation.createdAt)}',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: mediumGray, fontStyle: FontStyle.italic),
                                ),
                            ],
                        ),
                        trailing: const Icon(Icons.chevron_right, color: mediumGray),
                        onTap: () => _showCustomerDetailsDialog(customerDetails, reservation), // Show details on tap
                    ),
                );
            },
        );
    }

    // Dialog to show full customer details (Name, Phone, Email)
    void _showCustomerDetailsDialog(Map<String, String> customerDetails, Reservation reservation) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
                return AlertDialog(
                    backgroundColor: primaryWhite,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
                    title: Text('Reservation Details', style: TextStyle(color: primaryBlack, fontWeight: FontWeight.bold)),
                    content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            _buildDetailRow(context, 'Date', DateFormat('EEE, MMM d, y').format(reservation.date), Icons.date_range),
                            _buildDetailRow(context, 'Time', reservation.timeSlot, Icons.schedule),
                            _buildDetailRow(context, 'Guests', reservation.numberOfPeople.toString(), Icons.group),
                            const Divider(color: lightGray),
                            _buildDetailRow(context, 'Customer', customerDetails['name']!, Icons.person),
                            _buildDetailRow(context, 'Phone', customerDetails['phone']!, Icons.phone),
                            _buildDetailRow(context, 'Email', customerDetails['email']!, Icons.email),
                        ],
                    ),
                    actions: <Widget>[
                        TextButton(
                            onPressed: () {
                                Navigator.of(context).pop();
                            },
                            child: const Text('CLOSE', style: TextStyle(color: primaryBlack, fontWeight: FontWeight.bold)),
                        ),
                    ],
                );
            },
        );
    }

    Widget _buildDetailRow(BuildContext context, String label, String value, IconData icon) {
        return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Icon(icon, size: 18, color: mediumGray),
                    const SizedBox(width: 8),
                    Expanded(
                        flex: 1,
                        child: Text(
                            '$label:',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: mediumGray),
                        ),
                    ),
                    Expanded(
                        flex: 2,
                        child: Text(
                            value,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: primaryBlack, fontWeight: FontWeight.w600),
                        ),
                    ),
                ],
            ),
        );
    }


    Widget _buildEmptyState() {
        return Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                    Icon(
                        Icons.table_restaurant_outlined,
                        size: 64,
                        color: primaryBlack.withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                        'No Bookings Found',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: primaryBlack, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40.0),
                        child: Text(
                            'No tables are booked for the selected date${_selectedTimeSlot != null ? ' and time' : ''}.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: mediumGray),
                        ),
                    ),
                ],
            ),
        );
    }
}