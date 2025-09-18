import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/user_service.dart';
import '../services/auth_service.dart';

class ProfileSetupProvider extends ChangeNotifier {
  final UserService _userService = UserService();
  final AuthService _authService = AuthService();

  // Profile setup data
  String _fullName = '';
  String _gender = '';
  DateTime? _birthdate;
  double _heightCm = 0.0;
  double _weightKg = 0.0;
  int _householdSize = 1;
  int _weeklyBudgetMin = 0;
  int _weeklyBudgetMax = 0;
  List<String> _healthConditions = [];

  bool _isLoading = false;
  String? _error;

  // Getters
  String get fullName => _fullName;
  String get gender => _gender;
  DateTime? get birthdate => _birthdate;
  double get heightCm => _heightCm;
  double get weightKg => _weightKg;
  int get householdSize => _householdSize;
  int get weeklyBudgetMin => _weeklyBudgetMin;
  int get weeklyBudgetMax => _weeklyBudgetMax;
  List<String> get healthConditions => _healthConditions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Check if profile setup is complete
  bool get isProfileSetupComplete {
    return _fullName.isNotEmpty &&
           _gender.isNotEmpty &&
           _birthdate != null &&
           _heightCm > 0 &&
           _weightKg > 0 &&
           _householdSize > 0 &&
           _weeklyBudgetMin >= 0 &&
           _weeklyBudgetMax > 0;
  }

  // Update methods
  void setFullName(String name) {
    _fullName = name.trim();
    _clearError();
    notifyListeners();
  }

  void setGender(String gender) {
    _gender = gender;
    _clearError();
    notifyListeners();
  }

  void setBirthdate(DateTime birthdate) {
    _birthdate = birthdate;
    _clearError();
    notifyListeners();
  }

  void setHeight(double heightCm) {
    _heightCm = heightCm;
    _clearError();
    notifyListeners();
  }

  void setWeight(double weightKg) {
    _weightKg = weightKg;
    _clearError();
    notifyListeners();
  }

  void setHouseholdSize(int size) {
    _householdSize = size;
    _clearError();
    notifyListeners();
  }

  void setWeeklyBudget(int min, int max) {
    _weeklyBudgetMin = min;
    _weeklyBudgetMax = max;
    _clearError();
    notifyListeners();
  }

  void setHealthConditions(List<String> conditions) {
    _healthConditions = [...conditions];
    _clearError();
    notifyListeners();
  }

  void addHealthCondition(String condition) {
    if (!_healthConditions.contains(condition)) {
      _healthConditions.add(condition);
      _clearError();
      notifyListeners();
    }
  }

  void removeHealthCondition(String condition) {
    _healthConditions.remove(condition);
    _clearError();
    notifyListeners();
  }

  void _clearError() {
    if (_error != null) {
      _error = null;
      // Don't notify listeners for error clearing to avoid unnecessary rebuilds
    }
  }

  void clearProfileData() {
    _fullName = '';
    _gender = '';
    _birthdate = null;
    _heightCm = 0.0;
    _weightKg = 0.0;
    _householdSize = 1;
    _weeklyBudgetMin = 0;
    _weeklyBudgetMax = 0;
    _healthConditions.clear();
    _error = null;
    notifyListeners();
  }

  // Save profile to Firebase
  Future<bool> saveProfile() async {
    if (!isProfileSetupComplete) {
      _error = 'Please complete all profile setup steps';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Get current user from auth
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        _error = 'No authenticated user found';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Create User object
      final user = User(
        id: currentUser.uid,
        fullName: _fullName,
        email: currentUser.email ?? '',
        phoneNumber: currentUser.phoneNumber,
        gender: _gender,
        birthdate: _birthdate!,
        heightCm: _heightCm,
        weightKg: _weightKg,
        householdSize: _householdSize,
        weeklyBudgetMin: _weeklyBudgetMin,
        weeklyBudgetMax: _weeklyBudgetMax,
        role: 'user',
        healthConditions: _healthConditions.isNotEmpty ? _healthConditions : null,
        createdAt: DateTime.now(),
      );

      // Save to Firestore
      await _userService.createOrUpdateUser(user);

      // Save health conditions as subcollection if any
      if (_healthConditions.isNotEmpty) {
        await _userService.updateHealthConditions(currentUser.uid, _healthConditions);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to save profile: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Load existing profile data (if editing)
  Future<void> loadProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        _error = 'No authenticated user found';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final user = await _userService.getUser(currentUser.uid);
      if (user != null) {
        _fullName = user.fullName;
        _gender = user.gender;
        _birthdate = user.birthdate;
        _heightCm = user.heightCm;
        _weightKg = user.weightKg;
        _householdSize = user.householdSize;
        _weeklyBudgetMin = user.weeklyBudgetMin;
        _weeklyBudgetMax = user.weeklyBudgetMax;
        _healthConditions = user.healthConditions ?? [];
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load profile: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Calculate BMI from current height and weight
  double? get currentBmi {
    if (_heightCm > 0 && _weightKg > 0) {
      return _weightKg / ((_heightCm / 100) * (_heightCm / 100));
    }
    return null;
  }

  // Calculate age from current birthdate
  int? get currentAge {
    if (_birthdate != null) {
      final now = DateTime.now();
      int age = now.year - _birthdate!.year;
      if (now.month < _birthdate!.month || 
          (now.month == _birthdate!.month && now.day < _birthdate!.day)) {
        age--;
      }
      return age;
    }
    return null;
  }
}