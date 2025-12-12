






// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:flutter/foundation.dart';
// import 'package:device_preview/device_preview.dart';
// import 'package:my_first_flutter_app/theme/app_theme_new.dart' as app_theme;

// // Services
// import 'package:my_first_flutter_app/services/local_storage_service.dart';
// import 'package:my_first_flutter_app/services/auth_service.dart';
// import 'package:my_first_flutter_app/services/restaurant_service.dart';

// // Screens
// import 'package:my_first_flutter_app/screens/auth/role_selection_screen.dart';
// import 'package:my_first_flutter_app/screens/auth/login_screen.dart';
// import 'package:my_first_flutter_app/screens/auth/register_screen.dart';
// import 'package:my_first_flutter_app/screens/vendor/vendor_home_screen.dart';
// import 'package:my_first_flutter_app/screens/vendor/add_restaurant_screen.dart';
// import 'package:my_first_flutter_app/screens/vendor/booked_tables_screen.dart';
// import 'package:my_first_flutter_app/screens/customer/customer_home_screen.dart';

// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // Handle global errors
//   ErrorWidget.builder = (FlutterErrorDetails details) {
//     if (details.exception is FlutterError) {
//       return Scaffold(
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Icon(Icons.error_outline, size: 48, color: Colors.red),
//               const SizedBox(height: 16),
//               const Text("Something went wrong!", style: TextStyle(fontSize: 18)),
//               const SizedBox(height: 8),
//               Text(
//                 details.exception.toString(),
//                 style: const TextStyle(fontSize: 12, color: Colors.grey),
//                 textAlign: TextAlign.center,
//               ),
//             ],
//           ),
//         ),
//       );
//     }
//     return ErrorWidget(details.exception);
//   };

//   // Initialize Firebase
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );

//   // Initialize services
//   final authService = AuthService();
//   final restaurantService = RestaurantService();

//   final app = MultiProvider(
//     providers: [
//       ChangeNotifierProvider<AuthService>.value(value: authService),
//       ChangeNotifierProvider<RestaurantService>.value(value: restaurantService),
//     ],
//     child: MyApp(authService: authService, restaurantService: restaurantService),
//   );

//   runApp(
//     DevicePreview(
//       enabled: !kReleaseMode,
//       builder: (context) => app,
//     ),
//   );
// }

// class MyApp extends StatefulWidget {
//   final AuthService authService;
//   final RestaurantService restaurantService;

//   const MyApp({super.key, required this.authService, required this.restaurantService});

//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   Future<void> _initializeServices() async {
//     await LocalStorageService.init();
//     await widget.authService.init();
//     await widget.restaurantService.init();
//   }

//   Widget _getInitialScreen(AuthService authService) {
//     if (authService.currentUser != null) {
//       // Check if user is a vendor or customer
//       if (authService.currentUser!.isVendor) {
//         return const VendorHomeScreen();
//       } else {
//         return const CustomerHomeScreen();
//       }
//     } else {
//       return const RoleSelectionScreen();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder(
//       future: _initializeServices(),
//       builder: (context, snapshot) {
//         final authService = widget.authService;

//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return MaterialApp(
//             key: const ValueKey('loading'),
//             useInheritedMediaQuery: true,
//             builder: DevicePreview.appBuilder,
//             locale: DevicePreview.locale(context),
//             title: 'Restaurant Reservations',
//             theme: app_theme.AppTheme.lightTheme,
//             debugShowCheckedModeBanner: false,
//             home: const Scaffold(
//               body: Center(child: CircularProgressIndicator()),
//             ),
//           );
//         }

//         return MaterialApp(
//           key: const ValueKey('main'),
//           useInheritedMediaQuery: true,
//           builder: DevicePreview.appBuilder,
//           locale: DevicePreview.locale(context),
//           title: 'Restaurant Reservations',
//           theme: app_theme.AppTheme.lightTheme,
//           darkTheme: app_theme.AppTheme.darkTheme,
//           themeMode: ThemeMode.system,
//           debugShowCheckedModeBanner: false,
//           localizationsDelegates: const [
//             GlobalMaterialLocalizations.delegate,
//             GlobalWidgetsLocalizations.delegate,
//             GlobalCupertinoLocalizations.delegate,
//           ],
//           supportedLocales: const [Locale('en', 'US')],
//           home: _getInitialScreen(authService),
//           routes: {
//             '/role-selection': (context) => const RoleSelectionScreen(),
//             '/login': (context) {
//               final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
//               return LoginScreen(isVendor: args?['isVendor'] ?? false);
//             },
//             '/register': (context) {
//               final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
//               return RegisterScreen(isVendor: args?['isVendor'] ?? false);
//             },
//             '/vendor-home': (context) => VendorHomeScreen(),
//             '/vendor/add-restaurant': (context) => AddRestaurantScreen(),
//             '/vendor/booked-tables': (context) {
//               final restaurantId = ModalRoute.of(context)!.settings.arguments as String?;
//               if (restaurantId == null) {
//                 return const Scaffold(body: Center(child: Text('Restaurant ID is required')));
//               }
//               return BookedTablesScreen(restaurantId: restaurantId);
//             },
//             '/customer-home': (context) => const CustomerHomeScreen(),
//           },
//           onGenerateRoute: (settings) {
//             if (settings.name == '/restaurant-detail' || settings.name == '/booking') {
//               return MaterialPageRoute(builder: (context) => const VendorHomeScreen());
//             }
//             return null;
//           },
//         );
//       },
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:device_preview/device_preview.dart';
import 'package:my_first_flutter_app/theme/app_theme_new.dart' as app_theme;

// CORE FIREBASE MESSAGING IMPORT
import 'package:firebase_messaging/firebase_messaging.dart';

// Services
import 'package:my_first_flutter_app/services/local_storage_service.dart';
import 'package:my_first_flutter_app/services/auth_service.dart';
import 'package:my_first_flutter_app/services/restaurant_service.dart';
import 'package:my_first_flutter_app/services/notification_service.dart'; // <--- ADDED IMPORT

// Screens
import 'package:my_first_flutter_app/screens/auth/role_selection_screen.dart';
import 'package:my_first_flutter_app/screens/auth/login_screen.dart';
import 'package:my_first_flutter_app/screens/auth/register_screen.dart';
import 'package:my_first_flutter_app/screens/vendor/vendor_home_screen.dart';
import 'package:my_first_flutter_app/screens/vendor/add_restaurant_screen.dart';
import 'package:my_first_flutter_app/screens/vendor/booked_tables_screen.dart';
import 'package:my_first_flutter_app/screens/customer/customer_home_screen.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// ----------------------------------------------------------------------
// 1. TOP-LEVEL BACKGROUND HANDLER
// ----------------------------------------------------------------------
// This function must be a top-level function (outside of any class)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // NOTE: In a real app, you would need to access a shared service instance 
  // here to handle the background message. This usually requires either 
  // setting up service locators or using static methods in your NotificationService.
  print("Handling a background message: ${message.data}");
}

// Global key for the root Navigator. Use this to navigate without context.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Handle global errors
  ErrorWidget.builder = (FlutterErrorDetails details) {
    if (details.exception is FlutterError) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              const Text("Something went wrong!", style: TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Text(
                details.exception.toString(),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    return ErrorWidget(details.exception);
  };

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ----------------------------------------------------------------------
  // 2. FIX: SINGLETON SERVICE INSTANTIATION
  // ----------------------------------------------------------------------
  // Create a single instance of each core service that will be shared
  // by the Provider and other services (like NotificationService).
  final authService = AuthService();
  final restaurantService = RestaurantService();
  
  // NOTE: You must update your NotificationService constructor 
  // to accept AuthService and RestaurantService, 
  // as done in the previous step's explanation.
  final notificationService = NotificationService(
    authService: authService, 
    restaurantService: restaurantService,
  );

  // ----------------------------------------------------------------------
  // 3. NOTIFICATION SERVICE INITIALIZATION
  // ----------------------------------------------------------------------
  // Register the background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  // Initialize the notification service (sets up token, permissions, listeners)
  await notificationService.initNotifications(); 
  // ----------------------------------------------------------------------


  // 4. Setup MultiProvider with the SINGLE instances using .value
  final app = MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthService>.value(value: authService),
      ChangeNotifierProvider<RestaurantService>.value(value: restaurantService),
      // Add NotificationService as a simple Provider if needed later
      Provider<NotificationService>.value(value: notificationService), 
    ],
    // Pass the single instances to MyApp's constructor
    child: MyApp(authService: authService, restaurantService: restaurantService),
  );

  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => app,
    ),
  );
}

class MyApp extends StatefulWidget {
  final AuthService authService;
  final RestaurantService restaurantService;

  const MyApp({super.key, required this.authService, required this.restaurantService});

  @override
  State<MyApp> createState() => _MyAppState();
  
}

class _MyAppState extends State<MyApp> {
  // Services are already instantiated in main(). This method just runs init().
  Future<void> _initializeServices() async {
    await LocalStorageService.init();
    await widget.authService.init();
    await widget.restaurantService.init();
    // The NotificationService.init() is now in main(), no need to repeat here.
  }

  Widget _getInitialScreen(AuthService authService) {
    if (authService.currentUser != null) {
      // Check if user is a vendor or customer
      if (authService.currentUser!.isVendor) {
        return const VendorHomeScreen();
      } else {
        return const CustomerHomeScreen();
      }
    } else {
      return const RoleSelectionScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeServices(),
      builder: (context, snapshot) {
        final authService = widget.authService;

        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            key: const ValueKey('loading'),
            useInheritedMediaQuery: true,
            builder: DevicePreview.appBuilder,
            locale: DevicePreview.locale(context),
            title: 'Restaurant Reservations',
            theme: app_theme.AppTheme.lightTheme,
            debugShowCheckedModeBanner: false,
            home: const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        return MaterialApp(
          key: const ValueKey('main'),
          // VITAL FIX 1: Attach the GlobalKey to the MaterialApp
          navigatorKey: navigatorKey, 
          useInheritedMediaQuery: true,
          builder: DevicePreview.appBuilder,
          locale: DevicePreview.locale(context),
          title: 'Restaurant Reservations',
          theme: app_theme.AppTheme.lightTheme,
          darkTheme: app_theme.AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          debugShowCheckedModeBanner: false,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en', 'US')],
          home: _getInitialScreen(authService),
          routes: {
            '/role-selection': (context) => const RoleSelectionScreen(),
            '/login': (context) {
              final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
              return LoginScreen(isVendor: args?['isVendor'] ?? false);
            },
            '/register': (context) {
              final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
              return RegisterScreen(isVendor: args?['isVendor'] ?? false);
            },
            '/vendor-home': (context) => const VendorHomeScreen(),
            '/vendor/add-restaurant': (context) => const AddRestaurantScreen(),
            // VITAL FIX 2: Define the Route for Notification Tap Navigation
            '/vendor/booked_tables_notification': (context) { // <--- ADDED NEW ROUTE
              final restaurantId = ModalRoute.of(context)!.settings.arguments as String?;
                if (restaurantId == null) {
                  // If the ID is missing from the notification payload, use a placeholder or handle gracefully
                  return const Scaffold(body: Center(child: Text('Restaurant ID is missing from notification')));
                }
                return BookedTablesScreen(restaurantId: restaurantId);
            },
            // The existing '/vendor/booked-tables' route
            '/vendor/booked-tables': (context) {
              final restaurantId = ModalRoute.of(context)!.settings.arguments as String?;
              if (restaurantId == null) {
                return const Scaffold(body: Center(child: Text('Restaurant ID is required')));
              }
              return BookedTablesScreen(restaurantId: restaurantId);
            },
            '/customer-home': (context) => const CustomerHomeScreen(),
          },
          onGenerateRoute: (settings) {
            // Note: Your onGenerateRoute currently returns VendorHomeScreen for two specific paths.
            // This might need review in a real app if you are using 'routes' and 'onGenerateRoute' together.
            if (settings.name == '/restaurant-detail' || settings.name == '/booking') {
              return MaterialPageRoute(builder: (context) => const VendorHomeScreen());
            }
            return null;
          },
        );
      },
    );
  }
}