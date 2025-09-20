import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/predefined_meals.dart';

class MealLoggingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Log a meal to the current user's meal_plans subcollection
  /// According to firebase_structure.instructions.md schema:
  /// - meal_date: timestamp (date only)
  /// - meal_type: string (enum: ["Breakfast", "Lunch", "Dinner", "Snack"])
  /// - kcal_min: number (int)
  /// - kcal_max: number (int)
  /// - recipe_id: reference (→ recipes.recipeId) - we'll use the meal ID for now
  Future<void> logMeal({
    required PredefinedMeal meal,
    required String mealType,
    required double amount,
    required String measurement,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    // Calculate adjusted calories based on amount and measurement
    double adjustedKcal = _calculateAdjustedCalories(meal, amount, measurement);
    
    // Get today's date (date only, no time)
    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);

    // Create meal plan document according to Firebase schema
    final mealPlanData = {
      'meal_date': Timestamp.fromDate(todayDate),
      'meal_type': mealType,
      'kcal_min': adjustedKcal.floor(),
      'kcal_max': adjustedKcal.ceil(),
      'recipe_id': meal.id, // Using meal ID as reference for now
      'logged_at': FieldValue.serverTimestamp(),
      // Additional fields for better functionality (not in schema but useful)
      'recipe_name': meal.recipeName,
      'amount': amount,
      'measurement': measurement,
      'original_kcal': meal.kcal,
    };

    try {
      // Check if there's already a meal logged for this type today
      final existingMealQuery = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('meal_plans')
          .where('meal_date', isEqualTo: Timestamp.fromDate(todayDate))
          .where('meal_type', isEqualTo: mealType)
          .get();

      if (existingMealQuery.docs.isNotEmpty) {
        // Replace existing meal for this type today
        final docId = existingMealQuery.docs.first.id;
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('meal_plans')
            .doc(docId)
            .update(mealPlanData);
      } else {
        // Add new meal log
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('meal_plans')
            .add(mealPlanData);
      }
    } catch (e) {
      throw Exception('Failed to log meal: $e');
    }
  }

  /// Get today's logged meals for the current user
  Future<List<Map<String, dynamic>>> getTodaysMeals() async {
    final user = _auth.currentUser;
    if (user == null) {
      return [];
    }

    try {
      // Get today's date (date only, no time)
      final now = DateTime.now();
      final todayDate = DateTime(now.year, now.month, now.day);

      final querySnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('meal_plans')
          .where('meal_date', isEqualTo: Timestamp.fromDate(todayDate))
          .orderBy('logged_at', descending: false)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      print('Error fetching today\'s meals: $e');
      return [];
    }
  }

  /// Get meals for a specific date
  Future<List<Map<String, dynamic>>> getMealsForDate(DateTime date) async {
    final user = _auth.currentUser;
    if (user == null) {
      return [];
    }

    try {
      // Normalize date to date only (no time)
      final normalizedDate = DateTime(date.year, date.month, date.day);

      final querySnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('meal_plans')
          .where('meal_date', isEqualTo: Timestamp.fromDate(normalizedDate))
          .orderBy('logged_at', descending: false)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      print('Error fetching meals for date: $e');
      return [];
    }
  }

  /// Delete a logged meal
  Future<void> deleteMeal(String mealId) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('meal_plans')
          .doc(mealId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete meal: $e');
    }
  }

  /// Get weekly meal summary (calories per day)
  Future<Map<String, int>> getWeeklySummary() async {
    final user = _auth.currentUser;
    if (user == null) {
      return {};
    }

    try {
      final now = DateTime.now();
      final weekStart = DateTime(now.year, now.month, now.day - (now.weekday - 1));
      final weekEnd = DateTime(now.year, now.month, now.day + (7 - now.weekday));

      final querySnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('meal_plans')
          .where('meal_date', isGreaterThanOrEqualTo: Timestamp.fromDate(weekStart))
          .where('meal_date', isLessThan: Timestamp.fromDate(weekEnd))
          .get();

      Map<String, int> summary = {};
      
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final mealDate = (data['meal_date'] as Timestamp).toDate();
        final dayKey = '${mealDate.year}-${mealDate.month.toString().padLeft(2, '0')}-${mealDate.day.toString().padLeft(2, '0')}';
        final kcal = ((data['kcal_min'] as num?) ?? 0).toInt();
        
        summary[dayKey] = (summary[dayKey] ?? 0) + kcal;
      }

      return summary;
    } catch (e) {
      print('Error fetching weekly summary: $e');
      return {};
    }
  }

  /// Calculate adjusted calories based on amount and measurement
  double _calculateAdjustedCalories(PredefinedMeal meal, double amount, String measurement) {
    // Base calories are per serving
    double baseCalories = meal.kcal.toDouble();
    int servings = meal.servings;
    
    // Calculate calories per serving
    double caloriesPerServing = baseCalories / servings;
    
    // Adjust based on measurement type
    switch (measurement.toLowerCase()) {
      case 'serving':
      case 'servings':
        return caloriesPerServing * amount;
      case 'cup':
      case 'cups':
        // Assume 1 cup = 1 serving for most meals
        return caloriesPerServing * amount;
      case 'piece':
      case 'pieces':
        // Assume 1 piece = 1 serving
        return caloriesPerServing * amount;
      case 'gram':
      case 'grams':
      case 'g':
        // Rough estimation: assume 100g = 1 serving for most meals
        return caloriesPerServing * (amount / 100);
      case 'tablespoon':
      case 'tablespoons':
      case 'tbsp':
        // Assume 4 tablespoons = 1 serving
        return caloriesPerServing * (amount / 4);
      default:
        // Default to serving size
        return caloriesPerServing * amount;
    }
  }

  /// Get meal types for today with their status
  Future<Map<String, Map<String, dynamic>>> getTodaysMealStatus() async {
    final todaysMeals = await getTodaysMeals();
    
    Map<String, Map<String, dynamic>> mealStatus = {
      'Breakfast': {'logged': false, 'data': null},
      'Lunch': {'logged': false, 'data': null},
      'Dinner': {'logged': false, 'data': null},
      'Snack': {'logged': false, 'data': null},
    };

    for (var meal in todaysMeals) {
      final mealType = meal['meal_type'] as String?;
      if (mealType != null && mealStatus.containsKey(mealType)) {
        mealStatus[mealType] = {
          'logged': true,
          'data': meal,
        };
      }
    }

    return mealStatus;
  }

  /// Replace or add a meal for a specific type today
  Future<void> replaceMealForType(String mealType, PredefinedMeal meal, double amount, String measurement) async {
    await logMeal(
      meal: meal,
      mealType: mealType,
      amount: amount,
      measurement: measurement,
    );
  }
}