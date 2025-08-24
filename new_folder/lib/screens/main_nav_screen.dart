// lib/screens/main_nav_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// Correctly import from your 'screens' folder
import 'package:serene_sense/screens/chat_screen.dart';
import 'package:serene_sense/screens/journal_list_screen.dart';
import 'package:serene_sense/screens/recommendations_screen.dart';

/// The main container screen for the app's core features, using a BottomNavigationBar.
/// This screen is the root of the logged-in user experience.
class MainNavScreen extends StatefulWidget {
  final int initialIndex;
  const MainNavScreen({super.key, this.initialIndex = 0});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  late int _selectedIndex;

  // --- THIS IS THE CRITICAL FIX ---
  // The list of widgets is now a 'late final' instance variable, NOT 'static const'.
  // This allows each tab to be a stateful object that can be preserved.
  late final List<Widget> _widgetOptions;
  // --- END OF CRITICAL FIX ---

  static const List<String> _appBarTitles = [
    'AI Companion',
    'My Journal',
    'For You',
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;

    // Initialize the list of widgets here. They will now be created only ONCE
    // for the lifetime of this MainNavScreen widget.
    _widgetOptions = const <Widget>[
      ChatScreen(),
      JournalListScreen(),
      RecommendationsScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _appBarTitles[_selectedIndex],
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1.0,
        foregroundColor: Colors.black87,
      ),
      // The IndexedStack correctly preserves the state of the non-const widgets.
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_rounded),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_stories_rounded),
            label: 'Journal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lightbulb_rounded),
            label: 'For You',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Theme.of(context).primaryColor,
      ),
    );
  }
}