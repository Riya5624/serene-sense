enum Gender { male, female, other, preferNotToSay }

class UserProfile {
  final int age;
  final Gender gender;

  UserProfile({required this.age, required this.gender});
}