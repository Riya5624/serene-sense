import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:serene_sense/screens/home_screen.dart';
import 'package:serene_sense/services/auth_service.dart'; // Import the service

// Converted to a StatefulWidget to manage state (loading, errors)
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // Use a final instance of the service
  final AuthService _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- Helper method for showing snackbar errors ---
  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // --- Logic for Email & Password Sign In ---
  Future<void> _signInWithEmail() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showErrorSnackBar("Please enter both email and password.");
      return;
    }
    setState(() => _isLoading = true);

    try {
      final user = await _authService.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (user != null && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        // The service returns null on failure, we can show a generic error
        _showErrorSnackBar("Login failed. Please check your credentials.");
      }
    } catch (e) {
      _showErrorSnackBar("An unexpected error occurred: ${e.toString()}");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // --- Logic for Google Sign In ---
  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      final user = await _authService.signInWithGoogle();
      if (user != null && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
      // Note: If the user cancels the Google Sign-In, `user` will be null.
      // We don't need to show an error in that case. The loading state will just reset.
    } catch (e) {
      _showErrorSnackBar("Google Sign-In failed: ${e.toString()}");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // A softer, calmer background
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 32.0,
              vertical: 40.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- 1. Header Section ---
                Image.asset('assets/images/logo.png', height: 80),
                const SizedBox(height: 24),
                Text(
                  'Welcome Back',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to continue your journey.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 48),

                // --- 2. Form Fields ---
                TextFormField(
                  controller: _emailController,
                  decoration: _buildInputDecoration(
                    hintText: 'Email',
                    icon: Icons.email_outlined,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  enabled: !_isLoading, // Disable when loading
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: _buildInputDecoration(
                    hintText: 'Password',
                    icon: Icons.lock_outline,
                  ),
                  obscureText: true,
                  enabled: !_isLoading, // Disable when loading
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            // TODO: Implement Forgot Password logic
                          },
                    child: const Text('Forgot Password?'),
                  ),
                ),
                const SizedBox(height: 24),

                // --- 3. Login Button ---
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape:
                        const StadiumBorder(), // A modern, rounded pill shape
                  ),
                  onPressed: _isLoading
                      ? null
                      : _signInWithEmail, // Call our login method
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : Text(
                          'Login',
                          style: GoogleFonts.lato(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(height: 32),

                // --- 4. "OR" Divider ---
                _buildDivider(),
                const SizedBox(height: 24),

                // --- 5. Social Logins ---
                _buildSocialLoginButton(
                  label: 'Sign in with Google',
                  iconPath:
                      'assets/images/google_logo.png', // Make sure to have this asset
                  onPressed: _isLoading
                      ? null
                      : _signInWithGoogle, // Call our Google sign-in method
                ),
                const SizedBox(height: 12),
                _buildSocialLoginButton(
                  label: 'Sign in with Apple',
                  iconPath: 'assets/images/apple_logo.png', // And this one
                  onPressed: _isLoading
                      ? null
                      : () {
                          // TODO: Implement Apple Sign-In
                        },
                ),
                const SizedBox(height: 40),

                // --- 6. Register Link ---
                Center(
                  child: Text.rich(
                    TextSpan(
                      text: "Don't have an account? ",
                      style: GoogleFonts.lato(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                      children: [
                        TextSpan(
                          text: 'Register',
                          style: GoogleFonts.lato(
                            fontSize: 16,
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              // TODO: Navigate to a dedicated Register Screen or show a dialog
                            },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, curve: Curves.easeOut),
          ),
        ),
      ),
    );
  }

  // Helper methods remain the same
  InputDecoration _buildInputDecoration({
    required String hintText,
    required IconData icon,
  }) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: Colors.grey[500]),
      hintText: hintText,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.teal.shade400, width: 2),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text('OR', style: TextStyle(color: Colors.grey[600])),
        ),
        const Expanded(child: Divider(thickness: 1)),
      ],
    );
  }

  Widget _buildSocialLoginButton({
    required String label,
    required String iconPath,
    required VoidCallback? onPressed,
  }) {
    return OutlinedButton.icon(
      icon: Image.asset(iconPath, height: 24, width: 24),
      label: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        side: BorderSide(color: Colors.grey.shade300),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:serene_sense/screens/home_screen.dart';

// class AuthScreen extends StatelessWidget {
//   const AuthScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // In a real app, use TextEditingControllers to get the input values.
//      final _emailController = TextEditingController();
//      final _passwordController = TextEditingController();

//     return Scaffold(
//       backgroundColor: Colors.grey[50], // A softer, calmer background
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 // --- 1. Header Section ---
//                 Image.asset('assets/images/logo.png', height: 80),
//                 const SizedBox(height: 24),
//                 Text(
//                   'Welcome Back',
//                   textAlign: TextAlign.center,
//                   style: GoogleFonts.poppins(
//                     fontSize: 28,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   'Sign in to continue your journey.',
//                   textAlign: TextAlign.center,
//                   style: GoogleFonts.lato(
//                     fontSize: 16,
//                     color: Colors.grey[600],
//                   ),
//                 ),
//                 const SizedBox(height: 48),

//                 // --- 2. Form Fields ---
//                 TextFormField(
//                    controller: _emailController,
//                   decoration: _buildInputDecoration(hintText: 'Email', icon: Icons.email_outlined),
//                   keyboardType: TextInputType.emailAddress,
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                    controller: _passwordController,
//                   decoration: _buildInputDecoration(hintText: 'Password', icon: Icons.lock_outline),
//                   obscureText: true,
//                 ),
//                 const SizedBox(height: 12),
//                 Align(
//                   alignment: Alignment.centerRight,
//                   child: TextButton(
//                     onPressed: () {
//                       // TODO: Implement Forgot Password logic
//                     },
//                     child: const Text('Forgot Password?'),
//                   ),
//                 ),
//                 const SizedBox(height: 24),

//                 // --- 3. Login Button ---
//                 ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     shape: const StadiumBorder(), // A modern, rounded pill shape
//                   ),
//                   onPressed: () {
//                     // TODO: Implement real login logic
//                     Navigator.of(context).pushReplacement(
//                       MaterialPageRoute(builder: (context) => const HomeScreen()),
//                     );
//                   },
//                   child: Text('Login', style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold)),
//                 ),
//                 const SizedBox(height: 32),

//                 // --- 4. "OR" Divider ---
//                 _buildDivider(),
//                 const SizedBox(height: 24),

//                 // --- 5. Social Logins ---
//                 _buildSocialLoginButton(
//                   label: 'Sign in with Google',
//                   iconPath: 'assets/images/google_logo.png', // Make sure to have this asset
//                   onPressed: () {
//                     // TODO: Implement Google Sign-In
//                   },
//                 ),
//                 const SizedBox(height: 12),
//                 _buildSocialLoginButton(
//                   label: 'Sign in with Apple',
//                   iconPath: 'assets/images/apple_logo.png', // And this one
//                   onPressed: () {
//                     // TODO: Implement Apple Sign-In
//                   },
//                 ),
//                 const SizedBox(height: 40),

//                 // --- 6. Register Link ---
//                 Center(
//                   child: Text.rich(
//                     TextSpan(
//                       text: "Don't have an account? ",
//                       style: GoogleFonts.lato(fontSize: 16, color: Colors.black54),
//                       children: [
//                         TextSpan(
//                           text: 'Register',
//                           style: GoogleFonts.lato(
//                             fontSize: 16,
//                             color: Theme.of(context).primaryColor,
//                             fontWeight: FontWeight.bold,
//                           ),
//                           recognizer: TapGestureRecognizer()
//                             ..onTap = () {
//                               // TODO: Navigate to a dedicated Register Screen or show a dialog
//                             },
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, curve: Curves.easeOut),
//           ),
//         ),
//       ),
//     );
//   }

//   // Helper method to create consistent input decorations
//   InputDecoration _buildInputDecoration({required String hintText, required IconData icon}) {
//     return InputDecoration(
//       prefixIcon: Icon(icon, color: Colors.grey[500]),
//       hintText: hintText,
//       filled: true,
//       fillColor: Colors.white,
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide.none, // No border when not focused
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide(color: Colors.grey.shade300),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide(color: Colors.teal.shade400, width: 2),
//       ),
//     );
//   }

//   // Helper for the "OR" divider
//   Widget _buildDivider() {
//     return Row(
//       children: [
//         const Expanded(child: Divider(thickness: 1)),
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 8.0),
//           child: Text('OR', style: TextStyle(color: Colors.grey[600])),
//         ),
//         const Expanded(child: Divider(thickness: 1)),
//       ],
//     );
//   }

//   // Helper for social login buttons to reduce code duplication
//   Widget _buildSocialLoginButton({
//     required String label,
//     required String iconPath,
//     required VoidCallback onPressed,
//   }) {
//     return OutlinedButton.icon(
//       icon: Image.asset(iconPath, height: 24, width: 24),
//       label: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
//       onPressed: onPressed,
//       style: OutlinedButton.styleFrom(
//         padding: const EdgeInsets.symmetric(vertical: 12),
//         side: BorderSide(color: Colors.grey.shade300),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//       ),
//     );
//   }
// }
