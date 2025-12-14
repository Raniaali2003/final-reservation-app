

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
    final FirebaseMessaging _messaging = FirebaseMessaging.instance;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    static const String VENDOR_COLLECTION = 'vendorNotifications';
    static const String USER_TOKENS_COLLECTION = 'userFcmTokens';

    // -----------------------------------------------------------
    // ⚠️ Security Note: No client-side notification SENDING logic. 
    // Sending should be done via a secure Cloud Function (backend).
    // -----------------------------------------------------------

    /// Requests permissions and saves the FCM token for the current user.
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

            // Save/Merge the token to Firestore
            await _firestore
                .collection(USER_TOKENS_COLLECTION)
                .doc(userId)
                .set({
                    'token': token,
                    'updatedAt': FieldValue.serverTimestamp(),
                    'userId': userId,
                }, SetOptions(merge: true));

            debugPrint('✅ FCM Token saved successfully for user $userId');

            // Set up token refresh listener
            _messaging.onTokenRefresh.listen((newToken) async {
                debugPrint('FCM token refreshed, updating...');
                await _firestore
                    .collection(USER_TOKENS_COLLECTION)
                    .doc(userId)
                    .update({
                        'token': newToken,
                        'updatedAt': FieldValue.serverTimestamp(),
                    });
                debugPrint('✅ FCM Token refreshed for user $userId');
            });

        } catch (e) {
            debugPrint('❌ Failed to save FCM token: $e');
        }
    }

    /// Saves the FCM token specifically for the vendor's device.
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

            await _firestore
                .collection(VENDOR_COLLECTION)
                .doc(restaurantId)
                .set({
                    'token': token,
                    'updatedAt': FieldValue.serverTimestamp(),
                }, SetOptions(merge: true));

            debugPrint('✅ Vendor FCM Token saved for restaurant $restaurantId');

            // Set up token refresh listener for vendor
            _messaging.onTokenRefresh.listen((newToken) async {
                debugPrint('Vendor FCM token refreshed, updating...');
                await _firestore
                    .collection(VENDOR_COLLECTION)
                    .doc(restaurantId)
                    .update({
                        'token': newToken,
                        'updatedAt': FieldValue.serverTimestamp(),
                    });
                debugPrint('✅ Vendor FCM Token refreshed for restaurant $restaurantId');
            });

        } catch (e) {
            debugPrint('❌ Failed to save Vendor FCM token: $e');
        }
    }

    // -----------------------------------------------------------
    // ➕ NEW METHOD: Token Deletion 
    // -----------------------------------------------------------

    /// [NEW METHOD] Deletes the FCM token upon user logout.
    Future<void> deleteFcmToken(String userId) async {
        if (userId.isEmpty) return;

        try {
            // 1. Remove the token from the current device's FCM instance
            await _messaging.deleteToken();
            
            // 2. Delete the token record from Firestore
            await _firestore
                .collection(USER_TOKENS_COLLECTION)
                .doc(userId)
                .delete();

            debugPrint('🗑️ FCM Token deleted successfully for user $userId');
        } catch (e) {
            debugPrint('❌ Failed to delete FCM token for user $userId: $e');
        }
    }
    
    // -----------------------------------------------------------
    // Utility Method (Kept for Debugging)
    // -----------------------------------------------------------
    
    // Temporary method to print FCM token
    Future<void> printFcmToken() async {
        try {
            final token = await _messaging.getToken();
            debugPrint(' FCM Token: $token');
            debugPrint(' Copy this token and paste it in the VENDOR_FCM_TOKEN constant in restaurant_service.dart');
        } catch (e) {
            debugPrint(' Error getting FCM token: $e');
        }
    }
}