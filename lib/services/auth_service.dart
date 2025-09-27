import 'package:firebase_auth/firebase_auth.dart';
import 'analytics_service.dart';
import 'user_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
  }

  User? get currentUser => _auth.currentUser;
}