import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuth;
import '../models/user.dart';
import '../services/user_service.dart';

class ProfessionalSetupProvider extends ChangeNotifier {
  final UserService _userService = UserService();

  // Professional setup data
  String _fullName = '';
  String _phoneNumber = '';
  String _specialization = '';
  String _licenseNumber = '';
  String _experience = '';
  String _consultationFee = '';
  String _bio = '';

  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  String get fullName => _fullName;
  String get phoneNumber => _phoneNumber;
  String get specialization => _specialization;
  String get licenseNumber => _licenseNumber;
  String get experience => _experience;
  String get consultationFee => _consultationFee;
  String get bio => _bio;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Setters
  void setBasicInfo(String fullName, String phoneNumber) {
    _fullName = fullName;
    _phoneNumber = phoneNumber;
    notifyListeners();
  }

  void setCredentials(String specialization, String licenseNumber, String experience, String consultationFee) {
    _specialization = specialization;
    _licenseNumber = licenseNumber;
    _experience = experience;
    _consultationFee = consultationFee;
    notifyListeners();
  }

  void setBio(String bio) {
    _bio = bio;
    notifyListeners();
  }

  // Complete professional profile setup (update existing user)
  Future<bool> completeProfessionalSetup() async {
    try {
      _setLoading(true);
      _clearError();

      final currentUser = FirebaseAuth.FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Get existing user data
      final existingUser = await _userService.getUser(currentUser.uid);
      if (existingUser == null) {
        throw Exception('User profile not found');
      }

      // Update with professional setup data
      final updatedUser = User(
        id: existingUser.id,
        fullName: _fullName,
        email: existingUser.email,
        phoneNumber: _phoneNumber,
        gender: existingUser.gender.isEmpty ? '' : existingUser.gender, // Keep existing if any
        birthdate: existingUser.birthdate,
        heightCm: existingUser.heightCm,
        weightKg: existingUser.weightKg,
        bmi: existingUser.bmi,
        householdSize: existingUser.householdSize,
        weeklyBudgetMin: existingUser.weeklyBudgetMin,
        weeklyBudgetMax: existingUser.weeklyBudgetMax,
        role: existingUser.role, // Keep existing role ('professional')
        specialization: _specialization,
        licenseNumber: _licenseNumber,
        yearsExperience: int.tryParse(_experience) ?? 0,
        consultationFee: double.tryParse(_consultationFee) ?? 0.0,
        bio: _bio,
        isVerified: false, // Will be verified by admin
        createdAt: existingUser.createdAt,
        certifications: existingUser.certifications,
        healthConditions: existingUser.healthConditions,
        foodAllergies: existingUser.foodAllergies,
      );

      await _userService.createOrUpdateUser(updatedUser);

      _setLoading(false);
      return true;

    } catch (e) {
      _setError('Failed to complete professional setup: $e');
      _setLoading(false);
      return false;
    }
  }

  // Update existing professional profile (for editing)
  Future<bool> updateProfessionalProfile() async {
    try {
      _setLoading(true);
      _clearError();

      final currentUser = FirebaseAuth.FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Get existing user data
      final existingUser = await _userService.getUser(currentUser.uid);
      if (existingUser == null) {
        throw Exception('User profile not found');
      }

      // Update professional fields
      final updatedUser = User(
        id: existingUser.id,
        fullName: _fullName,
        email: existingUser.email,
        phoneNumber: _phoneNumber,
        gender: existingUser.gender,
        birthdate: existingUser.birthdate,
        heightCm: existingUser.heightCm,
        weightKg: existingUser.weightKg,
        bmi: existingUser.bmi,
        householdSize: existingUser.householdSize,
        weeklyBudgetMin: existingUser.weeklyBudgetMin,
        weeklyBudgetMax: existingUser.weeklyBudgetMax,
        role: existingUser.role,
        specialization: _specialization,
        licenseNumber: _licenseNumber,
        yearsExperience: int.tryParse(_experience) ?? 0,
        consultationFee: double.tryParse(_consultationFee) ?? 0.0,
        bio: _bio,
        isVerified: existingUser.isVerified,
        createdAt: existingUser.createdAt,
        certifications: existingUser.certifications,
        healthConditions: existingUser.healthConditions,
        foodAllergies: existingUser.foodAllergies,
      );

      await _userService.createOrUpdateUser(updatedUser);

      _setLoading(false);
      return true;

    } catch (e) {
      _setError('Failed to update professional profile: $e');
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearData() {
    _fullName = '';
    _phoneNumber = '';
    _specialization = '';
    _licenseNumber = '';
    _experience = '';
    _consultationFee = '';
    _bio = '';
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}