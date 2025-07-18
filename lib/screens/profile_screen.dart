import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:serene_sense/screens/auth_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Placeholder data
    const String userName = "Alex Doe";
    const String userEmail = "alex.doe@example.com";
    const int journalEntries = 15;
    const int moodsTracked = 42;

    return Scaffold(
      backgroundColor: Colors.grey[100], // A softer background color
      appBar: AppBar(
        title: Text('Profile', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      extendBodyBehindAppBar: true, // Allows the body to go behind the AppBar
      body: ListView(
        padding: EdgeInsets.zero, // Remove default padding
        children: [
          _buildProfileHeader(context, userName, userEmail),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle("Statistics"),
                const SizedBox(height: 12),
                _buildStatsSection(context, journalEntries, moodsTracked),
                const SizedBox(height: 24),
                _buildSectionTitle("General"),
                const SizedBox(height: 12),
                _buildOptionsSection(context),
                const SizedBox(height: 24),
                _buildLogoutButton(context),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ).animate().fadeIn(duration: 500.ms),
    );
  }

  /// The new, dynamic header section
  Widget _buildProfileHeader(BuildContext context, String name, String email) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 80, 20, 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundColor: Colors.teal,
            child: Icon(Icons.person_rounded, size: 50, color: Colors.white),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: GoogleFonts.lato(fontSize: 15, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () { /* TODO: Navigate to an Edit Profile screen */ },
            icon: Icon(Icons.edit_outlined, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  /// A simple, reusable section title
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.black54,
      ),
    );
  }

  /// The redesigned statistics section
  Widget _buildStatsSection(BuildContext context, int entries, int moods) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(context, 'Journal Entries', entries.toString()),
          Container(height: 40, width: 1, color: Colors.grey[200]), // Vertical divider
          _buildStatItem(context, 'Moods Tracked', moods.toString()),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.lato(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }

  /// The grouped options list
  Widget _buildOptionsSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildOptionItem(
            icon: Icons.settings_outlined,
            title: 'Account Settings',
            onTap: () {},
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _buildOptionItem(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            onTap: () {},
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _buildOptionItem(
            icon: Icons.help_outline,
            title: 'Help & Support',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildOptionItem({required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[700]),
      title: Text(title, style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }

  /// The dedicated, styled logout button
  Widget _buildLogoutButton(BuildContext context) {
    return OutlinedButton.icon(
      icon: const Icon(Icons.logout_rounded),
      label: const Text('Logout'),
      onPressed: () => _showLogoutDialog(context),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.red.shade700,
        side: BorderSide(color: Colors.red.shade200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  /// A reusable confirmation dialog for the logout action
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
              onPressed: () {
                Navigator.of(dialogContext).pop();
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