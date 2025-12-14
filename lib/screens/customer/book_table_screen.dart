

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:table_calendar/table_calendar.dart';

// // --- SERVICE IMPORTS ---
// import 'package:my_first_flutter_app/models/restaurant.dart';

// import 'package:my_first_flutter_app/services/restaurant_service.dart';
// import 'package:my_first_flutter_app/services/auth_service.dart';
// // NOTE: We are intentionally NOT importing the client-side notification service (which should be on the backend).

// // --- SECURE PLACEHOLDER FOR BACKEND NOTIFICATION TRIGGER ---
// // We define a dummy class to match the function signature used in _onBookTable().
// // ⚠️ WARNING: In a production app, the logic inside sendBookingNotification MUST 
// // be replaced with a call to a secure backend/Cloud Function!
// class BookingNotifierService {
//     Future<void> initialize() async {
//         // Initialization logic for the 'sending' mechanism (e.g. secure token loading)
//         // For secure production, this should connect to a Cloud Function endpoint.
//         debugPrint('🔔 BookingNotifierService (DUMMY) initialized.');
//     }
    
//     Future<void> sendBookingNotification({
//         required String vendorToken,
//         required String customerName,
//         required String timeSlot,
//     }) async {
//         debugPrint('--- 🔔 NOTIFICATION SENT TO BACKEND (DUMMY CLIENT LOGIC) ---');
//         debugPrint('   Vendor Token (for target): $vendorToken');
//         debugPrint('   Customer Name: $customerName');
//         debugPrint('   Time Slot: $timeSlot');
//         debugPrint('   ACTION: This data is ready to be sent to your FCM Cloud Function.');
//         debugPrint('-----------------------------------------------------------');
//         // If you were using the legacy, insecure client-side send method, the code would go here.
//         // Since we are encouraging the secure Cloud Function approach, we just print the payload.
//         await Future.delayed(const Duration(milliseconds: 50)); // Simulate network delay
//     }
// }
// // -------------------------------------------------------------------

// // Define common colors for consistency
// const Color primaryBlack = Colors.black;
// const Color primaryWhite = Colors.white;
// const Color lightGray = Colors.grey;

// class BookTableScreen extends StatefulWidget {
//     final String restaurantId;
//     final String restaurantName;

//     const BookTableScreen({
//         super.key,
//         required this.restaurantId,
//         required this.restaurantName,
//     });

//     @override
//     State<BookTableScreen> createState() => _BookTableScreenState();
// }

// class _BookTableScreenState extends State<BookTableScreen> {
//     // Note: Assuming Restaurant model and TableModel are correctly defined in your models folder
//     late Restaurant _restaurant;
//     bool _isLoading = true;
//     DateTime _selectedDate = DateTime.now();
//     String? _selectedTimeSlot;
//     int _selectedPeople = 2;
//     String? _selectedTableId;
//     final List<int> _peopleOptions = [1, 2, 3, 4, 5, 6];
//     bool _isBooking = false;

//     // 🌟 Using the Secure Placeholder Implementation
//     late final BookingNotifierService _notifierService; 

//     @override
//     void initState() {
//         super.initState();
//         // Set initial selected date to today, without time components
//         _selectedDate = DateTime.utc(DateTime.now().year, DateTime.now().month, DateTime.now().day);
        
//         // 🌟 INITIALIZE NOTIFIER SERVICE (Placeholder)
//         _notifierService = BookingNotifierService();
//         _notifierService.initialize(); 
        
//         _loadRestaurant();
//     }

//     Future<void> _loadRestaurant() async {
//         setState(() => _isLoading = true);

//         try {
//             // Ensure services are initialized (though usually done in main)
//             await context.read<RestaurantService>().init();
            
//             final restaurantService = context.read<RestaurantService>();
//             final restaurant = restaurantService.getRestaurantById(widget.restaurantId);
            
//             if (restaurant == null) {
//                 throw Exception('Restaurant not found');
//             }
            
//             setState(() {
//                 _restaurant = restaurant;
//             });
//         } catch (e) {
//             if (mounted) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text('Failed to load restaurant details.')),
//                 );
//             }
//         } finally {
//             if (mounted) {
//                 setState(() => _isLoading = false);
//             }
//         }
//     }

//     void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
//         // Only allow booking for today or future dates
//         final today = DateTime.utc(DateTime.now().year, DateTime.now().month, DateTime.now().day);
//         if (selectedDay.isBefore(today)) return; 

//         setState(() {
//             _selectedDate = selectedDay;
//             _selectedTimeSlot = null;
//             _selectedTableId = null; // Reset table selection when date changes
//         });
//     }

//     Future<void> _onBookTable() async {
//         if (_selectedTimeSlot == null) {
//             ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('Please select a time slot')),
//             );
//             return;
//         }
        
//         if (_selectedTableId == null) {
//             ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('Please select a table')),
//             );
//             return;
//         }

//         final authService = context.read<AuthService>();
//         final user = authService.currentUser; // Get the user object (assumed to have properties like .id and .name)

//         if (user == null) {
//             if (mounted) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text('Please sign in to book a table')),
//                 );
//             }
//             return;
//         }

//         setState(() => _isBooking = true);

//         try {
//             final restaurantService = context.read<RestaurantService>();
            
//             // Find the selected table
//             final table = _restaurant.tables.firstWhere(
//                 (table) => table.id == _selectedTableId,
//                 orElse: () => throw Exception('Selected table not found')
//             );
            
//             // Re-verify the table is still available *before* the final booking call
//             if (!table.isAvailable(_selectedDate, _selectedTimeSlot!)) {
//                 throw Exception('The selected table is no longer available');
//             }
            
//             // 1. Make the Reservation (Save to database)
//             await restaurantService.makeReservation(
//                 restaurantId: _restaurant.id,
//                 tableId: table.id,
//                 customer: user, 
//                 date: _selectedDate,
//                 timeSlot: _selectedTimeSlot!,
//                 numberOfPeople: _selectedPeople,
//             );

//             // 🌟 2. Send Notification to the Vendor (Restaurant) 🌟
//             final String? vendorToken = _restaurant.fcmToken; // Get the Restaurant's FCM token

//             if (vendorToken != null && vendorToken.isNotEmpty) {
//                 // Call the service (which in this version, just prints the payload)
//                 await _notifierService.sendBookingNotification(
//                     vendorToken: vendorToken,
//                     customerName: user.name, // Assuming User model has a 'name' field
//                     timeSlot: _selectedTimeSlot!,
//                 );
//                 debugPrint('FCM Notification triggered successfully (via dummy client call).');
//             } else {
//                 debugPrint('Warning: Vendor FCM token not available. Notification skipped.');
//             }
//             // 🌟 -------------------------------------------------- 🌟

//             if (mounted) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text('Table booked successfully!')),
//                 );
//                 // Pop the screen and return true to indicate success
//                 Navigator.of(context).pop(true);
//             }
//         } catch (e) {
//             if (mounted) {
//                 // Display only the error message text
//                 String errorText = e is Exception ? e.toString().replaceFirst('Exception: ', '') : e.toString();
//                 ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text('Failed to book table: $errorText')),
//                 );
//             }
//         } finally {
//             if (mounted) {
//                 setState(() => _isBooking = false);
//             }
//         }
//     }

//     List<String> _getAvailableTimeSlots() {
//         if (_isLoading || !mounted) return [];
//         if (_restaurant.timeSlots.isEmpty) return [];
        
//         final authService = context.read<AuthService>();
//         final currentUserId = authService.currentUser?.id;

//         // Reset selected time slot if it's no longer available for the new date/people count
//         final isCurrentSlotStillAvailable = _selectedTimeSlot != null && _restaurant.tables.any((table) => 
//             table.maxSeats >= _selectedPeople && 
//             table.isAvailable(_selectedDate, _selectedTimeSlot!, currentUserId: currentUserId)
//         );

//         if (_selectedTimeSlot != null && !isCurrentSlotStillAvailable) {
//             // Use addPostFrameCallback to avoid calling setState during build
//             WidgetsBinding.instance.addPostFrameCallback((_) {
//                 if (mounted) {
//                     setState(() {
//                         _selectedTimeSlot = null;
//                         _selectedTableId = null;
//                     });
//                 }
//             });
//         }

//         // Return all slots where at least one table is available for the selected party size
//         return _restaurant.timeSlots.where((slot) {
//             return _restaurant.tables.any((table) => 
//                 table.maxSeats >= _selectedPeople && 
//                 table.isAvailable(
//                     _selectedDate, 
//                     slot,
//                     currentUserId: currentUserId, // Passed to ensure user doesn't book same slot twice
//                 )
//             );
//         }).toList();
//     }
    
//     // Note: TableModel is assumed to be defined/imported correctly
//     // The previous code had TableModel as an implicit type, I'll keep the name standard.
//     // If you don't have a TableModel class, this section will throw an error.
//     List<TableModel> _getAvailableTables() {
//         if (_selectedTimeSlot == null || _isLoading || !mounted) return [];
        
//         final authService = context.read<AuthService>();
//         final currentUserId = authService.currentUser?.id;
        
//         // Filter tables by capacity and availability at the selected time
//         return _restaurant.tables.where((table) => 
//             table.maxSeats >= _selectedPeople && 
//             table.isAvailable(
//                 _selectedDate, 
//                 _selectedTimeSlot!,
//                 currentUserId: currentUserId, 
//             )
//         ).cast<TableModel>().toList(); // Added cast to explicitly use TableModel
//     }
    
//     Widget _buildTableSelection() {
//         if (_selectedTimeSlot == null) return const SizedBox.shrink();
        
//         final availableTables = _getAvailableTables();
//         final allTables = _restaurant.tables;
//         final authService = context.read<AuthService>();
//         final currentUserId = authService.currentUser?.id;
        
//         if (allTables.isEmpty) {
//             return const Padding(
//                 padding: EdgeInsets.symmetric(vertical: 16.0),
//                 child: Text('No tables configured for this restaurant', style: TextStyle(color: primaryBlack)),
//             );
//         }
        
//         // Sort tables by number for consistent display
//         allTables.sort((a, b) => a.number.compareTo(b.number));
        
//         return Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//                 const SizedBox(height: 16),
//                 Row(
//                     children: [
//                         Text(
//                             'Available Tables • ',
//                             style: Theme.of(context).textTheme.titleMedium?.copyWith(color: primaryBlack),
//                         ),
//                         Text(
//                             '${availableTables.length} of ${allTables.length} available',
//                             style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                                 color: primaryBlack,
//                                 fontWeight: FontWeight.bold,
//                             ),
//                         ),
//                     ],
//                 ),
//                 const SizedBox(height: 8),
//                 GridView.builder(
//                     shrinkWrap: true,
//                     physics: const NeverScrollableScrollPhysics(),
//                     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                         crossAxisCount: 4,
//                         childAspectRatio: 1.0,
//                         crossAxisSpacing: 12.0,
//                         mainAxisSpacing: 12.0,
//                     ),
//                     itemCount: allTables.length,
//                     itemBuilder: (context, index) {
//                         final table = allTables[index];
                        
//                         // Check if the table is currently available for booking *for anyone* matching the party size
//                         final isAvailableForBooking = table.maxSeats >= _selectedPeople && table.isAvailable(
//                             _selectedDate, 
//                             _selectedTimeSlot!, 
//                             currentUserId: currentUserId
//                         );
                        
//                         // Check if the table is currently booked by the logged-in user
//                         final isBookedByCurrentUser = table.reservations.any((r) => 
//                                 r.userId == currentUserId && 
//                                 r.timeSlot == _selectedTimeSlot &&
//                                 isSameDay(r.date, _selectedDate)
//                             );
                        
//                         // If it's booked by the current user, it should appear as booked, not available for *new* selection.
//                         final isAvailableToSelect = isAvailableForBooking && !isBookedByCurrentUser;

//                         // Check if the table is simply booked by someone else
//                         final isBookedBySomeoneElse = !isAvailableToSelect && !isBookedByCurrentUser && 
//                             table.reservations.any((r) => 
//                                 r.timeSlot == _selectedTimeSlot && isSameDay(r.date, _selectedDate)
//                             );
                        
//                         Color tableBackgroundColor;
//                         Color tableForegroundColor;
//                         Color tableBorderColor;

//                         if (isBookedByCurrentUser) {
//                             // User's own current booking (show as selected/booked)
//                             tableBackgroundColor = primaryBlack;
//                             tableForegroundColor = Colors.greenAccent; // Use a light, distinct color
//                             tableBorderColor = primaryBlack;
//                         } else if (_selectedTableId == table.id) {
//                             // Currently selected for booking
//                             tableBackgroundColor = primaryBlack;
//                             tableForegroundColor = primaryWhite;
//                             tableBorderColor = primaryBlack;
//                         } else if (isAvailableToSelect) {
//                             // Available for selection
//                             tableBackgroundColor = primaryWhite;
//                             tableForegroundColor = primaryBlack;
//                             tableBorderColor = primaryBlack; 
//                         } else {
//                             // Unavailable/Booked by someone else, or too small for party
//                             tableBackgroundColor = lightGray;
//                             tableForegroundColor = primaryWhite;
//                             tableBorderColor = lightGray;
//                         }
                        
//                         return GestureDetector(
//                             onTap: isAvailableToSelect
//                                 ? () {
//                                             setState(() {
//                                                 _selectedTableId = table.id;
//                                             });
//                                         }
//                                 : null,
//                             child: Tooltip(
//                                 message: isBookedByCurrentUser 
//                                     ? 'Your Current Booking' 
//                                     : isBookedBySomeoneElse ? 'Booked by Others' : 'Table ${table.number} (${table.maxSeats} seats)',
//                                 child: Container(
//                                     decoration: BoxDecoration(
//                                         color: tableBackgroundColor,
//                                         borderRadius: BorderRadius.circular(8.0),
//                                         border: Border.all(
//                                             color: tableBorderColor,
//                                             width: _selectedTableId == table.id || isBookedByCurrentUser ? 2.0 : 1.0,
//                                         ),
//                                         boxShadow: [
//                                             if (_selectedTableId == table.id || isBookedByCurrentUser)
//                                                 const BoxShadow(
//                                                     color: Colors.black12,
//                                                     blurRadius: 4,
//                                                     offset: Offset(0, 2),
//                                                 ),
//                                         ],
//                                     ),
//                                     child: Column(
//                                         mainAxisAlignment: MainAxisAlignment.center,
//                                         children: [
//                                             Stack(
//                                                 alignment: Alignment.center,
//                                                 children: [
//                                                     Icon(
//                                                         Icons.table_restaurant,
//                                                         size: 32,
//                                                         color: tableForegroundColor,
//                                                     ),
//                                                     if (isBookedByCurrentUser)
//                                                         const Positioned(
//                                                             top: 0,
//                                                             right: 4,
//                                                             child: Icon(
//                                                                 Icons.check_circle,
//                                                                 color: Colors.green, // Use a distinct color for your own booking checkmark
//                                                                 size: 16,
//                                                             ),
//                                                         ),
//                                                 ],
//                                             ),
//                                             const SizedBox(height: 4),
//                                             Text(
//                                                 'Table ${table.number}',
//                                                 style: TextStyle(
//                                                     color: tableForegroundColor,
//                                                     fontWeight: _selectedTableId == table.id || isBookedByCurrentUser
//                                                         ? FontWeight.bold
//                                                         : FontWeight.normal,
//                                                 ),
//                                             ),
//                                             if (!isAvailableToSelect && !isBookedByCurrentUser) ...[
//                                                 const SizedBox(height: 2),
//                                                 Text(
//                                                     'Booked',
//                                                     style: TextStyle(
//                                                         color: primaryWhite,
//                                                         fontSize: 10,
//                                                         fontWeight: FontWeight.bold,
//                                                     ),
//                                                 ),
//                                             ],
//                                         ],
//                                     ),
//                                 ),
//                             ),
//                         );
//                     },
//                 ),
//             ],
//         );
//     }

//     @override
//     Widget build(BuildContext context) {
//         final theme = Theme.of(context);
        
//         return Scaffold(
//             backgroundColor: primaryWhite,
//             appBar: AppBar(
//                 title: Text(
//                     'Book Table at ${widget.restaurantName}',
//                     style: const TextStyle(color: primaryBlack, fontWeight: FontWeight.bold),
//                 ),
//                 backgroundColor: primaryWhite,
//                 foregroundColor: primaryBlack,
//                 elevation: 1, // Keep a slight elevation for separation
//             ),
//             body: _isLoading
//                 ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(primaryBlack)))
//                 : SingleChildScrollView(
//                         padding: const EdgeInsets.all(16.0),
//                         child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.stretch,
//                             children: [
//                                 // Calendar
//                                 Card(
//                                     color: primaryWhite,
//                                     elevation: 1,
//                                     shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(12),
//                                         side: const BorderSide(color: lightGray),
//                                     ),
//                                     child: Padding(
//                                         padding: const EdgeInsets.all(8.0),
//                                         child: TableCalendar(
//                                             firstDay: DateTime.utc(DateTime.now().year, DateTime.now().month, DateTime.now().day), // Start from today
//                                             lastDay: DateTime.now().add(const Duration(days: 30)), // Book up to 30 days out
//                                             focusedDay: _selectedDate,
//                                             selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
//                                             onDaySelected: _onDaySelected,
//                                             headerStyle: const HeaderStyle(
//                                                 formatButtonVisible: false,
//                                                 titleCentered: true,
//                                                 titleTextStyle: TextStyle(color: primaryBlack, fontWeight: FontWeight.bold),
//                                                 leftChevronIcon: Icon(Icons.chevron_left, color: primaryBlack),
//                                                 rightChevronIcon: Icon(Icons.chevron_right, color: primaryBlack),
//                                             ),
//                                             calendarStyle: CalendarStyle(
//                                                 selectedDecoration: const BoxDecoration(color: primaryBlack, shape: BoxShape.circle),
//                                                 todayDecoration: BoxDecoration(color: lightGray.withOpacity(0.5), shape: BoxShape.circle),
//                                                 defaultTextStyle: const TextStyle(color: primaryBlack),
//                                                 weekendTextStyle: const TextStyle(color: primaryBlack),
//                                                 outsideTextStyle: TextStyle(color: lightGray.withOpacity(0.7)),
//                                                 disabledTextStyle: TextStyle(color: lightGray.withOpacity(0.7)), // Disable past dates
//                                             ),
//                                             daysOfWeekStyle: const DaysOfWeekStyle(
//                                                 weekdayStyle: TextStyle(color: primaryBlack, fontWeight: FontWeight.bold),
//                                                 weekendStyle: TextStyle(color: primaryBlack, fontWeight: FontWeight.bold),
//                                             ),
//                                         ),
//                                     ),
//                                 ),
                                
//                                 const SizedBox(height: 20),
                                
//                                 // Number of People
//                                 Text(
//                                     'Number of People',
//                                     style: theme.textTheme.titleMedium?.copyWith(color: primaryBlack),
//                                 ),
//                                 const SizedBox(height: 8),
//                                 DropdownButtonFormField<int>(
//                                     initialValue: _selectedPeople,
//                                     style: const TextStyle(color: primaryBlack),
//                                     items: _peopleOptions
//                                         .map((count) => DropdownMenuItem(
//                                                 value: count,
//                                                 child: Text(
//                                                     '$count ${count == 1 ? 'person' : 'people'}',
//                                                     style: const TextStyle(color: primaryBlack),
//                                                 ),
//                                             ))
//                                         .toList(),
//                                     onChanged: (value) {
//                                         if (value != null) {
//                                             setState(() {
//                                                 _selectedPeople = value;
//                                                 _selectedTimeSlot = null; // Reset time slot when people count changes
//                                                 _selectedTableId = null; // Reset table selection
//                                             });
//                                         }
//                                     },
//                                     decoration: InputDecoration(
//                                         border: const OutlineInputBorder(borderSide: BorderSide(color: primaryBlack)),
//                                         enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: lightGray)),
//                                         focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: primaryBlack, width: 2.0)),
//                                         contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                                         isDense: true,
//                                     ),
//                                 ),
                                
//                                 const SizedBox(height: 20),
                                
//                                 // Available Time Slots
//                                 Text(
//                                     'Available Time Slots',
//                                     style: theme.textTheme.titleMedium?.copyWith(color: primaryBlack),
//                                 ),
//                                 const SizedBox(height: 8),
//                                 _buildTimeSlotsGrid(),
                                
//                                 if (_selectedTimeSlot != null) _buildTableSelection(),
                                
//                                 const SizedBox(height: 20),
                                
//                                 // Book Now Button
//                                 ElevatedButton(
//                                     onPressed: _isBooking || _selectedTableId == null ? null : _onBookTable,
//                                     style: ElevatedButton.styleFrom(
//                                         backgroundColor: primaryBlack, // Black button background
//                                         foregroundColor: primaryWhite, // White text
//                                         padding: const EdgeInsets.symmetric(vertical: 16),
//                                         shape: RoundedRectangleBorder(
//                                             borderRadius: BorderRadius.circular(8),
//                                             side: const BorderSide(color: primaryBlack),
//                                         ),
//                                     ),
//                                     child: _isBooking
//                                         ? const SizedBox(
//                                                 height: 20,
//                                                 width: 20,
//                                                 child: CircularProgressIndicator(
//                                                     strokeWidth: 2,
//                                                     valueColor: AlwaysStoppedAnimation<Color>(primaryWhite),
//                                                 ),
//                                             )
//                                         : const Text(
//                                                 'Book Now', 
//                                                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
//                                             ),
//                                 ),
//                             ],
//                         ),
//                     ),
//         );
//     }

//     Widget _buildTimeSlotsGrid() {
//         final availableSlots = _getAvailableTimeSlots();
        
//         if (availableSlots.isEmpty) {
//             return const Padding(
//                 padding: EdgeInsets.symmetric(vertical: 16.0),
//                 child: Text('No available time slots for the selected date and party size', style: TextStyle(color: primaryBlack)),
//             );
//         }

//         return Wrap(
//             spacing: 8,
//             runSpacing: 8,
//             children: availableSlots.map((slot) {
//                 final isSelected = _selectedTimeSlot == slot;
//                 return FilterChip(
//                     label: Text(slot),
//                     selected: isSelected,
//                     onSelected: (selected) {
//                         setState(() {
//                             // Reset table selection when time slot changes
//                             _selectedTimeSlot = selected ? slot : null;
//                             _selectedTableId = null;
//                         });
//                     },
//                     backgroundColor: primaryWhite,
//                     selectedColor: primaryBlack,
//                     labelStyle: TextStyle(
//                         color: isSelected ? primaryWhite : primaryBlack,
//                     ),
//                     shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(20),
//                             side: BorderSide(color: isSelected ? primaryBlack : lightGray)),
//                 );
//             }).toList(),
//         );
//     }
// }



import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

// 🌟 NEW: Import the Cloud Functions package 🌟
import 'package:cloud_functions/cloud_functions.dart'; 

// --- SERVICE IMPORTS ---
import 'package:my_first_flutter_app/models/restaurant.dart';

import 'package:my_first_flutter_app/services/restaurant_service.dart';
import 'package:my_first_flutter_app/services/auth_service.dart';
// NOTE: Ensure your User and TableModel are defined and accessible via their imports.

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
    // Note: Assuming Restaurant model and TableModel are correctly defined in your models folder
    late Restaurant _restaurant;
    bool _isLoading = true;
    DateTime _selectedDate = DateTime.now();
    String? _selectedTimeSlot;
    int _selectedPeople = 2;
    String? _selectedTableId;
    final List<int> _peopleOptions = [1, 2, 3, 4, 5, 6];
    bool _isBooking = false;

    // ⚠️ REMOVED: The dummy BookingNotifierService is removed, 
    // we use FirebaseFunctions.instance directly.

    @override
    void initState() {
        super.initState();
        // Set initial selected date to today, without time components
        _selectedDate = DateTime.utc(DateTime.now().year, DateTime.now().month, DateTime.now().day);
        
        // ❌ REMOVED: Dummy service initialization is gone.
        // _notifierService = BookingNotifierService();
        // _notifierService.initialize(); 
        
        _loadRestaurant();
    }

    Future<void> _loadRestaurant() async {
        setState(() => _isLoading = true);

        try {
            // Ensure services are initialized (though usually done in main)
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
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to load restaurant details.')),
                );
            }
        } finally {
            if (mounted) {
                setState(() => _isLoading = false);
            }
        }
    }

    void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
        // Only allow booking for today or future dates
        final today = DateTime.utc(DateTime.now().year, DateTime.now().month, DateTime.now().day);
        if (selectedDay.isBefore(today)) return; 

        setState(() {
            _selectedDate = selectedDay;
            _selectedTimeSlot = null;
            _selectedTableId = null; // Reset table selection when date changes
        });
    }

    // ⭐️ MODIFIED: The core booking logic to call the Cloud Function
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
        // Assuming your user object has the required properties like .id and .name
        final user = authService.currentUser; 

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
            
            // 1. Make the Reservation (Save to database)
            await restaurantService.makeReservation(
                restaurantId: _restaurant.id,
                tableId: table.id,
                customer: user, 
                date: _selectedDate,
                timeSlot: _selectedTimeSlot!,
                numberOfPeople: _selectedPeople,
            );

            // 🌟 2. Send Notification to the Vendor (Restaurant) via Cloud Function 🌟
            final String? vendorToken = _restaurant.fcmToken; // Get the Restaurant's FCM token

            if (vendorToken != null && vendorToken.isNotEmpty) {
                // Instantiate the callable function object
                final callable = FirebaseFunctions.instance.httpsCallable('sendBookingNotification');

                // Call the function with the required parameters
                final result = await callable.call({
                    'vendorToken': vendorToken,
                    'customerName': user.name, 
                    'timeSlot': _selectedTimeSlot!,
                });

                debugPrint('FCM Notification triggered successfully via Cloud Function: ${result.data}');
                // The result.data will contain { success: true, messageId: ... } if successful
            } else {
                debugPrint('Warning: Vendor FCM token not available. Notification skipped.');
            }
            // 🌟 ------------------------------------------------------------------- 🌟

            if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Table booked successfully!')),
                );
                // Pop the screen and return true to indicate success
                Navigator.of(context).pop(true);
            }
        } on FirebaseFunctionsException catch (e) {
            // Catch errors specifically from the Cloud Function
            String errorText = 'Booking failed: ${e.message}';
            debugPrint('Cloud Function Error: ${e.code} - ${e.details}');
            if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(errorText)),
                );
            }
        } catch (e) {
            if (mounted) {
                // Display general errors (e.g., network, database save failure)
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
            // Use addPostFrameCallback to avoid calling setState during build
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
    
    // Note: TableModel is assumed to be defined/imported correctly
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
        ).cast<TableModel>().toList(); // Added cast to explicitly use TableModel
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
                            tableForegroundColor = Colors.greenAccent; // Use a light, distinct color
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

        // ⭐️ Finalizing the _buildTimeSlotsGrid implementation ⭐️
        return Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: availableSlots.map((slot) {
                final isSelected = _selectedTimeSlot == slot;
                
                return GestureDetector(
                    onTap: () {
                        setState(() {
                            _selectedTimeSlot = slot;
                            // Reset table ID when changing time slot
                            _selectedTableId = null; 
                        });
                    },
                    child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                            color: isSelected ? primaryBlack : primaryWhite,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: primaryBlack, width: isSelected ? 2.0 : 1.0),
                        ),
                        child: Text(
                            slot,
                            style: TextStyle(
                                color: isSelected ? primaryWhite : primaryBlack,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                        ),
                    ),
                );
            }).toList(),
        );
    }
}