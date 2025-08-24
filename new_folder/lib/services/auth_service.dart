// lib/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// A custom class to hold the result of an authentication action.
/// It includes the user and a flag to indicate if they are a new user.
class AuthResult {
  final User user;
  final bool isNewUser;

  AuthResult({required this.user, required this.isNewUser});
}

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// A stream to listen for real-time authentication state changes.
  /// Useful for automatically navigating the user when the app starts.
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // --- REGISTRATION ---

  /// Registers a new user with their email and password.
  Future<User?> registerWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      // Throw specific, user-friendly error messages
      if (e.code == 'weak-password') {
        throw Exception('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        throw Exception('An account already exists for that email.');
      }
      throw Exception('An error occurred during registration. Please try again.');
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  // --- SIGN IN ---

  /// Signs in a user with Google and determines if they are a new or returning user.
  Future<AuthResult?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null; // User canceled the sign-in
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);

      final bool isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
      
      return AuthResult(user: userCredential.user!, isNewUser: isNewUser);
    } catch (e) {
      // Re-throw the exception to be handled by the UI
      throw Exception('Google Sign-In failed. Please try again.');
    }
  }

  /// Signs in a user with their email and password.
  /// Assumes this is always a returning user.
  Future<AuthResult?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // For email/password sign-in, we assume they are not a new user.
      return AuthResult(user: userCredential.user!, isNewUser: false);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        throw Exception('Invalid email or password.');
      }
      throw Exception('An error occurred during login. Please try again.');
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  // --- SIGN OUT ---

  /// Signs the current user out from both Firebase and Google.
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      // It's good practice to handle potential errors even on sign-out
      print("Error signing out: $e");
    }
  }
}