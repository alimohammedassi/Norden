import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/NordenIntroPage.dart'; // Import the intro page file

void main() {
  runApp(const NordenApp());
}

class NordenApp extends StatelessWidget {
  const NordenApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Norden',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF1A1A2E),
        scaffoldBackgroundColor: const Color(0xFF16213E),
        textTheme: GoogleFonts.interTextTheme(),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF0F3460),
          secondary: Color(0xFFE94560),
          surface: Color(0xFF16213E),
          background: Color(0xFF0F0F23),
        ),
      ),
      home: const NordenIntroPage(), // Start with intro page
    );
  }
}
