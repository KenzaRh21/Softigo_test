import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:softigotest/pages/splash_screen_page.dart';
import 'package:softigotest/pages/splashscreen.dart';
import 'package:softigotest/utils/app_styles.dart';
import 'package:google_fonts/google_fonts.dart';

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
      home: const SplashScreenPage(),
    );
  }
}
