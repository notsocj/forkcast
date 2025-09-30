import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Temporary simplified models for migration
class SimpleMeal {
  final String id;
  final String recipeName;
  final String description;
  final int kcal;
  final int baseServings;
  final String funFact;
  final List<SimpleIngredient> ingredients;
  final String cookingInstructions;
  final Map<String, bool> healthConditions;
  final Map<String, bool> mealTiming;
  final List<String> tags;
  final String difficulty;
  final int prepTimeMinutes;
  final String imageUrl;

  SimpleMeal({
    required this.id,
    required this.recipeName,
    required this.description,
    required this.kcal,
    required this.baseServings,
    required this.funFact,
    required this.ingredients,
    required this.cookingInstructions,
    required this.healthConditions,
    required this.mealTiming,
    required this.tags,
    required this.difficulty,
    required this.prepTimeMinutes,
    required this.imageUrl,
  });
}

class SimpleIngredient {
  final String name;
  final double quantity;
  final String unit;

  SimpleIngredient({
    required this.name,
    required this.quantity,
    required this.unit,
  });
}

// FNRI Recipe Data
final List<SimpleMeal> fnriRecipes = [
  SimpleMeal(
    id: 'adobong_manok',
    recipeName: 'Adobong Manok',
    description: 'Classic Filipino chicken adobo with soy sauce and vinegar',
    kcal: 285,
    baseServings: 4,
    funFact: 'Adobo is considered the unofficial national dish of the Philippines',
    ingredients: [
      SimpleIngredient(name: 'Chicken (cut into pieces)', quantity: 1.0, unit: 'kg'),
      SimpleIngredient(name: 'Soy sauce', quantity: 0.5, unit: 'cup'),
      SimpleIngredient(name: 'White vinegar', quantity: 0.25, unit: 'cup'),
      SimpleIngredient(name: 'Garlic (minced)', quantity: 6.0, unit: 'cloves'),
      SimpleIngredient(name: 'Bay leaves', quantity: 3.0, unit: 'pieces'),
      SimpleIngredient(name: 'Black peppercorns', quantity: 1.0, unit: 'tsp'),
      SimpleIngredient(name: 'Cooking oil', quantity: 2.0, unit: 'tbsp'),
    ],
    cookingInstructions: 'Marinate chicken in soy sauce and vinegar for 30 minutes. Heat oil and brown chicken. Add garlic, bay leaves, and peppercorns. Simmer for 30-40 minutes until tender.',
    healthConditions: {
      'diabetes': true,
      'hypertension': false, // High sodium
      'obesity_overweight': true,
      'underweight_malnutrition': true,
      'heart_disease_chol': false, // High sodium
      'anemia': true,
      'osteoporosis': true,
      'none': true,
    },
    mealTiming: {
      'breakfast': false,
      'lunch': true,
      'dinner': true,
      'snack': false,
    },
    tags: ['Filipino', 'Protein-rich', 'Traditional'],
    difficulty: 'Medium',
    prepTimeMinutes: 60,
    imageUrl: 'assets/images/meals_pictures/adobong_manok.jpg',
  ),
  SimpleMeal(
    id: 'sinigang_na_hipon',
    recipeName: 'Sinigang na Hipon',
    description: 'Sour tamarind soup with shrimp and vegetables',
    kcal: 180,
    baseServings: 6,
    funFact: 'Sinigang is voted as the most popular Filipino dish among Filipinos',
    ingredients: [
      SimpleIngredient(name: 'Fresh shrimp (medium)', quantity: 0.5, unit: 'kg'),
      SimpleIngredient(name: 'Tamarind paste', quantity: 2.0, unit: 'tbsp'),
      SimpleIngredient(name: 'Tomatoes (quartered)', quantity: 2.0, unit: 'pieces'),
      SimpleIngredient(name: 'Onion (sliced)', quantity: 1.0, unit: 'medium'),
      SimpleIngredient(name: 'Kangkong', quantity: 1.0, unit: 'bunch'),
      SimpleIngredient(name: 'Radish (sliced)', quantity: 1.0, unit: 'medium'),
      SimpleIngredient(name: 'Green beans', quantity: 0.25, unit: 'kg'),
      SimpleIngredient(name: 'Fish sauce', quantity: 2.0, unit: 'tbsp'),
    ],
    cookingInstructions: 'Boil water with tamarind paste. Add tomatoes and onions. Add shrimp and cook for 3-5 minutes. Add vegetables and simmer until tender. Season with fish sauce.',
    healthConditions: {
      'diabetes': true,
      'hypertension': true,
      'obesity_overweight': true,
      'underweight_malnutrition': true,
      'heart_disease_chol': true,
      'anemia': true,
      'osteoporosis': true,
      'none': true,
    },
    mealTiming: {
      'breakfast': false,
      'lunch': true,
      'dinner': true,
      'snack': false,
    },
    tags: ['Filipino', 'Soup', 'Seafood', 'Vegetables'],
    difficulty: 'Easy',
    prepTimeMinutes: 30,
    imageUrl: 'assets/images/meals_pictures/sinigang_na_hipon.jpg',
  ),
  SimpleMeal(
    id: 'grilled_bangus',
    recipeName: 'Grilled Bangus',
    description: 'Healthy grilled milkfish with minimal oil',
    kcal: 220,
    baseServings: 2,
    funFact: 'Bangus is the Philippines\' national fish and excellent source of protein',
    ingredients: [
      SimpleIngredient(name: 'Bangus (milkfish)', quantity: 1.0, unit: 'whole'),
      SimpleIngredient(name: 'Lemon juice', quantity: 2.0, unit: 'tbsp'),
      SimpleIngredient(name: 'Salt', quantity: 1.0, unit: 'tsp'),
      SimpleIngredient(name: 'Black pepper', quantity: 0.5, unit: 'tsp'),
      SimpleIngredient(name: 'Garlic powder', quantity: 1.0, unit: 'tsp'),
    ],
    cookingInstructions: 'Clean and score the fish. Marinate with lemon juice, salt, pepper, and garlic powder for 30 minutes. Grill for 8-10 minutes per side until cooked through.',
    healthConditions: {
      'diabetes': true,
      'hypertension': true,
      'obesity_overweight': true,
      'underweight_malnutrition': true,
      'heart_disease_chol': true,
      'anemia': true,
      'osteoporosis': true,
      'none': true,
    },
    mealTiming: {
      'breakfast': false,
      'lunch': true,
      'dinner': true,
      'snack': false,
    },
    tags: ['Healthy', 'Grilled', 'Fish', 'Low-fat'],
    difficulty: 'Easy',
    prepTimeMinutes: 45,
    imageUrl: 'assets/images/meals_pictures/grilled_bangus.jpg',
  ),
  // Add more recipes as needed...
];

Future<void> main() async {
  print('🔥 FNRI Recipe Migration to Firebase Firestore');
  print('=' * 50);
  
  try {
    // Initialize Firebase (this works better in console apps)
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "your-api-key", // You'll need to add your actual Firebase config
        appId: "your-app-id",
        messagingSenderId: "your-sender-id",
        projectId: "your-project-id",
      ),
    );
    
    print('✅ Firebase initialized successfully');
    print('📋 Found ${fnriRecipes.length} recipes to migrate\n');

    final firestore = FirebaseFirestore.instance;
    int successCount = 0;
    int errorCount = 0;

    for (int i = 0; i < fnriRecipes.length; i++) {
      final meal = fnriRecipes[i];
      print('📝 [${i + 1}/${fnriRecipes.length}] Migrating: ${meal.recipeName}');

      try {
        // Create main recipe document
        final recipeData = {
          'recipe_name': meal.recipeName,
          'description': meal.description,
          'servings': meal.baseServings,
          'kcal': meal.kcal,
          'fun_fact': meal.funFact,
          'cooking_instructions': meal.cookingInstructions,
          'tags': meal.tags,
          'difficulty': meal.difficulty,
          'prep_time_minutes': meal.prepTimeMinutes,
          'image_url': meal.imageUrl,
          'created_at': FieldValue.serverTimestamp(),
          // Health conditions
          'diabetes': meal.healthConditions['diabetes'] ?? false,
          'hypertension': meal.healthConditions['hypertension'] ?? false,
          'obesity_overweight': meal.healthConditions['obesity_overweight'] ?? false,
          'underweight_malnutrition': meal.healthConditions['underweight_malnutrition'] ?? false,
          'heart_disease_chol': meal.healthConditions['heart_disease_chol'] ?? false,
          'anemia': meal.healthConditions['anemia'] ?? false,
          'osteoporosis': meal.healthConditions['osteoporosis'] ?? false,
          'none': meal.healthConditions['none'] ?? false,
          // Meal timing
          'breakfast': meal.mealTiming['breakfast'] ?? false,
          'lunch': meal.mealTiming['lunch'] ?? false,
          'dinner': meal.mealTiming['dinner'] ?? false,
          'snack': meal.mealTiming['snack'] ?? false,
        };

        // Add recipe to Firestore
        final recipeRef = await firestore.collection('recipes').add(recipeData);
        print('   ✅ Recipe document created: ${recipeRef.id}');

        // Add ingredients subcollection
        for (final ingredient in meal.ingredients) {
          await recipeRef.collection('ingredients').add({
            'ingredient_name': ingredient.name,
            'quantity': ingredient.quantity,
            'unit': ingredient.unit,
          });
        }

        print('   ✅ Added ${meal.ingredients.length} ingredients');
        successCount++;
        
      } catch (e) {
        print('   ❌ Error migrating ${meal.recipeName}: $e');
        errorCount++;
      }

      // Small delay to avoid overwhelming Firebase
      await Future.delayed(Duration(milliseconds: 100));
    }

    print('\n' + '=' * 50);
    print('🎉 Migration Complete!');
    print('✅ Successfully migrated: $successCount recipes');
    if (errorCount > 0) {
      print('❌ Failed to migrate: $errorCount recipes');
    }
    print('📊 Total processed: ${successCount + errorCount} recipes');
    print('🔗 Check your Firebase Firestore console to verify the data');

  } catch (e) {
    print('❌ Migration failed: $e');
    exit(1);
  }
}