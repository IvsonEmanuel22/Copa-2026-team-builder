import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const CopaScoutApp());
}

class CopaScoutApp extends StatelessWidget {
  const CopaScoutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Copa Scout 2026',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
