import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart'; // No longer needed if not explicitly used for text styles elsewhere

// Importez vos styles
import 'utils/app_styles.dart';

// Importez toutes vos pages avec les noms corrects
import 'pages/dashboard_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Softigo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // Directly set DashboardPage as the home.
      // DashboardPage will now be responsible for its own navigation if it includes a BottomNavigationBar.
      home: const DashboardPage(),
    );
  }
}

// The MainAppWithNavigation widget is removed entirely as it's no longer needed
// when the BottomNavigationBar logic is moved into DashboardPage.
