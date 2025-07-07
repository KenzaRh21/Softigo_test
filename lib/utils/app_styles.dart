// lib/utils/app_styles.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// --- Couleurs de l'application ---
class AppColors {
  static const Color scaffoldBackground = Color(0xFFF7F9FC);
  static const Color primaryText = Color(0xFF0B1F3A);
  static const Color primaryIndigo = Colors.indigo;
  static const Color accentBlue = Colors.blue;
  static const Color accentRed = Colors.red;
  static const Color accentOrange = Colors.orange;
  static const Color accentGreen = Colors.green;

  static const Color neutralGrey100 = Color(0xFFF5F5F5); // Very light grey
  static const Color neutralGrey300 = Color(0xFFE0E0E0); // Light grey
  static const Color neutralGrey500 = Color(0xFF9E9E9E); // Medium grey
  static const Color neutralGrey600 = Color(0xFF757575); // Example
  static const Color neutralGrey700 = Color(0xFF616161); // Example

  static const Color neutralGrey800 = Color(0xFF424242); // Example
  static const Color background = Color(0xFFF8F8F8);

  static const Color neutralGrey200 = Color(0xFFEEEEEE);
  static const Color neutralGrey400 = Color(0xFFBDBDBD);

  static const Color black87 = Colors.black87; // This is fine
  static const Color white = Colors.white; // Existing white
  static const Color neutralWhite = Color(
    0xFFFFFFFF,
  ); // New: Explicit white for consistency (same as Colors.white)
  static const Color black = Colors.black;
  static const Color appBarBackground = neutralGrey100; // Light background
  static const Color appBarForeground = black;
}

// --- Thème de l'application ---
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      fontFamily: GoogleFonts.poppins().fontFamily,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryIndigo,
        primary: AppColors.primaryIndigo,
        secondary: AppColors.accentBlue,
        surface: AppColors.scaffoldBackground,
        onSurface: AppColors.primaryText,
      ),
      scaffoldBackgroundColor: AppColors.scaffoldBackground,
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.appBarBackground,
        foregroundColor: AppColors.appBarForeground,
        elevation: 0,
        toolbarHeight: 90,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.poppins(
          fontSize: 57,
          fontWeight: FontWeight.bold,
          color: AppColors.black,
        ),
        displayMedium: GoogleFonts.poppins(
          fontSize: 45,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryText,
        ),
        displaySmall: GoogleFonts.poppins(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryText,
        ),
        headlineLarge: GoogleFonts.poppins(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryText,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryText,
        ),
        headlineSmall: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryText,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.black87,
        ),
        titleMedium: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.black87,
        ),
        titleSmall: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.black87,
        ),
        bodyLarge: GoogleFonts.poppins(fontSize: 16, color: AppColors.black87),
        bodyMedium: GoogleFonts.poppins(fontSize: 14, color: AppColors.black87),
        bodySmall: GoogleFonts.poppins(fontSize: 12, color: AppColors.black87),
        labelLarge: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        labelMedium: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        labelSmall: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),
      ),
      cardTheme: const CardThemeData(
        elevation: 1,
        margin: EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: AppColors.neutralGrey600),
        prefixIconColor: AppColors.neutralGrey600,
        filled: true,
        fillColor: AppColors.neutralGrey100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
      ),
    );
  }
}

// --- Widgets réutilisables ---
// lib/utils/app_styles.dart

class InfoCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const InfoCard({
    super.key,
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 10,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          // <--- CHANGE 1: Main layout is now a Column
          crossAxisAlignment:
              CrossAxisAlignment.start, // Align content to the left
          // No need for mainAxisAlignment here, as children will flow naturally
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                // Smaller font for title
                color: AppColors.neutralGrey600, // Grey color for the title
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8), // Space between title and the row below

            Row(
              // <--- CHANGE 2: New Row for icon and count
              mainAxisAlignment:
                  MainAxisAlignment.start, // Align to start (left)
              crossAxisAlignment:
                  CrossAxisAlignment.center, // Vertically center icon and count
              children: [
                CircleAvatar(
                  backgroundColor: color.withOpacity(0.1),
                  radius:
                      24, // <--- Adjust radius to make it slightly smaller (48x48)
                  child: Icon(
                    icon,
                    size: 20,
                    color: color,
                  ), // <--- Adjust icon size
                ),
                const SizedBox(
                  width: 12,
                ), // <--- Adjust space between icon and count
                Text(
                  '$count',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    // <--- Larger font for count
                    fontSize:
                        40, // <--- Explicitly set to a larger size for impact
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText, // Darker color for the count
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
