import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trucky/screens/auth/forgetpass.dart';
import 'package:trucky/screens/home_screen.dart';

import '../../config/colors.dart';
import 'register.dart';
import 'package:trucky/widgets/common/app_text_field.dart' as textField;

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: BTN100,
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(33.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    width: 200,
                    height: 200,
                  ),
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
                    hindtexttt: "Entrer votre Email ",
                    controller: emailController,
                    BackgroundColor: Colors.transparent,
                  ),
                  const SizedBox(height: 33),
                  textField.MytextField(
                    textInputTypeee: TextInputType.text,
                    ispassword: true,
                    hindtexttt: "Entrer votre mot de passe ",
                    controller: passwordController,
                    BackgroundColor: Colors.transparent,
                  ),
                  const SizedBox(height: 33),
                  ElevatedButton(
                    onPressed: () async {
                      if (Firebase.apps.isEmpty) {
                        await Firebase.initializeApp();
                      }
                      try {
                        await FirebaseAuth.instance.signInWithEmailAndPassword(
                          email: emailController.text.trim(),
                          password: passwordController.text.trim(),
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => HomePage()),
                        );
                      } on FirebaseAuthException catch (authError) {
                        String message =
                            authError.code == 'wrong-password'
                                ? 'Wrong password'
                                : 'Error: ${authError.message}';
                        ScaffoldMessenger.of(context)
                          ..removeCurrentSnackBar()
                          ..showSnackBar(SnackBar(content: Text(message)));
                      } catch (e) {
                        ScaffoldMessenger.of(context)
                          ..removeCurrentSnackBar()
                          ..showSnackBar(SnackBar(content: Text("Error: $e")));
                        log(e.toString());
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
                        'Vous n’avez pas de compte ?',
                        style: TextStyle(fontSize: 15),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Register()),
                          );
                        },
                        child: const Text(
                          "S'inscrire",
                          style: TextStyle(color: Colors.black, fontSize: 15),
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
                        'Mot de passe oublié ?',
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
      ),
    );
  }
}
