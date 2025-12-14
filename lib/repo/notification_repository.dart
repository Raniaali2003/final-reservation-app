import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
// Note: You need the 'cloud_firestore' package if you want to include the token saving logic here.
// import 'package:cloud_firestore/cloud_firestore.dart'; 

class NotificationRepository {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();

  // ------------------ Initialization ------------------ //
  Future<void> init() async {
    try {
      // 1. Request necessary permissions (especially for iOS and Android 13+)
      final settings = await _messaging.requestPermission();
      
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint("✅ Notification Permission granted");
      } else {
        debugPrint("⚠️ Notification Permission denied or not determined");
      }

      // 2. Initialize local notifications plugin
      // Ensure the @mipmap/ic_launcher path matches the icon in your Android project
      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const initSettings = InitializationSettings(android: androidInit);

      // Initialize the plugin
      await _local.initialize(initSettings, 
          // You can add onDidReceiveBackgroundNotificationResponse 
          // or onDidReceiveNotificationResponse callbacks here for tap handling
      );
      debugPrint("✅ Flutter Local Notifications initialized");


      // 3. Get and print the current device token (for debugging/manual saving)
      final token = await _messaging.getToken();
      debugPrint("FCM Token (for debug): $token");

      // 🚨 REMINDER: You must call your separate token saving service 
      // (e.g., NotificationService().saveTokenAsVendor()) when the user logs in
      // as a vendor. The repository is usually kept clean of user-role logic.


    } catch (e) {
      debugPrint("❌ Error during NotificationRepository init: $e");
    }
  }

  // ------------------ Local Display ------------------ //
  Future<void> showLocalNotification(RemoteMessage message) async {
    // This method is called by the NotificationCubit when a message arrives 
    // while the app is in the foreground.
    
    // Check if the message has notification data to display
    final notification = message.notification;
    if (notification == null) {
      debugPrint('Received message without displayable notification payload.');
      return;
    }

    const android = AndroidNotificationDetails(
      // CRITICAL: This ID must match the ID specified in your AndroidManifest.xml 
      // in the <meta-data> tag: android:value="default_channel"
      'default_channel',
      'Reservations Channel',
      channelDescription: 'Notifications for new table reservations.',
      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: android);
    
    // Use the message's unique hash or a timestamp as the ID
    final id = DateTime.now().millisecondsSinceEpoch % 2000000000; 

    await _local.show(
      id,
      notification.title ?? "New Message",
      notification.body ?? "",
      details,
      // You can pass the message data here to be retrieved on tap
      payload: message.data['type'] ?? 'general', 
    );
    debugPrint('Local notification displayed for: ${notification.title}');
  }
}