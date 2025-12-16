import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth_io.dart';
// Need to import http client

class SendNotificationScreen extends StatelessWidget {
  static const String routeName = '/sendNotification';

  const SendNotificationScreen({super.key});

  // 1. HARDCODED TOKEN: Your specific vendor device token is used here for testing.
  // This token should match the one stored in vendorNotification/MainVendor if 
  // you want your manual test to simulate a reservation notification.
  final deviceToken = "dCT3wq_ASIa6WPutvhJOyF:APA91bHwiDH5R6puTmU2Bs59UrYfeVpIKhBCl0eNjunJSlWoQAWYrWKMFOHRteXIs2hj3smtFW7oV7-Y7sTuhjXgeHCPmQ6yhh4EOqe4TDapgn-jCexGCrQ";

  // 2. PATH TO YOUR SERVICE ACCOUNT JSON
  // Ensure this path is correct and the file is included in your pubspec.yaml assets section.
  final String serviceAccountPath = 'assets/firebase/flutter-firebase-ddf2c-firebase-adminsdk-fbsvc-7db160a9b3.json';

  Future<void> onSubmit(BuildContext context) async {
    // ----------------------------------------------------
    // Authentication and Setup
    // ----------------------------------------------------
    
    // Load service account JSON
    final jsonString = await rootBundle.loadString('assets/firebase/flutter-firebase-ddf2c-firebase-adminsdk-fbsvc-7db160a9b3.json');
    final jsonMap = jsonDecode(jsonString);

    // Extract project_id and credentials
    final projectId = jsonMap['project_id'] as String;
    final credentials = ServiceAccountCredentials.fromJson(jsonMap);

    // Create an authenticated client with the Firebase Messaging scope
    final client = await clientViaServiceAccount(
      credentials,
      ['https://www.googleapis.com/auth/firebase.messaging'],
    );
    
    // Define the FCM endpoint URL using the project ID
    final url = Uri.parse(
      'https://fcm.googleapis.com/v1/projects/$projectId/messages:send',
    );

    // ----------------------------------------------------
    // Notification Payload (Simulating a New Reservation)
    // ----------------------------------------------------
    final payload = {
      "message": {
        "token": deviceToken, // Target your specific device
        "notification": {
          "title": "🛎️ TEST: New Reservation Received",
          "body": "Customer Jane Doe booked a table for 4 at 19:30.",
        },
        "data": {
          // This data payload is essential for background processing and tapping
          'type': 'new_booking',
          'restaurantId': 'MainVendor',
          'timeSlot': '19:30',
          'customerName': 'Jane Doe',
          'click_action': 'FLUTTER_NOTIFICATION_CLICK', // Standard action
        }
      }
    };

    // ----------------------------------------------------
    // Sending the Request
    // ----------------------------------------------------
    try {
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      // ----------------------------------------------------
      // Response Handling
      // ----------------------------------------------------
      if (response.statusCode == 200) {
        _showSnackbar(context, '✅ Notification sent successfully!');
        debugPrint('FCM Response: ${response.body}');
      } else {
        _showSnackbar(context, '❌ Failed to send notification (Status: ${response.statusCode})');
        debugPrint('FCM Failure Status: ${response.statusCode}');
        debugPrint('FCM Failure Body: ${response.body}');
      }
    } catch (e) {
      _showSnackbar(context, '🚨 Network Error: $e');
      debugPrint('FCM Network Error: $e');
    } finally {
      client.close();
    }
  }
  
  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Send Test Notification (HTTP v1)")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Press the button below to send a test notification to your hardcoded device token using the Service Account key.",
                textAlign: TextAlign.center,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => onSubmit(context),
              icon: const Icon(Icons.send),
              label: const Text("SEND TEST NOTIFICATION"),
            ),
          ],
        ),
      ),
    );
  }
}