import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contact Book',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          primary: const Color(0xFF6750A4),
          secondary: const Color(0xFF03DAC6),
          tertiary: const Color(0xFFEFB8C8),
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Color(0xFF6750A4),
          foregroundColor: Colors.white,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF03DAC6),
          foregroundColor: Colors.white,
        ),
        navigationRailTheme: const NavigationRailThemeData(
          backgroundColor: Color(0xFF6750A4),
          selectedIconTheme: IconThemeData(color: Colors.white),
          unselectedIconTheme: IconThemeData(color: Colors.white70),
          selectedLabelTextStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelTextStyle: TextStyle(color: Colors.white70),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}