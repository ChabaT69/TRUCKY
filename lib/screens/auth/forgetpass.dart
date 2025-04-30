import 'package:flutter/material.dart';
import '../../widgets/common/app_text_field.dart';
import '../../config/colors.dart';
import '../../services/auth_service.dart';

class ForgetPassPage extends StatefulWidget {
  const ForgetPassPage({Key? key}) : super(key: key);

  @override
  _ForgetPassPageState createState() => _ForgetPassPageState();
}

class _ForgetPassPageState extends State<ForgetPassPage> {
  final TextEditingController emailController = TextEditingController();
  bool isLoading = false;

  void resetPassword() async {
    setState(() {
      isLoading = true;
    });
    // Appel de reset password de AuthService
    await Future.delayed(Duration(seconds: 1));
    bool success = true;
    setState(() {
      isLoading = false;
    });
    final message =
        success
            ? "Please check your email for a reset link"
            : "Failed to reset password. Please try again.";
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BTN100,
      appBar: AppBar(
        title: const Text('Reset Password'),
        backgroundColor: BTN100,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 50),
            Image.asset(
              'assets/images/forgetpass.png',
              width: 400,
              height: 300,
            ),
            const SizedBox(height: 100),
            const Text(
              'Enter your email address to reset your password',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            MytextField(
              controller: emailController,
              hindtexttt: 'Email',
              textInputTypeee: TextInputType.emailAddress,
              ispassword: false,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: BTN500),
              onPressed: isLoading ? null : resetPassword,
              child:
                  isLoading
                      ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                      : const Text(
                        'Reset Password',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }
}
