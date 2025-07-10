import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:serene_sense/screens/auth_screen.dart'; // For logout
import 'package:serene_sense/screens/main_nav_screen.dart';
import 'package:serene_sense/screens/profile_screen.dart';
import 'package:serene_sense/utils/quotes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late String _dailyQuote;
  final String _userName = "Alex"; // Placeholder for the user's name

  @override
  void initState() {
    super.initState();
    _dailyQuote = getDailyQuote();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/images/logo.png', height: 40),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.grey[800]),
      ),
      // Extend the body behind the transparent AppBar
      extendBodyBehindAppBar: true,
      drawer: _buildAppDrawer(context),
      body: Container(
        // The new gradient background
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.teal.shade50, Colors.white, Colors.blue.shade50],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            children: [
              // 1. Personalized Header Card
              _buildHeader(context, _userName, _dailyQuote),
              const SizedBox(height: 32),
              
              // 2. Section Title
              Text(
                "How can I help you?",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),

              // 3. Redesigned Action Buttons
              _buildActionsRow(context),
              
              // You can add more sections here in the future
              // e.g., "Your recent journal entry", "Mood trends", etc.

            ].animate(interval: 100.ms).fadeIn(duration: 600.ms).slideY(begin: 0.2, curve: Curves.easeOut),
          ),
        ),
      ),
    );
  }

  /// The personalized header widget
  Widget _buildHeader(BuildContext context, String name, String quote) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Good Morning, $name",
            style: GoogleFonts.lato(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '"$quote"',
            style: GoogleFonts.lato(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: Colors.black54,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  /// The row of main action items
  Widget _buildActionsRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildActionItem(
          context: context,
          icon: Icons.chat_bubble_rounded,
          label: 'AI Chat',
          color: Colors.teal,
          onTap: () => _navigateTo(context, 0),
        ),
        _buildActionItem(
          context: context,
          icon: Icons.auto_stories_rounded,
          label: 'Journal',
          color: Colors.blue,
          onTap: () => _navigateTo(context, 1),
        ),
        _buildActionItem(
          context: context,
          icon: Icons.lightbulb_rounded,
          label: 'For You',
          color: Colors.purple,
          onTap: () => _navigateTo(context, 2),
        ),
      ],
    );
  }

  /// A single, beautifully styled action button
  Widget _buildActionItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
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
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: 12),
            Text(label, style: GoogleFonts.lato(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  /// Navigation logic remains the same
  void _navigateTo(BuildContext context, int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MainNavScreen(initialIndex: index),
      ),
    );
  }

  /// The new, enhanced App Drawer
  Widget _buildAppDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          _buildDrawerHeader(context, _userName, "alex.doe@example.com"),
          ListTile(
            leading: const Icon(Icons.person_outline_rounded),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ProfileScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Settings'),
            onTap: () { /* TODO: Navigate to Settings */ },
          ),
          const Spacer(), // Pushes the logout button to the bottom
          const Divider(),
          ListTile(
            leading: Icon(Icons.logout_rounded, color: Colors.red.shade700),
            title: Text('Logout', style: TextStyle(color: Colors.red.shade700)),
            onTap: () => _showLogoutDialog(context),
          ),
        ],
      ),
    );
  }

  /// The modern drawer header
  Widget _buildDrawerHeader(BuildContext context, String name, String email) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Theme.of(context).primaryColor, Colors.teal.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 35,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 40, color: Colors.teal),
          ),
          const SizedBox(height: 12),
          Text(name, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          Text(email, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
        ],
      ),
    );
  }

  /// Confirmation dialog for logging out
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
              onPressed: () {
                // Perform logout and navigate to AuthScreen
                Navigator.of(dialogContext).pop(); // Close dialog
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const AuthScreen()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }
}