import 'package:flutter/material.dart';
import 'package:trucky/screens/auth/login.dart';
import 'register.dart';
import '../../config/colors.dart';

class Bienvenue extends StatelessWidget {
  const Bienvenue({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: BTN100,
        // Utiliser une AppBar si nécessaire ou laisser un design plein écran
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,

              children: [
                // Logo en haut
                Image.asset('assets/images/logo.jpg', width: 200, height: 120),
                const SizedBox(height: 10),
                // Texte Bienvenue
                const Text(
                  'Bienvenue',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                // Message de bienvenue
                const Text(
                  'Ravi de vous revoir ! ',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
                const Text(
                  'Connectez-vous pour continuer. ',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
                const SizedBox(height: 24),
                // Photo supplémentaire
                Image.asset(
                  'assets/images/beinvenue.png', // Remplacer par une autre image si disponible
                  width: double.infinity,

                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 80),
                // Boutons "Se connectez" et "S'inscrire" dans une Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: BTN500),
                      onPressed: () {
                        // Naviguer vers la page de connexion
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Login(),
                          ),
                        );
                      },
                      child: const Text(
                        'Se connectez',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: BTN500),
                      onPressed: () {
                        // Naviguer vers la page d'inscription
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Register()),
                        );
                      },
                      child: const Text(
                        "S'inscrire",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
