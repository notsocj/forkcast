import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants.dart';
import '../sign_in_page.dart';

class AllSetPage extends StatelessWidget {
  const AllSetPage({super.key});

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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              // Success Icon (use lock with check)
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.grayText.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(Icons.lock, size: 60, color: AppColors.successGreen),
                    Positioned(
                      bottom: 18,
                      right: 18,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.successGreen,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(4),
                        child: const Icon(Icons.check, size: 20, color: AppColors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Title
              Text(
                "You're All Set!",
                style: const TextStyle(
                  fontFamily: AppConstants.headingFont,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: AppColors.blackText,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              // Subtitle
              Text(
                "You've successfully changed your password",
                style: const TextStyle(
                  fontFamily: AppConstants.primaryFont,
                  fontSize: 15,
                  color: AppColors.grayText,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              // Sign in Button at bottom
              SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const SignInPage()),
                        (route) => false,
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
                      "Sign in",
                      style: TextStyle(
                        fontFamily: AppConstants.primaryFont,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
