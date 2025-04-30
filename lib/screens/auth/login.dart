import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trucky/screens/auth/forgetpass.dart';
import 'package:trucky/screens/home_screen.dart';

import '../../config/colors.dart';
import 'register.dart';
import 'package:trucky/widgets/common/app_text_field.dart' as textField;

class Login extends StatelessWidget {
  const Login({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return SafeArea(
      child: Scaffold(
        backgroundColor: BTN100,

        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(33.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                Image.asset('assets/images/logo.jpg', width: 400, height: 120),

                const SizedBox(height: 33),
                Text(
                  'Se connecter',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 50),

                textField.MytextField(
                  textInputTypeee: TextInputType.text,
                  ispassword: false,
                  hindtexttt: "Entrer votre Email :",
                  controller: emailController,
                  BackgroundColor: Colors.transparent,
                ),
                const SizedBox(height: 33),
                textField.MytextField(
                  textInputTypeee: TextInputType.text,
                  ispassword: true,
                  hindtexttt: "Entrer votre mot de passe :",
                  controller: passwordController,
                  BackgroundColor: Colors.transparent,
                ),

                const SizedBox(height: 33),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await FirebaseAuth.instance.signInWithEmailAndPassword(
                        email: emailController.text.trim(),
                        password: passwordController.text.trim(),
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomePage(),
                        ),
                      ); // Navigate to the home screen or dashboard
                    } catch (e) {
                      print('Error: $e');
                    }
                  },
                  child: const Text(
                    "Sign In",
                    style: TextStyle(fontSize: 19, color: Colors.white),
                  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(BTN500),
                    padding: MaterialStateProperty.all(
                      const EdgeInsets.all(12),
                    ),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 33),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Don’t have an account?',
                      style: TextStyle(fontSize: 18),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Register(),
                          ),
                        );
                      },
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(color: Colors.black, fontSize: 18),
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.center,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ForgetPassPage(),
                        ),
                      );
                    },
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
