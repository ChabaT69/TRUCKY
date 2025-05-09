import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:trucky/screens/auth/bienvenue.dart';
import 'firebase_options.dart'; // NE PAS OUBLIER : généré par flutterfire configure

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trucky',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const Bienvenue(),
    );
  }
}
