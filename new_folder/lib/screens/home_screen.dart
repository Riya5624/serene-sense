// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:serene_sense/providers/user_data_provider.dart';
import 'package:serene_sense/screens/auth_screen.dart';
import 'package:serene_sense/screens/main_nav_screen.dart';
import 'package:serene_sense/screens/profile_screen.dart';
import 'package:serene_sense/services/auth_service.dart';
import 'package:serene_sense/utils/quotes.dart';

/// The primary dashboard screen that the user sees after logging in.
/// It provides a personalized greeting and entry points to the app's main features.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late String _dailyQuote;
  late String _greeting;

  @override
  void initState() {
    super.initState();
    _dailyQuote = getDailyQuote();
    _greeting = _getGreeting();
  }

  /// A helper to get a greeting based on the time of day.
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserDataProvider>(
      builder: (context, userDataProvider, child) {
        if (userDataProvider.user == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        final user = userDataProvider.user!;

        return Scaffold(
          appBar: AppBar(
            title: Image.asset('assets/images/logo.png', height: 40),
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            iconTheme: IconThemeData(color: Colors.grey[800]),
          ),
          extendBodyBehindAppBar: true,
          drawer: _buildAppDrawer(context, user.name, user.email),
          body: Container(
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
                  _buildHeader(context, user.name, _dailyQuote),
                  const SizedBox(height: 32),
                  Text(
                    "How can I help you today?",
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildActionsRow(context),
                ].animate(interval: 100.ms).fadeIn(duration: 600.ms).slideY(begin: 0.2),
              ),
            ),
          ),
        );
      },
    );
  }

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
            "$_greeting, $name",
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

  Widget _buildActionsRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildActionItem(
          icon: Icons.chat_bubble_rounded,
          label: 'AI Chat',
          color: Colors.teal,
          onTap: () => _navigateTo(context, 0),
        ),
        _buildActionItem(
          icon: Icons.auto_stories_rounded,
          label: 'Journal',
          color: Colors.blue,
          onTap: () => _navigateTo(context, 1),
        ),
        _buildActionItem(
          icon: Icons.lightbulb_rounded,
          label: 'For You',
          color: Colors.purple,
          onTap: () => _navigateTo(context, 2),
        ),
      ],
    );
  }

  Widget _buildActionItem({
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

  /// Navigates to the main tabbed screen, opening the specified tab index.
  void _navigateTo(BuildContext context, int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MainNavScreen(initialIndex: index),
      ),
    );
  }

  Widget _buildAppDrawer(BuildContext context, String name, String email) {
    return Drawer(
      child: Column(
        children: [
          _buildDrawerHeader(context, name, email),
          ListTile(
            leading: const Icon(Icons.person_outline_rounded),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context); // Close the drawer first
              if (mounted) {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ProfileScreen()));
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Settings'),
            onTap: () { /* TODO: Navigate to Settings */ },
          ),
          const Spacer(),
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

  Widget _buildDrawerHeader(BuildContext context, String name, String email) {
    // Use UserAccountsDrawerHeader for a standard, well-formatted header.
    return UserAccountsDrawerHeader(
      accountName: Text(name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
      accountEmail: Text(email, style: GoogleFonts.lato()),
      currentAccountPicture: const CircleAvatar(
        backgroundColor: Colors.white,
        child: Icon(Icons.person, size: 40, color: Colors.teal),
      ),
      decoration: BoxDecoration(color: Theme.of(context).primaryColor),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                // Correctly use the provided AuthService instance.
                await context.read<AuthService>().signOut();
                
                if (mounted) {
                  // Navigate to the AuthScreen and remove all previous screens.
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const AuthScreen()),
                    (Route<dynamic> route) => false,
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}