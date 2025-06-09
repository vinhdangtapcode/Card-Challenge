import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/history_screen.dart';

void main() {
  runApp(const CardChallengeApp());
}

class CardChallengeApp extends StatelessWidget {
  const CardChallengeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Card Random',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        textTheme: GoogleFonts.robotoFlexTextTheme()
            .apply(bodyColor: const Color(0xFFFE6B6B), displayColor: const Color(0xFFFE6B6B)),
        primaryTextTheme: GoogleFonts.robotoFlexTextTheme()
            .apply(bodyColor: const Color(0xFFFE6B6B), displayColor: const Color(0xFFFE6B6B)),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const CardChallengeScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/history': (context) => const HistoryScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
