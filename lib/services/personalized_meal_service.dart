import '../models/user.dart';
import '../models/recipe.dart';
import 'user_service.dart';
import 'recipe_service.dart';

/// AI-powered meal recommendation service with health condition awareness
/// Uses Firebase recipes instead of local predefined data
class PersonalizedMealService {
  final UserService _userService = UserService();
  final RecipeService _recipeService = RecipeService();
  
  // Track suggested recipes to ensure variety across meal types
  final Set<String> _suggestedRecipeIds = <String>{};
  
  // Track the date when suggestions were last made
  DateTime? _lastSuggestionDate;
  
  /// Clear suggested recipes cache only if it's a new day
  void clearSuggestedRecipesIfNewDay() {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    
    // If it's a new day or first time, clear the suggestions
    if (_lastSuggestionDate == null || 
        _lastSuggestionDate!.isBefore(todayDate)) {
      _suggestedRecipeIds.clear();
      _lastSuggestionDate = todayDate;
      print('Cleared suggestion cache for new day: $todayDate');
    }
  }
  
  /// Force clear suggested recipes cache (for testing or manual reset)
  void clearSuggestedRecipes() {
    _suggestedRecipeIds.clear();
    _lastSuggestionDate = null;
  }

  /// Generate daily meal plan with personalized meal suggestions for all meal types
  /// Returns Map with meal types as keys and List<Recipe> as values
  Future<Map<String, List<Recipe>>> generateDailyMealPlan(String userId) async {
    try {
      final user = await _userService.getUser(userId);
      if (user == null) {
        throw Exception('User not found');
      }

      // Clear suggestions only if it's a new day
      clearSuggestedRecipesIfNewDay();

      // Get all recipes from Firebase
      final allRecipes = await _recipeService.getAllRecipes();
      
      final mealPlan = <String, List<Recipe>>{};
      
      // Generate suggestions for each meal type with variety tracking
      for (final mealType in ['Breakfast', 'Lunch', 'Dinner', 'Snack']) {
        final suggestions = await _generateMealTypeSuggestionsWithVariety(
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
  /// This is used for individual meal type suggestions (refresh button)
  Future<List<Recipe>> generateMealTypeSuggestions(
    String userId, 
    String mealType, 
    List<Recipe>? allRecipes,
  ) async {
    // Clear cache only if it's a new day (keeps variety within the same day)
    clearSuggestedRecipesIfNewDay();
    
    return await _generateMealTypeSuggestionsWithVariety(
      userId,
      mealType,
      allRecipes,
    );
  }
  
  /// Internal method to generate meal suggestions with variety tracking
  Future<List<Recipe>> _generateMealTypeSuggestionsWithVariety(
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

      // Try to get suggestions with health conditions first
      List<Recipe> finalSuggestions = await _getSuggestionsWithHealthConditions(
        suitableRecipes, user, mealType);
      
      // If no suitable recipes found due to health conditions, use fallback
      if (finalSuggestions.isEmpty) {
        print('No recipes found for $mealType with health conditions, using fallback');
        finalSuggestions = await _getFallbackSuggestions(suitableRecipes, user, mealType);
      }
      
      // Mark suggested recipes as used to avoid repetition
      for (final recipe in finalSuggestions) {
        _suggestedRecipeIds.add(recipe.id);
      }
      
      return finalSuggestions;
    } catch (e) {
      print('Error generating meal suggestions: $e');
      return [];
    }
  }

  /// Get suggestions respecting health conditions and avoiding already suggested recipes
  Future<List<Recipe>> _getSuggestionsWithHealthConditions(
    List<Recipe> suitableRecipes, User user, String mealType) async {
    
    // Filter out already suggested recipes for variety
    final availableRecipes = suitableRecipes.where((recipe) => 
        !_suggestedRecipeIds.contains(recipe.id)).toList();
    
    // Filter by health conditions
    final healthSafeRecipes = availableRecipes.where((recipe) {
      final healthScore = _calculateHealthConditionScore(recipe, user);
      return healthScore >= 0.8; // Only use recipes that are very safe
    }).toList();
    
    if (healthSafeRecipes.isEmpty) {
      return []; // Will trigger fallback
    }
    
    // Score and rank the health-safe recipes
    final scoredRecipes = <Map<String, dynamic>>[];
    for (final recipe in healthSafeRecipes) {
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
  }
  
  /// Fallback method when no recipes available with health conditions
  /// Disregards health conditions and suggests any suitable meal
  Future<List<Recipe>> _getFallbackSuggestions(
    List<Recipe> suitableRecipes, User user, String mealType) async {
    
    // Filter out already suggested recipes for variety (if any left)
    List<Recipe> availableRecipes = suitableRecipes.where((recipe) => 
        !_suggestedRecipeIds.contains(recipe.id)).toList();
    
    // If no variety left, use all suitable recipes
    if (availableRecipes.isEmpty) {
      availableRecipes = suitableRecipes;
    }
    
    // Score recipes but ignore health condition score
    final scoredRecipes = <Map<String, dynamic>>[];
    for (final recipe in availableRecipes) {
      // Calculate score without health condition penalty
      double score = 0.0;
      
      // BMI-based nutrition scoring (50% weight)
      final nutritionScore = _calculateBMINutritionScore(recipe, user);
      score += nutritionScore * 0.5;

      // Budget considerations (30% weight)
      final budgetScore = _calculateBudgetScore(recipe, user);
      score += budgetScore * 0.3;

      // Variety and preparation factors (20% weight)
      final varietyScore = _calculateVarietyScore(recipe);
      score += varietyScore * 0.2;
      
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