import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/constants.dart';

// Import all your screens here
import '../features/auth/splash_screen.dart';
import '../features/auth/get_started_page.dart';
import '../features/auth/sign_in_page.dart';
import '../features/auth/sign_up_page.dart';
import '../features/auth/forgot_password/forgot_password_page.dart';
import '../features/auth/forgot_password/otp_code_page.dart';
import '../features/auth/forgot_password/create_new_password_page.dart';
import '../features/auth/forgot_password/all_set_page.dart';
import '../features/profile_setup/name_entry_page.dart';

class DebugScreenSwitcher extends StatelessWidget {
  const DebugScreenSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        title: const Text(
          "🐛 Debug Screen Switcher",
          style: TextStyle(
            fontFamily: AppConstants.headingFont,
            fontWeight: FontWeight.bold,
            color: AppColors.blackText,
          ),
        ),
        backgroundColor: AppColors.primaryBackground,
        elevation: 0,
        centerTitle: true,
        actions: [
          // Toggle back to normal flow
          IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const SplashScreen()),
              );
            },
            icon: const Icon(Icons.play_arrow, color: AppColors.successGreen),
            tooltip: "Switch to Normal Flow",
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Info
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primaryAccent.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppColors.primaryAccent,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Debug Mode Active",
                            style: TextStyle(
                              fontFamily: AppConstants.headingFont,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.blackText,
                            ),
                          ),
                          Text(
                            "Tap any screen below to preview it instantly",
                            style: TextStyle(
                              fontFamily: AppConstants.primaryFont,
                              fontSize: 14,
                              color: AppColors.grayText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Auth Screens
              _buildSectionTitle("Authentication Screens"),
              _buildScreenTile(
                context, 
                "Splash Screen", 
                "App startup with animations",
                Icons.auto_awesome,
                const SplashScreen(),
              ),
              _buildScreenTile(
                context, 
                "Get Started", 
                "Welcome page with sign-up options",
                Icons.waving_hand,
                const GetStartedPage(),
              ),
              _buildScreenTile(
                context, 
                "Sign In", 
                "User login form",
                Icons.login,
                const SignInPage(),
              ),
              _buildScreenTile(
                context, 
                "Sign Up", 
                "User registration form",
                Icons.person_add,
                const SignUpPage(),
              ),
              
              const SizedBox(height: 20),
              
              // Password Reset Flow
              _buildSectionTitle("Password Reset Flow"),
              _buildScreenTile(
                context, 
                "Forgot Password", 
                "Email input for password reset",
                Icons.email,
                const ForgotPasswordPage(),
              ),
              _buildScreenTile(
                context, 
                "OTP Code", 
                "Enter verification code",
                Icons.pin,
                const OTPCodePage(email: "test@example.com"),
              ),
              _buildScreenTile(
                context, 
                "New Password", 
                "Create new password",
                Icons.lock_reset,
                const CreateNewPasswordPage(),
              ),
              _buildScreenTile(
                context, 
                "All Set", 
                "Password reset success",
                Icons.check_circle,
                const AllSetPage(),
              ),
              
              const SizedBox(height: 20),
              
              // Profile Setup
              _buildSectionTitle("Profile Setup"),
              _buildScreenTile(
                context, 
                "Name Entry", 
                "Enter user's full name",
                Icons.person,
                const NameEntryPage(),
              ),
              
              const SizedBox(height: 20),
              
              // Coming Soon
              _buildSectionTitle("Coming Soon"),
              _buildComingSoonTile("Gender Selection", "Choose gender preference"),
              _buildComingSoonTile("Birthday Entry", "Select date of birth"),
              _buildComingSoonTile("Height Input", "Enter height measurement"),
              _buildComingSoonTile("Weight Input", "Enter weight measurement"),
              _buildComingSoonTile("Budget Setup", "Set weekly budget range"),
              _buildComingSoonTile("Household Size", "Number of family members"),
              _buildComingSoonTile("Medical Conditions", "Health condition selection"),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: AppConstants.headingFont,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.blackText,
        ),
      ),
    );
  }

  Widget _buildScreenTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Widget screen,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      color: AppColors.white,
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.successGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppColors.successGreen,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: AppConstants.primaryFont,
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: AppColors.blackText,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontFamily: AppConstants.primaryFont,
            fontSize: 14,
            color: AppColors.grayText,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: AppColors.grayText,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => screen),
          );
        },
      ),
    );
  }

  Widget _buildComingSoonTile(String title, String subtitle) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      color: AppColors.grayText.withOpacity(0.1),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.grayText.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.construction,
            color: AppColors.grayText,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: AppConstants.primaryFont,
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: AppColors.grayText,
          ),
        ),
        subtitle: Text(
          "$subtitle (Coming Soon)",
          style: const TextStyle(
            fontFamily: AppConstants.primaryFont,
            fontSize: 14,
            color: AppColors.grayText,
          ),
        ),
        trailing: const Icon(
          Icons.schedule,
          size: 16,
          color: AppColors.grayText,
        ),
      ),
    );
  }
}