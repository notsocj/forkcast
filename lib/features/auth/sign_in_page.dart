import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants.dart';
import 'forgot_password/forgot_password_page.dart';
import 'sign_up_page.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../services/persistent_auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core_features/main_navigation_wrapper.dart';
import '../professional/professional_navigation_wrapper.dart';
import '../admin/admin_navigation_wrapper.dart';
import '../profile_setup/name_entry_page.dart';
import '../professional/setup/professional_name_entry_page.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  bool _isLoading = false;
  bool _isProfessionalLogin = false;

  @override
  void initState() {
    super.initState();
    _loadStoredCredentials();
  }

  /// Load stored credentials if remember me was enabled
  Future<void> _loadStoredCredentials() async {
    final rememberMe = await PersistentAuthService.getRememberMeState();
    final storedEmail = await PersistentAuthService.getStoredEmail();
    
    if (rememberMe && storedEmail != null) {
      setState(() {
        _rememberMe = true;
        _emailController.text = storedEmail;
      });
    }
  }

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
                  
                  // Title with wave emoji
                  Row(
                    children: [
                      Text(
                        _isProfessionalLogin ? "Professional Login" : "Welcome Back!",
                        style: const TextStyle(
                          fontFamily: AppConstants.headingFont,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: AppColors.blackText,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isProfessionalLogin ? "🩺" : "👋",
                        style: const TextStyle(fontSize: 24),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Subtitle
                  Text(
                    _isProfessionalLogin 
                        ? "Sign in to access your professional dashboard"
                        : "Sign in to continue your journey towards a healthier you",
                    style: const TextStyle(
                      fontFamily: AppConstants.primaryFont,
                      fontSize: 14,
                      color: AppColors.grayText,
                      height: 1.4,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // User/Professional Toggle
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
                                _isProfessionalLogin = false;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: !_isProfessionalLogin ? AppColors.successGreen : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'User',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: AppConstants.primaryFont,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: !_isProfessionalLogin ? AppColors.white : AppColors.grayText,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _isProfessionalLogin = true;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _isProfessionalLogin ? AppColors.successGreen : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Professional',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: AppConstants.primaryFont,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _isProfessionalLogin ? AppColors.white : AppColors.grayText,
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
                      fillColor: AppColors.lightGray,
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
                      fillColor: AppColors.lightGray,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Remember Me and Forgot Password Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            onChanged: (value) {
                              setState(() {
                                _rememberMe = value ?? false;
                              });
                            },
                            activeColor: AppColors.successGreen,
                            side: const BorderSide(color: AppColors.grayText),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _rememberMe = !_rememberMe;
                              });
                            },
                            child: const Text(
                              "Remember me",
                              style: TextStyle(
                                fontFamily: AppConstants.primaryFont,
                                fontSize: 14,
                                color: AppColors.blackText,
                              ),
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
                          );
                        },
                        child: const Text(
                          "Forgot Password?",
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
                  
                  const SizedBox(height: 32),
                  
                  // Sign Up Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account? ",
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
                            MaterialPageRoute(builder: (context) => const SignUpPage()),
                          );
                        },
                        child: const Text(
                          "Sign up",
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
                      _buildSocialIcon(Icons.g_mobiledata, _handleGoogleSignIn),
                      const SizedBox(width: 16),
                      _buildSocialIcon(Icons.facebook, () {
                        // TODO: Implement Facebook login
                      }),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Sign In Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSignIn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.successGreen,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: AppColors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              "Sign in",
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

  void _handleSignIn() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      try {
        // Sign in with Firebase Auth
        final authService = AuthService();
        final userCredential = await authService.signIn(email, password);

        if (userCredential.user != null) {
          // Get user data from Firestore to check role
          final userService = UserService();
          final userData = await userService.getUser(userCredential.user!.uid);

          if (userData != null) {
            // Save remember me state and credentials
            await PersistentAuthService.saveRememberMeState(
              rememberMe: _rememberMe,
              email: email,
              userRole: userData.role,
            );

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Sign in successful!'),
                backgroundColor: AppColors.successGreen,
              ),
            );

            // Check if the user's role matches the selected login type
            final userRole = userData.role;
            final isUserProfessional = userRole == 'professional';
            final isUserAdmin = userRole == 'admin';
            final isUserRegular = userRole == 'user';
            
            // Validate login type against user role
            if (_isProfessionalLogin && !isUserProfessional) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('This account is not registered as a professional. Please use regular login.'),
                  backgroundColor: Colors.orange,
                ),
              );
              setState(() {
                _isLoading = false;
              });
              return;
            }
            
            // For user login, accept both 'user' and 'admin' roles
            if (!_isProfessionalLogin && !isUserRegular && !isUserAdmin) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('This is a professional account. Please use professional login.'),
                  backgroundColor: Colors.orange,
                ),
              );
              setState(() {
                _isLoading = false;
              });
              return;
            }

            // Navigate to appropriate navigation wrapper based on user role
            Widget navigationWrapper;
            if (isUserAdmin) {
              navigationWrapper = const AdminNavigationWrapper();
            } else if (isUserProfessional) {
              navigationWrapper = const ProfessionalNavigationWrapper();
            } else {
              navigationWrapper = const MainNavigationWrapper();
            }

            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => navigationWrapper),
              (route) => false,
            );
          } else {
            // User data not found in Firestore
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('User profile not found. Please contact support.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } on FirebaseAuthException catch (e) {
        String message = 'Sign in failed';
        if (e.code == 'user-not-found') {
          message = 'No user found for that email';
        } else if (e.code == 'wrong-password') {
          message = 'Wrong password provided';
        } else if (e.code == 'invalid-email') {
          message = 'Invalid email format';
        } else if (e.code == 'user-disabled') {
          message = 'This user account has been disabled';
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
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  // Handle Google Sign-In
  void _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authService = AuthService();
      final userCredential = await authService.signInWithGoogle();

      if (userCredential == null) {
        // User cancelled the sign-in
        setState(() {
          _isLoading = false;
        });
        return;
      }

      if (userCredential.user != null) {
        final userId = userCredential.user!.uid;
        
        // Check if user has completed profile setup
        final hasProfile = await authService.hasCompletedProfile(userId);
        
        if (!hasProfile) {
          // New Google user - redirect to profile setup
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Welcome! Please complete your profile setup.'),
              backgroundColor: AppColors.successGreen,
            ),
          );
          
          // Navigate to appropriate profile setup based on login type
          if (!mounted) return;
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => _isProfessionalLogin 
                  ? const ProfessionalNameEntryPage()
                  : const NameEntryPage(),
            ),
            (route) => false,
          );
          return;
        }

        // Existing user - check role and navigate
        final userService = UserService();
        final userData = await userService.getUser(userId);

        if (userData != null) {
          // Save remember me state
          await PersistentAuthService.saveRememberMeState(
            rememberMe: true,
            email: userCredential.user!.email ?? '',
            userRole: userData.role,
          );

          // Validate login type against user role
          final userRole = userData.role;
          final isUserProfessional = userRole == 'professional';
          final isUserAdmin = userRole == 'admin';
          final isUserRegular = userRole == 'user';
          
          if (_isProfessionalLogin && !isUserProfessional) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('This account is not registered as a professional. Please use regular login.'),
                backgroundColor: Colors.orange,
              ),
            );
            await authService.signOut();
            setState(() {
              _isLoading = false;
            });
            return;
          }
          
          if (!_isProfessionalLogin && !isUserRegular && !isUserAdmin) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('This is a professional account. Please use professional login.'),
                backgroundColor: Colors.orange,
              ),
            );
            await authService.signOut();
            setState(() {
              _isLoading = false;
            });
            return;
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sign in successful!'),
              backgroundColor: AppColors.successGreen,
            ),
          );

          // Navigate based on role
          Widget navigationWrapper;
          if (isUserAdmin) {
            navigationWrapper = const AdminNavigationWrapper();
          } else if (isUserProfessional) {
            navigationWrapper = const ProfessionalNavigationWrapper();
          } else {
            navigationWrapper = const MainNavigationWrapper();
          }

          if (!mounted) return;
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => navigationWrapper),
            (route) => false,
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Google Sign-In failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}