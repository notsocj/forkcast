import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants.dart';
import 'sign_in_page.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../profile_setup/name_entry_page.dart';
import '../professional/setup/professional_name_entry_page.dart'; 

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _agreeToTerms = false;
  bool _isProfessionalSignup = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.blackText,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  
                  // Title with star emoji
                  Row(
                    children: [
                      Text(
                        _isProfessionalSignup ? "Join as Professional!" : "Join Forkcast Today!",
                        style: const TextStyle(
                          fontFamily: AppConstants.headingFont,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: AppColors.blackText,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isProfessionalSignup ? "🩺" : "⭐",
                        style: const TextStyle(fontSize: 24),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Subtitle
                  Text(
                    _isProfessionalSignup 
                        ? "Create a professional account to provide nutrition consultations and help users achieve their health goals."
                        : "Create a forkcast account to receive personalized meal plans, prevent malnutrition, unhealthy food choices and achieve your health goals.",
                    style: const TextStyle(
                      fontFamily: AppConstants.primaryFont,
                      fontSize: 14,
                      color: AppColors.grayText,
                      height: 1.4,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Professional/User Toggle
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.successGreen.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _isProfessionalSignup = false;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: !_isProfessionalSignup ? AppColors.successGreen : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'User',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: AppConstants.primaryFont,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: !_isProfessionalSignup ? AppColors.white : AppColors.grayText,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _isProfessionalSignup = true;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _isProfessionalSignup ? AppColors.successGreen : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Professional',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: AppConstants.primaryFont,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _isProfessionalSignup ? AppColors.white : AppColors.grayText,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Email Field
                  Text(
                    "Email",
                    style: const TextStyle(
                      fontFamily: AppConstants.primaryFont,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.blackText,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: "Email",
                      hintStyle: const TextStyle(
                        color: AppColors.grayText,
                        fontFamily: AppConstants.primaryFont,
                      ),
                      prefixIcon: const Icon(
                        Icons.email_outlined,
                        color: AppColors.grayText,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.grayText),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.grayText),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.primaryAccent),
                      ),
                      filled: true,
                      fillColor: AppColors.white,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Password Field
                  Text(
                    "Password",
                    style: const TextStyle(
                      fontFamily: AppConstants.primaryFont,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.blackText,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      hintText: "Password",
                      hintStyle: const TextStyle(
                        color: AppColors.grayText,
                        fontFamily: AppConstants.primaryFont,
                      ),
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: AppColors.grayText,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          color: AppColors.grayText,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.grayText),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.grayText),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.primaryAccent),
                      ),
                      filled: true,
                      fillColor: AppColors.white,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Terms and Conditions Checkbox
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _agreeToTerms,
                        onChanged: (value) {
                          setState(() {
                            _agreeToTerms = value ?? false;
                          });
                        },
                        activeColor: AppColors.successGreen,
                        side: const BorderSide(color: AppColors.grayText),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _agreeToTerms = !_agreeToTerms;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(top: 12.0),
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  fontFamily: AppConstants.primaryFont,
                                  fontSize: 14,
                                  color: AppColors.blackText,
                                ),
                                children: [
                                  const TextSpan(text: "I Agree to Forkcast "),
                                  TextSpan(
                                    text: "Terms & Conditions",
                                    style: const TextStyle(
                                      color: AppColors.successGreen,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Sign In Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have an account? ",
                        style: TextStyle(
                          fontFamily: AppConstants.primaryFont,
                          fontSize: 14,
                          color: AppColors.grayText,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const SignInPage()),
                          );
                        },
                        child: const Text(
                          "Sign in",
                          style: TextStyle(
                            fontFamily: AppConstants.primaryFont,
                            fontSize: 14,
                            color: AppColors.successGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // OR Continue With Divider
                  Row(
                    children: [
                      const Expanded(
                        child: Divider(color: AppColors.grayText),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          "or continue with",
                          style: const TextStyle(
                            fontFamily: AppConstants.primaryFont,
                            fontSize: 14,
                            color: AppColors.grayText,
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Divider(color: AppColors.grayText),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Social Login Icons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialIcon(Icons.g_mobiledata, () {
                        // TODO: Implement Google login
                      }),
                      const SizedBox(width: 16),
                      _buildSocialIcon(Icons.facebook, () {
                        // TODO: Implement Facebook login
                      }),
                      const SizedBox(width: 16),
                      _buildSocialIcon(Icons.apple, () {
                        // TODO: Implement Apple login
                      }),
                      const SizedBox(width: 16),
                      _buildSocialIcon(Icons.close, () {
                        // TODO: Implement X (Twitter) login
                      }),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Sign Up Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _agreeToTerms ? _handleSignUp : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _agreeToTerms 
                            ? AppColors.successGreen 
                            : AppColors.grayText,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text(
                        "Sign up",
                        style: TextStyle(
                          fontFamily: AppConstants.primaryFont,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.grayText, width: 0.5),
          borderRadius: BorderRadius.circular(8),
          color: AppColors.white,
        ),
        child: Icon(
          icon,
          color: AppColors.blackText,
          size: 24,
        ),
      ),
    );
  }

  void _handleSignUp() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      try {
        // Create user in Firebase Auth
        final authService = AuthService();
        final userCredential = await authService.signUp(email, password);
        final userId = userCredential.user?.uid;

        if (userId != null) {
          // Create user document in Firestore with role based on signup type
          final userService = UserService();
          await userService.createUser(
            userId: userId,
            fullName: '', // Will be filled in profile setup
            email: email,
            passwordHash: '', // Do not store plain password, can use hash if needed
            gender: '',
            birthdate: DateTime.now(),
            heightCm: 0,
            weightKg: 0,
            householdSize: 1,
            weeklyBudgetMin: 0,
            weeklyBudgetMax: 0,
            role: _isProfessionalSignup ? 'professional' : 'user',
            specialization: _isProfessionalSignup ? 'Nutritionist' : null, // Default specialization for professionals
            createdAt: DateTime.now(),
            phoneNumber: null,
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isProfessionalSignup 
                ? 'Professional account created!' 
                : 'Account created!'),
              backgroundColor: AppColors.successGreen,
            ),
          );

          // Navigate to appropriate setup flow based on user type
          if (_isProfessionalSignup) {
            // Navigate to professional setup flow
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ProfessionalNameEntryPage()),
            );
          } else {
            // Navigate to regular user profile setup
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const NameEntryPage()),
            );
          }
        }
      } on FirebaseAuthException catch (e) {
        String message = 'Sign up failed';
        if (e.code == 'email-already-in-use') {
          message = 'Email already in use';
        } else if (e.code == 'weak-password') {
          message = 'Password is too weak';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}