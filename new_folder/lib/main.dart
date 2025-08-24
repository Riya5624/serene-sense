// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:serene_sense/firebase_options.dart';
import 'package:provider/provider.dart';

// Import all providers and services that need to be available globally
import 'package:serene_sense/providers/dass_result_provider.dart';
import 'package:serene_sense/providers/user_data_provider.dart';
import 'package:serene_sense/services/auth_service.dart';
import 'package:serene_sense/services/chat_service.dart';
import 'package:serene_sense/services/journal_service.dart';
import 'package:serene_sense/services/recommendation_service.dart';
import 'package:serene_sense/services/tts_service.dart';

// Import the initial screen of the app
import 'package:serene_sense/screens/logo_splash_screen.dart';

void main() async {
  // Ensure that Flutter bindings are initialized before calling native code.
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase for authentication and other backend services.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  runApp(
    // Use MultiProvider to make all app-wide services available to the widget tree.
    MultiProvider(
      providers: [
        // --- Independent Providers ---
        // These can be created without needing data from other providers.
        ChangeNotifierProvider(create: (context) => UserDataProvider()),
        ChangeNotifierProvider(create: (context) => JournalService()),
        ChangeNotifierProvider(create: (context) => DassResultProvider()),
        ChangeNotifierProvider(create: (context) => RecommendationService()),
        ChangeNotifierProvider(create: (context) => TtsService()),
        // A simple Provider for AuthService as it has no state that requires listeners.
        Provider(create: (context) => AuthService()),


        // --- Dependent Providers ---
        // ChangeNotifierProxyProvider2 is used because ChatService depends on TWO other providers.
        ChangeNotifierProxyProvider2<UserDataProvider, JournalService, ChatService>(
          
          // `create` is called once to create the initial service instance.
          // It provides both dependencies.
          create: (context) => ChatService(
            context.read<UserDataProvider>(),
            context.read<JournalService>(),
          ),
          
          // `update` is the crucial part that fixes the "restarting chat" bug.
          // It takes the PREVIOUS ChatService instance and updates its internal
          // references, returning the SAME instance instead of creating a new one.
          update: (context, userData, journalService, previousChatService) =>
              previousChatService!
                ..updateDependencies(userData, journalService),
        ),
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
      // The LogoSplashScreen handles the initial auth check and navigation.
      home: const LogoSplashScreen(),
    );
  }
}