import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing persistent authentication state
/// Handles remember me functionality for user convenience
class PersistentAuthService {
  static const String _keyRememberMe = 'remember_me';
  static const String _keyUserEmail = 'user_email';
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserRole = 'user_role';

  /// Save remember me state, user email, and user role
  static Future<void> saveRememberMeState({
    required bool rememberMe,
    required String email,
    String? userRole,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyRememberMe, rememberMe);
    
    if (rememberMe) {
      await prefs.setString(_keyUserEmail, email);
      await prefs.setBool(_keyIsLoggedIn, true);
      if (userRole != null) {
        await prefs.setString(_keyUserRole, userRole);
      }
    } else {
      // Clear stored data if remember me is disabled
      await prefs.remove(_keyUserEmail);
      await prefs.remove(_keyIsLoggedIn);
      await prefs.remove(_keyUserRole);
    }
  }

  /// Get stored remember me state
  static Future<bool> getRememberMeState() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyRememberMe) ?? false;
  }

  /// Get stored user email
  static Future<String?> getStoredEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserEmail);
  }

  /// Get stored user role
  static Future<String?> getStoredUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserRole);
  }

  /// Check if user should stay logged in
  static Future<bool> shouldStayLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool(_keyRememberMe) ?? false;
    final isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
    return rememberMe && isLoggedIn;
  }

  /// Clear all persistent auth data (for logout)
  static Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyRememberMe);
    await prefs.remove(_keyUserEmail);
    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keyUserRole);
  }

  /// Set logged in state (for manual control)
  static Future<void> setLoggedInState(bool isLoggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, isLoggedIn);
  }
}