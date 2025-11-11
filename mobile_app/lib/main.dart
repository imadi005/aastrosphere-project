import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// Hum is screen ko agle step mein banayenge
import 'package:mobile_app/features/auth/screens/role_selection_screen.dart'; 

// ----- THEME COLORS -----
// Hum aapke web app wale brand colors use kar rahe hain
const Color kPrimaryColor = Color(0xFF0b0f1a); // Cosmic Navy
const Color kAccentColor = Color(0xFFd4a657); // Gold
const Color kTextColor = Color(0xFFf5f5f5);   // White
const Color kSecondaryTextColor = Color(0xFFa5a6ab); // Muted Gray
const Color kSurfaceColor = Color(0xFF101622); // Soft Contrast
// --------------------------

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aastrosphere',
      debugShowCheckedModeBanner: false, // Disables the "DEBUG" banner
      
      // ----- APP THEME -----
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: kPrimaryColor,
        primaryColor: kAccentColor,
        
        // Font Theme (Inter for body, Cinzel for headings)
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme).apply(
          bodyColor: kTextColor,
          displayColor: kTextColor,
        ).copyWith(
          // Cinzel for Headings
          headlineSmall: GoogleFonts.cinzel(
            color: kAccentColor,
            fontWeight: FontWeight.bold,
          ),
          headlineMedium: GoogleFonts.cinzel(
            color: kAccentColor,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
          headlineLarge: GoogleFonts.cinzel(
            color: kAccentColor,
            fontWeight: FontWeight.bold,
          ),
          // Cinzel for Titles
          titleLarge: GoogleFonts.cinzel(
            color: kTextColor,
            fontWeight: FontWeight.w600,
          ),
        ),

        // App Bar Theme
        appBarTheme: const AppBarTheme(
          backgroundColor: kPrimaryColor,
          elevation: 0,
          centerTitle: true,
        ),
      ),
      // -----------------------

      // Hamara Home Page ab yeh nayi screen hai
      home: const RoleSelectionScreen(),
    );
  }
}