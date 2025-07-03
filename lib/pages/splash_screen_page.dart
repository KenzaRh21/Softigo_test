// lib/pages/splash_screen_page.dart
import 'package:flutter/material.dart';
import '../utils/app_styles.dart'; // Importez vos styles
import 'dashboard_page.dart'; // Importez la page du tableau de bord

/// Première page affichée au lancement de l'application.
/// Elle présente le logo de l'application et offre des options de connexion ou de création de compte.
class SplashScreenPage extends StatelessWidget {
  const SplashScreenPage({super.key});

  /// Helper function to show a SnackBar for button clicks.
  /// This simulates an action feedback and indicates where actual navigation/API calls would go.
  void _showActionClickedSnackBar(BuildContext context, String actionTitle) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"$actionTitle" cliqué !'),
        duration: const Duration(seconds: 1),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors
          .neutralGrey200, // Définissez une couleur de fond pour l'écran de démarrage
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo de l'application
              Image.asset(
                'assets/images/softigo_logo.png',
                height: 120, // Ajustez la taille du logo selon vos besoins
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 48), // Espace entre le logo et les boutons
              // Bouton "Se Connecter"
              SizedBox(
                width: double
                    .infinity, // Le bouton prend toute la largeur disponible
                child: ElevatedButton(
                  onPressed: () {
                    _showActionClickedSnackBar(context, 'Se Connecter');
                    // TODO: Intégrer l'appel API pour l'authentification et la navigation vers la page de connexion.
                    // Exemple: Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
                    // Pour l'exemple, nous naviguons directement vers le tableau de bord après un délai simulé.
                    Future.delayed(const Duration(milliseconds: 500), () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DashboardPage(),
                        ),
                      );
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primary, // Couleur principale du thème
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Se Connecter',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.neutralGrey200,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16), // Espace entre les boutons
              // Bouton "Créer un Compte"
              SizedBox(
                width: double
                    .infinity, // Le bouton prend toute la largeur disponible
                child: OutlinedButton(
                  onPressed: () {
                    _showActionClickedSnackBar(context, 'Créer un Compte');
                    // TODO: Intégrer l'appel API pour l'inscription et la navigation vers la page de création de compte.
                    // Exemple: Navigator.push(context, MaterialPageRoute(builder: (context) => CreateAccountPage()));
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(
                      context,
                    ).colorScheme.primary, // Couleur du texte du bouton
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                    ), // Couleur de la bordure
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Créer un Compte',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
