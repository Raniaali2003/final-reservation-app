class TimeSlot {
  final String id;
  final String startTime;
  final String endTime;
  final bool isAvailable;

  TimeSlot({
    required this.id,
    required this.startTime,
    required this.endTime,
    this.isAvailable = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'startTime': startTime,
      'endTime': endTime,
      'isAvailable': isAvailable,
    };
  }

  factory TimeSlot.fromMap(Map<String, dynamic> map) {
    return TimeSlot(
      id: map['id'],
      startTime: map['startTime'],
      endTime: map['endTime'],
      isAvailable: map['isAvailable'] ?? true,
    );
  }
}

// Default time slots for restaurants
List<TimeSlot> getDefaultTimeSlots() {
  return [
    TimeSlot(id: '1', startTime: '10:00', endTime: '10:30'),
    TimeSlot(id: '2', startTime: '10:30', endTime: '11:00'),
    TimeSlot(id: '3', startTime: '11:00', endTime: '11:30'),
    TimeSlot(id: '4', startTime: '11:30', endTime: '12:00'),
    TimeSlot(id: '5', startTime: '12:00', endTime: '12:30'),
  ];
}
