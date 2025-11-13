import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
// NAYA IMPORT: Ab main.dart seedha splash screen ko jaanta hai
import 'package:mobile_app/features/splash/screens/splash_screen.dart'; 
import 'package:mobile_app/firebase_options.dart';

// Color constants (Same as before)
const Color kPrimaryColor = Color(0xFF0b0f1a); 
const Color kAccentColor = Color(0xFFd4a657); 
const Color kTextColor = Color(0xFFf5f5f5);   
const Color kSecondaryTextColor = Color(0xFFa5a6ab);
const Color kSurfaceColor = Color(0xFF101622); 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aastrosphere',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: kPrimaryColor,
        primaryColor: kAccentColor,
        colorScheme: const ColorScheme.dark(
          primary: kAccentColor,
          secondary: kAccentColor,
          surface: kSurfaceColor,
          background: kPrimaryColor,
          onPrimary: kPrimaryColor,
          onBackground: kTextColor,
          onSurface: kTextColor,
        ),
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme).apply(
          bodyColor: kTextColor,
          displayColor: kAccentColor,
        ).copyWith(
          // Cinzel font for headings
          headlineLarge: GoogleFonts.cinzel(
            fontWeight: FontWeight.bold,
            color: kAccentColor,
          ),
          headlineMedium: GoogleFonts.cinzel(
            fontWeight: FontWeight.bold,
            color: kAccentColor,
          ),
          headlineSmall: GoogleFonts.cinzel(
            fontWeight: FontWeight.bold,
            color: kAccentColor,
          ),
          titleLarge: GoogleFonts.cinzel(
            fontWeight: FontWeight.w600,
            color: kTextColor,
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: kAccentColor),
          titleTextStyle: TextStyle(
            color: kAccentColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      
      // YEH UPDATE HUA HAI
      // Humara home ab HAMESHA SplashScreen hai
      home: const SplashScreen(),
    );
  }
}