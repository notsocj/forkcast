import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import '../archive/predefined_meals_backup.dart';
import '../models/recipe.dart';

/// Standalone migration script that directly uploads FNRI recipes to Firebase Firestore
/// without using any services that might cause initialization issues.
class StandaloneRecipeMigration {
  late FirebaseFirestore _firestore;

  /// Initialize Firebase and Firestore
  Future<void> initialize() async {
    print('🔥 Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    _firestore = FirebaseFirestore.instance;
    print('✅ Firebase initialized successfully\n');
  }

  /// Main migration method
  Future<void> migrateRecipesToFirebase() async {
    print('🚀 Starting FNRI Recipe Migration to Firebase\n');
    
    try {
      // Initialize Firebase first
      await initialize();

      // Get predefined meals from backup
      final predefinedMeals = PredefinedMealsData.meals;
      print('📋 Found ${predefinedMeals.length} recipes to migrate\n');

      if (predefinedMeals.isEmpty) {
        print('❌ No recipes found in backup data. Make sure the backup file contains meal data.');
        return;
      }

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
          final recipeDoc = await _firestore.collection('recipes').doc(meal.id).get();
          
          if (recipeDoc.exists) {
            print('   ⚠️  Recipe already exists, updating...');
            await _updateRecipe(meal.id, recipe);
            print('   ✅ Updated successfully');
          } else {
            print('   📝 Creating new recipe...');
            await _createRecipe(meal.id, recipe);
            print('   ✅ Created successfully');
          }
          
          successCount++;
          
        } catch (e) {
          print('   ❌ Error: $e');
          errorCount++;
          errorMessages.add('${meal.recipeName}: $e');
        }
        
        // Small delay to avoid overwhelming Firebase
        await Future.delayed(Duration(milliseconds: 100));
      }

      // Final summary
      print('\n' + '='*50);
      print('🎉 Migration Complete!');
      print('✅ Successfully migrated: $successCount recipes');
      print('❌ Errors: $errorCount recipes');
      
      if (errorMessages.isNotEmpty) {
        print('\n🚨 Error Details:');
        for (final error in errorMessages) {
          print('  • $error');
        }
      }
      
      print('\n🔍 Verifying migration...');
      final migratedRecipes = await _firestore.collection('recipes').get();
      print('📊 Total recipes in Firebase: ${migratedRecipes.docs.length}');
      print('✅ Migration verification complete!');

    } catch (e) {
      print('💥 Fatal error during migration: $e');
      rethrow;
    }
  }

  /// Create a new recipe in Firestore
  Future<void> _createRecipe(String id, Recipe recipe) async {
    final batch = _firestore.batch();
    
    // Create main recipe document
    final recipeRef = _firestore.collection('recipes').doc(id);
    batch.set(recipeRef, recipe.toFirestore());
    
    // Create ingredients subcollection
    for (int i = 0; i < recipe.ingredients.length; i++) {
      final ingredient = recipe.ingredients[i];
      final ingredientRef = recipeRef.collection('ingredients').doc('ingredient_$i');
      batch.set(ingredientRef, ingredient.toFirestore());
    }
    
    // Create health conditions subcollection
    final healthRef = recipeRef.collection('health_conditions').doc('conditions');
    batch.set(healthRef, recipe.healthConditions.toFirestore());
    
    // Create meal timing subcollection
    final timingRef = recipeRef.collection('meal_timing').doc('timing');
    batch.set(timingRef, recipe.mealTiming.toFirestore());
    
    // Commit the batch
    await batch.commit();
  }

  /// Update an existing recipe in Firestore
  Future<void> _updateRecipe(String id, Recipe recipe) async {
    final batch = _firestore.batch();
    
    // Update main recipe document
    final recipeRef = _firestore.collection('recipes').doc(id);
    batch.update(recipeRef, recipe.toFirestore());
    
    // Delete existing ingredients subcollection
    final ingredientsSnapshot = await recipeRef.collection('ingredients').get();
    for (final doc in ingredientsSnapshot.docs) {
      batch.delete(doc.reference);
    }
    
    // Recreate ingredients subcollection
    for (int i = 0; i < recipe.ingredients.length; i++) {
      final ingredient = recipe.ingredients[i];
      final ingredientRef = recipeRef.collection('ingredients').doc('ingredient_$i');
      batch.set(ingredientRef, ingredient.toFirestore());
    }
    
    // Update health conditions
    final healthRef = recipeRef.collection('health_conditions').doc('conditions');
    batch.set(healthRef, recipe.healthConditions.toFirestore());
    
    // Update meal timing
    final timingRef = recipeRef.collection('meal_timing').doc('timing');
    batch.set(timingRef, recipe.mealTiming.toFirestore());
    
    // Commit the batch
    await batch.commit();
  }

  /// Clean up all recipes from Firebase (DANGER!)
  Future<void> cleanupAllRecipes() async {
    print('⚠️  WARNING: This will delete ALL recipes from Firebase!');
    print('Type "DELETE ALL RECIPES" to confirm:');
    
    final input = stdin.readLineSync();
    if (input == 'DELETE ALL RECIPES') {
      print('🗑️  Deleting all recipes...');
      
      try {
        await initialize();
        
        final recipes = await _firestore.collection('recipes').get();
        print('📋 Found ${recipes.docs.length} recipes to delete');
        
        final batch = _firestore.batch();
        int deleteCount = 0;
        
        for (final doc in recipes.docs) {
          // Delete ingredients subcollection
          final ingredients = await doc.reference.collection('ingredients').get();
          for (final ingredientDoc in ingredients.docs) {
            batch.delete(ingredientDoc.reference);
          }
          
          // Delete health conditions subcollection
          final healthConditions = await doc.reference.collection('health_conditions').get();
          for (final healthDoc in healthConditions.docs) {
            batch.delete(healthDoc.reference);
          }
          
          // Delete meal timing subcollection
          final mealTiming = await doc.reference.collection('meal_timing').get();
          for (final timingDoc in mealTiming.docs) {
            batch.delete(timingDoc.reference);
          }
          
          // Delete main recipe document
          batch.delete(doc.reference);
          deleteCount++;
        }
        
        await batch.commit();
        print('✅ Successfully deleted $deleteCount recipes');
        
      } catch (e) {
        print('❌ Error during cleanup: $e');
      }
    } else {
      print('❌ Cleanup cancelled');
    }
  }
}

/// Main entry point for the standalone migration script
void main() async {
  // Initialize Flutter framework
  WidgetsFlutterBinding.ensureInitialized();
  
  final migration = StandaloneRecipeMigration();
  
  print('🍽️  ForkCast Standalone Recipe Migration Tool\n');
  print('🚀 Auto-starting recipe migration...');
  
  try {
    await migration.migrateRecipesToFirebase();
  } catch (e) {
    print('💥 Migration failed: $e');
  }
  
  print('\n🎉 Migration tool completed. You can now close this app.');
}