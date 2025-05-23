import 'package:firebase_auth/firebase_auth.dart';

class DebugHelper {
  // Print auth state information
  static void printAuthState() {
    final auth = FirebaseAuth.instance;
    final user = auth.currentUser;

    print('==== Auth State ====');
    print('User logged in: ${user != null}');
    if (user != null) {
      print('User ID: ${user.uid}');
      print('User email: ${user.email}');
      print('User display name: ${user.displayName}');
      print('User phone: ${user.phoneNumber}');
      print('Email verified: ${user.emailVerified}');
    } else {
      print('No user is logged in');
    }
    print('===================');
  }
}
