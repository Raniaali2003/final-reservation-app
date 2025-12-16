import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String VENDOR_COLLECTION = 'vendorNotifications';
  static const String USER_TOKENS_COLLECTION = 'userFcmTokens';

  Future<void> saveFcmToken(String userId) async {
    if (userId.isEmpty) {
      debugPrint('Cannot save FCM token: User ID is empty');
      return;
    }

    try {
      final settings = await _messaging.requestPermission();
      if (settings.authorizationStatus != AuthorizationStatus.authorized) {
        debugPrint('Notification permissions not granted');
        return;
      }

      final token = await _messaging.getToken();
      if (token == null || token.isEmpty) {
        debugPrint('FCM token is null or empty, skipping save.');
        return;
      }

      await _firestore.collection(USER_TOKENS_COLLECTION).doc(userId).set({
        'token': token,
        'updatedAt': FieldValue.serverTimestamp(),
        'userId': userId,
      }, SetOptions(merge: true));

      debugPrint(' FCM Token saved successfully for user $userId');

      _messaging.onTokenRefresh.listen((newToken) async {
        debugPrint('FCM token refreshed, updating...');
        await _firestore.collection(USER_TOKENS_COLLECTION).doc(userId).update({
          'token': newToken,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        debugPrint(' FCM Token refreshed for user $userId');
      });
    } catch (e) {
      debugPrint(' Failed to save FCM token: $e');
    }
  }

  Future<void> saveTokenAsVendor(String restaurantId) async {
    if (restaurantId.isEmpty) {
      debugPrint('Cannot save vendor token: Restaurant ID is empty');
      return;
    }

    try {
      final token = await _messaging.getToken();
      if (token == null || token.isEmpty) {
        debugPrint('Vendor FCM token is null or empty, skipping save.');
        return;
      }

      await _firestore.collection(VENDOR_COLLECTION).doc(restaurantId).set({
        'token': token,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      debugPrint(' Vendor FCM Token saved for restaurant $restaurantId');

      _messaging.onTokenRefresh.listen((newToken) async {
        debugPrint('Vendor FCM token refreshed, updating...');
        await _firestore
            .collection(VENDOR_COLLECTION)
            .doc(restaurantId)
            .update({
          'token': newToken,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        debugPrint(' Vendor FCM Token refreshed for restaurant $restaurantId');
      });
    } catch (e) {
      debugPrint(' Failed to save Vendor FCM token: $e');
    }
  }

  Future<void> deleteFcmToken(String userId) async {
    if (userId.isEmpty) return;

    try {
      await _messaging.deleteToken();

      await _firestore.collection(USER_TOKENS_COLLECTION).doc(userId).delete();

      debugPrint(' FCM Token deleted successfully for user $userId');
    } catch (e) {
      debugPrint(' Failed to delete FCM token for user $userId: $e');
    }
  }

  Future<void> printFcmToken() async {
    try {
      final token = await _messaging.getToken();
      debugPrint(' FCM Token: $token');
      debugPrint(
          ' Copy this token and paste it in the VENDOR_FCM_TOKEN constant in restaurant_service.dart');
    } catch (e) {
      debugPrint(' Error getting FCM token: $e');
    }
  }
}
