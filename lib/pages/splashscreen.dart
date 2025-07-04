import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:softigotest/pages/welcome_page.dart';

class Splashscreen extends StatelessWidget {
  const Splashscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Wrap the AnimatedSplashScreen with a Container that has the gradient
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, // Gradient starts from the top center
            end: Alignment.bottomCenter, // Gradient ends at the bottom center
            colors: [
              Color(0xFF177F23), // Starting green color
              Color(0xFF133F7B), // Ending blue color
            ],
          ),
        ),
        // Place your AnimatedSplashScreen inside this Container
        child: AnimatedSplashScreen(
          splash: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.4,
                child: Lottie.asset(
                  "assets/Lottie/Animation - 1749036696548.json",
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Welcome',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Keep text white for visibility
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          nextScreen: const WelcomePage(),
          // Set backgroundColor to transparent so the Container's gradient shows through
          backgroundColor: Colors.transparent,
          duration: 5000,
          splashIconSize: double.infinity,
          centered: true,
        ),
      ),
    );
  }
}
