import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/predefined_meals.dart';
import '../models/user.dart';
import 'user_service.dart';

class PersonalizedMealService {
  final UserService _userService = UserService();

  /// Get personalized meal suggestions based on user's health conditions and meal timing
  Future<List<PredefinedMeal>> getPersonalizedMealsForUser(String userId, String mealTime) async {
    try {
      // Get user data
      DocumentSnapshot userDoc = await _userService.users.doc(userId).get();
      if (!userDoc.exists) {
        // Return all meals if user not found
        return PredefinedMealsData.getMealsForMealTime(mealTime);
      }

      User user = User.fromFirestore(userDoc);
      
      // Use health conditions for filtering
      if (user.healthConditions != null && user.healthConditions!.isNotEmpty) {
        return PredefinedMealsData.getPersonalizedMeals(user.healthConditions!, mealTime);
      } else {
        // Return all meals suitable for the meal time if no health conditions
        return PredefinedMealsData.getMealsForMealTime(mealTime);
      }
    } catch (e) {
      // Return all meals if error occurs
      return PredefinedMealsData.getMealsForMealTime(mealTime);
    }
  }

  /// Get personalized search results based on user's health conditions
  Future<List<PredefinedMeal>> getPersonalizedSearchResults(String userId, String query) async {
    try {
      // Get user data
      DocumentSnapshot userDoc = await _userService.users.doc(userId).get();
      if (!userDoc.exists) {
        // Return standard search if user not found
        return PredefinedMealsData.searchMeals(query);
      }

      User user = User.fromFirestore(userDoc);
      
      // Use health-aware search
      return PredefinedMealsData.searchMealsWithHealthFilter(query, user.healthConditions);
    } catch (e) {
      // Return standard search if error occurs
      return PredefinedMealsData.searchMeals(query);
    }
  }

  /// Generate AI-powered meal plan suggestions for entire day
  Future<Map<String, List<PredefinedMeal>>> generateDailyMealPlan(String userId) async {
    try {
      // Get user data
      DocumentSnapshot userDoc = await _userService.users.doc(userId).get();
      User? user;
      if (userDoc.exists) {
        user = User.fromFirestore(userDoc);
      }

      // Get suitable meals for each meal time
      List<PredefinedMeal> breakfastOptions = await getPersonalizedMealsForUser(userId, 'breakfast');
      List<PredefinedMeal> lunchOptions = await getPersonalizedMealsForUser(userId, 'lunch');
      List<PredefinedMeal> dinnerOptions = await getPersonalizedMealsForUser(userId, 'dinner');
      List<PredefinedMeal> snackOptions = await getPersonalizedMealsForUser(userId, 'snack');

      // AI Logic: Select balanced meals based on nutrition and variety
      return {
        'breakfast': _selectBalancedMeals(breakfastOptions, 2, user),
        'lunch': _selectBalancedMeals(lunchOptions, 3, user),
        'dinner': _selectBalancedMeals(dinnerOptions, 3, user),
        'snack': _selectBalancedMeals(snackOptions, 2, user),
      };
    } catch (e) {
      // Return default suggestions if error occurs
      return {
        'breakfast': PredefinedMealsData.getMealsForMealTime('breakfast').take(2).toList(),
        'lunch': PredefinedMealsData.getMealsForMealTime('lunch').take(3).toList(),
        'dinner': PredefinedMealsData.getMealsForMealTime('dinner').take(3).toList(),
        'snack': PredefinedMealsData.getMealsForMealTime('snack').take(2).toList(),
      };
    }
  }

  /// Generate AI-powered meal suggestions for specific meal type
  Future<List<PredefinedMeal>> generateMealTypeSuggestions(String userId, String mealType) async {
    try {
      List<PredefinedMeal> suitableMeals = await getPersonalizedMealsForUser(userId, mealType);
      
      // Get user data for personalization
      DocumentSnapshot userDoc = await _userService.users.doc(userId).get();
      User? user;
      if (userDoc.exists) {
        user = User.fromFirestore(userDoc);
      }

      return _selectBalancedMeals(suitableMeals, 5, user);
    } catch (e) {
      return PredefinedMealsData.getMealsForMealTime(mealType).take(5).toList();
    }
  }

  /// AI Logic: Select balanced meals based on nutrition, variety, and user profile
  List<PredefinedMeal> _selectBalancedMeals(List<PredefinedMeal> availableMeals, int count, User? user) {
    if (availableMeals.length <= count) {
      return List.from(availableMeals);
    }

    List<PredefinedMeal> selected = [];
    List<PredefinedMeal> remaining = List.from(availableMeals);

    // Sort by nutritional balance and variety
    remaining.sort((a, b) {
      double scoreA = _calculateMealScore(a, user);
      double scoreB = _calculateMealScore(b, user);
      return scoreB.compareTo(scoreA); // Higher score first
    });

    // Select top-scored meals with variety
    Set<String> usedTags = {};
    
    for (PredefinedMeal meal in remaining) {
      if (selected.length >= count) break;
      
      // Ensure variety - avoid meals with too similar tags
      bool hasVariety = meal.tags.any((tag) => !usedTags.contains(tag.toLowerCase()));
      
      if (hasVariety || selected.isEmpty) {
        selected.add(meal);
        usedTags.addAll(meal.tags.map((tag) => tag.toLowerCase()));
      }
    }

    // Fill remaining slots if needed
    if (selected.length < count) {
      for (PredefinedMeal meal in remaining) {
        if (selected.length >= count) break;
        if (!selected.contains(meal)) {
          selected.add(meal);
        }
      }
    }

    return selected;
  }

  /// Calculate meal score based on user profile and nutritional value
  double _calculateMealScore(PredefinedMeal meal, User? user) {
    double score = 0.0;

    // Base nutritional score
    if (meal.kcal >= 200 && meal.kcal <= 600) score += 2.0; // Good calorie range
    if (meal.tags.contains('healthy') || meal.tags.contains('Filipino')) score += 1.5;
    if (meal.tags.contains('vegetables')) score += 1.0;
    if (meal.prepTimeMinutes <= 30) score += 0.5; // Quick to prepare

    // User-specific scoring
    if (user != null) {
      // BMI-based recommendations
      if (user.bmi != null) {
        if (user.bmi! < 18.5) { // Underweight
          if (meal.healthConditions.underweightMalnutrition) score += 2.0;
          if (meal.kcal > 400) score += 1.0; // Higher calorie meals
        } else if (user.bmi! > 25) { // Overweight
          if (meal.healthConditions.obesityOverweight) score += 2.0;
          if (meal.kcal < 400) score += 1.0; // Lower calorie meals
          if (meal.tags.contains('vegetables')) score += 1.0;
        }
      }

      // Budget considerations
      if (meal.difficulty == 'Easy') score += 0.5; // Easier meals might be more budget-friendly
      if (meal.ingredients.length <= 8) score += 0.3; // Fewer ingredients
    }

    // Add some randomization for variety
    score += (DateTime.now().millisecondsSinceEpoch % 100) / 200.0;

    return score;
  }

  /// Get health condition friendly alternatives for a specific meal
  Future<List<PredefinedMeal>> getHealthFriendlyAlternatives(String userId, String mealId) async {
    try {
      PredefinedMeal? originalMeal = PredefinedMealsData.getMealById(mealId);
      if (originalMeal == null) return [];

      // Get user health conditions
      DocumentSnapshot userDoc = await _userService.users.doc(userId).get();
      if (!userDoc.exists) return [];

      User user = User.fromFirestore(userDoc);
      if (user.healthConditions == null || user.healthConditions!.isEmpty) return [];

      // Find alternative meals with similar tags but health-appropriate
      List<PredefinedMeal> alternatives = [];
      
      for (PredefinedMeal meal in PredefinedMealsData.meals) {
        if (meal.id == mealId) continue; // Skip the original meal
        
        // Check if meal is health-appropriate
        bool isHealthFriendly = true;
        for (String condition in user.healthConditions!) {
          switch (condition.toLowerCase()) {
            case 'diabetes':
              if (!meal.healthConditions.diabetes) isHealthFriendly = false;
              break;
            case 'hypertension':
              if (!meal.healthConditions.hypertension) isHealthFriendly = false;
              break;
            case 'obesity':
              if (!meal.healthConditions.obesityOverweight) isHealthFriendly = false;
              break;
            case 'underweight':
              if (!meal.healthConditions.underweightMalnutrition) isHealthFriendly = false;
              break;
            case 'heart_disease':
              if (!meal.healthConditions.heartDiseaseChol) isHealthFriendly = false;
              break;
            case 'anemia':
              if (!meal.healthConditions.anemia) isHealthFriendly = false;
              break;
            case 'osteoporosis':
              if (!meal.healthConditions.osteoporosis) isHealthFriendly = false;
              break;
          }
        }

        if (isHealthFriendly) {
          // Check for similar tags or meal type
          bool hasSimilarTags = originalMeal.tags.any((tag) => meal.tags.contains(tag));
          if (hasSimilarTags) {
            alternatives.add(meal);
          }
        }
      }

      // Return top 5 alternatives
      return alternatives.take(5).toList();
    } catch (e) {
      return [];
    }
  }
}