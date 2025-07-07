// lib/pages/splash_screen_page.dart

import 'package:flutter/material.dart';
import '/utils/app_styles.dart'; // Import your styles
import '/pages/welcome_page.dart'; // Ensure WelcomePage is correctly imported
import 'package:animated_splash_screen/animated_splash_screen.dart';

class SplashScreenPage extends StatelessWidget {
  const SplashScreenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      nextScreen: const WelcomePage(),
      duration: 3000, // A comfortable duration for a stylish reveal
      splashIconSize: double.infinity,
      centered: true,

      // Using a light background color from your app styles
      backgroundColor: AppColors
          .neutralGrey100, // Or AppColors.neutralGrey200 if you prefer slightly darker light grey

      splash: Stack(
        // Use a Stack to layer background shapes and foreground content
        children: [
          // --- Background Shapes (Subtle & Modern) ---
          // Top-left abstract shape
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.accentBlue.withOpacity(0.1), // Subtle blue
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Bottom-right abstract shape
          Positioned(
            bottom: -70,
            right: -70,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: AppColors.primaryIndigo.withOpacity(
                  0.08,
                ), // Subtle indigo
                borderRadius: BorderRadius.circular(
                  50,
                ), // Soft rounded rectangle
              ),
            ),
          ),
          // Mid-left abstract shape
          Positioned(
            top: MediaQuery.of(context).size.height * 0.3,
            left: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.accentOrange.withOpacity(
                  0.05,
                ), // Very subtle orange
                shape: BoxShape.circle,
              ),
            ),
          ),

          // --- Foreground Content (Logo & Text) ---
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Softigo Logo
                Image.asset(
                  'assets/images/softigo_logo.png', // Ensure this path is correct
                  height: 180, // Slightly adjusted size for better balance
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 25), // Space below the logo
                // Softigo App Name
                Text(
                  'Softigo',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: AppColors
                        .primaryIndigo, // Using primary indigo for brand consistency
                    fontWeight: FontWeight.bold,
                    fontSize: 48,
                    letterSpacing: 2.0,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10), // Small space for tagline
                Text(
                  'Your Business, Simplified.', // A refined, modern tagline
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color:
                        AppColors.neutralGrey700, // Darker grey for readability
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
