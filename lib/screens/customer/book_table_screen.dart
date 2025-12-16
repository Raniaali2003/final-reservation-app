import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

// 🌟 Import Cloud Functions 🌟
import 'package:cloud_functions/cloud_functions.dart';

// --- SERVICE IMPORTS ---
// تأكد أن مسارات الـ Imports هذه صحيحة عندك
import 'package:my_first_flutter_app/models/restaurant.dart';
import 'package:my_first_flutter_app/services/restaurant_service.dart';
import 'package:my_first_flutter_app/services/auth_service.dart';

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
    _selectedDate = DateTime.utc(
        DateTime.now().year, DateTime.now().month, DateTime.now().day);
    _loadRestaurant();
  }

  Future<void> _loadRestaurant() async {
    setState(() => _isLoading = true);

    try {
      await context.read<RestaurantService>().init();

      final restaurantService = context.read<RestaurantService>();
      final restaurant =
          restaurantService.getRestaurantById(widget.restaurantId);

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
    final today = DateTime.utc(
        DateTime.now().year, DateTime.now().month, DateTime.now().day);
    if (selectedDay.isBefore(today)) return;

    setState(() {
      _selectedDate = selectedDay;
      _selectedTimeSlot = null;
      _selectedTableId = null; // Reset table selection when date changes
    });
  }

  // ⭐️ The core booking logic to call the Cloud Function
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
          orElse: () => throw Exception('Selected table not found'));

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
      final String? vendorToken = _restaurant.fcmToken;

      if (vendorToken != null && vendorToken.isNotEmpty) {
        final callable = FirebaseFunctions.instance
            .httpsCallable('sendBookingNotification');

        final result = await callable.call({
          'vendorToken': vendorToken,
          'customerName': user.name,
          'timeSlot': _selectedTimeSlot!,
        });

        debugPrint(
            'FCM Notification triggered successfully: ${result.data}');
      } else {
        debugPrint(
            'Warning: Vendor FCM token not available. Notification skipped.');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Table booked successfully!')),
        );
        Navigator.of(context).pop(true);
      }
    } on FirebaseFunctionsException catch (e) {
      String errorText = 'Booking failed: ${e.message}';
      debugPrint('Cloud Function Error: ${e.code} - ${e.details}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorText)),
        );
      }
    } catch (e) {
      if (mounted) {
        String errorText = e is Exception
            ? e.toString().replaceFirst('Exception: ', '')
            : e.toString();
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

    final isCurrentSlotStillAvailable = _selectedTimeSlot != null &&
        _restaurant.tables.any((table) =>
            table.maxSeats >= _selectedPeople &&
            table.isAvailable(_selectedDate, _selectedTimeSlot!,
                currentUserId: currentUserId));

    if (_selectedTimeSlot != null && !isCurrentSlotStillAvailable) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _selectedTimeSlot = null;
            _selectedTableId = null;
          });
        }
      });
    }

    return _restaurant.timeSlots.where((slot) {
      return _restaurant.tables.any((table) =>
          table.maxSeats >= _selectedPeople &&
          table.isAvailable(
            _selectedDate,
            slot,
            currentUserId: currentUserId,
          ));
    }).toList();
  }

  List<TableModel> _getAvailableTables() {
    if (_selectedTimeSlot == null || _isLoading || !mounted) return [];

    final authService = context.read<AuthService>();
    final currentUserId = authService.currentUser?.id;

    return _restaurant.tables
        .where((table) =>
            table.maxSeats >= _selectedPeople &&
            table.isAvailable(
              _selectedDate,
              _selectedTimeSlot!,
              currentUserId: currentUserId,
            ))
        .cast<TableModel>()
        .toList();
  }

  // ✅✅✅ THIS IS THE FIXED WIDGET ✅✅✅
  Widget _buildTableSelection() {
    if (_selectedTimeSlot == null) return const SizedBox.shrink();

    final availableTables = _getAvailableTables();
    final allTables = _restaurant.tables;
    final authService = context.read<AuthService>();
    final currentUserId = authService.currentUser?.id;

    if (allTables.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: Text('No tables configured for this restaurant',
            style: TextStyle(color: primaryBlack)),
      );
    }

    // Sort tables by number
    allTables.sort((a, b) => a.number.compareTo(b.number));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Row(
          children: [
            Text(
              'Available Tables • ',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: primaryBlack),
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

            final isAvailableForBooking = table.maxSeats >= _selectedPeople &&
                table.isAvailable(
                  _selectedDate,
                  _selectedTimeSlot!,
                  currentUserId: currentUserId,
                );

            final isBookedByCurrentUser = table.reservations.any((r) =>
                r.userId == currentUserId &&
                r.timeSlot == _selectedTimeSlot &&
                isSameDay(r.date, _selectedDate));

            final isAvailableToSelect =
                isAvailableForBooking && !isBookedByCurrentUser;

            final isBookedBySomeoneElse = !isAvailableToSelect &&
                !isBookedByCurrentUser &&
                table.reservations.any((r) =>
                    r.timeSlot == _selectedTimeSlot &&
                    isSameDay(r.date, _selectedDate));

            Color tableBackgroundColor;
            Color tableForegroundColor;
            Color tableBorderColor;

            if (isBookedByCurrentUser) {
              tableBackgroundColor = primaryBlack;
              tableForegroundColor = Colors.greenAccent;
              tableBorderColor = primaryBlack;
            } else if (_selectedTableId == table.id) {
              tableBackgroundColor = primaryBlack;
              tableForegroundColor = primaryWhite;
              tableBorderColor = primaryBlack;
            } else if (isAvailableToSelect) {
              tableBackgroundColor = primaryWhite;
              tableForegroundColor = primaryBlack;
              tableBorderColor = primaryBlack;
            } else {
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
                    : isBookedBySomeoneElse
                        ? 'Booked by Others'
                        : 'Table ${table.number} (${table.maxSeats} seats)',
                child: Container(
                  decoration: BoxDecoration(
                    color: tableBackgroundColor,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                      color: tableBorderColor,
                      width: _selectedTableId == table.id ||
                              isBookedByCurrentUser
                          ? 2.0
                          : 1.0,
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
                  // 🔥 FIXED: Wrapped with FittedBox to prevent overflow 🔥
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
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
                                    color: Colors.green,
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
                              fontWeight: _selectedTableId == table.id ||
                                      isBookedByCurrentUser
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          if (!isAvailableToSelect &&
                              !isBookedByCurrentUser) ...[
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
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTimeSlotsGrid() {
    final availableSlots = _getAvailableTimeSlots();

    if (availableSlots.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: Text(
            'No available time slots for the selected date and party size',
            style: TextStyle(color: primaryBlack)),
      );
    }

    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: availableSlots.map((slot) {
        final isSelected = _selectedTimeSlot == slot;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedTimeSlot = slot;
              _selectedTableId = null;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? primaryBlack : primaryWhite,
              borderRadius: BorderRadius.circular(20),
              border:
                  Border.all(color: primaryBlack, width: isSelected ? 2.0 : 1.0),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: primaryWhite,
      appBar: AppBar(
        title: Text(
          'Book Table at ${widget.restaurantName}',
          style: const TextStyle(
              color: primaryBlack, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryWhite,
        foregroundColor: primaryBlack,
        elevation: 1,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(primaryBlack)))
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
                        firstDay: DateTime.utc(DateTime.now().year,
                            DateTime.now().month, DateTime.now().day),
                        lastDay: DateTime.now().add(const Duration(days: 30)),
                        focusedDay: _selectedDate,
                        selectedDayPredicate: (day) =>
                            isSameDay(_selectedDate, day),
                        onDaySelected: _onDaySelected,
                        headerStyle: const HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                          titleTextStyle: TextStyle(
                              color: primaryBlack, fontWeight: FontWeight.bold),
                          leftChevronIcon:
                              Icon(Icons.chevron_left, color: primaryBlack),
                          rightChevronIcon:
                              Icon(Icons.chevron_right, color: primaryBlack),
                        ),
                        calendarStyle: CalendarStyle(
                          selectedDecoration: const BoxDecoration(
                              color: primaryBlack, shape: BoxShape.circle),
                          todayDecoration: BoxDecoration(
                              color: lightGray.withOpacity(0.5),
                              shape: BoxShape.circle),
                          defaultTextStyle:
                              const TextStyle(color: primaryBlack),
                          weekendTextStyle:
                              const TextStyle(color: primaryBlack),
                          outsideTextStyle:
                              TextStyle(color: lightGray.withOpacity(0.7)),
                          disabledTextStyle:
                              TextStyle(color: lightGray.withOpacity(0.7)),
                        ),
                        daysOfWeekStyle: const DaysOfWeekStyle(
                          weekdayStyle: TextStyle(
                              color: primaryBlack, fontWeight: FontWeight.bold),
                          weekendStyle: TextStyle(
                              color: primaryBlack, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Number of People
                  Text(
                    'Number of People',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(color: primaryBlack),
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
                          _selectedTimeSlot =
                              null; // Reset time slot when people count changes
                          _selectedTableId = null; // Reset table selection
                        });
                      }
                    },
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(
                          borderSide: BorderSide(color: primaryBlack)),
                      enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: lightGray)),
                      focusedBorder: const OutlineInputBorder(
                          borderSide:
                              BorderSide(color: primaryBlack, width: 2.0)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      isDense: true,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Available Time Slots
                  Text(
                    'Available Time Slots',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(color: primaryBlack),
                  ),
                  const SizedBox(height: 8),
                  _buildTimeSlotsGrid(),

                  if (_selectedTimeSlot != null) _buildTableSelection(),

                  const SizedBox(height: 20),

                  // Book Now Button
                  ElevatedButton(
                    onPressed: _isBooking || _selectedTableId == null
                        ? null
                        : _onBookTable,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlack,
                      foregroundColor: primaryWhite,
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
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(primaryWhite),
                            ),
                          )
                        : const Text(
                            'Book Now',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}