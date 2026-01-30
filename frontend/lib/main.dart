import 'package:flutter/material.dart';
import 'package:import_export_app/screens/splash_screen.dart'; // AJOUTER CETTE LIGNE

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Import Export App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SplashScreen(), // CHANGER LoginScreen par SplashScreen
      debugShowCheckedModeBanner: false,
    );
  }
}
