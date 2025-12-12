



class Restaurant {
  final String id;
  final String name;
  final String description;
  final String imagePath;
  final String category;
  final int tableCount;
  final int seatsPerTable; // This will be the same for all tables in the restaurant
  final List<String> timeSlots;
  final Map<String, dynamic> location; // {latitude: double, longitude: double}
  final List<TableModel> tables;

  Restaurant({
    required this.id,
    required this.name,
    required this.description,
    required this.imagePath,
    required this.category,
    required this.tableCount,
    required this.seatsPerTable,
    required this.timeSlots,
    required this.location,
    required this.tables,
  });

  // Convert Restaurant object to Map (Used for saving to Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imagePath': imagePath, // Stores the Base64 String
      'category': category,
      'tableCount': tableCount,
      'seatsPerTable': seatsPerTable,
      'timeSlots': timeSlots,
      'location': location,
      'tables': tables.map((table) => table.toMap()).toList(),
    };
  }

  // Create Restaurant object from Map (Used for reading from Firestore)
  factory Restaurant.fromMap(Map<String, dynamic> map) {
    // 🛡️ FIX 1: Safely handle nested List<TableModel>
    final rawTables = map['tables'] as List<dynamic>?;
    final tablesList = rawTables
        ?.map((x) {
            if (x is Map<String, dynamic>) {
                return TableModel.fromMap(x);
            }
            return null;
        })
        .whereType<TableModel>()
        .toList() ?? [];
    
    return Restaurant(
      id: map['id'] as String? ?? '', 
      name: map['name'] as String? ?? 'Unknown Restaurant',
      description: map['description'] as String? ?? '',
      imagePath: map['imagePath'] as String? ?? '', 
      category: map['category'] as String? ?? 'General',
      tableCount: map['tableCount'] as int? ?? 0,
      seatsPerTable: map['seatsPerTable'] as int? ?? 0,
      timeSlots: List<String>.from(map['timeSlots'] ?? []),
      location: Map<String, dynamic>.from(map['location'] ?? {}),
      tables: tablesList, // Use the safely built list
    );
  }
}

// -----------------------------------------------------------------------------

class TableModel {
  static const int maxSeatsPerTable = 6;

  final String id;
  final int number;
  final int maxSeats;
  List<Reservation> reservations;

  TableModel({
    required this.id,
    required this.number,
    required int maxSeats,
    List<Reservation>? reservations,
  }) : maxSeats = maxSeats.clamp(1, maxSeatsPerTable), // Clamps maxSeats when object is created manually
        reservations = reservations ?? [];

  bool isAvailable(DateTime date, String timeSlot, {String? currentUserId}) {
    // Normalize the date to ignore time component for comparison
    final normalizedDate = DateTime(date.year, date.month, date.day);

    // Check all reservations for this table
    for (final reservation in reservations) {
      // Skip cancelled reservations
      if (reservation.isCancelled == true) continue;

      // Normalize reservation date for comparison
      final normalizedReservationDate = DateTime(
        reservation.date.year,
        reservation.date.month,
        reservation.date.day,
      );

      // Check if date and time slot match
      if (normalizedReservationDate == normalizedDate &&
          reservation.timeSlot == timeSlot) {
        // Table is booked, regardless of who booked it (prevents double booking a slot)
        return false;
      }
    }

    // No conflicting reservations found
    return true;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'number': number,
      'maxSeats': maxSeats,
      'reservations': reservations.map((r) => r.toMap()).toList(),
    };
  }

  // MODIFICATION: Ensure maxSeats is clamped when reading from Firestore
  factory TableModel.fromMap(Map<String, dynamic> map) {
    final int rawMaxSeats = map['maxSeats'] as int? ?? 1; // Safely read and default to 1

    // 🛡️ FIX 2: Safely handle nested List<Reservation>
    final rawReservations = map['reservations'] as List<dynamic>?;
    final reservationsList = rawReservations
        ?.map((x) {
            if (x is Map<String, dynamic>) {
                return Reservation.fromMap(x);
            }
            return null;
        })
        .whereType<Reservation>()
        .toList() ?? [];
    
    return TableModel(
      id: map['id'] as String? ?? '',
      number: map['number'] as int? ?? 0,
      // Pass the raw value to the constructor so the clamp logic is applied
      maxSeats: rawMaxSeats, 
      reservations: reservationsList, // Use the safely built list
    );
  }
}

// -----------------------------------------------------------------------------

class Reservation {
  final String id;
  final String userId;
  final String tableId;
  final DateTime date;
  final String timeSlot;
  final int numberOfPeople;
  final String? specialRequests;
  final DateTime createdAt;
  final bool isCancelled;

  const Reservation({
    required this.id,
    required this.userId,
    required this.tableId,
    required this.date,
    required this.timeSlot,
    required this.numberOfPeople,
    this.specialRequests,
    required this.createdAt,
    this.isCancelled = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'tableId': tableId,
      'date': date.toIso8601String(),
      'timeSlot': timeSlot,
      'numberOfPeople': numberOfPeople,
      'specialRequests': specialRequests,
      'createdAt': createdAt.toIso8601String(),
      'isCancelled': isCancelled,
    };
  }

  factory Reservation.fromMap(Map<String, dynamic> map) {
    return Reservation(
      id: map['id'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      tableId: map['tableId'] as String? ?? '',
      date: DateTime.parse(map['date'] as String? ?? DateTime.now().toIso8601String()),
      timeSlot: map['timeSlot'] as String? ?? '',
      numberOfPeople: map['numberOfPeople'] as int? ?? 1,
      specialRequests: map['specialRequests'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String? ?? DateTime.now().toIso8601String()),
      isCancelled: map['isCancelled'] as bool? ?? false,
    );
  }

  // Create a copy of the reservation with updated fields
  Reservation copyWith({
    String? id,
    String? userId,
    String? tableId,
    DateTime? date,
    String? timeSlot,
    int? numberOfPeople,
    String? specialRequests,
    DateTime? createdAt,
    bool? isCancelled,
  }) {
    return Reservation(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      tableId: tableId ?? this.tableId,
      date: date ?? this.date,
      timeSlot: timeSlot ?? this.timeSlot,
      numberOfPeople: numberOfPeople ?? this.numberOfPeople,
      specialRequests: specialRequests ?? this.specialRequests,
      createdAt: createdAt ?? this.createdAt,
      isCancelled: isCancelled ?? this.isCancelled,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Reservation &&
        other.id == id &&
        other.userId == userId &&
        other.tableId == tableId &&
        other.date == date &&
        other.timeSlot == timeSlot;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        tableId.hashCode ^
        date.hashCode ^
        timeSlot.hashCode;
  }

  @override
  String toString() {
    return 'Reservation(id: $id, userId: $userId, tableId: $tableId, date: $date, timeSlot: $timeSlot, numberOfPeople: $numberOfPeople, isCancelled: $isCancelled)';
  }
}

// -----------------------------------------------------------------------------

class User {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final List<String> favoriteRestaurants;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    List<String>? favoriteRestaurants,
  }) : favoriteRestaurants = favoriteRestaurants ?? [];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'favoriteRestaurants': favoriteRestaurants,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String?,
      favoriteRestaurants: List<String>.from(map['favoriteRestaurants'] ?? []),
    );
  }
}



