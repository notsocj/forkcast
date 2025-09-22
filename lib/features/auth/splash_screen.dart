import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants.dart';
import '../../services/persistent_auth_service.dart';
import '../core_features/main_navigation_wrapper.dart';
import 'get_started_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to the next screen after animation completes
    _navigateToHome();
  }

  void _navigateToHome() async {
    await Future.delayed(AppConstants.splashScreenDuration);
    
    if (mounted) {
      // Check if user should stay logged in
      final shouldStayLoggedIn = await PersistentAuthService.shouldStayLoggedIn();
      final currentUser = FirebaseAuth.instance.currentUser;
      
      // If remember me is enabled and user is authenticated, go directly to main app
      if (shouldStayLoggedIn && currentUser != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigationWrapper()),
        );
      } else {
        // Clear any stale auth data and go to get started page
        await PersistentAuthService.clearAuthData();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const GetStartedPage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Logo with Pop-up Effect
            Image.asset(
              AppConstants.logoPath,
              width: 150,
              height: 150,
            )
                .animate()
                .scale(
                  duration: 800.ms,
                  curve: Curves.elasticOut,
                  begin: const Offset(0, 0),
                  end: const Offset(1, 1),
                )
                .fadeIn(
                  duration: 600.ms,
                  delay: 200.ms,
                ),
            
            const SizedBox(height: 30),
            
            // FORKCAST Text with Montserrat Bold
            Text(
              AppConstants.appName,
              style: const TextStyle(
                fontFamily: AppConstants.headingFont,
                fontWeight: FontWeight.bold,
                fontSize: 28,
                color: AppColors.blackText,
                letterSpacing: 2.0,
              ),
            )
                .animate(delay: 1000.ms)
                .fadeIn(duration: 800.ms)
                .slideY(
                  begin: 0.3,
                  end: 0,
                  duration: 600.ms,
                  curve: Curves.easeOut,
                ),
            
            const SizedBox(height: 10),
            
            // Tagline
            Text(
              AppConstants.appDescription,
              style: const TextStyle(
                fontFamily: AppConstants.primaryFont,
                fontSize: 16,
                color: AppColors.grayText,
                letterSpacing: 0.5,
              ),
            )
                .animate(delay: 1800.ms)
                .fadeIn(duration: 800.ms)
                .slideY(
                  begin: 0.2,
                  end: 0,
                  duration: 500.ms,
                  curve: Curves.easeOut,
                ),
          ],
        ),
      ),
    );
  }
}