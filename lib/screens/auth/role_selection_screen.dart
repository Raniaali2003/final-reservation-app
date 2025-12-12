import 'package:flutter/material.dart';

import 'package:flutter/services.dart'; // Needed for SystemChrome




class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  // Color constants for B&W theme (matching RegisterScreen)
  static const Color primaryBlack = Colors.black;
  static const Color lightGray = Colors.grey;
  static const Color light = Colors.white;
  static const double borderRadius = 70.0;
  static const double cardElevation = 0.0;

  @override
  Widget build(BuildContext context) {
    // 1. Set System UI style to make status bar transparent and icons visible
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, 
      statusBarIconBrightness: Brightness.light, // For Android (dark status bar)
      statusBarBrightness: Brightness.dark,      // For iOS (dark status bar)
    ));

    return Scaffold(
      // 2. CRUCIAL FIX: Extend the body to draw behind the status bar
      extendBodyBehindAppBar: true, 
      backgroundColor: primaryBlack,
      // Use Stack to place background image behind content
      body: Stack(
        children: [
          // 3. Background Image (will now fill the entire physical screen)
          Positioned.fill(
            child: Image.asset(
              'assets/background.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // 4. Content with ScrollView wrapped in SafeArea
          // SafeArea ensures content starts below the status bar/notch.
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 60.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildLogoPlaceholder(),
                  const SizedBox(height: 50),

                  const Text(
                    'Welcome',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: light,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Please select your role to continue.',
                    style: TextStyle(
                      color: light, 
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  _buildRoleCard(
                    context,
                    icon: Icons.person,
                    title: 'Customer',
                    description: 'Browse restaurants and make reservations',
                    // Navigation: Customer -> RegisterScreen (will redirect to vendor home)
                    onTap: () => _navigateToAuth(context, isVendor: false),
                  ),
                  const SizedBox(height: 20),
                  _buildRoleCard(
                    context,
                    icon: Icons.restaurant,
                    title: 'Restaurant Owner',
                    description: 'Manage your restaurant and view reservations',
                    // ARGUMENT ADDED: Explicitly pass isVendor: true to match _navigateToAuth logic
                    onTap: () => _navigateToAuth(context, isVendor: true),
                  ),
                  const SizedBox(height: 80), 
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widget for Logo
  Widget _buildLogoPlaceholder() {
    return Center(
      child: Image.asset(
        'assets/Reservo-white.png',
        height: 80, 
      ),
    );
  }

  // Helper Widget for Role Cards
  Widget _buildRoleCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: cardElevation, 
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        side: const BorderSide(color: primaryBlack, width: 1.5), 
      ),
      color: Colors.white, 
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Colors.white, 
                  shape: BoxShape.circle,
                  border: Border.fromBorderSide(BorderSide(color: lightGray, width: 1)),
                ),
                // FIX APPLIED: Replaced non-ASCII space with standard space
                child: Icon(icon, size: 30, color: primaryBlack), 
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryBlack, 
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: lightGray, 
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: primaryBlack),
            ],
          ),
        ),
      ),
    );
  }

    // Both customer and vendor will eventually go to vendor home
    void _navigateToAuth(BuildContext context, {required bool isVendor}) {
  if (isVendor) {
    // Navigate directly to vendor home without authentication
    Navigator.pushReplacementNamed(context, '/vendor-home');
  } else {
    // For customers, direct to login page
    Navigator.pushNamed(
      context,
      '/login',
      arguments: {'isVendor': false},
    );
  }
}
}
