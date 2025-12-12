
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

  // Convert Reservation object to Map
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

  // Create Reservation object from Map
  factory Reservation.fromMap(Map<String, dynamic> map) {
    return Reservation(
      id: map['id'],
      userId: map['userId'],
      tableId: map['tableId'],
      date: DateTime.parse(map['date']),
      timeSlot: map['timeSlot'],
      numberOfPeople: map['numberOfPeople'],
      specialRequests: map['specialRequests'],
      createdAt: DateTime.parse(map['createdAt']),
      isCancelled: map['isCancelled'] ?? false,
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
