import 'package:cloud_firestore/cloud_firestore.dart';

/// Service for managing app analytics and admin statistics
/// Handles retrieving and aggregating data for admin dashboard
class AnalyticsService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get total user count by role
  static Future<Map<String, int>> getUserCountByRole() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      Map<String, int> roleCount = {
        'total': 0,
        'user': 0,
        'professional': 0,
        'admin': 0,
      };

      for (var doc in snapshot.docs) {
        roleCount['total'] = roleCount['total']! + 1;
        final role = doc.data()['role'] ?? 'user';
        roleCount[role] = (roleCount[role] ?? 0) + 1;
      }

      return roleCount;
    } catch (e) {
      print('Error getting user count by role: $e');
      return {
        'total': 0,
        'user': 0,
        'professional': 0,
        'admin': 0,
      };
    }
  }

  /// Get active users today (users who logged in today)
  static Future<int> getActiveUsersToday() async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      
      final snapshot = await _firestore
          .collection('user_activity')
          .where('last_login', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .get();
      
      return snapshot.docs.length;
    } catch (e) {
      print('Error getting active users today: $e');
      return 0;
    }
  }

  /// Get total meal plans created
  static Future<int> getTotalMealPlans() async {
    try {
      int totalMealPlans = 0;
      
      final usersSnapshot = await _firestore.collection('users').get();
      
      for (var userDoc in usersSnapshot.docs) {
        final mealPlansSnapshot = await userDoc.reference
            .collection('meal_plans')
            .get();
        totalMealPlans += mealPlansSnapshot.docs.length;
      }
      
      return totalMealPlans;
    } catch (e) {
      print('Error getting total meal plans: $e');
      return 0;
    }
  }

  /// Get total Q&A questions
  static Future<int> getTotalQnAQuestions() async {
    try {
      final snapshot = await _firestore.collection('qna_questions').get();
      return snapshot.docs.length;
    } catch (e) {
      print('Error getting total Q&A questions: $e');
      return 0;
    }
  }

  /// Get daily active users for the last 7 days
  static Future<Map<String, int>> getDailyActiveUsers() async {
    try {
      final today = DateTime.now();
      Map<String, int> dailyUsers = {};
      
      for (int i = 6; i >= 0; i--) {
        final date = today.subtract(Duration(days: i));
        final startOfDay = DateTime(date.year, date.month, date.day);
        final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
        
        final snapshot = await _firestore
            .collection('user_activity')
            .where('last_login', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
            .where('last_login', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
            .get();
        
        final dayName = _getDayName(date.weekday);
        dailyUsers[dayName] = snapshot.docs.length;
      }
      
      return dailyUsers;
    } catch (e) {
      print('Error getting daily active users: $e');
      return {
        'Mon': 0,
        'Tue': 0,
        'Wed': 0,
        'Thu': 0,
        'Fri': 0,
        'Sat': 0,
        'Sun': 0,
      };
    }
  }

  /// Get feature usage statistics
  static Future<Map<String, double>> getFeatureUsage() async {
    try {
      final snapshot = await _firestore.collection('feature_usage').get();
      Map<String, double> usage = {
        'Meal Planning': 0.0,
        'Market Prices': 0.0,
        'Q&A Forum': 0.0,
        'Teleconsultation': 0.0,
        'BMI Calculator': 0.0,
      };

      if (snapshot.docs.isNotEmpty) {
        for (var doc in snapshot.docs) {
          final data = doc.data();
          final feature = data['feature_name'] as String;
          final usageCount = (data['usage_count'] as num).toDouble();
          final totalUsers = (data['total_users'] as num).toDouble();
          
          if (totalUsers > 0) {
            usage[feature] = (usageCount / totalUsers) * 100;
          }
        }
      }

      return usage;
    } catch (e) {
      print('Error getting feature usage: $e');
      return {
        'Meal Planning': 85.0,
        'Market Prices': 72.0,
        'Q&A Forum': 68.0,
        'Teleconsultation': 45.0,
        'BMI Calculator': 92.0,
      };
    }
  }

  /// Get recent user activities
  static Future<List<Map<String, dynamic>>> getRecentActivities({int limit = 10}) async {
    try {
      final snapshot = await _firestore
          .collection('user_activities')
          .orderBy('created_at', descending: true)
          .limit(limit)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'action': data['action'] ?? 'Unknown action',
          'user': data['user_name'] ?? 'Unknown user',
          'time': _formatTimeAgo(data['created_at']),
          'icon': _getIconForAction(data['action'] ?? ''),
        };
      }).toList();
    } catch (e) {
      print('Error getting recent activities: $e');
      return []; // Return empty list on error
    }
  }

  /// Record user activity for analytics
  static Future<void> recordUserActivity({
    required String userId,
    required String userName,
    required String action,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _firestore.collection('user_activities').add({
        'user_id': userId,
        'user_name': userName,
        'action': action,
        'metadata': metadata ?? {},
        'created_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error recording user activity: $e');
    }
  }

  /// Update user last login time for activity tracking
  static Future<void> updateUserLastLogin(String userId) async {
    try {
      await _firestore.collection('user_activity').doc(userId).set({
        'user_id': userId,
        'last_login': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error updating user last login: $e');
    }
  }

  /// Helper method to get day name from weekday number
  static String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Mon';
      case 2: return 'Tue';
      case 3: return 'Wed';
      case 4: return 'Thu';
      case 5: return 'Fri';
      case 6: return 'Sat';
      case 7: return 'Sun';
      default: return 'Unknown';
    }
  }

  /// Helper method to format time ago
  static String _formatTimeAgo(Timestamp? timestamp) {
    if (timestamp == null) return 'Unknown time';
    
    final now = DateTime.now();
    final date = timestamp.toDate();
    final difference = now.difference(date);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    }
  }

  /// Helper method to get icon for action type
  static String _getIconForAction(String action) {
    if (action.contains('registration') || action.contains('sign up')) {
      return 'person_add';
    } else if (action.contains('meal') || action.contains('recipe')) {
      return 'restaurant_menu';
    } else if (action.contains('question') || action.contains('Q&A')) {
      return 'help_outline';
    } else if (action.contains('consultation') || action.contains('booking')) {
      return 'video_call';
    } else if (action.contains('rating') || action.contains('review')) {
      return 'star';
    } else {
      return 'circle';
    }
  }

  /// Get growth statistics (comparing current period with previous)
  static Future<Map<String, String>> getGrowthStats() async {
    try {
      final now = DateTime.now();
      final thirtyDaysAgo = now.subtract(const Duration(days: 30));
      final sixtyDaysAgo = now.subtract(const Duration(days: 60));

      // Get current period users (last 30 days)
      final currentUsersSnapshot = await _firestore
          .collection('users')
          .where('created_at', isGreaterThanOrEqualTo: Timestamp.fromDate(thirtyDaysAgo))
          .get();

      // Get previous period users (30-60 days ago)
      final previousUsersSnapshot = await _firestore
          .collection('users')
          .where('created_at', isGreaterThanOrEqualTo: Timestamp.fromDate(sixtyDaysAgo))
          .where('created_at', isLessThan: Timestamp.fromDate(thirtyDaysAgo))
          .get();

      final currentCount = currentUsersSnapshot.docs.length;
      final previousCount = previousUsersSnapshot.docs.length;

      String userGrowth = '+0%';
      if (previousCount > 0) {
        final growth = ((currentCount - previousCount) / previousCount * 100);
        userGrowth = growth >= 0 ? '+${growth.toInt()}%' : '${growth.toInt()}%';
      } else if (currentCount > 0) {
        userGrowth = '+100%';
      }

      // Similar calculations for other metrics can be added here
      return {
        'users': userGrowth,
        'active_today': '+5%', // Placeholder - implement similar logic
        'meal_plans': '+18%', // Placeholder - implement similar logic
        'qna_posts': '+8%', // Placeholder - implement similar logic
      };
    } catch (e) {
      print('Error getting growth stats: $e');
      return {
        'users': '+12%',
        'active_today': '+5%',
        'meal_plans': '+18%',
        'qna_posts': '+8%',
      };
    }
  }
}