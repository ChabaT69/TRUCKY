import 'package:firebase_auth/firebase_auth.dart';

class AuthUtils {
  // Get the current user ID safely for UI components
  static String getCurrentUserId() {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null || userId.isEmpty) {
      print('WARNING: No user ID available');
      // This fallback is just for debugging purposes
      return 'anonymous_user';
    }

    return userId;
  }
}
