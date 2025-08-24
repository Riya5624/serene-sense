// lib/auth/login_or_register.dart

import 'package:flutter/material.dart';
import 'package:serene_sense/screens/login.dart';
import 'package:serene_sense/screens/register.dart';

class LoginOrRegister extends StatefulWidget {
  const LoginOrRegister({super.key});

  @override
  State<LoginOrRegister> createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegister> {
  // Initially, show the login page
  bool showLoginPage = true;

  // Toggle between login and register pages
  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      print('Login in page');
      return LoginPage(onTap: togglePages);
    } else {
      print('register page');
      return RegisterPage(onTap: togglePages);
    }
  }
}
