// lib/providers/user_data_provider.dart

import 'package:flutter/material.dart';
import '../models/user_model.dart';

class UserDataProvider with ChangeNotifier {
  UserModel? _user;

  UserModel? get user => _user;

  void updateUserDetails({
    required String name,
    required String age,
    required String gender,
    required String education,
    required String maritalStatus,
  }) {
    _user = UserModel(
      name: name,
      age: int.tryParse(age) ?? 0,
      gender: gender,
      education: education,
      maritalStatus: maritalStatus,
      // You would get the real email after a full authentication flow
      email: name.toLowerCase().replaceAll(' ', '.') + '@example.com',
    );
    
    // This is the crucial part that tells listening widgets to rebuild
    notifyListeners();
  }
}