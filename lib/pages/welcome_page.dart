// lib/pages/welcome_page.dart
import 'package:flutter/material.dart';
import 'login_page.dart'; // Import the login page
import 'signup_page.dart'; // Import the sign up page
import 'dashboard_page.dart'; // Import the dashboard page

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Optional: Add a clean background color if your logo works better on it
      // backgroundColor: Colors.grey[100],
      body: Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center, // Vertically center content
          crossAxisAlignment:
              CrossAxisAlignment.stretch, // Stretch buttons horizontally
          children: <Widget>[
            // --- REPLACED TEXT WITH IMAGE HERE ---
            Image.asset(
              'assets/images/softigo_logo.png', // Path to your logo (ensure it's 'softigo_logo.png' if it's a file)
              height: 150, // Adjust height as needed
              // width: 250, // You can also specify width
              fit: BoxFit
                  .contain, // Ensures the whole image fits without cropping
            ),

            // --- END IMAGE REPLACEMENT ---
            const SizedBox(height: 50), // Space between logo and buttons

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 40.0,
              ), // Add horizontal padding
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(
                    0xFF133F7B,
                  ), // Button background color
                  foregroundColor: Colors.white, // Text color
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                  ), // Vertical padding for button
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                  ),
                ),
                onPressed: () {
                  // Navigate to the LoginPage
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                child: const Text('Login', style: TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(height: 20), // Space between buttons

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 40.0,
              ), // Add horizontal padding
              child: ElevatedButton(
                // Using OutlinedButton for Sign Up
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(
                    0xFF177F23,
                  ), // Button background color
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  // Navigate to the SignUpPage
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignUpPage()),
                  );
                },
                child: const Text(
                  'Sign Up',
                  style: TextStyle(
                    fontSize: 20,
                    color: Color(0xFFFFFFFF),
                  ), // Text color
                ),
              ),
            ),
            const SizedBox(height: 20), // Space between buttons
            // New "Skip to Dashboard" button (changed to TextButton with arrow)
            Align(
              alignment: Alignment.centerRight, // Align to the right
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40.0,
                ), // Consistent horizontal padding
                child: TextButton.icon(
                  onPressed: () {
                    // Navigate to the DashboardPage
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DashboardPage(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                  ), // Smaller arrow icon
                  label: const Text(
                    'Skip to Dashboard',
                    style: TextStyle(
                      fontSize: 16, // Smaller font size
                      color: Colors.grey, // A subtle color
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets
                        .zero, // Remove default padding for a more compact look
                    alignment: Alignment
                        .centerRight, // Align icon and text to the right within the button
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
