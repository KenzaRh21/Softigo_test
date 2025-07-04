// lib/main.dart
import 'package:flutter/material.dart';
import 'pages/splashscreen.dart'; // Importe la page d'écran de démarrage
import '/pages/dashboard_page.dart'; // Importe la page du tableau de bord
import '/utils/app_styles.dart'; // Importe les styles et couleurs de l'application
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
      title: 'Softigo App',
      debugShowCheckedModeBanner:
          false, // Cache le bandeau "DEBUG" en mode développement
      theme: ThemeData(
        // Configuration du thème de l'application, utilisant AppColors pour la cohérence des couleurs
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryIndigo),
        useMaterial3: true,
        fontFamily: 'Inter', // Définit la police de caractères globale
        appBarTheme: const AppBarTheme(elevation: 0),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.neutralGrey100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.primaryIndigo, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 16,
          ),
          hintStyle: TextStyle(color: AppColors.neutralGrey500),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: AppColors.neutralGrey200,
            backgroundColor: AppColors.primaryIndigo,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryIndigo,
            side: const BorderSide(color: AppColors.primaryIndigo, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // TODO: Ajoutez ici d'autres styles de thème si nécessaire pour une personnalisation globale.
        // Par exemple, les styles de texte par défaut, les thèmes de cartes, etc.
      ),
      // Définit SplashScreenPage comme la page initiale de l'application.
      // C'est le point d'entrée après le démarrage.
      home: const Splashscreen(),
      // Définit les routes nommées pour une navigation facile entre les pages.
      routes: {
        '/dashboard': (context) => const DashboardPage(),
        // TODO: Ajoutez ici des routes pour les pages d'authentification (connexion, inscription).
        // Ces pages sont les points d'entrée pour les appels API liés à l'authentification.
        // Exemple:
        // '/login': (context) => const LoginPage(), // Page de connexion, avec formulaire et appel API de login
        // '/create-account': (context) => const CreateAccountPage(), // Page de création de compte, avec formulaire et appel API d'inscription
        // TODO: Ajoutez d'autres routes pour les différentes sections de l'application (factures, tiers, congés, etc.).
        // Ces pages contiendront la logique pour charger et afficher les données via des APIs.
        // Exemple:
        // '/factures': (context) => const FacturesPage(),
        // '/tiers': (context) => const TiersPage(),
      },
    );
  }
}
