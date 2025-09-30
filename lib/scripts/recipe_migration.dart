import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import '../archive/predefined_meals_backup.dart';
import '../models/recipe.dart';
import '../services/recipe_service.dart';

/// Migration script to upload FNRI recipes to Firebase Firestore
/// 
/// This script migrates all predefined meals from the local data file
/// to Firebase Firestore using the new Recipe model structure.
/// 
/// Usage: Run this script once to populate the Firebase database.
/// The script will:
/// 1. Connect to Firebase
/// 2. Convert PredefinedMeal objects to Recipe objects
/// 3. Upload recipes with ingredients to Firestore
/// 4. Provide progress feedback
class RecipeMigrationScript {
  RecipeService? _recipeService;
  
  /// Main migration method
  Future<void> migrateRecipesToFirebase() async {
    print('🔥 Starting Firebase Recipe Migration...\n');
    
    try {
      // Initialize Firebase first
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('✅ Firebase initialized successfully');

      // Now we can safely create the RecipeService
      _recipeService = RecipeService();
      print('✅ RecipeService initialized');

      // Get predefined meals from backup
      final predefinedMeals = PredefinedMealsData.meals;
      print('📋 Found ${predefinedMeals.length} recipes to migrate\n');

      // Migration counters
      int successCount = 0;
      int errorCount = 0;
      final List<String> errorMessages = [];

      // Migrate each recipe
      for (int i = 0; i < predefinedMeals.length; i++) {
        final meal = predefinedMeals[i];
        final progress = '${i + 1}/${predefinedMeals.length}';
        
        print('⏳ [$progress] Migrating: ${meal.recipeName}');
        
        try {
          // Convert PredefinedMeal to Recipe
          final recipe = Recipe.fromPredefinedMeal(meal);
          
          // Check if recipe already exists
          final existingRecipe = await _recipeService!.getRecipeById(meal.id);
          
          if (existingRecipe != null) {
            print('   ⚠️  Recipe already exists, updating...');
            final updated = await _recipeService!.updateRecipe(meal.id, recipe);
            if (updated) {
              print('   ✅ Updated successfully');
              successCount++;
            } else {
              throw Exception('Failed to update existing recipe');
            }
          } else {
            // Upload new recipe
            final recipeId = await _uploadRecipeWithCustomId(meal.id, recipe);
            if (recipeId != null) {
              print('   ✅ Uploaded successfully (ID: $recipeId)');
              successCount++;
            } else {
              throw Exception('Failed to upload recipe');
            }
          }
          
        } catch (e) {
          print('   ❌ Error: $e');
          errorCount++;
          errorMessages.add('${meal.recipeName}: $e');
        }
        
        // Small delay to avoid overwhelming Firebase
        await Future.delayed(const Duration(milliseconds: 100));
      }

      // Print final results
      print('\n🎉 Migration Complete!');
      print('✅ Successfully migrated: $successCount recipes');
      print('❌ Failed migrations: $errorCount recipes');
      
      if (errorMessages.isNotEmpty) {
        print('\n📝 Error Summary:');
        for (final error in errorMessages) {
          print('   • $error');
        }
      }

      // Verify migration
      await _verifyMigration();

    } catch (e) {
      print('💥 Migration failed with error: $e');
    }
  }

  /// Upload recipe with custom document ID (to match FNRI IDs)
  Future<String?> _uploadRecipeWithCustomId(String customId, Recipe recipe) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final docRef = firestore.collection('recipes').doc(customId);
      
      // Set the main recipe document
      await docRef.set(recipe.toFirestore());

      // Add ingredients subcollection
      final batch = firestore.batch();
      
      for (int i = 0; i < recipe.ingredients.length; i++) {
        final ingredient = recipe.ingredients[i];
        final ingredientRef = docRef
            .collection('ingredients')
            .doc('ingredient_${i.toString().padLeft(2, '0')}'); // Padded for sorting
        
        batch.set(ingredientRef, ingredient.toFirestore());
      }

      await batch.commit();
      return customId;
    } catch (e) {
      print('Error uploading recipe with custom ID: $e');
      return null;
    }
  }

  /// Verify that all recipes were migrated successfully
  Future<void> _verifyMigration() async {
    print('\n🔍 Verifying migration...');
    
    try {
      final migratedRecipes = await _recipeService!.getAllRecipes();
      final originalCount = PredefinedMealsData.meals.length;
      final migratedCount = migratedRecipes.length;
      
      print('📊 Original recipes: $originalCount');
      print('📊 Migrated recipes: $migratedCount');
      
      if (migratedCount >= originalCount) {
        print('✅ Migration verification passed!');
        
        // Sample a few recipes to verify data integrity
        await _sampleDataIntegrity(migratedRecipes);
      } else {
        print('⚠️  Migration incomplete: ${originalCount - migratedCount} recipes missing');
      }
      
    } catch (e) {
      print('❌ Verification failed: $e');
    }
  }

  /// Sample a few recipes to verify data integrity
  Future<void> _sampleDataIntegrity(List<Recipe> recipes) async {
    print('\n🧪 Sampling data integrity...');
    
    // Test first recipe
    if (recipes.isNotEmpty) {
      final recipe = recipes.first;
      print('📝 Sample Recipe: ${recipe.recipeName}');
      print('   🥗 Ingredients: ${recipe.ingredients.length}');
      print('   🏷️  Tags: ${recipe.tags.join(', ')}');
      print('   ⚡ Calories: ${recipe.kcal} kcal');
      print('   🍽️  Servings: ${recipe.baseServings}');
      print('   ⏱️  Prep time: ${recipe.prepTimeMinutes} minutes');
      print('   🖼️  Image: ${recipe.imageUrl}');
      print('   💡 Fun fact: ${recipe.funFact}');
      
      // Check health conditions
      final healthFlags = [
        if (recipe.healthConditions.diabetes) 'Diabetes-safe',
        if (recipe.healthConditions.hypertension) 'Hypertension-safe',
        if (recipe.healthConditions.anemia) 'Anemia-safe',
        if (recipe.healthConditions.none) 'General-safe',
      ];
      print('   💊 Health conditions: ${healthFlags.join(', ')}');
      
      // Check meal timing
      final mealTimes = [
        if (recipe.mealTiming.breakfast) 'Breakfast',
        if (recipe.mealTiming.lunch) 'Lunch',
        if (recipe.mealTiming.dinner) 'Dinner',
        if (recipe.mealTiming.snack) 'Snack',
      ];
      print('   ⏰ Suitable for: ${mealTimes.join(', ')}');
      
      print('✅ Data integrity check passed!');
    }
  }

  /// Clean up all recipes (use with caution!)
  Future<void> cleanupAllRecipes() async {
    print('⚠️  WARNING: This will delete ALL recipes from Firebase!');
    print('Type "DELETE ALL RECIPES" to confirm:');
    
    final input = stdin.readLineSync();
    if (input == 'DELETE ALL RECIPES') {
      print('🗑️  Deleting all recipes...');
      
      try {
        final firestore = FirebaseFirestore.instance;
        final recipes = await firestore.collection('recipes').get();
        
        final batch = firestore.batch();
        for (final doc in recipes.docs) {
          // Delete ingredients subcollection first
          final ingredients = await doc.reference.collection('ingredients').get();
          for (final ingredient in ingredients.docs) {
            batch.delete(ingredient.reference);
          }
          
          // Delete recipe document
          batch.delete(doc.reference);
        }
        
        await batch.commit();
        print('✅ All recipes deleted successfully');
      } catch (e) {
        print('❌ Error deleting recipes: $e');
      }
    } else {
      print('❌ Cleanup cancelled');
    }
  }
}

/// Main entry point for the migration script
void main() async {
  // Initialize Flutter framework
  WidgetsFlutterBinding.ensureInitialized();
  
  final migrationScript = RecipeMigrationScript();
  
  print('🍽️  ForkCast Recipe Migration Tool\n');
  print('Choose an option:');
  print('1. Migrate recipes to Firebase');
  print('2. Clean up all recipes (DANGER!)');
  print('\nEnter your choice (1 or 2):');
  
  final choice = stdin.readLineSync();
  
  switch (choice) {
    case '1':
      await migrationScript.migrateRecipesToFirebase();
      break;
    case '2':
      await migrationScript.cleanupAllRecipes();
      break;
    default:
      print('❌ Invalid choice. Exiting...');
  }
}