import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/recipe.dart';

class RecipeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'recipes';

  // Cache for better performance
  List<Recipe>? _cachedRecipes;
  DateTime? _lastCacheTime;
  static const Duration _cacheValidDuration = Duration(hours: 1);

  /// Get all recipes from Firebase with caching
  Future<List<Recipe>> getAllRecipes() async {
    // Return cached data if still valid
    if (_cachedRecipes != null && 
        _lastCacheTime != null &&
        DateTime.now().difference(_lastCacheTime!) < _cacheValidDuration) {
      return _cachedRecipes!;
    }

    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .orderBy('recipe_name')
          .get();

      final recipes = <Recipe>[];
      
      for (final doc in querySnapshot.docs) {
        final recipe = await _buildRecipeFromDocument(doc);
        recipes.add(recipe);
      }

      // Update cache
      _cachedRecipes = recipes;
      _lastCacheTime = DateTime.now();

      return recipes;
    } catch (e) {
      print('Error getting recipes: $e');
      return [];
    }
  }

  /// Get recipe by ID
  Future<Recipe?> getRecipeById(String recipeId) async {
    try {
      final doc = await _firestore
          .collection(_collection)
          .doc(recipeId)
          .get();

      if (!doc.exists) return null;

      return await _buildRecipeFromDocumentSnapshot(doc);
    } catch (e) {
      print('Error getting recipe by ID: $e');
      return null;
    }
  }

  /// Search recipes by name, ingredients, or tags with advanced filtering
  Future<List<Recipe>> searchRecipes(String query, {
    List<String>? healthConditions,
    List<String>? mealTypes,
    String? prepTimeRange,
    List<String>? mainIngredients,
  }) async {
    try {
      final recipes = await getAllRecipes();
      
      final filteredRecipes = recipes.where((recipe) {
        // Text search filter
        bool textMatch = true;
        if (query.isNotEmpty) {
          final lowercaseQuery = query.toLowerCase();
          
          // Search in recipe name
          final nameMatch = recipe.recipeName.toLowerCase().contains(lowercaseQuery);
          
          // Search in description
          final descMatch = recipe.description.toLowerCase().contains(lowercaseQuery);
          
          // Search in tags
          final tagMatch = recipe.tags.any((tag) => 
              tag.toLowerCase().contains(lowercaseQuery));
          
          // Search in ingredients
          final ingredientMatch = recipe.ingredients.any((ingredient) =>
              ingredient.ingredientName.toLowerCase().contains(lowercaseQuery));

          textMatch = nameMatch || descMatch || tagMatch || ingredientMatch;
        }

        // Health condition filter
        bool healthMatch = true;
        if (healthConditions != null && healthConditions.isNotEmpty) {
          healthMatch = recipe.isSuitableFor(healthConditions);
        }

        // Meal type filter
        bool mealTypeMatch = true;
        if (mealTypes != null && mealTypes.isNotEmpty) {
          mealTypeMatch = mealTypes.any((mealType) => 
              recipe.isSuitableForMealTime(mealType));
        }

        // Prep time filter
        bool prepTimeMatch = true;
        if (prepTimeRange != null) {
          prepTimeMatch = _matchesPrepTimeRange(recipe.prepTimeMinutes, prepTimeRange);
        }

        // Main ingredient filter
        bool ingredientMatch = true;
        if (mainIngredients != null && mainIngredients.isNotEmpty) {
          ingredientMatch = mainIngredients.any((mainIngredient) =>
              recipe.ingredients.any((ingredient) =>
                  ingredient.ingredientName.toLowerCase().contains(mainIngredient.toLowerCase())));
        }

        return textMatch && healthMatch && mealTypeMatch && prepTimeMatch && ingredientMatch;
      }).toList();

      return filteredRecipes;
    } catch (e) {
      print('Error searching recipes: $e');
      return [];
    }
  }

  /// Get recipes suitable for specific health conditions
  Future<List<Recipe>> getRecipesForHealthConditions(List<String> healthConditions) async {
    try {
      final recipes = await getAllRecipes();
      
      return recipes.where((recipe) => 
          recipe.isSuitableFor(healthConditions)).toList();
    } catch (e) {
      print('Error getting recipes for health conditions: $e');
      return [];
    }
  }

  /// Get recipes suitable for specific meal time
  Future<List<Recipe>> getRecipesForMealTime(String mealTime) async {
    try {
      final recipes = await getAllRecipes();
      
      return recipes.where((recipe) => 
          recipe.isSuitableForMealTime(mealTime)).toList();
    } catch (e) {
      print('Error getting recipes for meal time: $e');
      return [];
    }
  }

  /// Get recipes by tags
  Future<List<Recipe>> getRecipesByTags(List<String> tags) async {
    try {
      final recipes = await getAllRecipes();
      
      return recipes.where((recipe) => 
          tags.any((tag) => recipe.tags.contains(tag))).toList();
    } catch (e) {
      print('Error getting recipes by tags: $e');
      return [];
    }
  }

  /// Get recipes within calorie range
  Future<List<Recipe>> getRecipesByCalories(int minKcal, int maxKcal) async {
    try {
      final recipes = await getAllRecipes();
      
      return recipes.where((recipe) => 
          recipe.kcal >= minKcal && recipe.kcal <= maxKcal).toList();
    } catch (e) {
      print('Error getting recipes by calories: $e');
      return [];
    }
  }

  /// Add a new recipe to Firebase
  Future<String?> addRecipe(Recipe recipe) async {
    try {
      final docRef = await _firestore
          .collection(_collection)
          .add(recipe.toFirestore());

      // Add ingredients subcollection
      final batch = _firestore.batch();
      
      for (int i = 0; i < recipe.ingredients.length; i++) {
        final ingredient = recipe.ingredients[i];
        final ingredientRef = docRef
            .collection('ingredients')
            .doc('ingredient_$i');
        
        batch.set(ingredientRef, ingredient.toFirestore());
      }

      await batch.commit();

      // Clear cache to force refresh
      _clearCache();

      return docRef.id;
    } catch (e) {
      print('Error adding recipe: $e');
      return null;
    }
  }

  /// Update an existing recipe
  Future<bool> updateRecipe(String recipeId, Recipe recipe) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(recipeId)
          .update(recipe.toFirestore());

      // Update ingredients subcollection
      final ingredientsRef = _firestore
          .collection(_collection)
          .doc(recipeId)
          .collection('ingredients');

      // Delete existing ingredients
      final existingIngredients = await ingredientsRef.get();
      final batch = _firestore.batch();
      
      for (final doc in existingIngredients.docs) {
        batch.delete(doc.reference);
      }

      // Add updated ingredients
      for (int i = 0; i < recipe.ingredients.length; i++) {
        final ingredient = recipe.ingredients[i];
        final ingredientRef = ingredientsRef.doc('ingredient_$i');
        batch.set(ingredientRef, ingredient.toFirestore());
      }

      await batch.commit();

      // Clear cache to force refresh
      _clearCache();

      return true;
    } catch (e) {
      print('Error updating recipe: $e');
      return false;
    }
  }

  /// Delete a recipe
  Future<bool> deleteRecipe(String recipeId) async {
    try {
      // Delete ingredients subcollection first
      final ingredientsRef = _firestore
          .collection(_collection)
          .doc(recipeId)
          .collection('ingredients');

      final ingredients = await ingredientsRef.get();
      final batch = _firestore.batch();
      
      for (final doc in ingredients.docs) {
        batch.delete(doc.reference);
      }

      // Delete the recipe document
      batch.delete(_firestore.collection(_collection).doc(recipeId));

      await batch.commit();

      // Clear cache to force refresh
      _clearCache();

      return true;
    } catch (e) {
      print('Error deleting recipe: $e');
      return false;
    }
  }

  /// Build Recipe object from Firestore document
  Future<Recipe> _buildRecipeFromDocument(QueryDocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>;
    
    // Get ingredients from subcollection
    final ingredientsSnapshot = await doc.reference
        .collection('ingredients')
        .get();

    final ingredients = ingredientsSnapshot.docs
        .map((ingredientDoc) => RecipeIngredient.fromFirestore(
            ingredientDoc.data()))
        .toList();

    // Sort ingredients by document ID to maintain order
    ingredients.sort((a, b) => 
        ingredientsSnapshot.docs
            .firstWhere((doc) => doc.data()['ingredient_name'] == a.ingredientName)
            .id
            .compareTo(
                ingredientsSnapshot.docs
                    .firstWhere((doc) => doc.data()['ingredient_name'] == b.ingredientName)
                    .id
            ));

    return Recipe.fromFirestore(data, doc.id, ingredients);
  }

  /// Build Recipe object from DocumentSnapshot (for getById)
  Future<Recipe> _buildRecipeFromDocumentSnapshot(DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>;
    
    // Get ingredients from subcollection
    final ingredientsSnapshot = await doc.reference
        .collection('ingredients')
        .get();

    final ingredients = ingredientsSnapshot.docs
        .map((ingredientDoc) => RecipeIngredient.fromFirestore(
            ingredientDoc.data()))
        .toList();

    // Sort ingredients by document ID to maintain order
    ingredients.sort((a, b) => 
        ingredientsSnapshot.docs
            .firstWhere((doc) => doc.data()['ingredient_name'] == a.ingredientName)
            .id
            .compareTo(
                ingredientsSnapshot.docs
                    .firstWhere((doc) => doc.data()['ingredient_name'] == b.ingredientName)
                    .id
            ));

    return Recipe.fromFirestore(data, doc.id, ingredients);
  }

  /// Clear the cache
  void _clearCache() {
    _cachedRecipes = null;
    _lastCacheTime = null;
  }

  /// Helper method to check if prep time matches the specified range
  bool _matchesPrepTimeRange(int prepTimeMinutes, String range) {
    switch (range.toLowerCase()) {
      case 'under 20 mins':
      case 'under 20':
        return prepTimeMinutes < 20;
      case '15–30 min':
      case '15-30 min':
      case '15-30':
        return prepTimeMinutes >= 15 && prepTimeMinutes <= 30;
      case '30–60 min':
      case '30-60 min':
      case '30-60':
        return prepTimeMinutes >= 30 && prepTimeMinutes <= 60;
      case 'over 1 hour':
      case 'over 60':
        return prepTimeMinutes > 60;
      default:
        return true; // No filter applied
    }
  }

  /// Force refresh cache
  Future<List<Recipe>> refreshRecipes() async {
    _clearCache();
    return await getAllRecipes();
  }
}