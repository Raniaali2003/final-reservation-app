import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart'; // Import for debugPrint
import '../../cubit/notification/notification_state.dart';
import '../../repo/notification_repository.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationRepository repository;

  NotificationCubit(this.repository) : super(NotificationState(notifications: [])) {
    
    // ----------------------------------------------------
    // 1. FOREGROUND LISTENER
    // This is the core logic that runs when the app is OPEN.
    // ----------------------------------------------------
    FirebaseMessaging.onMessage.listen((msg) {
      debugPrint('🔔 FCM Foreground Message received: ${msg.notification?.title}');
      
      // Use the repository to show a local notification banner (popup)
      repository.showLocalNotification(msg);
      
      // Add the message to the Cubit's state list
      addNotification(msg);
    });
    
    // ----------------------------------------------------
    // 2. BACKGROUND/TERMINATED TAP HANDLER (Optional but Recommended)
    // This handles taps on notifications received when the app was closed/backgrounded.
    // ----------------------------------------------------
    FirebaseMessaging.onMessageOpenedApp.listen((msg) {
      debugPrint('👆 Notification tapped (App was in background/terminated)');
      
      // While you don't typically show a new local notification here (it was already shown by the OS),
      // you DO need to process the data and update the state/navigate.
      addNotification(msg);
      
      // Example of handling a specific notification type for navigation:
      if (msg.data['type'] == 'new_booking') {
          // You would typically navigate the user to the Reservation Details screen here.
          debugPrint('Navigating to new booking details...');
      }
    });
    
    // We don't initialize FirebaseMessaging.getInitialMessage() here because 
    // the notifications list is designed to show history, and the background handler 
    // (in main.dart) should ideally load that history upon startup.
  }

  /// Adds a received RemoteMessage to the beginning of the list for display.
  void addNotification(RemoteMessage msg) {
    // Create a new list with the new message added
    final updated = [...state.notifications, msg]; 
    
    // Emit the new state, triggering UI rebuilds
    emit(state.copyWith(notifications: updated));
    debugPrint('Cubit State updated: ${updated.length} notifications in list.');
  }
}