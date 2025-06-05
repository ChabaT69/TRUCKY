import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trucky/screens/auth/login.dart';
import 'package:trucky/screens/home_screen.dart';
import 'package:trucky/config/colors.dart';
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo at the top
                    Image.asset(
                      'assets/images/logo.png',
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
                            hindtexttt: "Entrer votre nom ",
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
                            hindtexttt: "Entrer votre prénom ",
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
                      hindtexttt: "Entrer votre email ",
                      controller: emailController,
                      BackgroundColor: Colors.transparent,
                      validator: Validators.validateEmail,
                    ),
                    const SizedBox(height: 33),
                    // Password TextField
                    textField.MytextField(
                      textInputTypeee: TextInputType.text,
                      ispassword: true,
                      hindtexttt: "Entrer votre mot de passe ",
                      controller: passwordController,
                      BackgroundColor: Colors.transparent,
                      validator: Validators.validatePassword,
                    ),
                    const SizedBox(height: 33),
                    // Confirm Password TextField
                    textField.MytextField(
                      textInputTypeee: TextInputType.text,
                      ispassword: true,
                      hindtexttt: "Confirmer votre mot de passe ",
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
                            // Show loading indicator
                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      CircularProgressIndicator(),
                                      SizedBox(width: 20),
                                      Text(
                                        "Creation de votre compte en cours...",
                                      ),
                                    ],
                                  ),
                                  duration: Duration(seconds: 10),
                                ),
                              );

                            // Register the user
                            final userCredential = await FirebaseAuth.instance
                                .createUserWithEmailAndPassword(
                                  email: emailController.text.trim(),
                                  password: passwordController.text.trim(),
                                );

                            // Create user profile document
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(userCredential.user!.uid)
                                .set({
                                  'firstName': firstNameController.text.trim(),
                                  'lastName': lastNameController.text.trim(),
                                  'email': emailController.text.trim(),
                                  'createdAt': FieldValue.serverTimestamp(),
                                });

                            // Hide any active snackbars
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();

                            // Navigate to home and clear the stack
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HomePage(),
                              ),
                              (route) => false,
                            );
                          } catch (e) {
                            // Hide any active snackbars
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();

                            // Show error message
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Error: ${e.toString()}"),
                                backgroundColor: Colors.red,
                              ),
                            );
                            print('Registration error: $e');
                          }
                        }
                      },
                      child: const Text(
                        "S'inscrire",
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
                          style: TextStyle(fontSize: 17),
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
                            style: TextStyle(color: Colors.black, fontSize: 17),
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
