// FNRI Recipes data for ForkCast
// This file contains minimal compatibility classes for migration to Firebase
// The actual recipes are now stored in Firebase Firestore

class HealthConditions {
  final bool diabetes;
  final bool hypertension;
  final bool obesityOverweight;
  final bool underweightMalnutrition;
  final bool heartDiseaseChol;
  final bool anemia;
  final bool osteoporosis;
  final bool none; // Safe for healthy individuals

  const HealthConditions({
    required this.diabetes,
    required this.hypertension,
    required this.obesityOverweight,
    required this.underweightMalnutrition,
    required this.heartDiseaseChol,
    required this.anemia,
    required this.osteoporosis,
    required this.none,
  });
}

class MealTiming {
  final bool breakfast;
  final bool lunch;
  final bool dinner;
  final bool snack;

  const MealTiming({
    required this.breakfast,
    required this.lunch,
    required this.dinner,
    required this.snack,
  });
}

class MealIngredient {
  final String ingredientName;
  final double quantity;
  final String unit;

  const MealIngredient({
    required this.ingredientName,
    required this.quantity,
    required this.unit,
  });
}

class PredefinedMeal {
  final String id;
  final String recipeName;
  final String description;
  final int baseServings;
  final int kcal;
  final String funFact;
  final List<MealIngredient> ingredients;
  final String cookingInstructions;
  final HealthConditions healthConditions;
  final MealTiming mealTiming;
  
  // Backward compatibility fields
  final List<String> tags;
  final String difficulty;
  final int prepTimeMinutes;
  final String imageUrl;
  final double? averagePrice; // Average price in PHP, nullable for backward compatibility

  const PredefinedMeal({
    required this.id,
    required this.recipeName,
    required this.description,
    required this.baseServings,
    required this.kcal,
    required this.funFact,
    required this.ingredients,
    required this.cookingInstructions,
    required this.healthConditions,
    required this.mealTiming,
    required this.tags,
    required this.difficulty,
    required this.prepTimeMinutes,
    required this.imageUrl,
    this.averagePrice, // Optional parameter
  });
}

/// Temporary compatibility class during Firebase migration
/// All meal data is now stored in Firebase Firestore
class PredefinedMealsData {
  // Static nutrition tips that rotate based on date
  static const List<String> nutritionTips = [
    'Malunggay leaves contain 7 times more Vitamin C than oranges!',
    'Brown rice has 3 times more fiber than white rice.',
    'One medium banana provides about 10% of your daily potassium needs.',
    'Sweet potato leaves are rich in iron and can help prevent anemia.',
    'Sardines are an excellent source of omega-3 fatty acids.',
    'Kamote (sweet potato) is rich in beta-carotene, good for eye health.',
    'Pechay (bok choy) is high in calcium for strong bones.',
    'Tomatoes contain lycopene, a powerful antioxidant.',
    'Ginger has anti-inflammatory properties and aids digestion.',
    'Coconut water is a natural source of electrolytes.',
  ];

  // Sample recent searches for UI demo
  static const List<String> recentSearches = [
    'Adobo',
    'Sinigang',
    'Healthy breakfast',
    'Low sodium',
    'High protein',
  ];

  /// Scale recipe for number of people (PAX)
  /// This is kept for backward compatibility
  static PredefinedMeal scaleRecipeForPax(PredefinedMeal meal, int pax) {
    if (pax <= 0) pax = 1;
    final double scalingFactor = pax / meal.baseServings;

    return PredefinedMeal(
      id: meal.id,
      recipeName: meal.recipeName,
      description: meal.description,
      baseServings: pax,
      kcal: (meal.kcal * scalingFactor).round(),
      funFact: meal.funFact,
      ingredients: meal.ingredients.map((ingredient) => MealIngredient(
        ingredientName: ingredient.ingredientName,
        quantity: ingredient.quantity * scalingFactor,
        unit: ingredient.unit,
      )).toList(),
      cookingInstructions: meal.cookingInstructions,
      healthConditions: meal.healthConditions,
      mealTiming: meal.mealTiming,
      tags: meal.tags,
      difficulty: meal.difficulty,
      prepTimeMinutes: meal.prepTimeMinutes,
      imageUrl: meal.imageUrl,
    );
  }

  /// Get meal by ID - returns null during Firebase migration
  /// This will be replaced by Firebase recipe lookup
  static PredefinedMeal? getMealById(String id) {
    return null;
  }

  /// Get meals list - returns empty list during Firebase migration
  /// All meals are now in Firebase Firestore
  static List<PredefinedMeal> get meals => [];

  /// Get personalized meals - redirects to Firebase service
  /// This method is deprecated, use PersonalizedMealService instead
  @deprecated
  static List<PredefinedMeal> getPersonalizedMealsForUser(List<String> healthConditions) {
    return [];
  }

  /// Search meals - redirects to Firebase service
  /// This method is deprecated, use RecipeService.searchRecipes instead
  @deprecated
  static List<PredefinedMeal> searchMeals(String query) {
    return [];
  }
}