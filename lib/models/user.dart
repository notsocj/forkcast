import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String? id;
  final String fullName;
  final String email;
  final String? passwordHash;
  final String? phoneNumber;
  final String gender;
  final DateTime birthdate;
  final double heightCm;
  final double weightKg;
  final double? bmi;
  final int householdSize;
  final int weeklyBudgetMin;
  final int weeklyBudgetMax;
  final DateTime? createdAt;
  final String role;
  final String? specialization;
  final String? licenseNumber;
  final int? yearsExperience;
  final double? consultationFee;
  final String? bio;
  final List<String>? certifications;
  final bool? isVerified;
  final List<String>? healthConditions;
  final List<String>? foodAllergies;

  User({
    this.id,
    required this.fullName,
    required this.email,
    this.passwordHash,
    this.phoneNumber,
    required this.gender,
    required this.birthdate,
    required this.heightCm,
    required this.weightKg,
    this.bmi,
    required this.householdSize,
    required this.weeklyBudgetMin,
    required this.weeklyBudgetMax,
    this.createdAt,
    this.role = 'user',
    this.specialization,
    this.licenseNumber,
    this.yearsExperience,
    this.consultationFee,
    this.bio,
    this.certifications,
    this.isVerified,
    this.healthConditions,
    this.foodAllergies,
  });

  // Factory constructor to create User from Firebase document
  factory User.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return User(
      id: doc.id,
      fullName: data['full_name'] ?? '',
      email: data['email'] ?? '',
      passwordHash: data['password_hash'],
      phoneNumber: data['phone_number'],
      gender: data['gender'] ?? '',
      birthdate: (data['birthdate'] as Timestamp).toDate(),
      heightCm: (data['height_cm'] ?? 0.0).toDouble(),
      weightKg: (data['weight_kg'] ?? 0.0).toDouble(),
      bmi: data['bmi']?.toDouble(),
      householdSize: data['household_size'] ?? 1,
      weeklyBudgetMin: data['weekly_budget_min'] ?? 0,
      weeklyBudgetMax: data['weekly_budget_max'] ?? 0,
      createdAt: data['created_at'] != null 
          ? (data['created_at'] as Timestamp).toDate()
          : null,
      role: data['role'] ?? 'user',
      specialization: data['specialization'],
      licenseNumber: data['license_number'],
      yearsExperience: data['years_experience'],
      consultationFee: data['consultation_fee']?.toDouble(),
      bio: data['bio'],
      certifications: data['certifications'] != null
          ? List<String>.from(data['certifications'])
          : null,
      isVerified: data['is_verified'] ?? false,
      healthConditions: data['health_conditions'] != null
          ? List<String>.from(data['health_conditions'])
          : null,
      foodAllergies: data['food_allergies'] != null
          ? List<String>.from(data['food_allergies'])
          : null,
    );
  }

  // Factory constructor to create User from data map with ID
  factory User.fromMap(Map<String, dynamic> data) {
    return User(
      id: data['id'],
      fullName: data['full_name'] ?? '',
      email: data['email'] ?? '',
      passwordHash: data['password_hash'],
      phoneNumber: data['phone_number'],
      gender: data['gender'] ?? '',
      birthdate: (data['birthdate'] as Timestamp).toDate(),
      heightCm: (data['height_cm'] ?? 0.0).toDouble(),
      weightKg: (data['weight_kg'] ?? 0.0).toDouble(),
      bmi: data['bmi']?.toDouble(),
      householdSize: data['household_size'] ?? 1,
      weeklyBudgetMin: data['weekly_budget_min'] ?? 0,
      weeklyBudgetMax: data['weekly_budget_max'] ?? 0,
      createdAt: data['created_at'] != null 
          ? (data['created_at'] as Timestamp).toDate()
          : null,
      role: data['role'] ?? 'user',
      specialization: data['specialization'],
      licenseNumber: data['license_number'],
      yearsExperience: data['years_experience'],
      consultationFee: data['consultation_fee']?.toDouble(),
      bio: data['bio'],
      certifications: data['certifications'] != null
          ? List<String>.from(data['certifications'])
          : null,
      isVerified: data['is_verified'] ?? false,
      healthConditions: data['health_conditions'] != null
          ? List<String>.from(data['health_conditions'])
          : null,
      foodAllergies: data['food_allergies'] != null
          ? List<String>.from(data['food_allergies'])
          : null,
    );
  }

  // Convert User to Map for Firebase
  Map<String, dynamic> toFirestore() {
    return {
      'full_name': fullName,
      'email': email,
      if (passwordHash != null) 'password_hash': passwordHash,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      'gender': gender,
      'birthdate': Timestamp.fromDate(birthdate),
      'height_cm': heightCm,
      'weight_kg': weightKg,
      if (bmi != null) 'bmi': bmi,
      'household_size': householdSize,
      'weekly_budget_min': weeklyBudgetMin,
      'weekly_budget_max': weeklyBudgetMax,
      'created_at': createdAt != null 
          ? Timestamp.fromDate(createdAt!)
          : Timestamp.fromDate(DateTime.now()),
      'role': role,
      if (specialization != null) 'specialization': specialization,
      if (licenseNumber != null) 'license_number': licenseNumber,
      if (yearsExperience != null) 'years_experience': yearsExperience,
      if (consultationFee != null) 'consultation_fee': consultationFee,
      if (bio != null) 'bio': bio,
      if (certifications != null) 'certifications': certifications,
      if (isVerified != null) 'is_verified': isVerified,
      if (healthConditions != null) 'health_conditions': healthConditions,
      if (foodAllergies != null) 'food_allergies': foodAllergies,
    };
  }

  // Create a copy of User with updated fields
  User copyWith({
    String? id,
    String? fullName,
    String? email,
    String? passwordHash,
    String? phoneNumber,
    String? gender,
    DateTime? birthdate,
    double? heightCm,
    double? weightKg,
    double? bmi,
    int? householdSize,
    int? weeklyBudgetMin,
    int? weeklyBudgetMax,
    DateTime? createdAt,
    String? role,
    String? specialization,
    String? licenseNumber,
    int? yearsExperience,
    double? consultationFee,
    String? bio,
    List<String>? certifications,
    bool? isVerified,
    List<String>? healthConditions,
    List<String>? foodAllergies,
  }) {
    return User(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      gender: gender ?? this.gender,
      birthdate: birthdate ?? this.birthdate,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      bmi: bmi ?? this.bmi,
      householdSize: householdSize ?? this.householdSize,
      weeklyBudgetMin: weeklyBudgetMin ?? this.weeklyBudgetMin,
      weeklyBudgetMax: weeklyBudgetMax ?? this.weeklyBudgetMax,
      createdAt: createdAt ?? this.createdAt,
      role: role ?? this.role,
      specialization: specialization ?? this.specialization,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      yearsExperience: yearsExperience ?? this.yearsExperience,
      consultationFee: consultationFee ?? this.consultationFee,
      bio: bio ?? this.bio,
      certifications: certifications ?? this.certifications,
      isVerified: isVerified ?? this.isVerified,
      healthConditions: healthConditions ?? this.healthConditions,
      foodAllergies: foodAllergies ?? this.foodAllergies,
    );
  }

  // Calculate BMI
  double get calculatedBmi => weightKg / ((heightCm / 100) * (heightCm / 100));

  // Calculate age
  int get age {
    final now = DateTime.now();
    int age = now.year - birthdate.year;
    if (now.month < birthdate.month || 
        (now.month == birthdate.month && now.day < birthdate.day)) {
      age--;
    }
    return age;
  }

  @override
  String toString() {
    return 'User{id: $id, fullName: $fullName, email: $email, gender: $gender, age: $age}';
  }
}