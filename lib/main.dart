import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'features/auth/splash_screen.dart';

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
    return MaterialApp(
      title: 'ForkCast',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
