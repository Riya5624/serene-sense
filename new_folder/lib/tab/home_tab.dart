// lib/tabs/home_tab.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:serene_sense/providers/user_data_provider.dart';
import 'package:serene_sense/utils/quotes.dart';

class HomeTab extends StatefulWidget {
  // Callback to notify the parent (MainNavScreen) to switch tabs
  final Function(int) onNavigateToTab;
  const HomeTab({super.key, required this.onNavigateToTab});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  late String _dailyQuote;
  late String _greeting;

  @override
  void initState() {
    super.initState();
    _dailyQuote = getDailyQuote();
    _greeting = _getGreeting();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    // This widget still needs user data for the greeting
    final user = context.watch<UserDataProvider>().user;

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.teal.shade50, Colors.white, Colors.blue.shade50],
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        children: [
          _buildHeader(context, user.name, _dailyQuote),
          const SizedBox(height: 32),
          Text(
            "How can I help you?",
            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),
          _buildActionsRow(context),
        ].animate(interval: 100.ms).fadeIn(duration: 600.ms).slideY(begin: 0.2),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String name, String quote) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.teal.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$_greeting, $name", style: GoogleFonts.lato(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text('"$quote"', style: GoogleFonts.lato(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.black54, height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildActionsRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildActionItem(
          icon: Icons.chat_bubble_rounded,
          label: 'AI Chat',
          color: Colors.teal,
          onTap: () => widget.onNavigateToTab(1), // Navigate to Chat Tab (index 1)
        ),
        _buildActionItem(
          icon: Icons.auto_stories_rounded,
          label: 'Journal',
          color: Colors.blue,
          onTap: () => widget.onNavigateToTab(2), // Navigate to Journal Tab (index 2)
        ),
      ],
    );
  }

  Widget _buildActionItem({
    required IconData icon, required String label,
    required Color color, required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: 12),
            Text(label, style: GoogleFonts.lato(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}