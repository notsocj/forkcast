// App-wide constants for ForkCast
class AppConstants {
  // App Info
  static const String appName = 'ForkCast';
  static const String appDescription = 'Personalized Meal Planning App';
  static const String appVersion = '1.0.0';
  
  // Animation Durations
  static const Duration splashScreenDuration = Duration(milliseconds: 3500);
  static const Duration standardAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 800);
  
  // Asset Paths
  static const String logoPath = 'assets/images/forkcast_logo.png';
  
  // Font Families
  static const String primaryFont = 'Lato';
  static const String headingFont = 'Montserrat';
  static const String bodyFont = 'OpenSans';
  
  // Prevent instantiation
  AppConstants._();
}