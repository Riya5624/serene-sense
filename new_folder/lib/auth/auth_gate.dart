// lib/auth/auth_gate.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:serene_sense/auth/login_or_register.dart'; // Change your_app_name
import 'package:serene_sense/screens/personal_details_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // User is logged in
          if (snapshot.hasData) {
            print("logged in");
            return const PersonalDetailsScreen();
          }
          // User is NOT logged in
          else {
            print("logged out");
            return const LoginOrRegister();
          }
        },
      ),
    );
  }
}
