import 'package:flutter/material.dart';
import 'package:serene_sense/models/user_profile.dart';

class ProfileService with ChangeNotifier {
  // The profile data is stored here. In a real app, this would be loaded from
  // a persistent storage like SharedPreferences.
  UserProfile _userProfile = UserProfile(age: 25, gender: Gender.preferNotToSay);

  /// A public getter to allow other parts of the app to read the user profile.
  UserProfile get userProfile => _userProfile;

  /// Updates the user profile with new data and notifies any listening widgets.
  void updateUserProfile(int age, Gender gender) {
    _userProfile = UserProfile(age: age, gender: gender);
    
    // --- THIS IS THE CORRECTED LINE ---
    // The variable is now correctly capitalized as _userProfile.
    print("Profile Updated: Age - ${_userProfile.age}, Gender - ${_userProfile.gender.name}");
    
    // Notify any widgets that are 'watching' this service to rebuild.
    notifyListeners();
  }
}