import 'package:flutter/material.dart';
import 'package:serene_sense/screens/chat_screen.dart';
import 'package:serene_sense/screens/journal_list_screen.dart';
import 'package:serene_sense/screens/recommendations_screen.dart';

class MainNavScreen extends StatefulWidget {
  final int initialIndex;
  const MainNavScreen({super.key, this.initialIndex = 0});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  static const List<Widget> _widgetOptions = <Widget>[
    ChatScreen(),
    JournalListScreen(),
    RecommendationsScreen(),
  ];

  static const List<String> _appBarTitles = <String>[
    'AI Chat',
    'My Journal',
    'For You',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitles.elementAt(_selectedIndex)),
        centerTitle: true,
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            activeIcon: Icon(Icons.book),
            label: 'Journal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lightbulb_outline),
            activeIcon: Icon(Icons.lightbulb),
            label: 'For You',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.teal[800],
      ),
    );
  }
}