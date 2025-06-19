import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:trucky/screens/auth/wrapper.dart';
import 'firebase_options.dart';
import 'services/notification_service.dart'; // Import your notification service

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with the correct options
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('Error initializing Firebase: $e');
  }

  // Configure Firebase Storage settings
  FirebaseStorage.instance.setMaxUploadRetryTime(Duration(seconds: 10));
  FirebaseStorage.instance.setMaxOperationRetryTime(Duration(seconds: 10));

  // Initialize notifications
  final notificationService = NotificationService();
  await notificationService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tracky',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const Wrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}
