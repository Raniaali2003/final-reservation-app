import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationState {
  // The core piece of state: a list of all received notifications (RemoteMessage objects)
  final List<RemoteMessage> notifications;

  NotificationState({required this.notifications});

  /// Allows the Cubit to easily create a new state instance with updated data.
  NotificationState copyWith({
    List<RemoteMessage>? notifications,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
    );
  }
}