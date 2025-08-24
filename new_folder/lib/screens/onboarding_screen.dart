// lib/screens/onboarding_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:serene_sense/screens/personal_details_screen.dart'; // Updated import

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // We've added a color to each data map for our custom illustrations.
  final List<Map<String, dynamic>> _onboardingData = [
    {
      'title': 'Conversational AI Therapy',
      'description':
          'Engage with our AI chatbot trained in CBT methods to navigate your thoughts and feelings.',
      'icon': Icons.chat_bubble_rounded,
      'color': Colors.teal.shade300,
    },
    {
      'title': 'Insightful Journaling',
      'description':
          'Track your mood and uncover patterns with sentiment-aware journaling and analysis.',
      'icon': Icons.book_rounded,
      'color': Colors.blue.shade300,
    },
    {
      'title': 'Personalized For You',
      'description':
          'Receive recommendations for music, tasks, and exercises tailored to your mood.',
      'icon': Icons.lightbulb_rounded,
      'color': Colors.purple.shade300,
    }
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Main content PageView
            PageView.builder(
              controller: _pageController,
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              itemCount: _onboardingData.length,
              itemBuilder: (context, index) {
                final item = _onboardingData[index];
                // The key is crucial for re-triggering animations on page swipe
                return OnboardingPage(
                  key: ValueKey(_currentPage),
                  title: item['title'],
                  description: item['description'],
                  // We build the "illustration" widget here
                  illustration: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      color: (item['color'] as Color).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(item['icon'],
                          size: 120, color: item['color']),
                    ),
                  ),
                );
              },
            ),

            // Top "Skip" button
            Positioned(
              top: 16,
              right: 16,
              child: TextButton(
                onPressed: _finishOnboarding,
                child: const Text('Skip', style: TextStyle(fontSize: 16)),
              ),
            ),

            // Bottom controls (dots and next button)
            Positioned(
              bottom: 30,
              left: 24,
              right: 24,
              child: _buildFooterControls(),
            ),
          ],
        ),
      ),
    );
  }

  /// The footer containing page indicator dots and the next/done button.
  Widget _buildFooterControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Page indicator dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _onboardingData.length,
            (index) => buildDot(index),
          ),
        ),
        // Next/Done button
        FloatingActionButton(
          onPressed: _onNextTapped,
          elevation: 2,
          child: Icon(
            _currentPage == _onboardingData.length - 1
                ? Icons.check
                : Icons.arrow_forward_ios,
          ),
        ),
      ],
    );
  }

  /// Builds a single animated dot for the page indicator.
  Widget buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      height: 10,
      width: _currentPage == index ? 30 : 10,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: _currentPage == index
            ? Theme.of(context).primaryColor
            : Colors.grey.shade300,
      ),
    );
  }

  /// Logic for the next/done button.
  void _onNextTapped() {
    if (_currentPage == _onboardingData.length - 1) {
      _finishOnboarding();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Navigates to the personal details screen.
  void _finishOnboarding() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const PersonalDetailsScreen()),
    );
  }
}

// The new, animated content page
class OnboardingPage extends StatelessWidget {
  final String title;
  final String description;
  final Widget illustration;

  const OnboardingPage({
    super.key,
    required this.title,
    required this.description,
    required this.illustration,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration with fade and scale animation
          illustration.animate().fadeIn(duration: 600.ms).scale(
                duration: 600.ms,
                begin: const Offset(0.8, 0.8),
                curve: Curves.easeOutBack,
              ),
          const SizedBox(height: 60),
          // Title with fade and slide animation
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          )
              .animate()
              .fadeIn(delay: 200.ms, duration: 600.ms)
              .slideY(begin: 0.2, duration: 600.ms, curve: Curves.easeOut),
          const SizedBox(height: 16),
          // Description with fade and slide animation
          Text(
            description,
            textAlign: TextAlign.center,
            style: GoogleFonts.lato(
              fontSize: 16,
              color: Colors.grey[700],
              height: 1.5, // Improved line spacing for readability
            ),
          )
              .animate()
              .fadeIn(delay: 300.ms, duration: 600.ms)
              .slideY(begin: 0.2, duration: 600.ms, curve: Curves.easeOut),
        ],
      ),
    );
  }
}