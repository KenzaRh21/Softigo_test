import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:softigotest/pages/splash_screen_page.dart';
import 'package:softigotest/pages/splashscreen.dart'; // Keep if used, otherwise consider removing
import 'package:softigotest/utils/app_styles.dart';
import 'package:google_fonts/google_fonts.dart'; // Keep if used, otherwise consider removing

// Import the necessary localization packages
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter engine is initialized
  await dotenv.load(fileName: ".env"); // Load environment variables from .env
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,

      // Add localization delegates and supported locales here
      localizationsDelegates: const [
        GlobalMaterialLocalizations
            .delegate, // Provides Material Design localized strings
        GlobalWidgetsLocalizations
            .delegate, // Provides basic widget localized strings
        GlobalCupertinoLocalizations
            .delegate, // Provides iOS-style widget localized strings
      ],
      supportedLocales: const [
        Locale('en', ''), // English locale
        Locale('fr', ''), // French locale
        // Add other locales here if your app supports them, e.g., Locale('es', '') for Spanish
      ],
      // Optional: Set a default locale if you want your app to always start in a specific language,
      // regardless of the device's locale. If not set, it will try to match device locale first.
      locale: const Locale('fr', 'FR'), // Setting French as default

      home: const SplashScreenPage(),
    );
  }
}
