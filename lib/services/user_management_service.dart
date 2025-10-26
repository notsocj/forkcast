import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

/// Service for managing users from admin perspective
/// Handles user CRUD operations, statistics, and admin-specific user data
class UserManagementService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get all users with pagination and filtering
  static Future<Map<String, dynamic>> getAllUsers({
    int limit = 20,
    DocumentSnapshot? startAfter,
    String? roleFilter,
    String? searchQuery,
    String? statusFilter,
  }) async {
    try {
      Query query = _firestore.collection('users');

      // Apply role filter
      if (roleFilter != null && roleFilter != 'All') {
        String role = roleFilter.toLowerCase();
        if (role == 'users') role = 'user';
        if (role == 'professionals') role = 'professional';
        if (role == 'admins') role = 'admin';
        query = query.where('role', isEqualTo: role);
      }

      // Apply status filter (based on account_status field)
      // Note: Don't apply both role and status filters to avoid needing composite index
      // Filter by status on client side if role filter is already applied
      if (statusFilter != null && statusFilter != 'All' && (roleFilter == null || roleFilter == 'All')) {
        query = query.where('account_status', isEqualTo: statusFilter.toLowerCase());
      }

      // Apply search query (name or email)
      if (searchQuery != null && searchQuery.isNotEmpty) {
        // For text search, we'll filter on the client side due to Firestore limitations
        // In production, consider using Algolia or similar for full-text search
      }

      // Order by creation date
      query = query.orderBy('created_at', descending: true);

      // Apply pagination
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      query = query.limit(limit);

      final snapshot = await query.get();

      // Filter on client side
      List<QueryDocumentSnapshot> filteredDocs = snapshot.docs;
      
      // Apply search query filter
      if (searchQuery != null && searchQuery.isNotEmpty) {
        filteredDocs = filteredDocs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final name = (data['full_name'] ?? '').toString().toLowerCase();
          final email = (data['email'] ?? '').toString().toLowerCase();
          final search = searchQuery.toLowerCase();
          return name.contains(search) || email.contains(search);
        }).toList();
      }
      
      // Apply status filter on client side if role filter was applied
      if (statusFilter != null && statusFilter != 'All' && roleFilter != null && roleFilter != 'All') {
        filteredDocs = filteredDocs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final status = (data['account_status'] ?? 'active').toString().toLowerCase();
          return status == statusFilter.toLowerCase();
        }).toList();
      }
      
      // Exclude deleted users by default (client-side filter)
      if (statusFilter == null || statusFilter == 'All') {
        filteredDocs = filteredDocs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final status = (data['account_status'] ?? 'active').toString().toLowerCase();
          return status != 'deleted';
        }).toList();
      }

      // Convert to User models
      List<User> users = filteredDocs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Add document ID
        return User.fromMap(data);
      }).toList();

      return {
        'users': users,
        'hasMore': snapshot.docs.length == limit,
        'lastDocument': snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
      };
    } catch (e) {
      print('Error getting all users: $e');
      return {
        'users': <User>[],
        'hasMore': false,
        'lastDocument': null,
      };
    }
  }

  /// Get user statistics for admin dashboard
  static Future<Map<String, dynamic>> getUserStatistics() async {
    try {
      final usersSnapshot = await _firestore.collection('users').get();
      
      Map<String, int> roleCounts = {
        'total': 0,
        'user': 0,
        'professional': 0,
        'admin': 0,
      };

      Map<String, int> statusCounts = {
        'active': 0,
        'suspended': 0,
        'pending': 0,
      };

      int newUsersThisMonth = 0;
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);

      for (var doc in usersSnapshot.docs) {
        final data = doc.data();
        
        // Count by role
        roleCounts['total'] = roleCounts['total']! + 1;
        final role = data['role'] ?? 'user';
        roleCounts[role] = (roleCounts[role] ?? 0) + 1;

        // Count by status
        final status = data['account_status'] ?? 'active';
        statusCounts[status] = (statusCounts[status] ?? 0) + 1;

        // Count new users this month
        final createdAt = data['created_at'] as Timestamp?;
        if (createdAt != null && createdAt.toDate().isAfter(startOfMonth)) {
          newUsersThisMonth++;
        }
      }

      return {
        'roleCounts': roleCounts,
        'statusCounts': statusCounts,
        'newUsersThisMonth': newUsersThisMonth,
      };
    } catch (e) {
      print('Error getting user statistics: $e');
      return {
        'roleCounts': {'total': 0, 'user': 0, 'professional': 0, 'admin': 0},
        'statusCounts': {'active': 0, 'suspended': 0, 'pending': 0},
        'newUsersThisMonth': 0,
      };
    }
  }

  /// Get user profile details with health conditions
  static Future<Map<String, dynamic>?> getUserProfileDetails(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return null;

      final userData = userDoc.data()!;
      
      // Get health conditions
      final healthConditionsSnapshot = await userDoc.reference
          .collection('health_conditions')
          .get();
      
      List<String> healthConditions = healthConditionsSnapshot.docs
          .map((doc) => doc.data()['condition_name'] as String)
          .toList();

      // Get last login from user_activity
      final activityDoc = await _firestore.collection('user_activity').doc(userId).get();
      Timestamp? lastLogin;
      if (activityDoc.exists) {
        lastLogin = activityDoc.data()!['last_login'];
      }

      // Get meal plan count
      final mealPlansSnapshot = await userDoc.reference
          .collection('meal_plans')
          .get();
      
      return {
        'user': User.fromMap({...userData, 'id': userId}),
        'healthConditions': healthConditions,
        'lastLogin': lastLogin,
        'mealPlansCount': mealPlansSnapshot.docs.length,
      };
    } catch (e) {
      print('Error getting user profile details: $e');
      return null;
    }
  }

  /// Update user status (Active, Suspended, Pending)
  static Future<bool> updateUserStatus(String userId, String status) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'account_status': status.toLowerCase(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      // Record admin activity
      await _recordAdminActivity(
        action: 'User status updated to $status',
        targetUserId: userId,
      );

      return true;
    } catch (e) {
      print('Error updating user status: $e');
      return false;
    }
  }

  /// Update user profile information
  static Future<bool> updateUser(String userId, Map<String, dynamic> userData) async {
    try {
      // Add metadata
      userData['updated_at'] = FieldValue.serverTimestamp();
      
      await _firestore.collection('users').doc(userId).update(userData);

      // Record admin activity
      await _recordAdminActivity(
        action: 'User profile updated',
        targetUserId: userId,
      );

      return true;
    } catch (e) {
      print('Error updating user: $e');
      return false;
    }
  }

  /// Update user role (user, professional, admin)
  static Future<bool> updateUserRole(String userId, String role) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'role': role.toLowerCase(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      // Record admin activity
      await _recordAdminActivity(
        action: 'User role updated to $role',
        targetUserId: userId,
      );

      return true;
    } catch (e) {
      print('Error updating user role: $e');
      return false;
    }
  }

  /// Delete user account (soft delete by setting status)
  static Future<bool> deleteUser(String userId) async {
    try {
      // Option 1: Soft delete (mark as deleted but keep in database)
      // Option 2: Hard delete (completely remove from database)
      
      // Using hard delete for complete removal
      // First delete all subcollections
      final userRef = _firestore.collection('users').doc(userId);
      
      // Delete health_conditions subcollection
      final healthConditions = await userRef.collection('health_conditions').get();
      for (var doc in healthConditions.docs) {
        await doc.reference.delete();
      }
      
      // Delete meal_plans subcollection
      final mealPlans = await userRef.collection('meal_plans').get();
      for (var doc in mealPlans.docs) {
        await doc.reference.delete();
      }
      
      // Delete teleconsultations subcollection
      final teleconsultations = await userRef.collection('teleconsultations').get();
      for (var doc in teleconsultations.docs) {
        await doc.reference.delete();
      }
      
      // Delete qna_questions subcollection
      final qnaQuestions = await userRef.collection('qna_questions').get();
      for (var doc in qnaQuestions.docs) {
        await doc.reference.delete();
      }
      
      // Delete saved_questions subcollection
      final savedQuestions = await userRef.collection('saved_questions').get();
      for (var doc in savedQuestions.docs) {
        await doc.reference.delete();
      }
      
      // Delete availability subcollection (for professionals)
      final availability = await userRef.collection('availability').get();
      for (var doc in availability.docs) {
        await doc.reference.delete();
      }
      
      // Record admin activity before deleting user document
      await _recordAdminActivity(
        action: 'User account deleted',
        targetUserId: userId,
      );
      
      // Finally, delete the user document itself
      await userRef.delete();

      return true;
    } catch (e) {
      print('Error deleting user: $e');
      return false;
    }
  }

  /// Get users with health profiles for analysis
  static Future<List<Map<String, dynamic>>> getUserHealthProfiles({
    String? healthConditionFilter,
    int limit = 20,
  }) async {
    try {
      final usersSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'user')
          .where('account_status', isEqualTo: 'active')
          .limit(limit)
          .get();

      List<Map<String, dynamic>> profiles = [];

      for (var userDoc in usersSnapshot.docs) {
        final userData = userDoc.data();
        
        // Get health conditions
        final healthConditionsSnapshot = await userDoc.reference
            .collection('health_conditions')
            .get();
        
        List<String> healthConditions = healthConditionsSnapshot.docs
            .map((doc) => doc.data()['condition_name'] as String)
            .toList();

        // Apply health condition filter
        if (healthConditionFilter != null && 
            healthConditionFilter != 'All' && 
            healthConditionFilter != 'None') {
          if (!healthConditions.contains(healthConditionFilter)) {
            continue;
          }
        } else if (healthConditionFilter == 'None') {
          if (healthConditions.isNotEmpty) {
            continue;
          }
        }

        // Get last activity
        final activityDoc = await _firestore.collection('user_activity').doc(userDoc.id).get();
        Timestamp? lastLogin;
        if (activityDoc.exists) {
          lastLogin = activityDoc.data()!['last_login'];
        }

        profiles.add({
          'user': User.fromMap({...userData, 'id': userDoc.id}),
          'healthConditions': healthConditions,
          'lastLogin': lastLogin,
        });
      }

      return profiles;
    } catch (e) {
      print('Error getting user health profiles: $e');
      return [];
    }
  }

  /// Get health analytics for admin dashboard
  static Future<Map<String, dynamic>> getHealthAnalytics() async {
    try {
      final usersSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'user')
          .get();

      Map<String, int> conditionCounts = {};
      int totalProfiles = 0;
      int profilesWithHealthIssues = 0;
      int activeThisWeek = 0;

      final oneWeekAgo = DateTime.now().subtract(const Duration(days: 7));

      for (var userDoc in usersSnapshot.docs) {
        totalProfiles++;

        // Get health conditions
        final healthConditionsSnapshot = await userDoc.reference
            .collection('health_conditions')
            .get();

        if (healthConditionsSnapshot.docs.isNotEmpty) {
          profilesWithHealthIssues++;
          
          for (var conditionDoc in healthConditionsSnapshot.docs) {
            final condition = conditionDoc.data()['condition_name'] as String;
            conditionCounts[condition] = (conditionCounts[condition] ?? 0) + 1;
          }
        }

        // Check if active this week
        final activityDoc = await _firestore.collection('user_activity').doc(userDoc.id).get();
        if (activityDoc.exists) {
          final lastLogin = activityDoc.data()!['last_login'] as Timestamp?;
          if (lastLogin != null && lastLogin.toDate().isAfter(oneWeekAgo)) {
            activeThisWeek++;
          }
        }
      }

      return {
        'totalProfiles': totalProfiles,
        'profilesWithHealthIssues': profilesWithHealthIssues,
        'activeThisWeek': activeThisWeek,
        'conditionCounts': conditionCounts,
      };
    } catch (e) {
      print('Error getting health analytics: $e');
      return {
        'totalProfiles': 0,
        'profilesWithHealthIssues': 0,
        'activeThisWeek': 0,
        'conditionCounts': <String, int>{},
      };
    }
  }

  /// Search users by name or email
  static Future<List<User>> searchUsers(String query) async {
    try {
      if (query.isEmpty) return [];

      // Get all users and filter client-side
      // In production, consider using Algolia or similar for better search
      final snapshot = await _firestore.collection('users').get();
      
      List<User> users = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final name = (data['full_name'] ?? '').toString().toLowerCase();
        final email = (data['email'] ?? '').toString().toLowerCase();
        final searchLower = query.toLowerCase();
        
        if (name.contains(searchLower) || email.contains(searchLower)) {
          users.add(User.fromMap({...data, 'id': doc.id}));
        }
      }

      return users;
    } catch (e) {
      print('Error searching users: $e');
      return [];
    }
  }

  /// Record admin activity for audit trail
  static Future<void> _recordAdminActivity({
    required String action,
    String? targetUserId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _firestore.collection('admin_activities').add({
        'action': action,
        'target_user_id': targetUserId,
        'metadata': metadata ?? {},
        'created_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error recording admin activity: $e');
    }
  }

  /// Format time ago for display
  static String formatTimeAgo(Timestamp? timestamp) {
    if (timestamp == null) return 'Never';
    
    final now = DateTime.now();
    final date = timestamp.toDate();
    final difference = now.difference(date);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks week${weeks == 1 ? '' : 's'} ago';
    } else {
      final months = (difference.inDays / 30).floor();
      return '$months month${months == 1 ? '' : 's'} ago';
    }
  }
}