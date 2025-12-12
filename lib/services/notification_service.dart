import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// Import to use GlobalKey
// Needed for your service classes
import 'package:my_first_flutter_app/services/auth_service.dart';
import 'package:my_first_flutter_app/services/restaurant_service.dart';

// IMPORTANT: Assuming you have a file (like main.dart) where you declared
// 'final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();'
// Replace 'my_first_flutter_app/main.dart' with the actual path to your main file.
import 'package:my_first_flutter_app/main.dart'; // <--- IMPORT NAVIGATOR KEY HERE

// ----------------------------------------------------------------------
// 1. TOP-LEVEL BACKGROUND HANDLER
// ----------------------------------------------------------------------
// This function must be a top-level function (outside of any class)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // NOTE: Firebase.initializeApp() is usually done in main(), 
  // but good practice to ensure it here for background processing.
  // await Firebase.initializeApp(); 
  
  print("--- FCM BACKGROUND MESSAGE HANDLED ---");
  print("Data: ${message.data}");
}


class NotificationService {
  final _fcm = FirebaseMessaging.instance;
  final _firestore = FirebaseFirestore.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  // ----------------------------------------------------------------------
  // VITAL FIX: INJECTED DEPENDENCIES
  // ----------------------------------------------------------------------
  final AuthService authService;
  final RestaurantService restaurantService;

  NotificationService({
    required this.authService, 
    required this.restaurantService,
  });
  // ----------------------------------------------------------------------


  // ----------------------------------------------------------------------
  // CORE INITIALIZATION
  // ----------------------------------------------------------------------

  Future<void> initNotifications() async {
    // 1. Register the background message handler (still needed, but uses the top-level function)
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 2. Initialize local notifications (needed for foreground display)
    await _initLocalNotifications();
    
    // 3. Request permissions from the user
    await _fcm.requestPermission();

    // 4. Handle FCM Token logic (retrieve and save)
    _setupTokenManagement();
    
    // 5. Setup foreground and interaction listeners
    _setupMessageListeners();
  }

  // ----------------------------------------------------------------------
  // TOKEN MANAGEMENT
  // ----------------------------------------------------------------------
  
  void _setupTokenManagement() async {
    // Get and save the initial token
    final token = await _fcm.getToken();
    if (token != null) {
      await _saveTokenToDatabase(token);
    }
    
    // Listen for token refreshes and save the new one
    _fcm.onTokenRefresh.listen(_saveTokenToDatabase).onError((error) {
      print("Error refreshing token: $error");
    });
  }

  // Persists the token to the Firestore document for the Cloud Function to use.
  Future<void> _saveTokenToDatabase(String token) async {
    try {
      final userId = authService.currentUser?.id;
      
      if (userId == null) {
        print(' User not logged in. Storing token in temporary collection.');
        // Store in a temporary collection if user is not logged in
        await _firestore.collection('unassigned_tokens')
            .doc(token) // Use token as document ID to prevent duplicates
            .set({
              'token': token,
              'createdAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
        return;
      }

      // User is logged in, save with their user ID
      await _firestore.collection('vendorNotifications')
          .doc(userId)
          .set({
            'token': token,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
      
      print(' FCM Token saved/updated for user: $userId');
      
      // Check if this token was previously unassigned and clean up
      await _firestore.collection('unassigned_tokens')
          .doc(token)
          .delete()
          .catchError((_) {}); // Ignore if document doesn't exist
          
    } catch (e) {
      print(' Error saving FCM token: $e');
    }
  }

  // ----------------------------------------------------------------------
  // MESSAGE LISTENERS AND HANDLERS
  // ----------------------------------------------------------------------

  void _setupMessageListeners() {
    // Handles message when app is in FOREGROUND
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Using top-level debugPrint function
      debugPrint('Foreground Message Received: ${message.data}');
      
      // Handle both notification and data messages
      if (message.notification != null) {
        // If the message contains a notification, show it
        _showLocalNotification(message);
      } else {
        // If it's a data message, create a notification manually
        _showDataMessageAsNotification(message);
      }
    });

    // Handles message when app is opened from a terminated state
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        // Handle deep-link navigation if user taps on a notification 
        // that launched the app from terminated state.
        _handleNotificationTap(message);
      }
    });

    // Handles message when app is in BACKGROUND but running (user taps notification)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
  }

  // Handles navigation when the vendor taps on the notification
  void _handleNotificationTap(RemoteMessage message) {
    final restaurantId = message.data['restaurantId']; // Assuming Cloud Function sends restaurantId
    
    if (restaurantId != null) {
      print('Navigating to booked tables for Restaurant ID: $restaurantId');
      
      // VITAL FIX: Use the global navigatorKey to navigate without context.
      // The route MUST match the one defined in main.dart: /vendor/booked_tables_notification
      navigatorKey.currentState?.pushNamed(
        '/vendor/booked_tables_notification', 
        arguments: restaurantId, // Pass the restaurantId for the screen to load data
      );
    } else {
      print('Error: Notification data is missing restaurantId for navigation.');
    }
  }

  // ----------------------------------------------------------------------
  // LOCAL NOTIFICATION LOGIC (for displaying foreground messages)
  // ----------------------------------------------------------------------

  Future<void> _initLocalNotifications() async {
    // Initialize Android settings with a default icon
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // Initialize iOS settings with default settings
    const iosSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );
    
    // Combine settings for both platforms
    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    // Create a notification channel for Android 8.0+
    await _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(
      const AndroidNotificationChannel(
        'vendor_booking_channel',
        'New Booking Alerts',
        description: 'Notifications for new table bookings',
        importance: Importance.max,
        playSound: true,
        showBadge: true,
      ),
    );
    
    // Initialize the plugin
    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        if (response.payload != null) {
          print('Local notification tapped. Payload: ${response.payload}');
          final mockMessage = RemoteMessage(data: {'restaurantId': response.payload});
          _handleNotificationTap(mockMessage);
        }
      },
    );
    
    // Request permission for iOS 10.0+ (will do nothing on Android)
    await _localNotifications
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  // Displays a simple local notification using the FCM payload
  void _showLocalNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    // Use a unique ID for each notification
    final id = DateTime.now().millisecondsSinceEpoch % 100000;
    
    _localNotifications.show(
      id,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'vendor_booking_channel', // Channel ID (must be unique)
          'New Booking Alerts', // Channel Name
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          playSound: true,
          enableVibration: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: message.data['restaurantId'] // Pass key data (restaurantId) in the payload
    );
  }
  
  // Handles data messages by showing them as local notifications
  void _showDataMessageAsNotification(RemoteMessage message) {
    final title = message.data['title'] ?? 'New Booking';
    final body = message.data['body'] ?? 'You have a new booking';
    
    // Generate a unique ID for the notification
    final id = DateTime.now().millisecondsSinceEpoch % 100000;
    
    _localNotifications.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'vendor_booking_channel',
          'New Booking Alerts',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          playSound: true,
          enableVibration: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: message.data['restaurantId'],
    );
  }
}