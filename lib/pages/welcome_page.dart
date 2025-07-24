import 'package:flutter/material.dart';
import 'login_page.dart'; // Assurez-vous que ce fichier existe
import 'signup_page.dart'; // Assurez-vous que ce fichier existe

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Couleurs de base originales, simples et intuitives
    const Color primaryAppColor = Colors.blue;
    const Color secondaryAppColor = Colors.green;

    return Scaffold(
      backgroundColor: Colors.white, // Fond blanc épuré
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 25.0, // Padding ajusté pour un meilleur espacement
            vertical: 50.0,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment
                .stretch, // Étire les éléments horizontalement
            children: <Widget>[
              // Espace supérieur pour un bon alignement visuel
              const SizedBox(height: 60),

              // Logo de l'application
              Image.asset(
                'assets/images/softigo_logo.png', // Vérifiez le chemin de votre logo
                height: 160, // Hauteur du logo ajustée
                fit: BoxFit.contain,
              ),

              // Un peu d'espace après le logo
              const SizedBox(height: 60),

              // Bouton "Se connecter"
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      primaryAppColor, // Utilise la couleur primaire originale
                  foregroundColor:
                      Colors.white, // Texte blanc pour un bon contraste
                  padding: const EdgeInsets.symmetric(
                    vertical:
                        16, // Rembourrage légèrement réduit pour un look plus compact
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      12,
                    ), // Coins légèrement plus arrondis pour une touche moderne
                  ),
                  elevation:
                      3, // Petite ombre pour un effet de profondeur subtil
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                child: const Text(
                  'Se connecter',
                  style: TextStyle(
                    fontSize:
                        18, // Taille de texte un peu plus petite pour la subtilité
                    fontWeight: FontWeight.w600, // Gras moins prononcé
                  ),
                ),
              ),

              const SizedBox(height: 12), // Espace réduit entre les boutons
              // Bouton "Créer un compte"
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor:
                      secondaryAppColor, // Utilise la couleur secondaire originale pour la bordure et le texte
                  padding: const EdgeInsets.symmetric(
                    vertical: 16, // Rembourrage similaire au bouton précédent
                  ),
                  side: BorderSide(
                    color: secondaryAppColor,
                    width: 2, // Épaisseur de la bordure
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      12,
                    ), // Coins arrondis pour correspondre au bouton "Se connecter"
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignUpPage()),
                  );
                },
                child: const Text(
                  'Créer un compte',
                  style: TextStyle(
                    fontSize: 18, // Taille de texte un peu plus petite
                    fontWeight: FontWeight.w600, // Gras moins prononcé
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
