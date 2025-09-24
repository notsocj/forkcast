import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'features/auth/splash_screen.dart';
import 'debug/debug_config.dart';
import 'debug/debug_screen_switcher.dart';
import 'providers/profile_setup_provider.dart';
import 'providers/professional_setup_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ForkCastApp());
}

class ForkCastApp extends StatelessWidget {
  const ForkCastApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProfileSetupProvider()),
        ChangeNotifierProvider(create: (_) => ProfessionalSetupProvider()),
        // Add more providers here as needed
      ],
      child: MaterialApp(
        title: 'ForkCast',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        // Toggle between debug mode and normal flow
        home: DebugConfig.enableDebugMode 
            ? const DebugScreenSwitcher() 
            : const SplashScreen(),
      ),
    );
  }
}
