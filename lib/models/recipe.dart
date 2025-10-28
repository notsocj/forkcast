import 'package:cloud_firestore/cloud_firestore.dart';

/// Recipe ingredient model for Firebase integration
class RecipeIngredient {
  final String ingredientName;
  final double quantity;
  final String unit;

  const RecipeIngredient({
    required this.ingredientName,
    required this.quantity,
    required this.unit,
  });

  /// Create from Firestore document
  factory RecipeIngredient.fromFirestore(Map<String, dynamic> data) {
    return RecipeIngredient(
      ingredientName: data['ingredient_name'] ?? '',
      quantity: (data['quantity'] ?? 0.0).toDouble(),
      unit: data['unit'] ?? '',
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'ingredient_name': ingredientName,
      'quantity': quantity,
      'unit': unit,
    };
  }

  /// Create from PredefinedMeal MealIngredient
  factory RecipeIngredient.fromMealIngredient(dynamic mealIngredient) {
    return RecipeIngredient(
      ingredientName: mealIngredient.ingredientName,
      quantity: mealIngredient.quantity,
      unit: mealIngredient.unit,
    );
  }
}

/// Health conditions model for recipe suitability
class RecipeHealthConditions {
  final bool diabetes;
  final bool hypertension;
  final bool obesityOverweight;
  final bool underweightMalnutrition;
  final bool heartDiseaseChol;
  final bool anemia;
  final bool osteoporosis;
  final bool none; // Safe for healthy individuals

  const RecipeHealthConditions({
    required this.diabetes,
    required this.hypertension,
    required this.obesityOverweight,
    required this.underweightMalnutrition,
    required this.heartDiseaseChol,
    required this.anemia,
    required this.osteoporosis,
    required this.none,
  });

  /// Create from Firestore document
  factory RecipeHealthConditions.fromFirestore(Map<String, dynamic> data) {
    return RecipeHealthConditions(
      diabetes: data['is_diabetes_safe'] ?? false,
      hypertension: data['is_hypertension_safe'] ?? false,
      obesityOverweight: data['is_obesity_safe'] ?? false,
      underweightMalnutrition: data['is_underweight_safe'] ?? false,
      heartDiseaseChol: data['is_heart_disease_safe'] ?? false,
      anemia: data['is_anemia_safe'] ?? false,
      osteoporosis: data['is_osteoporosis_safe'] ?? false,
      none: data['is_none_safe'] ?? false,
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'is_diabetes_safe': diabetes,
      'is_hypertension_safe': hypertension,
      'is_obesity_safe': obesityOverweight,
      'is_underweight_safe': underweightMalnutrition,
      'is_heart_disease_safe': heartDiseaseChol,
      'is_anemia_safe': anemia,
      'is_osteoporosis_safe': osteoporosis,
      'is_none_safe': none,
    };
  }

  /// Create from PredefinedMeal HealthConditions
  factory RecipeHealthConditions.fromHealthConditions(dynamic healthConditions) {
    return RecipeHealthConditions(
      diabetes: healthConditions.diabetes,
      hypertension: healthConditions.hypertension,
      obesityOverweight: healthConditions.obesityOverweight,
      underweightMalnutrition: healthConditions.underweightMalnutrition,
      heartDiseaseChol: healthConditions.heartDiseaseChol,
      anemia: healthConditions.anemia,
      osteoporosis: healthConditions.osteoporosis,
      none: healthConditions.none,
    );
  }
}

/// Meal timing model for when recipe is suitable
class RecipeMealTiming {
  final bool breakfast;
  final bool lunch;
  final bool dinner;
  final bool snack;

  const RecipeMealTiming({
    required this.breakfast,
    required this.lunch,
    required this.dinner,
    required this.snack,
  });

  /// Create from Firestore document
  factory RecipeMealTiming.fromFirestore(Map<String, dynamic> data) {
    return RecipeMealTiming(
      breakfast: data['is_breakfast_suitable'] ?? false,
      lunch: data['is_lunch_suitable'] ?? false,
      dinner: data['is_dinner_suitable'] ?? false,
      snack: data['is_snack_suitable'] ?? false,
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'is_breakfast_suitable': breakfast,
      'is_lunch_suitable': lunch,
      'is_dinner_suitable': dinner,
      'is_snack_suitable': snack,
    };
  }

  /// Create from PredefinedMeal MealTiming
  factory RecipeMealTiming.fromMealTiming(dynamic mealTiming) {
    return RecipeMealTiming(
      breakfast: mealTiming.breakfast,
      lunch: mealTiming.lunch,
      dinner: mealTiming.dinner,
      snack: mealTiming.snack,
    );
  }
}

/// Main Recipe model for Firebase integration
class Recipe {
  final String id;
  final String recipeName;
  final String description;
  final int baseServings;
  final int kcal;
  final String funFact;
  final List<RecipeIngredient> ingredients;
  final String cookingInstructions;
  final RecipeHealthConditions healthConditions;
  final RecipeMealTiming mealTiming;
  final List<String> tags;
  final String difficulty;
  final int prepTimeMinutes;
  final String imageUrl; // Asset path, not URL
  final DateTime createdAt;
  final double? averagePrice; // Average price in PHP, nullable for old recipes

  const Recipe({
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
    required this.createdAt,
    this.averagePrice,
  });

  /// Create from Firestore document (ingredients loaded separately)
  factory Recipe.fromFirestore(
    Map<String, dynamic> data,
    String documentId,
    List<RecipeIngredient> ingredients, {
    RecipeHealthConditions? healthConditions,
    RecipeMealTiming? mealTiming,
  }) {
    return Recipe(
      id: documentId,
      recipeName: data['recipe_name'] ?? '',
      description: data['description'] ?? '',
      baseServings: data['servings'] ?? 1,
      kcal: data['kcal'] ?? 0,
      funFact: data['fun_fact'] ?? '',
      ingredients: ingredients,
      cookingInstructions: data['cooking_instructions'] ?? '',
      // Use subcollection data if available, otherwise fall back to denormalized fields
      healthConditions: healthConditions ?? RecipeHealthConditions.fromFirestore(data),
      mealTiming: mealTiming ?? RecipeMealTiming.fromFirestore(data),
      tags: List<String>.from(data['tags'] ?? []),
      difficulty: data['difficulty'] ?? 'Medium',
      prepTimeMinutes: data['prep_time_minutes'] ?? 30,
      imageUrl: data['image_url'] ?? '',
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      averagePrice: data['average_price']?.toDouble(), // Nullable, defaults to null for old recipes
    );
  }

  /// Convert to Firestore document (ingredients saved separately)
  Map<String, dynamic> toFirestore() {
    return {
      'recipe_name': recipeName,
      'description': description,
      'servings': baseServings,
      'kcal': kcal,
      'fun_fact': funFact,
      'cooking_instructions': cookingInstructions,
      'tags': tags,
      'difficulty': difficulty,
      'prep_time_minutes': prepTimeMinutes,
      'image_url': imageUrl,
      'created_at': Timestamp.fromDate(createdAt),
      if (averagePrice != null) 'average_price': averagePrice, // Only save if not null
      // Health conditions (spread operator)
      ...healthConditions.toFirestore(),
      // Meal timing (spread operator)
      ...mealTiming.toFirestore(),
    };
  }

  /// Create from PredefinedMeal object (for migration)
  factory Recipe.fromPredefinedMeal(dynamic predefinedMeal) {
    return Recipe(
      id: predefinedMeal.id,
      recipeName: predefinedMeal.recipeName,
      description: predefinedMeal.description,
      baseServings: predefinedMeal.baseServings,
      kcal: predefinedMeal.kcal,
      funFact: predefinedMeal.funFact,
      ingredients: predefinedMeal.ingredients
          .map<RecipeIngredient>((ingredient) => 
              RecipeIngredient.fromMealIngredient(ingredient))
          .toList(),
      cookingInstructions: predefinedMeal.cookingInstructions,
      healthConditions: RecipeHealthConditions.fromHealthConditions(
          predefinedMeal.healthConditions),
      mealTiming: RecipeMealTiming.fromMealTiming(predefinedMeal.mealTiming),
      tags: List<String>.from(predefinedMeal.tags),
      difficulty: predefinedMeal.difficulty,
      prepTimeMinutes: predefinedMeal.prepTimeMinutes,
      imageUrl: predefinedMeal.imageUrl,
      createdAt: DateTime.now(),
    );
  }

  /// Backward compatibility getter
  int get servings => baseServings;

  /// Helper method to check if suitable for a specific health condition
  bool isSuitableFor(List<String> userConditions) {
    if (userConditions.isEmpty) return healthConditions.none;
    
    for (String condition in userConditions) {
      switch (condition.toLowerCase()) {
        case 'diabetes':
          if (!healthConditions.diabetes) return false;
          break;
        case 'hypertension':
          if (!healthConditions.hypertension) return false;
          break;
        case 'obesity':
        case 'overweight':
          if (!healthConditions.obesityOverweight) return false;
          break;
        case 'underweight':
        case 'malnutrition':
          if (!healthConditions.underweightMalnutrition) return false;
          break;
        case 'heart disease':
        case 'high cholesterol':
          if (!healthConditions.heartDiseaseChol) return false;
          break;
        case 'anemia':
          if (!healthConditions.anemia) return false;
          break;
        case 'osteoporosis':
          if (!healthConditions.osteoporosis) return false;
          break;
      }
    }
    return true;
  }

  /// Helper method to check if suitable for meal time
  bool isSuitableForMealTime(String mealTime) {
    switch (mealTime.toLowerCase()) {
      case 'breakfast':
        return mealTiming.breakfast;
      case 'lunch':
        return mealTiming.lunch;
      case 'dinner':
        return mealTiming.dinner;
      case 'snack':
        return mealTiming.snack;
      default:
        return false;
    }
  }

  /// Scale recipe for different number of people (PAX)
  Recipe scaleForPax(int targetPax) {
    final scaleFactor = targetPax / baseServings;
    
    final scaledIngredients = ingredients.map((ingredient) => 
        RecipeIngredient(
          ingredientName: ingredient.ingredientName,
          quantity: ingredient.quantity * scaleFactor,
          unit: ingredient.unit,
        )).toList();

    return Recipe(
      id: id,
      recipeName: recipeName,
      description: description,
      baseServings: targetPax,
      kcal: (kcal * scaleFactor).round(),
      funFact: funFact,
      ingredients: scaledIngredients,
      cookingInstructions: cookingInstructions,
      healthConditions: healthConditions,
      mealTiming: mealTiming,
      tags: tags,
      difficulty: difficulty,
      prepTimeMinutes: prepTimeMinutes,
      imageUrl: imageUrl,
      createdAt: createdAt,
    );
  }

  /// Copy with method for modifications
  Recipe copyWith({
    String? id,
    String? recipeName,
    String? description,
    int? baseServings,
    int? kcal,
    String? funFact,
    List<RecipeIngredient>? ingredients,
    String? cookingInstructions,
    RecipeHealthConditions? healthConditions,
    RecipeMealTiming? mealTiming,
    List<String>? tags,
    String? difficulty,
    int? prepTimeMinutes,
    String? imageUrl,
    DateTime? createdAt,
  }) {
    return Recipe(
      id: id ?? this.id,
      recipeName: recipeName ?? this.recipeName,
      description: description ?? this.description,
      baseServings: baseServings ?? this.baseServings,
      kcal: kcal ?? this.kcal,
      funFact: funFact ?? this.funFact,
      ingredients: ingredients ?? this.ingredients,
      cookingInstructions: cookingInstructions ?? this.cookingInstructions,
      healthConditions: healthConditions ?? this.healthConditions,
      mealTiming: mealTiming ?? this.mealTiming,
      tags: tags ?? this.tags,
      difficulty: difficulty ?? this.difficulty,
      prepTimeMinutes: prepTimeMinutes ?? this.prepTimeMinutes,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}