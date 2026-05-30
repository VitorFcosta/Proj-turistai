import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:touristai/screens/home_screen.dart';

void main() {
  runApp(const TouristAiApp());
}

class TouristAiApp extends StatelessWidget {
  const TouristAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseColorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF0052FF),
      primary: const Color(0xFF003EC7),
      secondary: const Color(0xFF3D6654),
      tertiary: const Color(0xFFBF3003),
      surface: const Color(0xFFF9F9F9),
    );

    return MaterialApp(
      title: 'TouristAI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: baseColorScheme,
        scaffoldBackgroundColor: const Color(0xFFF9F9F9),
        textTheme: GoogleFonts.interTextTheme().copyWith(
          headlineLarge: GoogleFonts.montserrat(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
          headlineMedium: GoogleFonts.montserrat(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
          headlineSmall: GoogleFonts.montserrat(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            height: 1.3,
          ),
          titleLarge: GoogleFonts.montserrat(fontWeight: FontWeight.w700),
          titleMedium: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
          titleSmall: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 1,
          shadowColor: const Color(0xFF003EC7).withValues(alpha: 0.06),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFE2E2E2)),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF003EC7),
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF003EC7),
            side: const BorderSide(color: Color(0xFFC3C5D9)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF3F3F3),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFC3C5D9)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFC3C5D9)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF0052FF), width: 2),
          ),
        ),
        useMaterial3: true,
      ),
      home: HomeScreen(),
    );
  }
}
