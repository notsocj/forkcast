import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class UserService {
  final CollectionReference users = FirebaseFirestore.instance.collection('users');

  // Legacy method - kept for backward compatibility
  Future<void> createUser({
    required String userId,
    required String fullName,
    required String email,
    required String passwordHash,
    required String gender,
    required DateTime birthdate,
    required double heightCm,
    required double weightKg,
    required int householdSize,
    required int weeklyBudgetMin,
    required int weeklyBudgetMax,
    required String role,
    String? specialization,
    required DateTime createdAt,
    String? phoneNumber,
  }) async {
    await users.doc(userId).set({
      'full_name': fullName,
      'email': email,
      'password_hash': passwordHash,
      'gender': gender,
      'birthdate': Timestamp.fromDate(birthdate),
      'height_cm': heightCm,
      'weight_kg': weightKg,
      'household_size': householdSize,
      'weekly_budget_min': weeklyBudgetMin,
      'weekly_budget_max': weeklyBudgetMax,
      'role': role,
      'specialization': specialization,
      'created_at': Timestamp.fromDate(createdAt),
      'phone_number': phoneNumber,
    });
  }

  // New method using User model
  Future<void> createOrUpdateUser(User user) async {
    try {
      await users.doc(user.id).set(user.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to save user profile: $e');
    }
  }

  // Get user by ID
  Future<User?> getUser(String userId) async {
    try {
      final doc = await users.doc(userId).get();
      if (doc.exists) {
        return User.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  // Update user profile
  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      await users.doc(userId).update(data);
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  // Update health conditions subcollection
  Future<void> updateHealthConditions(String userId, List<String> conditions) async {
    try {
      final healthConditionsRef = users.doc(userId).collection('health_conditions');
      
      // First, delete existing health conditions
      final existingConditions = await healthConditionsRef.get();
      for (final doc in existingConditions.docs) {
        await doc.reference.delete();
      }

      // Add new health conditions
      for (final condition in conditions) {
        await healthConditionsRef.add({
          'condition_name': condition,
        });
      }
    } catch (e) {
      throw Exception('Failed to update health conditions: $e');
    }
  }

  // Get user's health conditions
  Future<List<String>> getHealthConditions(String userId) async {
    try {
      final snapshot = await users.doc(userId).collection('health_conditions').get();
      return snapshot.docs
          .map((doc) => doc.data()['condition_name'] as String)
          .toList();
    } catch (e) {
      throw Exception('Failed to get health conditions: $e');
    }
  }

  // Check if user profile exists
  Future<bool> userExists(String userId) async {
    try {
      final doc = await users.doc(userId).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  // Delete user account and all associated data
  Future<void> deleteUser(String userId) async {
    try {
      // Delete health conditions subcollection
      final healthConditionsRef = users.doc(userId).collection('health_conditions');
      final healthConditions = await healthConditionsRef.get();
      for (final doc in healthConditions.docs) {
        await doc.reference.delete();
      }

      // Delete other subcollections as needed (meal_plans, teleconsultations, etc.)
      final subCollections = ['meal_plans', 'teleconsultations', 'qna_questions', 'availability'];
      for (final collection in subCollections) {
        final collectionRef = users.doc(userId).collection(collection);
        final snapshot = await collectionRef.get();
        for (final doc in snapshot.docs) {
          await doc.reference.delete();
        }
      }

      // Finally delete the main user document
      await users.doc(userId).delete();
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  // Get all users (for admin purposes)
  Future<List<User>> getAllUsers() async {
    try {
      final snapshot = await users.get();
      return snapshot.docs.map((doc) => User.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get all users: $e');
    }
  }

  // Get users by role
  Future<List<User>> getUsersByRole(String role) async {
    try {
      final snapshot = await users.where('role', isEqualTo: role).get();
      return snapshot.docs.map((doc) => User.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get users by role: $e');
    }
  }
}