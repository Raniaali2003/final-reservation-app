import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/restaurant.dart';
import '../models/user.dart' as user_model;
import 'category_service.dart';

class RestaurantService extends ChangeNotifier {
  static final RestaurantService _instance = RestaurantService._internal();
  factory RestaurantService() => _instance;

  RestaurantService._internal() {
    init();
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _restaurantsRef =
      FirebaseFirestore.instance.collection('restaurants');
  final CollectionReference _usersRef =
      FirebaseFirestore.instance.collection('users');

  // NEW: Dedicated Reservations Collection for easy Cloud Function listening
  final CollectionReference _reservationsRef =
      FirebaseFirestore.instance.collection('reservations');

  final Uuid _uuid = const Uuid();
  final CategoryService _categoryService = CategoryService();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  List<Restaurant> _restaurants = [];
  List<user_model.User> _users = [];
  user_model.User? _currentUser;

  static const List<String> defaultTimeSlots = [
    '10:00',
    '10:30',
    '11:00',
    '11:30',
    '12:00',
  ];

  // ------------------ Initialization ------------------ //
  Future<void> init() async {
    if (!_isInitialized) {
      await loadUsers();
      await loadRestaurants();
      _isInitialized = true;
    }
  }

  // ------------------ Firestore Load ------------------ //
  Future<void> loadRestaurants() async {
    try {
      final snapshot = await _restaurantsRef.get();
      _restaurants = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Inject ID before calling fromMap
        return Restaurant.fromMap(data);
      }).toList();
      notifyListeners();
      debugPrint('Loaded ${_restaurants.length} restaurants from Firestore');
    } catch (e) {
      debugPrint('Error loading restaurants: $e');
      throw Exception('Failed to load restaurants: $e');
    }
  }

  Future<void> loadUsers() async {
    try {
      final snapshot = await _usersRef.get();
      _users = snapshot.docs
          .map((doc) =>
              user_model.User.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      // If no users, create default admin
      if (_users.isEmpty) {
        final admin = user_model.User(
          id: _uuid.v4(),
          name: 'Admin',
          email: 'admin@example.com',
          password: 'admin123',
          phoneNumber: '+1234567890',
        );
        _users.add(admin);
        await _usersRef.doc(admin.id).set(admin.toJson());
      }
      notifyListeners();
      debugPrint('Loaded ${_users.length} users from Firestore');
    } catch (e) {
      debugPrint('Error loading users: $e');
    }
  }

  // ------------------ Restaurant CRUD ------------------ //
  Future<Restaurant> addRestaurant({
    required String name,
    required String description,
    String? imagePath,
    required String category,
    required int tableCount,
    required Map<String, dynamic> location,
    List<String>? timeSlots,
  }) async {
    final restaurantTimeSlots = timeSlots ?? List.from(defaultTimeSlots);

    // Hardcoded seats per table, matching the constructor logic
    const int seatsPerTable = 6;

    // 1. Generate TableModels (FIXED)
    final List<TableModel> initialTables = List.generate(tableCount, (index) {
      return TableModel(
        id: _uuid.v4(),
        number: index + 1,
        maxSeats: seatsPerTable,
        reservations: [],
      );
    });

    // Use a placeholder if imagePath is null
    const String defaultPlaceholder = 'assets/restaurant_placeholder.png';

    final newRestaurant = Restaurant(
      id: _uuid.v4(),
      name: name,
      description: description,
      imagePath: imagePath ?? defaultPlaceholder,
      category: category,
      tableCount: tableCount,
      seatsPerTable: seatsPerTable,
      timeSlots: restaurantTimeSlots,
      location: location,
      tables: initialTables, // Now correctly initialized
    );

    _restaurants.add(newRestaurant);
    await _restaurantsRef.doc(newRestaurant.id).set(newRestaurant.toMap());
    notifyListeners();
    return newRestaurant;
  }

  Future<void> updateRestaurant(Restaurant updatedRestaurant) async {
    final index = _restaurants.indexWhere((r) => r.id == updatedRestaurant.id);
    if (index != -1) {
      _restaurants[index] = updatedRestaurant;
      await _restaurantsRef
          .doc(updatedRestaurant.id)
          .set(updatedRestaurant.toMap());
      notifyListeners();
    }
  }

  // DELETE IMPLEMENTATION: Robust with error handling
  Future<void> deleteRestaurant(String restaurantId) async {
    // 1. Remove from local list (Optimistic Update)
    _restaurants.removeWhere((r) => r.id == restaurantId);
    notifyListeners();

    try {
      // 2. Delete from Firestore
      await _restaurantsRef.doc(restaurantId).delete();

      // NOTE: If reservations or other child data are stored in sub-collections,
      // they must be deleted here or via a Firebase Function to avoid orphaned data.
    } catch (e) {
      // 3. Error Handling: Revert the local change and inform the user.
      debugPrint('Error deleting restaurant $restaurantId: $e');
      await loadRestaurants();
      throw Exception('Failed to delete restaurant due to a database error.');
    }
  }

  List<Restaurant> getAllRestaurants() => List.from(_restaurants);

  List<Restaurant> getRestaurantsByCategory(String category) =>
      _restaurants.where((r) => r.category == category).toList();

  List<String> getAllCategories() {
    final categories = _restaurants.map((r) => r.category).toSet().toList();
    return categories..sort();
  }

  Restaurant? getRestaurantById(String id) {
    try {
      return _restaurants.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  // ------------------ Notification Methods ------------------ //

  // Fixed FCM token for vendor's device
  static const String VENDOR_FCM_TOKEN =
      'faHscCoQQLCgDK3eUwDUqE:APA91bE_C4GpOTumjmZCEdPSEMkhYxpgHTpXur-dbmEF29fbhTTC6GLM2ofrkTOlx_3850S_U2dl7YdBMJy4j7jjRHhjU2UvWmGHm4kHRkNyMc0jLHpjDzc';

  Future<void> _sendBookingNotification({
    required String restaurantId,
    required String tableId,
    required String timeSlot,
    required String customerName,
    required int numberOfPeople,
  }) async {
    debugPrint('🔄 Starting to send booking notification...');
    debugPrint(
        '📝 Details - Restaurant: $restaurantId, Table: $tableId, Time: $timeSlot');

    if (VENDOR_FCM_TOKEN.isEmpty ||
        VENDOR_FCM_TOKEN == 'YOUR_VENDOR_DEVICE_FCM_TOKEN') {
      debugPrint('❌ Vendor FCM token is not configured');
      debugPrint(
          '   Please update VENDOR_FCM_TOKEN with the actual token from the vendor device');
      return;
    }

    debugPrint('� Using fixed FCM token for vendor notifications');

    // Create a properly typed data map with String values
    final Map<String, String> messageData = {
      'type': 'new_booking',
      'restaurantId': restaurantId,
      'tableId': tableId,
      'timeSlot': timeSlot,
      'customerName': customerName,
      'numberOfPeople': numberOfPeople.toString(),
      'timestamp': DateTime.now().toIso8601String(),
      'click_action': 'FLUTTER_NOTIFICATION_CLICK',
    };

    // Create the complete message with notification and data
    try {
      await FirebaseFirestore.instance.collection('fcm_messages').add({
        'to':
            'faHscCoQQLCgDK3eUwDUqE:APA91bE_C4GpOTumjmZCEdPSEMkhYxpgHTpXur-dbmEF29fbhTTC6GLM2ofrkTOlx_3850S_U2dl7YdBMJy4j7jjRHhjU2UvWmGHm4kHRkNyMc0jLHpjDzc',
        'notification': {
          'title': 'New Table Booking',
          'body':
              '$customerName has booked a table for $numberOfPeople at $timeSlot',
          'sound': 'default',
        },
        'data': messageData,
        'priority': 'high',
        'content_available': true,
      });

      debugPrint('✅ FCM notification queued for delivery to vendor device');
    } catch (e) {
      debugPrint('❌ Error sending FCM message: $e');
      debugPrint('   This could be due to an invalid token or network issues');
    }
  }

  // ------------------ Table & Reservation ------------------ //

  List<dynamic> getAvailableTables({
    required String restaurantId,
    required DateTime date,
    required String timeSlot,
    required int numberOfPeople,
  }) {
    final restaurant = getRestaurantById(restaurantId);
    if (restaurant == null) return [];

    // Returns a list of available tables matching the criteria
    return restaurant.tables
        .where((table) =>
            table.maxSeats >= numberOfPeople &&
            table.isAvailable(date, timeSlot))
        .toList();
  }

  // Helper function to find user or return null
  user_model.User? getUserById(String userId) {
    try {
      return _users.firstWhere((u) => u.id == userId);
    } catch (_) {
      debugPrint('User with ID $userId not found in loaded _users list.');
      return null;
    }
  }

  // CRITICAL FIX: Changed 'userId' to require 'user' object directly for reliability.
  Future<void> makeReservation({
    required String restaurantId,
    required String tableId,
    required user_model.User
        customer, // 🌟 FIX: Require the User object directly
    required DateTime date,
    required String timeSlot,
    required int numberOfPeople,
    String? specialRequests,
  }) async {
    final restaurant = getRestaurantById(restaurantId);
    if (restaurant == null) throw Exception('Restaurant not found');

    // Check if customer ID is valid (more permissive check)
    if (customer.id.isEmpty) {
      throw Exception('Invalid user information. Please log in again.');
    }

    // 1. Locate the table index
    final tableIndex = restaurant.tables.indexWhere((t) => t.id == tableId);
    if (tableIndex == -1) throw Exception('Table not found');

    // 2. Generate required data (ID and timestamp)
    final reservationId = _uuid.v4();
    final now = DateTime.now();

    // 3. Create the new Reservation object
    final newReservation = Reservation(
      id: reservationId,
      userId: customer.id, // Use ID from the reliable customer object
      tableId: tableId,
      date: date,
      timeSlot: timeSlot,
      numberOfPeople: numberOfPeople,
      specialRequests: specialRequests,
      createdAt: now,
      isCancelled: false,
    );

    // 4. Update the local Restaurant model (For Availability Check)
    final tableToUpdate = restaurant.tables[tableIndex];

    // Check availability one last time (Good practice before local modification)
    if (!tableToUpdate.isAvailable(date, timeSlot)) {
      throw Exception('The selected table is no longer available.');
    }

    tableToUpdate.reservations.add(newReservation);

    // 5. Persist the change (Two steps are required now)
    try {
      // A) UPDATE RESTAURANT: Update the ENTIRE Restaurant document
      await _restaurantsRef.doc(restaurantId).set(restaurant.toMap());

      // B) CREATE RESERVATION DOCUMENT: Write the reservation to a separate collection
      await _reservationsRef.doc(reservationId).set(newReservation.toMap());

      notifyListeners();

      // Attempt to send notification (Logic inside is now disabled/safe)
      await _sendBookingNotification(
        restaurantId: restaurantId,
        tableId: tableId,
        timeSlot: timeSlot,
        customerName: customer.name,
        numberOfPeople: numberOfPeople,
      );
    } catch (e) {
      // 6. Rollback local change if save fails
      tableToUpdate.reservations.remove(newReservation);
      notifyListeners();
      debugPrint('Error saving reservation: $e');
      // Re-throw the exception to notify the UI
      throw Exception('Failed to book table: Database save error. $e');
    }
  }

  // ----------------------------------------------------
  // NEW METHOD: Get all reservations for the current user
  // ----------------------------------------------------
  List<Reservation> getUserReservations(String userId) {
    final List<Reservation> userBookings = [];

    // Iterate over all restaurants
    for (final restaurant in _restaurants) {
      // Iterate over all tables in the restaurant
      for (final table in restaurant.tables) {
        // Filter the table's reservations for the current user's ID
        final reservationsForUser = table.reservations.where(
          (reservation) =>
              reservation.userId == userId && !reservation.isCancelled,
        );

        // Add the found reservations to the main list
        userBookings.addAll(reservationsForUser);
      }
    }

    // Sort the reservations, typically by date and time (e.g., upcoming first)
    try {
      userBookings.sort((a, b) {
        // Combine date and timeSlot into a single DateTime for reliable sorting
        final timePartsA = a.timeSlot.split(':');
        final combinedA = DateTime(a.date.year, a.date.month, a.date.day,
            int.parse(timePartsA[0]), int.parse(timePartsA[1]));

        final timePartsB = b.timeSlot.split(':');
        final combinedB = DateTime(b.date.year, b.date.month, b.date.day,
            int.parse(timePartsB[0]), int.parse(timePartsB[1]));

        return combinedA.compareTo(combinedB);
      });
    } catch (e) {
      debugPrint('Error sorting reservations: $e');
      // Fallback to unsorted list if parsing fails
    }

    return userBookings;
  }

  // ------------------ User Auth ------------------ //
  Future<bool> login(String email, String password) async {
    final user = _users.firstWhere(
      (u) => u.email.toLowerCase() == email.toLowerCase(),
      orElse: () => user_model.User(id: '', name: '', email: ''),
    );

    if (user.id.isEmpty) return false;
    if (user.password != password) return false;

    _currentUser = user;
    notifyListeners();
    return true;
  }

  Future<user_model.User> register(
      String name, String email, String password) async {
    if (_users.any((u) => u.email.toLowerCase() == email.toLowerCase())) {
      throw Exception('Email already registered');
    }

    final newUser = user_model.User(
      id: _uuid.v4(),
      name: name,
      email: email,
      password: password,
    );

    _users.add(newUser);
    _currentUser = newUser;
    await _usersRef.doc(newUser.id).set(newUser.toJson());
    notifyListeners();
    return newUser;
  }

  // ------------------ Public Getters ------------------ //

  // Public getter for the list of users, accessed as RestaurantService.users
  List<user_model.User> get users => _users;

  user_model.User? get currentUser => _currentUser;
  void setCurrentUser(user_model.User? user) {
    _currentUser = user;
    notifyListeners();
  }

  // ------------------ Category ------------------ //
  Future<List<String>> getCategories() async =>
      await _categoryService.getCategories();
  Future<bool> addCategory(String category) async {
    final success = await _categoryService.addCategory(category);
    if (success) notifyListeners();
    return success;
  }

  Future<bool> removeCategory(String category) async {
    final success = await _categoryService.removeCategory(category);
    if (success) {
      for (var i = 0; i < _restaurants.length; i++) {
        if (_restaurants[i].category == category) {
          _restaurants[i] = _restaurants[i].copyWith(category: 'Uncategorized');
          await updateRestaurant(_restaurants[i]);
        }
      }
      notifyListeners();
    }
    return success;
  }
}

// ----------------------------------------------------
// Restaurant Extension (Assuming this lives in restaurant.dart or similar)
// ----------------------------------------------------

extension RestaurantExtension on Restaurant {
  Restaurant copyWith({
    String? id,
    String? name,
    String? description,
    String? imagePath,
    String? category,
    int? tableCount,
    int? seatsPerTable,
    List<String>? timeSlots,
    Map<String, dynamic>? location,
    dynamic tables,
  }) {
    return Restaurant(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      category: category ?? this.category,
      tableCount: tableCount ?? this.tableCount,
      seatsPerTable: seatsPerTable ?? this.seatsPerTable,
      timeSlots: timeSlots ?? this.timeSlots,
      location: location ?? this.location,
      tables: tables ?? this.tables,
    );
  }
}
