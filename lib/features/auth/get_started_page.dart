import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants.dart';
import 'sign_up_page.dart';
import 'sign_in_page.dart';

class GetStartedPage extends StatelessWidget {
  const GetStartedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 60),
                // ForkCast Logo
                Image.asset(
                  AppConstants.logoPath,
                  width: 80,
                  height: 80,
                ),
                const SizedBox(height: 16),
                // App Name
                Text(
                  AppConstants.appName.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: AppConstants.headingFont,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppColors.blackText,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 40),
                // Main Heading
                Text(
                  "Let's Get Started!",
                  style: const TextStyle(
                    fontFamily: AppConstants.headingFont,
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                    color: AppColors.blackText,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                // Subtitle
                Text(
                  "Let's dive in into your account",
                  style: const TextStyle(
                    fontFamily: AppConstants.primaryFont,
                    fontSize: 16,
                    color: AppColors.grayText,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                // Social Login Buttons
                _buildSocialButton(
                  context,
                  icon: Icons.g_mobiledata,
                  text: "Continue with Google",
                  onTap: () {
                    // TODO: Implement Google login
                  },
                ),
                const SizedBox(height: 16),
                _buildSocialButton(
                  context,
                  icon: Icons.facebook,
                  text: "Continue with Facebook",
                  onTap: () {
                    // TODO: Implement Facebook login
                  },
                ),
                const SizedBox(height: 16),
                _buildSocialButton(
                  context,
                  icon: Icons.apple,
                  text: "Continue with Apple",
                  onTap: () {
                    // TODO: Implement Apple login
                  },
                ),
                const SizedBox(height: 16),
                _buildSocialButton(
                  context,
                  icon: Icons.close, // Using close icon as X placeholder
                  text: "Continue with X",
                  onTap: () {
                    // TODO: Implement X (Twitter) login
                  },
                ),
                const SizedBox(height: 32),
                // Sign Up Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SignUpPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.successGreen,
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
                const SizedBox(height: 16),
                // Sign In Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SignInPage()),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.grayText),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      "Sign in",
                      style: TextStyle(
                        fontFamily: AppConstants.primaryFont,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.blackText,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Privacy Policy and Terms of Service
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: TextButton(
                        onPressed: () {
                          // TODO: Navigate to privacy policy
                        },
                        child: const Text(
                          "Privacy Policy",
                          style: TextStyle(
                            fontFamily: AppConstants.primaryFont,
                            fontSize: 14,
                            color: AppColors.grayText,
                            decoration: TextDecoration.underline,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(width: 32),
                    Flexible(
                      child: TextButton(
                        onPressed: () {
                          // TODO: Navigate to terms of service
                        },
                        child: const Text(
                          "Terms of Service",
                          style: TextStyle(
                            fontFamily: AppConstants.primaryFont,
                            fontSize: 14,
                            color: AppColors.grayText,
                            decoration: TextDecoration.underline,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(
    BuildContext context, {
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.grayText, width: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          backgroundColor: AppColors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: AppColors.blackText,
              size: 20,
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                text,
                style: const TextStyle(
                  fontFamily: AppConstants.primaryFont,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.blackText,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}