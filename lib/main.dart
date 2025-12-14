

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:device_preview/device_preview.dart';
import 'package:my_first_flutter_app/theme/app_theme_new.dart' as app_theme;
import 'package:flutter_bloc/flutter_bloc.dart'; // <--- NEW

// CORE FIREBASE MESSAGING IMPORT
import 'package:firebase_messaging/firebase_messaging.dart';
// <--- NEW for service

// Services
import 'package:my_first_flutter_app/services/local_storage_service.dart';
import 'package:my_first_flutter_app/services/auth_service.dart';
import 'package:my_first_flutter_app/services/restaurant_service.dart';
import 'package:my_first_flutter_app/services/notification_service.dart'; // <--- NEW
import 'package:my_first_flutter_app/repo/notification_repository.dart'; // <--- NEW

// Cubits
import 'package:my_first_flutter_app/cubit/notification/notification_cubit.dart'; // <--- NEW

// Screens
import 'package:my_first_flutter_app/screens/auth/role_selection_screen.dart';
import 'package:my_first_flutter_app/screens/auth/login_screen.dart';
import 'package:my_first_flutter_app/screens/auth/register_screen.dart';
import 'package:my_first_flutter_app/screens/vendor/vendor_home_screen.dart';
import 'package:my_first_flutter_app/screens/vendor/add_restaurant_screen.dart';
import 'package:my_first_flutter_app/screens/vendor/booked_tables_screen.dart';
import 'package:my_first_flutter_app/screens/customer/customer_home_screen.dart';
import 'package:my_first_flutter_app/screens/notification/notifications_screen.dart'; // <--- NEW

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// ----------------------------------------------------------------------
// 1. TOP-LEVEL BACKGROUND HANDLER
// ----------------------------------------------------------------------
// This function runs when the app is in the background or terminated.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // MUST initialize Firebase in the background isolate
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // NOTE: In a real app, you would log or save the data here to be loaded later.
  debugPrint("Handling a background message: ${message.data}");
}

// Global key for the root Navigator. Used for navigation on notification tap.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ----------------------------------------------------------------------
  // 2. NOTIFICATION SERVICE INITIALIZATION
  // ----------------------------------------------------------------------
  // Register the background message handler before running the app
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  // Instantiate Notification Repository and initialize it
  final notificationRepo = NotificationRepository();
  await notificationRepo.init();
  
  // Instantiate Notification Service (for token management)
  final notificationService = NotificationService();
  // ----------------------------------------------------------------------
  
  // 3. CORE SERVICE INSTANTIATION
  final authService = AuthService();
  final restaurantService = RestaurantService();
  
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
  
  // 4. Setup MultiProvider with the SINGLE instances
  final app = MultiProvider(
    providers: [
      // Standard Providers
      ChangeNotifierProvider<AuthService>.value(value: authService),
      ChangeNotifierProvider<RestaurantService>.value(value: restaurantService),
      Provider<NotificationService>.value(value: notificationService), // <--- NEW

      // BLoC Providers
      BlocProvider<NotificationCubit>( // <--- NEW
        lazy: false,
        create: (_) => NotificationCubit(notificationRepo),
      ),
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
  Future<void> _initializeServices() async {
    await LocalStorageService.init();
    await widget.authService.init();
    await widget.restaurantService.init();
    
    // ----------------------------------------------------------------------
    // Save FCM token for the current user
    // This runs after the AuthService has initialized the current user.
    // ----------------------------------------------------------------------
    final authService = Provider.of<AuthService>(context, listen: false);
    final notificationService = Provider.of<NotificationService>(context, listen: false);

    if (authService.currentUser != null) {
      // Save token for all users
      await notificationService.saveFcmToken(authService.currentUser!.id);
      
      // If user is a vendor, also save as vendor token
      if (authService.currentUser!.isVendor) {
        // Assuming the vendor's restaurant ID is stored in the user object
        // You might need to adjust this based on your data model
        final restaurantId = authService.currentUser!.restaurantId;
        if (restaurantId != null && restaurantId.isNotEmpty) {
          await notificationService.saveTokenAsVendor(restaurantId);
        }
      }
    }
    // ----------------------------------------------------------------------
  }

  Widget _getInitialScreen(AuthService authService) {
    if (authService.currentUser != null) {
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
            '/vendor/notifications': (context) => const NotificationsScreen(), // <--- NEW NOTIFICATION HISTORY ROUTE
            
            // Route for notification tap navigation
            '/vendor/booked_tables_notification': (context) { 
              final restaurantId = ModalRoute.of(context)!.settings.arguments as String?;
              if (restaurantId == null) {
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
            // This section might need cleanup, but keeping the original logic structure
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