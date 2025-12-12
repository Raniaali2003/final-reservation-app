import 'package:flutter/material.dart';



class AppTheme {
  // --- Private method to ensure TextTheme consistency across light and dark themes ---
  static TextTheme _buildTextTheme(TextTheme base, {Color? bodyColor, Color? titleColor}) {
    // This method ensures that the custom styles are always built on top of 
    // the appropriate base (light or dark), preserving properties like 'inherit: true'.
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        fontSize: 24, 
        fontWeight: FontWeight.bold, 
        color: titleColor ?? base.displayLarge!.color,
      ),
      displayMedium: base.displayMedium?.copyWith(
        fontSize: 22, 
        fontWeight: FontWeight.bold,
        color: titleColor ?? base.displayMedium!.color,
      ),
      displaySmall: base.displaySmall?.copyWith(
        fontSize: 20, 
        fontWeight: FontWeight.bold,
        color: titleColor ?? base.displaySmall!.color,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontSize: 18, 
        fontWeight: FontWeight.w600,
        color: titleColor ?? base.headlineMedium!.color,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontSize: 16, 
        fontWeight: FontWeight.w600,
        color: titleColor ?? base.titleLarge!.color,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        fontSize: 16,
        color: bodyColor ?? base.bodyLarge!.color,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: 14,
        color: bodyColor ?? base.bodyMedium!.color,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontWeight: FontWeight.w500, 
        fontSize: 16,
        color: bodyColor ?? base.labelLarge!.color,
      ),
    );
  }

  // --- LIGHT THEME ---
  static ThemeData get lightTheme {
    final base = ThemeData.light();
    
    return base.copyWith(
      // Apply the consistent text theme
      textTheme: _buildTextTheme(base.textTheme),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.black87),
        titleTextStyle: TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[400]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[400]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      // FIX: Use copyWith on base.cardTheme for better inheritance
      cardTheme: base.cardTheme.copyWith( 
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: Colors.white,
        shadowColor: Colors.black.withOpacity(0.1),
      ),
    );
  }

  // --- DARK THEME ---
  static ThemeData get darkTheme {
    final base = ThemeData.dark();
    final darkSurface = const Color(0xFF1E1E1E); // Custom dark surface color

    return base.copyWith(
      // FIX: Apply the consistent text theme here as well
      textTheme: _buildTextTheme(base.textTheme),

      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.dark,
        surface: darkSurface,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[700]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[700]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[800],
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      // FIX: Use copyWith on base.cardTheme for better inheritance
      cardTheme: base.cardTheme.copyWith( 
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: darkSurface,
        shadowColor: Colors.black.withOpacity(0.3),
        surfaceTintColor: Colors.transparent,
      ),
    );
  }

  // Common text styles (These are fine, but you should use them with Theme.of(context))
  static const TextStyle heading1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    height: 1.5,
  );

  // Spacing
  static const double defaultPadding = 16.0;
  static const double defaultMargin = 16.0;
  static const double defaultBorderRadius = 12.0;
}

// class AppTheme {
//   static ThemeData get lightTheme {
//     final base = ThemeData.light();
    
//     return base.copyWith(
//       textTheme: TextTheme(
//         displayLarge: base.textTheme.displayLarge?.copyWith(fontSize: 24, fontWeight: FontWeight.bold),
//         displayMedium: base.textTheme.displayMedium?.copyWith(fontSize: 22, fontWeight: FontWeight.bold),
//         displaySmall: base.textTheme.displaySmall?.copyWith(fontSize: 20, fontWeight: FontWeight.bold),
//         headlineMedium: base.textTheme.headlineMedium?.copyWith(fontSize: 18, fontWeight: FontWeight.w600),
//         titleLarge: base.textTheme.titleLarge?.copyWith(fontSize: 16, fontWeight: FontWeight.w600),
//         bodyLarge: base.textTheme.bodyLarge?.copyWith(fontSize: 16),
//         bodyMedium: base.textTheme.bodyMedium?.copyWith(fontSize: 14),
//         labelLarge: base.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w500, fontSize: 16),
//       ),
//       textButtonTheme: TextButtonThemeData(
//         style: TextButton.styleFrom(
//           textStyle: const TextStyle(fontWeight: FontWeight.w500),
//         ),
//       ),
//       elevatedButtonTheme: ElevatedButtonThemeData(
//         style: ElevatedButton.styleFrom(
//           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//           textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(8),
//           ),
//         ),
//       ),
//       colorScheme: ColorScheme.fromSeed(
//         seedColor: Colors.blue,
//         brightness: Brightness.light,
//       ),
//       appBarTheme: const AppBarTheme(
//         centerTitle: true,
//         elevation: 0,
//         backgroundColor: Colors.transparent,
//         iconTheme: IconThemeData(color: Colors.black87),
//         titleTextStyle: TextStyle(
//           color: Colors.black87,
//           fontSize: 20,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//       inputDecorationTheme: InputDecorationTheme(
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: BorderSide(color: Colors.grey[400]!),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: BorderSide(color: Colors.grey[400]!),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: const BorderSide(color: Colors.blue, width: 2),
//         ),
//         filled: true,
//         fillColor: Colors.grey[100],
//         contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//       ),
//       cardTheme: CardThemeData(
//         elevation: 2,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//         color: Colors.white,
//         shadowColor: Colors.black.withOpacity(0.1),
//       ),
//     );
//   }

//   static ThemeData get darkTheme {
//     final base = ThemeData.dark();
//     return base.copyWith(
//       colorScheme: ColorScheme.fromSeed(
//         seedColor: Colors.blue,
//         brightness: Brightness.dark,
//       ),
//       appBarTheme: const AppBarTheme(
//         centerTitle: true,
//         elevation: 0,
//         backgroundColor: Colors.transparent,
//         iconTheme: IconThemeData(color: Colors.white),
//         titleTextStyle: TextStyle(
//           color: Colors.white,
//           fontSize: 20,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//       elevatedButtonTheme: ElevatedButtonThemeData(
//         style: ElevatedButton.styleFrom(
//           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(8),
//           ),
//         ),
//       ),
//       inputDecorationTheme: InputDecorationTheme(
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: BorderSide(color: Colors.grey[700]!),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: BorderSide(color: Colors.grey[700]!),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: const BorderSide(color: Colors.blue, width: 2),
//         ),
//         filled: true,
//         fillColor: Colors.grey[800],
//         contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//       ),
//       cardTheme: CardThemeData(
//         elevation: 2,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//         color: const Color(0xFF1E1E1E),
//         shadowColor: Colors.black.withOpacity(0.3),
//         surfaceTintColor: Colors.transparent,
//       ),
//     );
//   }

//   // Common text styles
//   static const TextStyle heading1 = TextStyle(
//     fontSize: 28,
//     fontWeight: FontWeight.bold,
//     letterSpacing: -0.5,
//   );

//   static const TextStyle heading2 = TextStyle(
//     fontSize: 24,
//     fontWeight: FontWeight.w600,
//     letterSpacing: -0.5,
//   );

//   static const TextStyle heading3 = TextStyle(
//     fontSize: 20,
//     fontWeight: FontWeight.w600,
//   );

//   static const TextStyle bodyLarge = TextStyle(
//     fontSize: 16,
//     height: 1.5,
//   );

//   static const TextStyle bodyMedium = TextStyle(
//     fontSize: 14,
//     height: 1.5,
//   );

//   static const TextStyle bodySmall = TextStyle(
//     fontSize: 12,
//     height: 1.5,
//   );

//   // Spacing
//   static const double defaultPadding = 16.0;
//   static const double defaultMargin = 16.0;
//   static const double defaultBorderRadius = 12.0;
// }
