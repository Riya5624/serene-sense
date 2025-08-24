import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:serene_sense/screens/onboarding_screen.dart';
import 'package:serene_sense/utils/quotes.dart';

class LogoSplashScreen extends StatefulWidget {
  const LogoSplashScreen({super.key});

  @override
  State<LogoSplashScreen> createState() => _LogoSplashScreenState();
}

class _LogoSplashScreenState extends State<LogoSplashScreen> {
  @override
  void initState() {
    super.initState();
    // The timer remains the same. It starts when the screen is built.
    // The animations will play within this 5-second window.
    Timer(
      const Duration(seconds: 5),
      () {
        if (mounted) { // Check if the widget is still in the tree
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const OnboardingScreen()),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // 1. The Look: A subtle gradient background for a premium feel
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.teal.shade50,
              Colors.white,
              Colors.white,
              Colors.teal.shade100,
            ],
            stops: const [0.0, 0.4, 0.6, 1.0],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 2. The Animation: Logo fades in and scales up
                Image.asset('assets/images/logo.png', height: 150)
                    .animate()
                    .fadeIn(duration: 1200.ms, curve: Curves.easeIn)
                    .scale(
                      delay: 200.ms,
                      duration: 1000.ms,
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1, 1),
                      curve: Curves.easeOutBack,
                    ),
                const SizedBox(height: 40),
                // 3. The Animation & Look: Quote fades and slides up after the logo
                Text(
                  '"${getDailyQuote()}"',
                  textAlign: TextAlign.center,
                  // Using Google Fonts for a more elegant look
                  style: GoogleFonts.lato(
                    fontSize: 19,
                    fontStyle: FontStyle.italic,
                    color: Colors.black54,
                    fontWeight: FontWeight.w400,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 800.ms, duration: 1000.ms)
                    .slideY(
                      begin: 0.5,
                      end: 0,
                      duration: 800.ms,
                      curve: Curves.easeOutCubic,
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}