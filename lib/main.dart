import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:trucky/screens/auth/bienvenue.dart';
import 'screens/auth/login.dart';
import 'utils/firebase_initializer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
