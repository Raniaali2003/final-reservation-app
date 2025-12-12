import 'package:flutter/foundation.dart';
import '../models/user.dart';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';

// Your local User model

class AuthService extends ChangeNotifier {
  // Firebase Instances
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // State Management
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  StreamSubscription<firebase_auth.User?>? _authStateSubscription;

  // Initialize service
  Future<void> init() async {
    _isLoading = true;
    if (hasListeners) {
      notifyListeners();
    }

    // Listen to Firebase auth changes
    _authStateSubscription = _auth.authStateChanges().listen((fUser) async {
      try {
        if (fUser != null) {
          await _fetchUserData(fUser);
        } else {
          _currentUser = null;
        }
        _isLoading = false;
        // Only notify if there are listeners (widgets still in tree)
        if (hasListeners) {
          notifyListeners();
        }
      } catch (e) {
        debugPrint('Error in auth state listener: $e');
        _isLoading = false;
        if (hasListeners) {
          notifyListeners();
        }
      }
    });
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }

  // --- Helper Methods ---

  // Fetch Firestore user data
  Future<User?> _fetchUserData(firebase_auth.User fUser) async {
    try {
      final doc = await _db.collection('users').doc(fUser.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        _currentUser = User(
          id: fUser.uid,
          email: fUser.email!,
          name: data['name'] ?? fUser.displayName,
          isVendor: data['isVendor'] ?? false,
          phoneNumber: data['phoneNumber'],
          restaurantId: data['restaurantId'],
        );
        return _currentUser;
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching user data: $e');
      return null;
    }
  }

  // Store or update Firestore user
  Future<void> _storeUserData(firebase_auth.User fUser, bool isVendor,
      {String? name}) async {
    final roleData = {
      'uid': fUser.uid,
      'email': fUser.email,
      'name': name ?? fUser.displayName ?? (isVendor ? 'Vendor' : 'Customer'),
      'isVendor': isVendor,
      'lastSignInTime': FieldValue.serverTimestamp(),
    };
    await _db
        .collection('users')
        .doc(fUser.uid)
        .set(roleData, SetOptions(merge: true));
  }

  // --- Core Auth Methods ---

  // Helper method to ensure Firebase Auth is ready
  Future<void> _ensureAuthReady() async {
    // Wait a small delay to ensure native code is initialized
    await Future.delayed(const Duration(milliseconds: 100));
    // Access the auth instance to trigger initialization if needed
    _auth.currentUser;
  }

  // Email/Password Registration
  Future<bool> register(
      String email, String password, String name, bool isVendor) async {
    try {
      _isLoading = true;
      _error = null;
      if (hasListeners) {
        notifyListeners();
      }

      // Ensure Firebase Auth is ready before attempting registration
      await _ensureAuthReady();

      debugPrint('Attempting to register user with email: $email');

      firebase_auth.UserCredential? userCredential;
      try {
        userCredential = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);
        debugPrint('Registration successful for email: $email');
      } on firebase_auth.FirebaseAuthException catch (e) {
        debugPrint(
            'FirebaseAuthException during registration: ${e.code} - ${e.message}');
        // Check if user was actually created despite the error
        final currentUser = _auth.currentUser;
        if (e.code == 'email-already-in-use' &&
            currentUser != null &&
            currentUser.email == email) {
          // User exists and is signed in - this is actually a success case
          debugPrint(
              'User already exists and is signed in, proceeding with registration...');
          userCredential = null; // We'll use currentUser instead
        } else {
          // Re-throw Firebase Auth exceptions (like email-already-in-use for real)
          rethrow;
        }
      } on TypeError catch (e) {
        debugPrint('TypeError during registration: $e');
        // If we get the PigeonUserDetails error, check if user was created first
        if (e.toString().contains('PigeonUserDetails') ||
            e.toString().contains('List<Object?>')) {
          // Wait a bit for Firebase Auth to update currentUser
          await Future.delayed(const Duration(milliseconds: 300));
          // Check if user was actually created despite the TypeError
          final currentUser = _auth.currentUser;
          if (currentUser != null && currentUser.email == email) {
            debugPrint('User was created despite TypeError, proceeding...');
            userCredential = null; // We'll use currentUser instead
          } else {
            // User wasn't created, try retry
            debugPrint(
                'PigeonUserDetails error detected, retrying after delay...');
            await Future.delayed(const Duration(milliseconds: 500));
            try {
              // Retry the registration
              userCredential = await _auth.createUserWithEmailAndPassword(
                  email: email, password: password);
              debugPrint('Retry registration successful for email: $email');
            } on firebase_auth.FirebaseAuthException catch (retryAuthError) {
              debugPrint(
                  'FirebaseAuthException on retry: ${retryAuthError.code} - ${retryAuthError.message}');
              // Wait a bit and check again if user exists
              await Future.delayed(const Duration(milliseconds: 300));
              final retryCurrentUser = _auth.currentUser;
              if (retryAuthError.code == 'email-already-in-use' &&
                  retryCurrentUser != null &&
                  retryCurrentUser.email == email) {
                debugPrint('User exists from first attempt, proceeding...');
                userCredential = null; // We'll use currentUser instead
              } else {
                // Real email-already-in-use error - user exists but it's not the one we created
                rethrow;
              }
            } catch (retryError) {
              debugPrint('Other error on retry: $retryError');
              // Wait a bit and check one more time if user was created
              await Future.delayed(const Duration(milliseconds: 300));
              final retryCurrentUser = _auth.currentUser;
              if (retryCurrentUser != null && retryCurrentUser.email == email) {
                debugPrint(
                    'User was created despite retry error, proceeding...');
                userCredential = null; // We'll use currentUser instead
              } else {
                rethrow;
              }
            }
          }
        } else {
          rethrow;
        }
      }

      // Get the Firebase user - either from credential or current user
      firebase_auth.User? fUser;
      if (userCredential?.user != null) {
        fUser = userCredential!.user;
      } else {
        // Check if user was created via currentUser (in case of TypeError workaround)
        fUser = _auth.currentUser;
        if (fUser == null || fUser.email != email) {
          throw Exception('Registration failed: Unable to create user account');
        }
      }

      // Store user data in Firestore
      if (fUser != null) {
        await _storeUserData(fUser, isVendor, name: name);

        // Wait a bit for Firestore to be ready, then fetch user data
        await Future.delayed(const Duration(milliseconds: 500));
        var user = await _fetchUserData(fUser);

        // If fetch fails, try a few more times
        if (user == null) {
          for (int i = 0; i < 3; i++) {
            await Future.delayed(const Duration(milliseconds: 500));
            user = await _fetchUserData(fUser);
            if (user != null) break;
          }
        }

        // If still null, create user object from Firebase user directly
        // This ensures currentUser is always set before returning success
        if (_currentUser == null && fUser.email != null) {
          _currentUser = User(
            id: fUser.uid,
            email: fUser.email!,
            name: name,
            isVendor: isVendor,
            phoneNumber: null,
            restaurantId: null,
          );
          notifyListeners();
        }
      }

      return true;
    } on TypeError catch (e) {
      debugPrint('Type error during registration: $e');
      if (e.toString().contains('PigeonUserDetails') ||
          e.toString().contains('List<Object?>')) {
        _error =
            'Firebase Auth native code is out of sync. Please run: flutter clean && flutter pub get && rebuild the app.';
      } else {
        _error = 'Registration failed due to a type error. Please try again.';
      }
      return false;
    } on firebase_auth.FirebaseAuthException catch (e) {
      debugPrint(
          'FirebaseAuthException caught in outer handler: ${e.code} - ${e.message}');
      if (e.code == 'email-already-in-use') {
        // Before showing error, check if user was actually created in this attempt
        // This handles the case where TypeError caused a retry, and the retry says
        // email-already-in-use because the first attempt succeeded
        final currentUser = _auth.currentUser;
        if (currentUser != null && currentUser.email == email) {
          // User was created in this registration attempt - registration succeeded!
          debugPrint(
              'User was created despite email-already-in-use error, registration succeeded');
          // Proceed with storing user data
          try {
            await _storeUserData(currentUser, isVendor, name: name);
            await Future.delayed(const Duration(milliseconds: 500));
            var user = await _fetchUserData(currentUser);
            if (user == null) {
              // Create user object from Firebase user
              _currentUser = User(
                id: currentUser.uid,
                email: currentUser.email!,
                name: name,
                isVendor: isVendor,
                phoneNumber: null,
                restaurantId: null,
              );
              notifyListeners();
            }
            return true; // Registration succeeded!
          } catch (storeError) {
            debugPrint('Error storing user data: $storeError');
            // Even if storing fails, user is created, so return success
            if (_currentUser == null && currentUser.email != null) {
              _currentUser = User(
                id: currentUser.uid,
                email: currentUser.email!,
                name: name,
                isVendor: isVendor,
                phoneNumber: null,
                restaurantId: null,
              );
              notifyListeners();
            }
            return true;
          }
        } else {
          // Email really exists in Firebase Auth (different user or not signed in)
          _error = 'You already have an account. Please sign in.';
        }
      } else {
        _error = e.message ?? 'Registration failed. Please try again.';
      }
      return false;
    } catch (e) {
      _error = 'Registration failed: $e';
      debugPrint('Registration error details: $e');
      return false;
    } finally {
      _isLoading = false;
      if (hasListeners) {
        notifyListeners();
      }
    }
  }

  // Email/Password Login
  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      _currentUser = null;
      if (hasListeners) {
        notifyListeners();
      }

      // Ensure Firebase Auth is ready before attempting login
      await _ensureAuthReady();

      firebase_auth.UserCredential? userCredential;
      try {
        userCredential = await _auth.signInWithEmailAndPassword(
            email: email, password: password);
      } on TypeError catch (e) {
        // If we get the PigeonUserDetails error, wait and retry once
        if (e.toString().contains('PigeonUserDetails') ||
            e.toString().contains('List<Object?>')) {
          debugPrint(
              'PigeonUserDetails error detected during signIn, retrying after delay...');
          await Future.delayed(const Duration(milliseconds: 500));
          try {
            // Retry the login
            userCredential = await _auth.signInWithEmailAndPassword(
                email: email, password: password);
          } catch (retryError) {
            // If retry also fails, check if user is actually logged in
            final currentUser = _auth.currentUser;
            if (currentUser != null && currentUser.email == email) {
              // User is actually logged in despite the error, create credential manually
              debugPrint('User is logged in despite TypeError, proceeding...');
              // Create a mock credential - we'll use currentUser directly
              userCredential = null; // We'll handle this below
            } else {
              rethrow;
            }
          }
        } else {
          rethrow;
        }
      }

      // Get the Firebase user - either from credential or current user
      firebase_auth.User? fUser;
      if (userCredential?.user != null) {
        fUser = userCredential!.user;
      } else {
        // Check if user is logged in via currentUser (in case of TypeError workaround)
        fUser = _auth.currentUser;
        if (fUser == null || fUser.email != email) {
          throw Exception('Login failed: Unable to authenticate user');
        }
      }

      // Try to fetch user data, but don't fail if it errors
      if (fUser != null) {
        try {
          var user = await _fetchUserData(fUser);
          if (user == null) {
            // If user data doesn't exist, wait a bit and try again
            await Future.delayed(const Duration(milliseconds: 500));
            user = await _fetchUserData(fUser);
          }

          // If still no user data, create from Firebase user
          if (_currentUser == null && fUser.email != null) {
            _currentUser = User(
              id: fUser.uid,
              email: fUser.email!,
              name: fUser.displayName ?? 'User',
              isVendor:
                  false, // Default, will be updated from Firestore if available
              phoneNumber: fUser.phoneNumber,
              restaurantId: null,
            );
          }
        } catch (e) {
          // If fetching user data fails, still allow login with basic user info
          debugPrint('Error fetching user data, using Firebase user info: $e');
          if (_currentUser == null && fUser.email != null) {
            _currentUser = User(
              id: fUser.uid,
              email: fUser.email!,
              name: fUser.displayName ?? 'User',
              isVendor: false,
              phoneNumber: fUser.phoneNumber,
              restaurantId: null,
            );
          }
        }

        // Final check: ensure currentUser is set before returning success
        if (_currentUser == null && fUser.email != null) {
          _currentUser = User(
            id: fUser.uid,
            email: fUser.email!,
            name: fUser.displayName ?? 'User',
            isVendor: false,
            phoneNumber: fUser.phoneNumber,
            restaurantId: null,
          );
          notifyListeners();
        }
      }

      return true;
    } on TypeError catch (e) {
      debugPrint('Type error during login: $e');
      if (e.toString().contains('PigeonUserDetails') ||
          e.toString().contains('List<Object?>')) {
        _error =
            'Firebase Auth native code is out of sync. Please run: flutter clean && flutter pub get && rebuild the app.';
      } else {
        _error = 'Login failed due to a type error. Please try again.';
      }
      return false;
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'invalid-email') {
        _error = "No account found. Please sign up first.";
      } else if (e.code == 'wrong-password') {
        _error = "Incorrect password. Please try again.";
      } else {
        _error = e.message;
      }
      return false;
    } catch (e) {
      _error = 'Login failed: $e';
      return false;
    } finally {
      _isLoading = false;
      if (hasListeners) {
        notifyListeners();
      }
    }
  }

  //
  // // Apple Sign-In
  // Future<bool> signInWithApple(bool isVendor) async {
  //   try {
  //     _isLoading = true;
  //     _error = null;
  //     if (hasListeners) {
  //       notifyListeners();
  //     }

  // final credential = await SignInWithApple.getAppleIDCredential(
  //   scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
  // );

  // final appleCredential = firebase_auth.OAuthProvider('apple.com').credential(
  //   idToken: credential.identityToken,
  //   accessToken: credential.authorizationCode,
  // );

  // final userCredential = await _auth.signInWithCredential(appleCredential);
  // final fUser = userCredential.user!;

  // if (await _fetchUserData(fUser) == null) {
  //   final fullName = '${credential.givenName ?? ''} ${credential.familyName ?? ''}'.trim();
  //   await _storeUserData(fUser, isVendor, name: fullName);
  //   await Future.delayed(const Duration(milliseconds: 500));
  //   await _fetchUserData(fUser);
  // }

  //     return true;
  //   } catch (e) {
  //     _error = 'Apple Sign-In Failed: $e';
  //     return false;
  //   } finally {
  //     _isLoading = false;
  //     if (hasListeners) {
  //       notifyListeners();
  //     }
  //   }
  // }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
    _currentUser = null;
    if (hasListeners) {
      notifyListeners();
    }
  }
}
