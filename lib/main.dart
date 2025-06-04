import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:trucky/screens/auth/bienvenue.dart';
import 'services/notification_service.dart'; // Import your notification service

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize notifications
  final notificationService = NotificationService();
  await notificationService.init();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trucky',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Bienvenue(),
      debugShowCheckedModeBanner: false,
    );
  }
}
