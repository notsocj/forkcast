import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final CollectionReference users = FirebaseFirestore.instance.collection('users');

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
}