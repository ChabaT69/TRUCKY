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
                hindtexttt: "Entrer votre mot de pa sse :",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
