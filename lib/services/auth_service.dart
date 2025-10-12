import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'analytics_service.dart';
import 'user_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<UserCredential> signUp(String email, String password) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    
    // Record signup activity for analytics
    if (userCredential.user != null) {
      // Wait a moment for user data to be saved in Firestore
      await Future.delayed(const Duration(seconds: 1));
      
      try {
        final userService = UserService();
        final userData = await userService.getUser(userCredential.user!.uid);
        if (userData != null) {
          await AnalyticsService.recordUserActivity(
            userId: userCredential.user!.uid,
            userName: userData.fullName,
            action: 'New user registration',
          );
        }
      } catch (e) {
        print('Error recording signup activity: $e');
      }
    }
    
    return userCredential;
  }

  Future<UserCredential> signIn(String email, String password) async {
    final userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
    
    // Record login activity for analytics
    if (userCredential.user != null) {
      try {
        await AnalyticsService.updateUserLastLogin(userCredential.user!.uid);
        
        // Also record login activity
        final userService = UserService();
        final userData = await userService.getUser(userCredential.user!.uid);
        if (userData != null) {
          await AnalyticsService.recordUserActivity(
            userId: userCredential.user!.uid,
            userName: userData.fullName,
            action: 'User login',
          );
        }
      } catch (e) {
        print('Error recording login activity: $e');
      }
    }
    
    return userCredential;
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  // Google Sign-In method
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the Google authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      // If user cancels the sign-in
      if (googleUser == null) {
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _auth.signInWithCredential(credential);
      
      // Record login activity for analytics
      if (userCredential.user != null) {
        try {
          await AnalyticsService.updateUserLastLogin(userCredential.user!.uid);
          
          // Check if user data exists in Firestore
          final userService = UserService();
          final userData = await userService.getUser(userCredential.user!.uid);
          
          if (userData != null) {
            await AnalyticsService.recordUserActivity(
              userId: userCredential.user!.uid,
              userName: userData.fullName,
              action: 'User login via Google',
            );
          }
        } catch (e) {
          print('Error recording Google login activity: $e');
        }
      }
      
      return userCredential;
    } catch (e) {
      print('Error signing in with Google: $e');
      rethrow;
    }
  }

  // Check if user has completed profile setup
  Future<bool> hasCompletedProfile(String userId) async {
    try {
      final userService = UserService();
      final userData = await userService.getUser(userId);
      
      // If user data doesn't exist or fullName is empty, profile is incomplete
      if (userData == null || userData.fullName.isEmpty) {
        return false;
      }
      
      // Check if essential fields are filled
      return userData.fullName.isNotEmpty && 
             userData.email.isNotEmpty;
    } catch (e) {
      print('Error checking profile completion: $e');
      return false;
    }
  }

  // Get user role from Firestore
  Future<String> getUserRole(String userId) async {
    try {
      final userService = UserService();
      final userData = await userService.getUser(userId);
      return userData?.role ?? 'user';
    } catch (e) {
      print('Error getting user role: $e');
      return 'user';
    }
  }

  // Change password functionality
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user is currently signed in');
    }

    // Reauthenticate the user with current password
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );

    try {
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'wrong-password':
          throw Exception('Current password is incorrect');
        case 'weak-password':
          throw Exception('New password is too weak');
        case 'requires-recent-login':
          throw Exception('Please sign in again before changing your password');
        default:
          throw Exception('Failed to change password: ${e.message}');
      }
    }
  }

  // Delete account functionality
  Future<void> deleteAccount(String currentPassword) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user is currently signed in');
    }

    // Reauthenticate the user with current password
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );

    try {
      await user.reauthenticateWithCredential(credential);
      
      // Delete user data from Firestore first
      final userService = UserService();
      await userService.deleteUser(user.uid);
      
      // Record account deletion activity
      try {
        final userData = await userService.getUser(user.uid);
        if (userData != null) {
          await AnalyticsService.recordUserActivity(
            userId: user.uid,
            userName: userData.fullName,
            action: 'Account deletion',
          );
        }
      } catch (e) {
        print('Error recording deletion activity: $e');
      }
      
      // Finally delete the Firebase Auth account
      await user.delete();
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'wrong-password':
          throw Exception('Current password is incorrect');
        case 'requires-recent-login':
          throw Exception('Please sign in again before deleting your account');
        default:
          throw Exception('Failed to delete account: ${e.message}');
      }
    }
  }

  User? get currentUser => _auth.currentUser;
}