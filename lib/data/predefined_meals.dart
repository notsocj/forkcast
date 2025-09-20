// Predefined meals data for ForkCast
// This file contains a comprehensive list of Filipino and international dishes
// Used instead of Firebase recipes collection for meal planning functionality

class PredefinedMeal {
  final String id;
  final String recipeName;
  final String description;
  final int kcal;
  final int servings;
  final String cookingInstructions;
  final List<String> tags;
  final String difficulty;
  final int prepTimeMinutes;
  final String imageUrl;
  final List<MealIngredient> ingredients;

  const PredefinedMeal({
    required this.id,
    required this.recipeName,
    required this.description,
    required this.kcal,
    required this.servings,
    required this.cookingInstructions,
    required this.tags,
    required this.difficulty,
    required this.prepTimeMinutes,
    required this.imageUrl,
    required this.ingredients,
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

class PredefinedMealsData {
  static const List<PredefinedMeal> meals = [
    // === FILIPINO BREAKFAST ===
    PredefinedMeal(
      id: 'fil_001',
      recipeName: 'Tapsilog',
      description: 'Filipino breakfast combo with beef tapa, sinangag (garlic rice), and itlog (egg)',
      kcal: 580,
      servings: 1,
      cookingInstructions: '1. Marinate beef strips in soy sauce, garlic, and sugar for 2 hours.\n2. Pan-fry beef until caramelized.\n3. Prepare garlic fried rice with day-old rice.\n4. Fry egg sunny-side up.\n5. Serve together with pickled vegetables.',
      tags: ['Filipino', 'Breakfast', 'High-protein', 'Comfort food'],
      difficulty: 'Medium',
      prepTimeMinutes: 30,
      imageUrl: 'https://via.placeholder.com/300x200/4CAF50/FFFFFF?text=Tapsilog',
      ingredients: [
        MealIngredient(ingredientName: 'Beef sirloin', quantity: 150, unit: 'g'),
        MealIngredient(ingredientName: 'Cooked rice', quantity: 1, unit: 'cup'),
        MealIngredient(ingredientName: 'Egg', quantity: 1, unit: 'piece'),
        MealIngredient(ingredientName: 'Garlic', quantity: 3, unit: 'cloves'),
        MealIngredient(ingredientName: 'Soy sauce', quantity: 2, unit: 'tbsp'),
        MealIngredient(ingredientName: 'Brown sugar', quantity: 1, unit: 'tbsp'),
      ],
    ),

    PredefinedMeal(
      id: 'fil_002',
      recipeName: 'Longsilog',
      description: 'Sweet Filipino longanisa sausage with garlic rice and egg',
      kcal: 620,
      servings: 1,
      cookingInstructions: '1. Pan-fry longanisa until golden brown and cooked through.\n2. Prepare garlic fried rice using the oil from longanisa.\n3. Fry egg to preference.\n4. Serve hot with atchara (pickled papaya).',
      tags: ['Filipino', 'Breakfast', 'Sweet', 'Traditional'],
      difficulty: 'Easy',
      prepTimeMinutes: 20,
      imageUrl: 'https://via.placeholder.com/300x200/FF9800/FFFFFF?text=Longsilog',
      ingredients: [
        MealIngredient(ingredientName: 'Longanisa', quantity: 4, unit: 'pieces'),
        MealIngredient(ingredientName: 'Cooked rice', quantity: 1, unit: 'cup'),
        MealIngredient(ingredientName: 'Egg', quantity: 1, unit: 'piece'),
        MealIngredient(ingredientName: 'Garlic', quantity: 2, unit: 'cloves'),
        MealIngredient(ingredientName: 'Cooking oil', quantity: 2, unit: 'tbsp'),
      ],
    ),

    PredefinedMeal(
      id: 'fil_003',
      recipeName: 'Champorado',
      description: 'Filipino chocolate rice porridge, perfect for breakfast',
      kcal: 320,
      servings: 1,
      cookingInstructions: '1. Cook glutinous rice with water until soft.\n2. Add tablea or cocoa powder, stir continuously.\n3. Sweeten with brown sugar to taste.\n4. Serve hot with tuyo (dried fish) or evaporated milk.',
      tags: ['Filipino', 'Breakfast', 'Sweet', 'Porridge', 'Traditional'],
      difficulty: 'Easy',
      prepTimeMinutes: 25,
      imageUrl: 'https://via.placeholder.com/300x200/8D6E63/FFFFFF?text=Champorado',
      ingredients: [
        MealIngredient(ingredientName: 'Glutinous rice', quantity: 0.5, unit: 'cup'),
        MealIngredient(ingredientName: 'Tablea or cocoa powder', quantity: 2, unit: 'tbsp'),
        MealIngredient(ingredientName: 'Brown sugar', quantity: 3, unit: 'tbsp'),
        MealIngredient(ingredientName: 'Water', quantity: 2, unit: 'cups'),
        MealIngredient(ingredientName: 'Evaporated milk', quantity: 2, unit: 'tbsp'),
      ],
    ),

    // === FILIPINO LUNCH/DINNER ===
    PredefinedMeal(
      id: 'fil_004',
      recipeName: 'Adobong Manok',
      description: 'Classic Filipino chicken adobo in soy sauce and vinegar',
      kcal: 485,
      servings: 4,
      cookingInstructions: '1. Marinate chicken pieces in soy sauce and vinegar for 30 minutes.\n2. Brown chicken in oil, remove and set aside.\n3. Sauté garlic and onion.\n4. Add marinade, bring to boil, add chicken back.\n5. Simmer covered for 30-40 minutes until tender.\n6. Serve with steamed rice.',
      tags: ['Filipino', 'Main dish', 'Traditional', 'Salty', 'High-protein'],
      difficulty: 'Easy',
      prepTimeMinutes: 60,
      imageUrl: 'https://via.placeholder.com/300x200/795548/FFFFFF?text=Adobong+Manok',
      ingredients: [
        MealIngredient(ingredientName: 'Chicken', quantity: 1, unit: 'kg'),
        MealIngredient(ingredientName: 'Soy sauce', quantity: 0.5, unit: 'cup'),
        MealIngredient(ingredientName: 'Vinegar', quantity: 0.25, unit: 'cup'),
        MealIngredient(ingredientName: 'Garlic', quantity: 6, unit: 'cloves'),
        MealIngredient(ingredientName: 'Onion', quantity: 1, unit: 'medium'),
        MealIngredient(ingredientName: 'Bay leaves', quantity: 3, unit: 'pieces'),
        MealIngredient(ingredientName: 'Black peppercorns', quantity: 1, unit: 'tsp'),
      ],
    ),

    PredefinedMeal(
      id: 'fil_005',
      recipeName: 'Sinigang na Baboy',
      description: 'Sour Filipino pork soup with tamarind and vegetables',
      kcal: 380,
      servings: 6,
      cookingInstructions: '1. Boil pork ribs until tender (about 1 hour).\n2. Add onion and tomato, cook until soft.\n3. Add sinigang mix or tamarind paste.\n4. Add radish, cook for 5 minutes.\n5. Add kangkong and other vegetables.\n6. Season with fish sauce. Serve hot.',
      tags: ['Filipino', 'Soup', 'Sour', 'Vegetables', 'Traditional'],
      difficulty: 'Medium',
      prepTimeMinutes: 90,
      imageUrl: 'https://via.placeholder.com/300x200/4CAF50/FFFFFF?text=Sinigang+na+Baboy',
      ingredients: [
        MealIngredient(ingredientName: 'Pork ribs', quantity: 500, unit: 'g'),
        MealIngredient(ingredientName: 'Sinigang mix', quantity: 1, unit: 'pack'),
        MealIngredient(ingredientName: 'Kangkong', quantity: 1, unit: 'bundle'),
        MealIngredient(ingredientName: 'Radish', quantity: 1, unit: 'medium'),
        MealIngredient(ingredientName: 'Tomato', quantity: 2, unit: 'medium'),
        MealIngredient(ingredientName: 'Onion', quantity: 1, unit: 'medium'),
        MealIngredient(ingredientName: 'Fish sauce', quantity: 2, unit: 'tbsp'),
      ],
    ),

    PredefinedMeal(
      id: 'fil_006',
      recipeName: 'Kare-Kare',
      description: 'Filipino oxtail stew with peanut sauce and vegetables',
      kcal: 520,
      servings: 6,
      cookingInstructions: '1. Boil oxtail and tripe until tender (2-3 hours).\n2. In another pot, sauté garlic and onion.\n3. Add ground peanuts and rice flour, gradually add broth.\n4. Add oxtail and vegetables (eggplant, kangkong, banana heart).\n5. Simmer until vegetables are tender.\n6. Serve with bagoong (shrimp paste).',
      tags: ['Filipino', 'Main dish', 'Traditional', 'Peanut sauce', 'Special occasion'],
      difficulty: 'Hard',
      prepTimeMinutes: 180,
      imageUrl: 'https://via.placeholder.com/300x200/FF5722/FFFFFF?text=Kare-Kare',
      ingredients: [
        MealIngredient(ingredientName: 'Oxtail', quantity: 1, unit: 'kg'),
        MealIngredient(ingredientName: 'Ground peanuts', quantity: 1, unit: 'cup'),
        MealIngredient(ingredientName: 'Rice flour', quantity: 3, unit: 'tbsp'),
        MealIngredient(ingredientName: 'Eggplant', quantity: 2, unit: 'medium'),
        MealIngredient(ingredientName: 'Kangkong', quantity: 1, unit: 'bundle'),
        MealIngredient(ingredientName: 'Banana heart', quantity: 0.5, unit: 'cup'),
        MealIngredient(ingredientName: 'Bagoong', quantity: 2, unit: 'tbsp'),
      ],
    ),

    PredefinedMeal(
      id: 'fil_007',
      recipeName: 'Pinakbet',
      description: 'Mixed vegetables stew with shrimp paste, Ilocano style',
      kcal: 180,
      servings: 4,
      cookingInstructions: '1. Sauté garlic, onion, and tomato.\n2. Add pork belly, cook until lightly browned.\n3. Add bagoong (shrimp paste) and a little water.\n4. Layer vegetables according to cooking time (squash, eggplant, okra, sitaw, ampalaya).\n5. Cover and steam until vegetables are tender.\n6. Serve with steamed rice.',
      tags: ['Filipino', 'Vegetables', 'Low-calorie', 'Traditional', 'Healthy'],
      difficulty: 'Medium',
      prepTimeMinutes: 45,
      imageUrl: 'https://via.placeholder.com/300x200/8BC34A/FFFFFF?text=Pinakbet',
      ingredients: [
        MealIngredient(ingredientName: 'Pork belly', quantity: 200, unit: 'g'),
        MealIngredient(ingredientName: 'Squash', quantity: 1, unit: 'cup'),
        MealIngredient(ingredientName: 'Eggplant', quantity: 1, unit: 'medium'),
        MealIngredient(ingredientName: 'Okra', quantity: 10, unit: 'pieces'),
        MealIngredient(ingredientName: 'String beans', quantity: 10, unit: 'pieces'),
        MealIngredient(ingredientName: 'Bitter melon', quantity: 1, unit: 'small'),
        MealIngredient(ingredientName: 'Bagoong', quantity: 2, unit: 'tbsp'),
      ],
    ),

    // === INTERNATIONAL DISHES ===
    PredefinedMeal(
      id: 'int_001',
      recipeName: 'Grilled Chicken Caesar Salad',
      description: 'Fresh romaine lettuce with grilled chicken, parmesan, and caesar dressing',
      kcal: 420,
      servings: 1,
      cookingInstructions: '1. Season and grill chicken breast until fully cooked.\n2. Wash and chop romaine lettuce.\n3. Prepare caesar dressing with mayo, parmesan, lemon, and anchovies.\n4. Toss lettuce with dressing.\n5. Top with sliced grilled chicken and parmesan cheese.\n6. Serve with croutons.',
      tags: ['International', 'Salad', 'High-protein', 'Low-carb', 'Healthy'],
      difficulty: 'Easy',
      prepTimeMinutes: 20,
      imageUrl: 'https://via.placeholder.com/300x200/4CAF50/FFFFFF?text=Caesar+Salad',
      ingredients: [
        MealIngredient(ingredientName: 'Chicken breast', quantity: 150, unit: 'g'),
        MealIngredient(ingredientName: 'Romaine lettuce', quantity: 2, unit: 'cups'),
        MealIngredient(ingredientName: 'Parmesan cheese', quantity: 30, unit: 'g'),
        MealIngredient(ingredientName: 'Caesar dressing', quantity: 3, unit: 'tbsp'),
        MealIngredient(ingredientName: 'Croutons', quantity: 0.25, unit: 'cup'),
      ],
    ),

    PredefinedMeal(
      id: 'int_002',
      recipeName: 'Spaghetti Carbonara',
      description: 'Classic Italian pasta with eggs, cheese, pancetta, and black pepper',
      kcal: 580,
      servings: 1,
      cookingInstructions: '1. Cook spaghetti al dente according to package instructions.\n2. Render pancetta in a pan until crispy.\n3. Beat eggs with parmesan cheese and black pepper.\n4. Drain pasta, reserving some pasta water.\n5. Toss hot pasta with pancetta, then with egg mixture off heat.\n6. Add pasta water if needed. Serve immediately.',
      tags: ['International', 'Italian', 'Pasta', 'High-calorie', 'Comfort food'],
      difficulty: 'Medium',
      prepTimeMinutes: 25,
      imageUrl: 'https://via.placeholder.com/300x200/FFD700/FFFFFF?text=Carbonara',
      ingredients: [
        MealIngredient(ingredientName: 'Spaghetti', quantity: 100, unit: 'g'),
        MealIngredient(ingredientName: 'Pancetta', quantity: 50, unit: 'g'),
        MealIngredient(ingredientName: 'Eggs', quantity: 2, unit: 'pieces'),
        MealIngredient(ingredientName: 'Parmesan cheese', quantity: 50, unit: 'g'),
        MealIngredient(ingredientName: 'Black pepper', quantity: 1, unit: 'tsp'),
      ],
    ),

    PredefinedMeal(
      id: 'int_003',
      recipeName: 'Beef Teriyaki Bowl',
      description: 'Japanese-style beef with teriyaki sauce over steamed rice',
      kcal: 520,
      servings: 1,
      cookingInstructions: '1. Slice beef thinly against the grain.\n2. Make teriyaki sauce with soy sauce, mirin, sake, and sugar.\n3. Marinate beef in half the sauce for 15 minutes.\n4. Cook beef in a hot pan until caramelized.\n5. Add remaining sauce and cook until glossy.\n6. Serve over steamed rice with vegetables.',
      tags: ['International', 'Japanese', 'Rice bowl', 'High-protein', 'Asian'],
      difficulty: 'Medium',
      prepTimeMinutes: 35,
      imageUrl: 'https://via.placeholder.com/300x200/8BC34A/FFFFFF?text=Teriyaki+Bowl',
      ingredients: [
        MealIngredient(ingredientName: 'Beef sirloin', quantity: 150, unit: 'g'),
        MealIngredient(ingredientName: 'Steamed rice', quantity: 1, unit: 'cup'),
        MealIngredient(ingredientName: 'Soy sauce', quantity: 3, unit: 'tbsp'),
        MealIngredient(ingredientName: 'Mirin', quantity: 2, unit: 'tbsp'),
        MealIngredient(ingredientName: 'Sugar', quantity: 1, unit: 'tbsp'),
        MealIngredient(ingredientName: 'Mixed vegetables', quantity: 0.5, unit: 'cup'),
      ],
    ),

    PredefinedMeal(
      id: 'int_004',
      recipeName: 'Greek Chicken Gyro',
      description: 'Marinated chicken with tzatziki sauce in pita bread',
      kcal: 450,
      servings: 1,
      cookingInstructions: '1. Marinate chicken in lemon juice, olive oil, garlic, and oregano.\n2. Grill or pan-cook chicken until fully cooked.\n3. Prepare tzatziki with yogurt, cucumber, garlic, and dill.\n4. Warm pita bread.\n5. Assemble with chicken, tzatziki, tomatoes, onion, and lettuce.\n6. Serve immediately.',
      tags: ['International', 'Greek', 'Mediterranean', 'Healthy', 'High-protein'],
      difficulty: 'Easy',
      prepTimeMinutes: 30,
      imageUrl: 'https://via.placeholder.com/300x200/2196F3/FFFFFF?text=Greek+Gyro',
      ingredients: [
        MealIngredient(ingredientName: 'Chicken thigh', quantity: 150, unit: 'g'),
        MealIngredient(ingredientName: 'Pita bread', quantity: 1, unit: 'piece'),
        MealIngredient(ingredientName: 'Greek yogurt', quantity: 0.25, unit: 'cup'),
        MealIngredient(ingredientName: 'Cucumber', quantity: 0.5, unit: 'medium'),
        MealIngredient(ingredientName: 'Tomato', quantity: 0.5, unit: 'medium'),
        MealIngredient(ingredientName: 'Red onion', quantity: 0.25, unit: 'small'),
        MealIngredient(ingredientName: 'Lettuce', quantity: 2, unit: 'leaves'),
      ],
    ),

    // === HEALTHY/DIET OPTIONS ===
    PredefinedMeal(
      id: 'healthy_001',
      recipeName: 'Quinoa Buddha Bowl',
      description: 'Nutritious bowl with quinoa, roasted vegetables, and tahini dressing',
      kcal: 380,
      servings: 1,
      cookingInstructions: '1. Cook quinoa according to package instructions.\n2. Roast mixed vegetables (sweet potato, broccoli, chickpeas) with olive oil.\n3. Prepare tahini dressing with tahini, lemon juice, and water.\n4. Arrange quinoa and vegetables in a bowl.\n5. Drizzle with tahini dressing.\n6. Top with seeds and herbs.',
      tags: ['Healthy', 'Vegetarian', 'High-fiber', 'Low-calorie', 'Bowl'],
      difficulty: 'Easy',
      prepTimeMinutes: 40,
      imageUrl: 'https://via.placeholder.com/300x200/4CAF50/FFFFFF?text=Buddha+Bowl',
      ingredients: [
        MealIngredient(ingredientName: 'Quinoa', quantity: 0.5, unit: 'cup'),
        MealIngredient(ingredientName: 'Sweet potato', quantity: 100, unit: 'g'),
        MealIngredient(ingredientName: 'Broccoli', quantity: 100, unit: 'g'),
        MealIngredient(ingredientName: 'Chickpeas', quantity: 0.5, unit: 'cup'),
        MealIngredient(ingredientName: 'Tahini', quantity: 2, unit: 'tbsp'),
        MealIngredient(ingredientName: 'Lemon juice', quantity: 1, unit: 'tbsp'),
      ],
    ),

    PredefinedMeal(
      id: 'healthy_002',
      recipeName: 'Grilled Salmon with Vegetables',
      description: 'Heart-healthy salmon with steamed vegetables and lemon',
      kcal: 420,
      servings: 1,
      cookingInstructions: '1. Season salmon fillet with salt, pepper, and herbs.\n2. Grill salmon for 4-5 minutes per side.\n3. Steam mixed vegetables (broccoli, carrots, zucchini).\n4. Prepare lemon butter sauce.\n5. Serve salmon with vegetables and sauce.\n6. Garnish with fresh herbs.',
      tags: ['Healthy', 'High-protein', 'Low-carb', 'Heart-healthy', 'Omega-3'],
      difficulty: 'Easy',
      prepTimeMinutes: 20,
      imageUrl: 'https://via.placeholder.com/300x200/FF5722/FFFFFF?text=Grilled+Salmon',
      ingredients: [
        MealIngredient(ingredientName: 'Salmon fillet', quantity: 150, unit: 'g'),
        MealIngredient(ingredientName: 'Broccoli', quantity: 100, unit: 'g'),
        MealIngredient(ingredientName: 'Carrots', quantity: 80, unit: 'g'),
        MealIngredient(ingredientName: 'Zucchini', quantity: 80, unit: 'g'),
        MealIngredient(ingredientName: 'Lemon', quantity: 0.5, unit: 'piece'),
        MealIngredient(ingredientName: 'Olive oil', quantity: 1, unit: 'tbsp'),
      ],
    ),

    // === SNACKS ===
    PredefinedMeal(
      id: 'snack_001',
      recipeName: 'Halo-Halo',
      description: 'Filipino shaved ice dessert with mixed ingredients and ice cream',
      kcal: 350,
      servings: 1,
      cookingInstructions: '1. Layer sweetened beans, jellies, and fruits in a tall glass.\n2. Add cooked sago pearls and sweetened banana.\n3. Top with shaved ice.\n4. Drizzle with evaporated milk and ube flavoring.\n5. Top with ice cream and leche flan.\n6. Serve with a spoon and straw.',
      tags: ['Filipino', 'Dessert', 'Sweet', 'Cold', 'Traditional'],
      difficulty: 'Medium',
      prepTimeMinutes: 15,
      imageUrl: 'https://via.placeholder.com/300x200/9C27B0/FFFFFF?text=Halo-Halo',
      ingredients: [
        MealIngredient(ingredientName: 'Shaved ice', quantity: 1, unit: 'cup'),
        MealIngredient(ingredientName: 'Sweet beans', quantity: 2, unit: 'tbsp'),
        MealIngredient(ingredientName: 'Jellies', quantity: 2, unit: 'tbsp'),
        MealIngredient(ingredientName: 'Sago pearls', quantity: 1, unit: 'tbsp'),
        MealIngredient(ingredientName: 'Ube ice cream', quantity: 1, unit: 'scoop'),
        MealIngredient(ingredientName: 'Leche flan', quantity: 1, unit: 'slice'),
        MealIngredient(ingredientName: 'Evaporated milk', quantity: 3, unit: 'tbsp'),
      ],
    ),

    PredefinedMeal(
      id: 'snack_002',
      recipeName: 'Fresh Fruit Smoothie',
      description: 'Refreshing blend of tropical fruits with yogurt',
      kcal: 180,
      servings: 1,
      cookingInstructions: '1. Combine mango, banana, and pineapple in a blender.\n2. Add Greek yogurt and a splash of coconut milk.\n3. Add honey to taste.\n4. Blend until smooth and creamy.\n5. Add ice if desired consistency.\n6. Serve immediately in a chilled glass.',
      tags: ['Healthy', 'Snack', 'Smoothie', 'Low-calorie', 'Refreshing'],
      difficulty: 'Easy',
      prepTimeMinutes: 5,
      imageUrl: 'https://via.placeholder.com/300x200/FF9800/FFFFFF?text=Fruit+Smoothie',
      ingredients: [
        MealIngredient(ingredientName: 'Mango', quantity: 0.5, unit: 'cup'),
        MealIngredient(ingredientName: 'Banana', quantity: 0.5, unit: 'piece'),
        MealIngredient(ingredientName: 'Pineapple', quantity: 0.25, unit: 'cup'),
        MealIngredient(ingredientName: 'Greek yogurt', quantity: 0.5, unit: 'cup'),
        MealIngredient(ingredientName: 'Coconut milk', quantity: 0.25, unit: 'cup'),
        MealIngredient(ingredientName: 'Honey', quantity: 1, unit: 'tbsp'),
      ],
    ),
  ];

  // Helper methods for filtering meals
  static List<PredefinedMeal> searchMeals(String query) {
    if (query.isEmpty) return meals;
    
    final lowercaseQuery = query.toLowerCase();
    return meals.where((meal) {
      return meal.recipeName.toLowerCase().contains(lowercaseQuery) ||
             meal.description.toLowerCase().contains(lowercaseQuery) ||
             meal.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery)) ||
             meal.ingredients.any((ingredient) => 
               ingredient.ingredientName.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  static List<PredefinedMeal> getMealsByTag(String tag) {
    return meals.where((meal) => meal.tags.contains(tag)).toList();
  }

  static List<PredefinedMeal> getMealsByCalories(int minKcal, int maxKcal) {
    return meals.where((meal) => 
      meal.kcal >= minKcal && meal.kcal <= maxKcal).toList();
  }

  static PredefinedMeal? getMealById(String id) {
    try {
      return meals.firstWhere((meal) => meal.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get meals suitable for specific health conditions
  static List<PredefinedMeal> getHealthyMeals() {
    return meals.where((meal) => 
      meal.tags.contains('Healthy') || 
      meal.tags.contains('Low-calorie') ||
      meal.tags.contains('Vegetables')).toList();
  }

  static List<PredefinedMeal> getLowCalorieMeals(int maxKcal) {
    return meals.where((meal) => meal.kcal <= maxKcal).toList();
  }

  static List<PredefinedMeal> getHighProteinMeals() {
    return meals.where((meal) => meal.tags.contains('High-protein')).toList();
  }

  // Recent searches mock data
  static const List<String> recentSearches = [
    'chicken',
    'adobo',
    'healthy',
    'breakfast',
    'vegetarian',
    'low-calorie',
    'filipino',
    'pasta',
  ];

  // Nutrition tips
  static const List<String> nutritionTips = [
    'Malunggay leaves contain 7× more Vitamin C than oranges!',
    'Sweet potatoes are rich in beta-carotene for healthy vision',
    'Kangkong is high in iron and helps prevent anemia',
    'Fish like bangus provides omega-3 for heart health',
    'Ampalaya helps regulate blood sugar levels naturally',
    'Brown rice has more fiber than white rice for better digestion',
    'Coconut water is a natural electrolyte drink',
    'Guava has more Vitamin C than citrus fruits',
  ];
}