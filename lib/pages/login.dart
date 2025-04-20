import 'package:flutter/material.dart';

import '../shared/costumshared.dart';

class Login extends StatelessWidget {
  const Login({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(33.0),
          child: Column(
            children: [
              const SizedBox(height: 64),
              MytextField(
                textInputTypeee: TextInputType.emailAddress,
                ispassword: false,
                hindtexttt: "Entrer votre email :",
              ),
              const SizedBox(height: 33),
              MytextField(
                textInputTypeee: TextInputType.text,
                ispassword: true,
                hindtexttt: "Entrer votre mot de passe :",
              ),

              const SizedBox(height: 33),

              ElevatedButton(
                onPressed: () {},
                child: Text("click here", style: TextStyle(fontSize: 19)),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.orange),
                  padding: MaterialStateProperty.all(EdgeInsets.all(12)),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
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
