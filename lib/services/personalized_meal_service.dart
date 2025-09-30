import '../models/user.dart';
import '../models/recipe.dart';
import 'user_service.dart';
import 'recipe_service.dart';

/// AI-powered meal recommendation service with health condition awareness
/// Uses Firebase recipes instead of local predefined data
class PersonalizedMealService {
  final UserService _userService = UserService();
  final RecipeService _recipeService = RecipeService();

  /// Generate daily meal plan with personalized meal suggestions for all meal types
  /// Returns Map with meal types as keys and List<Recipe> as values
  Future<Map<String, List<Recipe>>> generateDailyMealPlan(String userId) async {
    try {
      final user = await _userService.getUser(userId);
      if (user == null) {
        throw Exception('User not found');
      }

      // Get all recipes from Firebase
      final allRecipes = await _recipeService.getAllRecipes();
      
      final mealPlan = <String, List<Recipe>>{};
      
      // Generate suggestions for each meal type
      for (final mealType in ['Breakfast', 'Lunch', 'Dinner', 'Snack']) {
        final suggestions = await generateMealTypeSuggestions(
          userId, 
          mealType, 
          allRecipes,
        );
        mealPlan[mealType] = suggestions;
      }
      
      return mealPlan;
    } catch (e) {
      print('Error generating daily meal plan: $e');
      return {};
    }
  }

  /// Generate targeted recommendations for specific meal times
  /// Returns List<Recipe> filtered and scored for the meal type
  Future<List<Recipe>> generateMealTypeSuggestions(
    String userId, 
    String mealType, 
    List<Recipe>? allRecipes,
  ) async {
    try {
      final user = await _userService.getUser(userId);
      if (user == null) {
        throw Exception('User not found');
      }

      // Get recipes from Firebase if not provided
      final recipes = allRecipes ?? await _recipeService.getAllRecipes();
      
      // Filter recipes suitable for the meal type
      final suitableRecipes = recipes.where((recipe) {
        // Check meal timing suitability
        switch (mealType.toLowerCase()) {
          case 'breakfast':
            return recipe.mealTiming.breakfast;
          case 'lunch':
            return recipe.mealTiming.lunch;
          case 'dinner':
            return recipe.mealTiming.dinner;
          case 'snack':
            return recipe.mealTiming.snack;
          default:
            return true;
        }
      }).toList();

      // Score and rank recipes based on user profile
      final scoredRecipes = <Map<String, dynamic>>[];
      for (final recipe in suitableRecipes) {
        final score = await _calculateMealScore(recipe, user);
        scoredRecipes.add({
          'recipe': recipe,
          'score': score,
        });
      }

      // Sort by score (highest first) and return top 5
      scoredRecipes.sort((a, b) => b['score'].compareTo(a['score']));
      
      return scoredRecipes
          .take(5)
          .map((item) => item['recipe'] as Recipe)
          .toList();
    } catch (e) {
      print('Error generating meal suggestions: $e');
      return [];
    }
  }

  /// Multi-factor scoring algorithm considering BMI, health conditions, variety, budget
  Future<double> _calculateMealScore(Recipe recipe, User user) async {
    double score = 0.0;

    // 1. Health condition safety scoring (40% weight)
    final healthScore = _calculateHealthConditionScore(recipe, user);
    score += healthScore * 0.4;

    // 2. BMI-based nutrition scoring (30% weight)
    final nutritionScore = _calculateBMINutritionScore(recipe, user);
    score += nutritionScore * 0.3;

    // 3. Budget considerations (20% weight)
    final budgetScore = _calculateBudgetScore(recipe, user);
    score += budgetScore * 0.2;

    // 4. Variety and preparation factors (10% weight)
    final varietyScore = _calculateVarietyScore(recipe);
    score += varietyScore * 0.1;

    return score;
  }

  /// Calculate health condition safety score (0.0 to 1.0)
  double _calculateHealthConditionScore(Recipe recipe, User user) {
    // Get user's health conditions
    final userConditions = user.healthConditions ?? [];
    
    if (userConditions.isEmpty) {
      // User has no health conditions, check if recipe is safe for general health
      return recipe.healthConditions.none ? 1.0 : 0.8;
    }

    // Check recipe safety for each user condition
    double safetyScore = 1.0;

    for (final condition in userConditions) {
      switch (condition.toLowerCase()) {
        case 'diabetes':
          if (!recipe.healthConditions.diabetes) safetyScore -= 0.2;
          break;
        case 'hypertension':
          if (!recipe.healthConditions.hypertension) safetyScore -= 0.2;
          break;
        case 'obesity':
        case 'overweight':
          if (!recipe.healthConditions.obesityOverweight) safetyScore -= 0.2;
          break;
        case 'underweight':
        case 'malnutrition':
          if (!recipe.healthConditions.underweightMalnutrition) safetyScore -= 0.2;
          break;
        case 'heart disease':
        case 'high cholesterol':
          if (!recipe.healthConditions.heartDiseaseChol) safetyScore -= 0.2;
          break;
        case 'anemia':
        case 'iron deficiency':
          if (!recipe.healthConditions.anemia) safetyScore -= 0.2;
          break;
        case 'osteoporosis':
        case 'calcium deficiency':
          if (!recipe.healthConditions.osteoporosis) safetyScore -= 0.2;
          break;
      }
    }

    return safetyScore.clamp(0.0, 1.0);
  }

  /// Calculate BMI-based nutrition score (0.0 to 1.0)
  double _calculateBMINutritionScore(Recipe recipe, User user) {
    final bmi = user.bmi ?? 22.0; // Default to normal BMI if not set
    
    if (bmi < 18.5) {
      // Underweight: prefer high-calorie, high-protein meals
      if (recipe.kcal > 400) return 1.0;
      if (recipe.kcal > 300) return 0.8;
      return 0.6;
    } else if (bmi >= 18.5 && bmi < 25.0) {
      // Normal weight: balanced nutrition
      if (recipe.kcal >= 250 && recipe.kcal <= 400) return 1.0;
      if (recipe.kcal >= 200 && recipe.kcal <= 500) return 0.8;
      return 0.6;
    } else if (bmi >= 25.0 && bmi < 30.0) {
      // Overweight: moderate calorie restriction
      if (recipe.kcal <= 350) return 1.0;
      if (recipe.kcal <= 400) return 0.7;
      return 0.5;
    } else {
      // Obese: low-calorie, high-nutrition meals
      if (recipe.kcal <= 300) return 1.0;
      if (recipe.kcal <= 350) return 0.6;
      return 0.3;
    }
  }

  /// Calculate budget score based on estimated cost (0.0 to 1.0)
  double _calculateBudgetScore(Recipe recipe, User user) {
    // Simple budget scoring - can be enhanced with actual ingredient prices
    final weeklyBudget = user.weeklyBudgetMax.toDouble();
    final dailyBudget = weeklyBudget / 7;
    final mealBudget = dailyBudget / 4; // 4 meals per day
    
    // Estimate recipe cost based on ingredients (simplified)
    final estimatedCost = recipe.ingredients.length * 25.0; // Rough estimate
    
    if (estimatedCost <= mealBudget * 0.8) return 1.0;
    if (estimatedCost <= mealBudget) return 0.8;
    if (estimatedCost <= mealBudget * 1.2) return 0.6;
    return 0.4;
  }

  /// Calculate variety score to promote diverse meals (0.0 to 1.0)
  double _calculateVarietyScore(Recipe recipe) {
    // Simple variety scoring - can be enhanced with meal history
    // For now, prefer recipes with more ingredients (more diverse nutrition)
    final ingredientCount = recipe.ingredients.length;
    
    if (ingredientCount >= 8) return 1.0;
    if (ingredientCount >= 6) return 0.8;
    if (ingredientCount >= 4) return 0.6;
    return 0.4;
  }

  /// Get personalized meals filtered by health conditions
  Future<List<Recipe>> getPersonalizedMealsForUser(String userId) async {
    try {
      final user = await _userService.getUser(userId);
      if (user == null) {
        throw Exception('User not found');
      }

      // Get all recipes and filter by health conditions
      final allRecipes = await _recipeService.getAllRecipes();
      final userConditions = user.healthConditions ?? [];
      
      if (userConditions.isEmpty) {
        // No health conditions, return all recipes
        return allRecipes;
      }

      // Filter recipes safe for user's health conditions
      final safeRecipes = allRecipes.where((recipe) {
        for (final condition in userConditions) {
          switch (condition.toLowerCase()) {
            case 'diabetes':
              if (!recipe.healthConditions.diabetes) return false;
              break;
            case 'hypertension':
              if (!recipe.healthConditions.hypertension) return false;
              break;
            case 'obesity':
            case 'overweight':
              if (!recipe.healthConditions.obesityOverweight) return false;
              break;
            case 'underweight':
            case 'malnutrition':
              if (!recipe.healthConditions.underweightMalnutrition) return false;
              break;
            case 'heart disease':
            case 'high cholesterol':
              if (!recipe.healthConditions.heartDiseaseChol) return false;
              break;
            case 'anemia':
            case 'iron deficiency':
              if (!recipe.healthConditions.anemia) return false;
              break;
            case 'osteoporosis':
            case 'calcium deficiency':
              if (!recipe.healthConditions.osteoporosis) return false;
              break;
          }
        }
        return true;
      }).toList();

      return safeRecipes;
    } catch (e) {
      print('Error getting personalized meals: $e');
      return [];
    }
  }

  /// Search recipes with health awareness
  Future<List<Recipe>> searchRecipes(String query, String userId) async {
    try {
      final personalizedRecipes = await getPersonalizedMealsForUser(userId);
      
      // Filter by search query
      final searchResults = personalizedRecipes.where((recipe) {
        final queryLower = query.toLowerCase();
        return recipe.recipeName.toLowerCase().contains(queryLower) ||
               recipe.description.toLowerCase().contains(queryLower) ||
               recipe.ingredients.any((ingredient) => 
                   ingredient.ingredientName.toLowerCase().contains(queryLower));
      }).toList();

      return searchResults;
    } catch (e) {
      print('Error searching recipes: $e');
      return [];
    }
  }
}