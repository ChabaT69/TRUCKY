import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trucky/screens/auth/login.dart';
import 'package:trucky/screens/home_screen.dart';
import 'package:trucky/config/colors.dart';
import 'package:trucky/services/auth_service.dart';
import 'package:trucky/utils/validators.dart';
import 'package:trucky/widgets/common/app_text_field.dart' as textField;

class Register extends StatelessWidget {
  Register({Key? key}) : super(key: key);
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final TextEditingController firstNameController = TextEditingController();
    final TextEditingController lastNameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();

    return SafeArea(
      child: Scaffold(
        backgroundColor: BTN100,
        body: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(33.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo at the top
                    Image.asset(
                      'assets/images/logo.jpg',
                      width: 400,
                      height: 120,
                    ),
                    const SizedBox(height: 70),
                    const Text(
                      'S\'inscrire',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 33),
                    // Row with two TextFields: Nom et Prénom
                    Row(
                      children: [
                        Expanded(
                          child: textField.MytextField(
                            textInputTypeee: TextInputType.text,
                            ispassword: false,
                            hindtexttt: "Entrer votre nom :",
                            controller: firstNameController,
                            BackgroundColor: Colors.transparent,
                            validator: Validators.validateName,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: textField.MytextField(
                            textInputTypeee: TextInputType.text,
                            ispassword: false,
                            hindtexttt: "Entrer votre prénom :",
                            controller: lastNameController,
                            BackgroundColor: Colors.transparent,
                            validator: Validators.validateName,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 33),
                    // Email TextField
                    textField.MytextField(
                      textInputTypeee: TextInputType.emailAddress,
                      ispassword: false,
                      hindtexttt: "Entrer votre email :",
                      controller: emailController,
                      validator: Validators.validateEmail,
                    ),
                    const SizedBox(height: 33),
                    // Password TextField
                    textField.MytextField(
                      textInputTypeee: TextInputType.text,
                      ispassword: true,
                      hindtexttt: "Entrer votre mot de passe :",
                      controller: passwordController,
                      BackgroundColor: Colors.transparent,
                      validator: Validators.validatePassword,
                    ),
                    const SizedBox(height: 33),
                    // Confirm Password TextField
                    textField.MytextField(
                      textInputTypeee: TextInputType.text,
                      ispassword: true,
                      hindtexttt: "Confirmer votre mot de passe :",
                      controller: confirmPasswordController,
                      BackgroundColor: Colors.transparent,
                      validator:
                          (value) => Validators.validateConfirmPassword(
                            value,
                            original: passwordController.text,
                          ),
                    ),
                    const SizedBox(height: 33),
                    // Sign Up Button
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          try {
                            await AuthService.registerWithEmailAndPassword(
                              emailController.text.trim(),
                              passwordController.text.trim(),
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        HomeScreen(userId: 'currentUser'),
                              ),
                            );
                          } catch (e) {
                            print('Error: $e');
                          }
                        }
                      },
                      child: const Text(
                        "Sign Up",
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
                    // Already have an account? Sign In
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Vous avez déjà un compte ?',
                          style: TextStyle(fontSize: 18),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Login(),
                              ),
                            );
                          },
                          child: const Text(
                            'Se connecter',
                            style: TextStyle(color: Colors.black, fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
