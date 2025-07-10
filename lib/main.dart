import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:serene_sense/screens/logo_splash_screen.dart';
import 'package:serene_sense/services/chat_service.dart';
import 'package:serene_sense/services/recommendation_service.dart'; // <-- 1. IMPORT the new service
import 'package:serene_sense/services/journal_service.dart';
void main() {
  runApp(
    // 2. Use MultiProvider to register all your services
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ChatService()),
        ChangeNotifierProvider(create: (context) => RecommendationService()),
        ChangeNotifierProvider(create: (context) => JournalService()), // <-- ADD THIS
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Serene Sense',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.white,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: const LogoSplashScreen(),
    );
  }
}