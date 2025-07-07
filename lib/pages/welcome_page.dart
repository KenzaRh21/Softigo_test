// lib/pages/welcome_page.dart
import 'package:flutter/material.dart';
import 'login_page.dart'; // Import the login page
import 'signup_page.dart'; // Import the sign up page
import 'dashboard_page.dart'; // Import the dashboard page
import 'package:softigotest/utils/app_styles.dart'; // Ensure AppColors is available

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the current theme for consistent styling
    final TextTheme textTheme = Theme.of(context).textTheme;
    // Using AppColors for consistency
    final Color primaryBrandColor = AppColors.primaryIndigo;
    const Color secondaryBrandColor = AppColors.accentGreen;
    const Color textColor = AppColors.primaryText;

    return Scaffold(
      backgroundColor: Colors.white, // A clean white background
      body: Center(
        child: SingleChildScrollView(
          // Use SingleChildScrollView to prevent overflow on small screens
          padding: const EdgeInsets.symmetric(
            horizontal: 30.0,
            vertical: 40.0,
          ), // Overall padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment:
                CrossAxisAlignment.stretch, // Stretch buttons horizontally
            children: <Widget>[
              // Optional: Add a subtle top padding to push content down slightly
              const SizedBox(height: 20),

              // Welcome Title
              Text(
                'Bienvenue !',
                textAlign: TextAlign.center,
                style: textTheme.displaySmall?.copyWith(
                  // Use a larger, more impactful text style
                  color: primaryBrandColor,
                  fontWeight: FontWeight.w900, // Extra bold
                  fontSize: 42, // Larger font size
                  letterSpacing: -0.5, // Tighter letter spacing
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Gérez vos factures en toute simplicité.',
                textAlign: TextAlign.center,
                style: textTheme.titleMedium?.copyWith(
                  color: textColor.withOpacity(
                    0.7,
                  ), // Slightly faded for secondary text
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 60), // More space before logo
              // Logo with a more pronounced shadow and subtle glow
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    20,
                  ), // Rounded corners for the container
                  boxShadow: [
                    BoxShadow(
                      color: primaryBrandColor.withOpacity(
                        0.3,
                      ), // Shadow matching primary color
                      blurRadius:
                          25, // Increased blur for a softer, larger shadow
                      offset: const Offset(0, 15), // Push shadow down
                    ),
                  ],
                ),
                child: ClipRRect(
                  // Clip the image to match container's border radius
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/images/softigo_logo.png',
                    height: 180, // Consistent height
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 70), // Increased space after logo
              // Login Button - Primary action
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBrandColor, // Primary brand color
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                  ), // More vertical padding
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      15,
                    ), // Even more rounded corners
                  ),
                  elevation: 8, // More prominent shadow
                  shadowColor: primaryBrandColor.withOpacity(
                    0.4,
                  ), // Custom shadow color
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                child: Text(
                  'Se connecter', // More natural French translation
                  style: textTheme.titleLarge?.copyWith(
                    // Use a larger text style for main buttons
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22, // Larger font
                  ),
                ),
              ),
              const SizedBox(height: 20), // Space between buttons
              // Sign Up Button - Secondary action
              OutlinedButton(
                // Changed to OutlinedButton for a softer secondary action
                style: OutlinedButton.styleFrom(
                  foregroundColor:
                      secondaryBrandColor, // Text color matches secondary brand
                  padding: const EdgeInsets.symmetric(
                    vertical: 18,
                  ), // Slightly less padding than primary
                  side: BorderSide(
                    color: secondaryBrandColor,
                    width: 2,
                  ), // Border color and width
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      15,
                    ), // Consistent rounded corners
                  ),
                  elevation: 3, // Subtle elevation
                  backgroundColor:
                      Colors.white, // White background for outlined button
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignUpPage()),
                  );
                },
                child: Text(
                  'Créer un compte', // More natural French translation
                  style: textTheme.titleLarge?.copyWith(
                    color: secondaryBrandColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 20, // Slightly smaller than primary button
                  ),
                ),
              ),
              const SizedBox(height: 40), // Increased space before skip button
              // Skip to Dashboard Button - Subtle alternative
              TextButton.icon(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DashboardPage(),
                    ),
                  );
                },
                icon: Icon(
                  Icons.arrow_forward_rounded, // More modern arrow icon
                  size: 20, // Slightly larger icon
                  color: primaryBrandColor.withOpacity(
                    0.8,
                  ), // Matches brand color, slightly faded
                ),
                label: Text(
                  'Continuer sans compte', // More natural French translation
                  style: textTheme.bodyLarge?.copyWith(
                    fontSize: 17,
                    color: primaryBrandColor.withOpacity(0.8),
                    decoration: TextDecoration
                        .underline, // Keep underline for link-like appearance
                    fontWeight: FontWeight.w600, // Slightly bolder
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  alignment: Alignment.center, // Center the text button
                  splashFactory: NoSplash
                      .splashFactory, // No splash effect for a cleaner look
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
