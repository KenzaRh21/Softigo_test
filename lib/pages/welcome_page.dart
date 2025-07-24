import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Pour SystemChrome
import 'login_page.dart'; // Assurez-vous que ce fichier existe
import 'signup_page.dart'; // Assurez-vous que ce fichier existe

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    // Ajuster la barre de statut pour qu'elle soit discrète et s'intègre au design
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor:
            Colors.transparent, // Rendre la barre de statut transparente
        statusBarIconBrightness:
            Brightness.dark, // Icônes sombres pour un fond clair
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white, // Un fond blanc pur pour la simplicité
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 30.0,
          ), // Marge généreuse sur les côtés
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment:
                CrossAxisAlignment.stretch, // Les éléments s'étirent en largeur
            children: <Widget>[
              // Espace pour un bon alignement vertical
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.15,
              ), // 15% de la hauteur de l'écran
              // Logo de l'application
              // Pas d'ombre ou de bordures, juste le logo
              Image.asset(
                'assets/images/softigo_logo.png', // Vérifiez ce chemin
                height: 180, // Taille légèrement augmentée pour l'impact
                fit: BoxFit.contain,
              ),

              // Un grand espace après le logo pour la respiration
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.1,
              ), // 10% de la hauteur de l'écran
              // Titre principal de bienvenue
              Text(
                'Bienvenue.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 40, // Très grande taille pour l'impact visuel
                  fontWeight: FontWeight.bold,
                  color:
                      colorScheme.onSurface, // Couleur de texte foncée du thème
                  height: 1.2, // Hauteur de ligne pour une meilleure lisibilité
                ),
              ),

              const SizedBox(height: 10), // Petit espace
              // Message secondaire (slogan ou courte description)
              Text(
                'Gérez vos tiers en toute simplicité.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: colorScheme.onSurface.withOpacity(
                    0.7,
                  ), // Texte légèrement grisé
                ),
              ),

              // Un espace généreux avant les boutons
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.1,
              ), // 10% de la hauteur de l'écran
              // Bouton "Se connecter"
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme
                      .primary, // Utilise la couleur primaire du thème
                  foregroundColor: colorScheme
                      .onPrimary, // Texte blanc sur la couleur primaire
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      12,
                    ), // Coins légèrement arrondis
                  ),
                  elevation: 0, // Pas d'ombre pour un look plat et moderne
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600, // Semi-gras
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                child: const Text('Se connecter'),
              ),

              const SizedBox(height: 15), // Espace entre les boutons
              // Bouton "Créer un compte"
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme
                      .primary, // Texte et bordure avec la couleur primaire
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  side: BorderSide(
                    color:
                        colorScheme.primary, // Bordure avec la couleur primaire
                    width: 1.5, // Épaisseur de la bordure
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      12,
                    ), // Coins légèrement arrondis
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignUpPage()),
                  );
                },
                child: const Text('Créer un compte'),
              ),

              // Espace en bas
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.05,
              ), // 5% de la hauteur de l'écran
            ],
          ),
        ),
      ),
    );
  }
}
