import 'package:flutter/material.dart';
import 'package:touristai/screens/home_screen.dart';

void main() {
  runApp(const TouristAiApp());
}

class TouristAiApp extends StatelessWidget {
  const TouristAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TouristAI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F766E)),
        useMaterial3: true,
      ),
      home: HomeScreen(),
    );
  }
}
