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
                const SizedBox(height: 20),
                // Logo en haut
                Image.asset('assets/images/logo.png', width: 200, height: 200),
                const SizedBox(height: 50),

                // Texte Bienvenue
                const SizedBox(height: 5),
                // Photo supplémentaire
                Image.asset(
                  'assets/images/beinvenue.png', // Remplacer par une autre image si disponible
                  width: 400,

                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 50),
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
