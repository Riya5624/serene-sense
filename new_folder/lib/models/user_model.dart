// lib/models/user_model.dart

class UserModel {
  final String name;
  final int age;
  final String gender;
  final String education;
  final String maritalStatus;
  final String email; // Added email for the profile screen

  UserModel({
    required this.name,
    required this.age,
    required this.gender,
    required this.education,
    required this.maritalStatus,
    this.email = 'anonymous@serene.com', // Default email
  });
}