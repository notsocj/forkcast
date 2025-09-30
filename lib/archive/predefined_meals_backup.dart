// FNRI Recipes data for ForkCast
// This file contains recipes from FNRI (Food and Nutrition Research Institute)
// Used for meal planning functionality with health condition filtering

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

  factory HealthConditions.fromCsv({
    required int diabetes,
    required int hypertension,
    required int obesity,
    required int underweight,
    required int heartDisease,
    required int anemia,
    required int osteoporosis,
    required int none,
  }) {
    return HealthConditions(
      diabetes: diabetes == 1,
      hypertension: hypertension == 1,
      obesityOverweight: obesity == 1,
      underweightMalnutrition: underweight == 1,
      heartDiseaseChol: heartDisease == 1,
      anemia: anemia == 1,
      osteoporosis: osteoporosis == 1,
      none: none == 1,
    );
  }
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

  factory MealTiming.fromCsv({
    int breakfast = 1, // Default to 1 (most meals suitable for breakfast)
    required int lunch,
    required int dinner,
    required int snack,
  }) {
    return MealTiming(
      breakfast: breakfast == 1,
      lunch: lunch == 1,
      dinner: dinner == 1,
      snack: snack == 1,
    );
  }
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
    this.tags = const [],
    this.difficulty = 'Medium',
    this.prepTimeMinutes = 30,
    this.imageUrl = '',
  });

  // Backward compatibility getter
  int get servings => baseServings;

  // Helper method to check if suitable for a specific health condition
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

  // Helper method to check if suitable for meal time
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
  // FNRI Recipes from CSV data
  static final List<PredefinedMeal> meals = [
    PredefinedMeal(
      id: 'fnri_001',
      recipeName: 'Chicken Lumpia and Ginulay na Mais at Malunggay',
      description: 'Kids enjoy veggies when hidden in tasty lumpia. Malunggay boosts vitamin A and C for immunity.',
      baseServings: 20,
      kcal: 552,
      funFact: 'Kids enjoy veggies when hidden in tasty lumpia. Malunggay boosts vitamin A and C for immunity.',
      ingredients: [
        MealIngredient(ingredientName: 'Ground chicken', quantity: 3, unit: 'cups'),
        MealIngredient(ingredientName: 'Carrots, chopped', quantity: 1.33, unit: 'cups'),
        MealIngredient(ingredientName: 'Kinchay, chopped', quantity: 0.33, unit: 'cups'),
        MealIngredient(ingredientName: 'Lumpia wrapper', quantity: 20, unit: 'pcs'),
        MealIngredient(ingredientName: 'Corn, shredded', quantity: 4, unit: 'cups'),
        MealIngredient(ingredientName: 'Malunggay leaves, chopped', quantity: 3, unit: 'cups'),
      ],
      cookingInstructions: 'Step 1: Sauté garlic and onion, then add corn and water and let it simmer. Step 2: Mix ground chicken, carrots, and kinchay, then wrap the mixture in lumpia wrappers. Step 3: Add malunggay leaves to the corn mixture and serve, while frying the lumpia until golden brown.',
      healthConditions: HealthConditions.fromCsv(
        diabetes: 0, hypertension: 0, obesity: 0, underweight: 1,
        heartDisease: 0, anemia: 1, osteoporosis: 0, none: 1
      ),
      mealTiming: MealTiming.fromCsv(lunch: 1, dinner: 1, snack: 1),
      tags: ['Filipino', 'chicken', 'vegetables'],
      difficulty: 'Medium',
      prepTimeMinutes: 45,
      imageUrl: 'meals_pictures/chicken_lumpia_1.png',
    ),

    PredefinedMeal(
      id: 'fnri_002',
      recipeName: 'Ground Pork Menudo',
      description: 'Raisins provide iron for healthy growth.',
      baseServings: 20,
      kcal: 563,
      funFact: 'Raisins provide iron for healthy growth.',
      ingredients: [
        MealIngredient(ingredientName: 'Ground pork', quantity: 4, unit: 'cups'),
        MealIngredient(ingredientName: 'Potato, cubed', quantity: 3.5, unit: 'cups'),
      ],
      cookingInstructions: 'Step 1: Brown ground pork. Step 2: Add potatoes and simmer until tender. Step 3: Add vegetables and seasonings; simmer until cooked.',
      healthConditions: HealthConditions.fromCsv(
        diabetes: 0, hypertension: 0, obesity: 0, underweight: 1,
        heartDisease: 0, anemia: 1, osteoporosis: 0, none: 1
      ),
      mealTiming: MealTiming.fromCsv(lunch: 1, dinner: 1, snack: 0),
      tags: ['Filipino', 'pork', 'menudo'],
      difficulty: 'Easy',
      prepTimeMinutes: 30,
      imageUrl: 'meals_pictures/ground_pork_menudo_2.png',
    ),

    PredefinedMeal(
      id: 'fnri_003',
      recipeName: 'Tokwa Balls with Gravy',
      description: 'Tokwa is a protein-rich, affordable meat substitute.',
      baseServings: 20,
      kcal: 623,
      funFact: 'Tokwa is a protein-rich, affordable meat substitute.',
      ingredients: [
        MealIngredient(ingredientName: 'Tokwa (tofu), mashed', quantity: 3, unit: 'cups'),
        MealIngredient(ingredientName: 'Ground pork', quantity: 2, unit: 'cups'),
      ],
      cookingInstructions: 'Step 1: Mash tofu and mix with ground pork. Step 2: Form into balls and fry until golden. Step 3: Prepare gravy and serve with balls.',
      healthConditions: HealthConditions.fromCsv(
        diabetes: 0, hypertension: 0, obesity: 0, underweight: 1,
        heartDisease: 0, anemia: 0, osteoporosis: 1, none: 1
      ),
      mealTiming: MealTiming.fromCsv(lunch: 1, dinner: 1, snack: 1),
      tags: ['Filipino', 'tokwa', 'tofu'],
      difficulty: 'Medium',
      prepTimeMinutes: 40,
      imageUrl: 'meals_pictures/tokwa_balls_with_gravy_3.png',
    ),

    PredefinedMeal(
      id: 'fnri_004',
      recipeName: 'Sardines-Kalabasa Patties',
      description: 'Sardines are rich in calcium for strong bones.',
      baseServings: 20,
      kcal: 576,
      funFact: 'Sardines are rich in calcium for strong bones.',
      ingredients: [
        MealIngredient(ingredientName: 'Sardines, mashed', quantity: 2, unit: 'cups'),
        MealIngredient(ingredientName: 'Kalabasa (squash), grated', quantity: 3, unit: 'cups'),
      ],
      cookingInstructions: 'Step 1: Mash sardines and mix with grated squash. Step 2: Form into patties and fry until golden.',
      healthConditions: HealthConditions.fromCsv(
        diabetes: 1, hypertension: 1, obesity: 1, underweight: 0,
        heartDisease: 1, anemia: 1, osteoporosis: 1, none: 1
      ),
      mealTiming: MealTiming.fromCsv(lunch: 1, dinner: 1, snack: 1),
      tags: ['Filipino', 'sardines', 'kalabasa', 'healthy'],
      difficulty: 'Easy',
      prepTimeMinutes: 20,
      imageUrl: 'meals_pictures/sardines_kalabas_patties_4.png',
    ),

    PredefinedMeal(
      id: 'fnri_005',
      recipeName: 'Chicken Almondigas',
      description: 'This recipe is high in vitamin A and C which can boosts your child\'s immunity against infections and diseases.',
      baseServings: 20,
      kcal: 571,
      funFact: 'This recipe is high in vitamin A and C which can boosts your child\'s immunity against infections and diseases.',
      ingredients: [
        MealIngredient(ingredientName: 'Chicken eggs, beaten', quantity: 4, unit: 'pcs'),
        MealIngredient(ingredientName: 'Chicken breast, ground', quantity: 3, unit: 'cups'),
        MealIngredient(ingredientName: 'Carrots, chopped', quantity: 1.5, unit: 'cups'),
        MealIngredient(ingredientName: 'Cooking oil, for frying', quantity: 2, unit: 'cups'),
      ],
      cookingInstructions: 'Step 1: Make and fry meatballs; Step 2: Sauté garlic and onion then add water, patis, patola, and meatballs; Step 3: Add misua, carrots, and malunggay then simmer until cooked.',
      healthConditions: HealthConditions.fromCsv(
        diabetes: 0, hypertension: 1, obesity: 1, underweight: 0,
        heartDisease: 0, anemia: 1, osteoporosis: 0, none: 1
      ),
      mealTiming: MealTiming.fromCsv(lunch: 1, dinner: 1, snack: 0),
      tags: ['Filipino', 'chicken', 'soup', 'almondigas'],
      difficulty: 'Medium',
      prepTimeMinutes: 50,
      imageUrl: 'meals_pictures/chicken_almondigas_5.png',
    ),

    PredefinedMeal(
      id: 'fnri_006',
      recipeName: 'Ground pork picadillo soup with vegetable tempura',
      description: 'For picky eaters, make vegetables more interesting by dipping in batter and frying to achieve that crispy texture.',
      baseServings: 20,
      kcal: 586,
      funFact: 'For picky eaters, make vegetables more interesting by dipping in batter and frying to achieve that crispy texture.',
      ingredients: [
        MealIngredient(ingredientName: 'Pork liempo', quantity: 3, unit: 'cups'),
        MealIngredient(ingredientName: 'Carrots', quantity: 0.5, unit: 'cup'),
        MealIngredient(ingredientName: 'Sayote', quantity: 1.33, unit: 'cups'),
        MealIngredient(ingredientName: 'Malunggay leaves', quantity: 3, unit: 'cups'),
      ],
      cookingInstructions: 'Step 1: Saute garlic, onion, and ground pork; Step 2: Add water, salt, and pepper then boil; Step 3: Add carrots, sayote, and malunggay then simmer until cooked.',
      healthConditions: HealthConditions.fromCsv(
        diabetes: 0, hypertension: 1, obesity: 1, underweight: 0,
        heartDisease: 0, anemia: 1, osteoporosis: 0, none: 1
      ),
      mealTiming: MealTiming.fromCsv(lunch: 1, dinner: 1, snack: 0),
      tags: ['Filipino', 'pork', 'soup', 'vegetables'],
      difficulty: 'Medium',
      prepTimeMinutes: 45,
      imageUrl: 'meals_pictures/ground_pork_picadillo_6.png',
    ),

    PredefinedMeal(
      id: 'fnri_007',
      recipeName: 'Veggie patties with liver',
      description: 'Incorporate ground liver in patties. Liver is loaded with iron and vitamin A.',
      baseServings: 20,
      kcal: 589,
      funFact: 'Incorporate ground liver in patties. Liver is loaded with iron and vitamin A.',
      ingredients: [
        MealIngredient(ingredientName: 'Egg', quantity: 4, unit: 'pcs'),
        MealIngredient(ingredientName: 'Chicken breast', quantity: 4, unit: 'cups'),
        MealIngredient(ingredientName: 'Chicken liver', quantity: 0.25, unit: 'cup'),
        MealIngredient(ingredientName: 'Garlic', quantity: 2, unit: 'Tbsp'),
        MealIngredient(ingredientName: 'Kalabasa', quantity: 2, unit: 'cups'),
        MealIngredient(ingredientName: 'Kulitis/Spinach', quantity: 5, unit: 'cups'),
      ],
      cookingInstructions: 'Step 1: Mix eggs, chicken, liver, garlic, kalabasa, and kulitis; Step 2: Shape into patties; Step 3: Fry until browned and serve with catsup.',
      healthConditions: HealthConditions.fromCsv(
        diabetes: 0, hypertension: 1, obesity: 1, underweight: 0,
        heartDisease: 0, anemia: 1, osteoporosis: 1, none: 1
      ),
      mealTiming: MealTiming.fromCsv(lunch: 1, dinner: 1, snack: 1),
      tags: ['Filipino', 'vegetables', 'liver', 'healthy'],
      difficulty: 'Medium',
      prepTimeMinutes: 35,
      imageUrl: 'meals_pictures/veggie_patties_7.png',
    ),

    PredefinedMeal(
      id: 'fnri_008',
      recipeName: 'Ginataang munggo and kalabasa with dilis',
      description: 'Add gata to your classic ginisang munggo to enhance its flavor and provide more energy to children.',
      baseServings: 20,
      kcal: 565,
      funFact: 'Add gata to your classic ginisang munggo to enhance its flavor and provide more energy to children.',
      ingredients: [
        MealIngredient(ingredientName: 'Munggo', quantity: 1.5, unit: 'cups'),
        MealIngredient(ingredientName: 'Dilis', quantity: 2, unit: 'cups'),
        MealIngredient(ingredientName: 'Garlic', quantity: 0.33, unit: 'cup'),
        MealIngredient(ingredientName: 'Ginger', quantity: 2, unit: 'Tbsp'),
        MealIngredient(ingredientName: 'Tomato', quantity: 0.25, unit: 'cup'),
        MealIngredient(ingredientName: 'Kalabasa', quantity: 2, unit: 'cups'),
        MealIngredient(ingredientName: 'Coconut cream', quantity: 2, unit: 'cups'),
        MealIngredient(ingredientName: 'Malunggay', quantity: 4, unit: 'cups'),
      ],
      cookingInstructions: 'Step 1: Boil munggo until soft; Step 2: Fry dilis until crisp and set aside; Step 3: Sauté garlic, ginger, and tomato, then add munggo, kalabasa, coconut cream, and malunggay, simmer, and serve with dilis on top.',
      healthConditions: HealthConditions.fromCsv(
        diabetes: 0, hypertension: 1, obesity: 1, underweight: 0,
        heartDisease: 0, anemia: 1, osteoporosis: 0, none: 1
      ),
      mealTiming: MealTiming.fromCsv(lunch: 1, dinner: 1, snack: 0),
      tags: ['Filipino', 'munggo', 'ginataang', 'kalabasa'],
      difficulty: 'Medium',
      prepTimeMinutes: 40,
      imageUrl: 'meals_pictures/ginataang_munggo_8.png',
    ),

    PredefinedMeal(
      id: 'fnri_009',
      recipeName: 'Pork ginisang sinigang',
      description: 'Gabi is a good source of fiber and minerals which is essential for digestive health.',
      baseServings: 20,
      kcal: 546,
      funFact: 'Gabi is a good source of fiber and minerals which is essential for digestive health.',
      ingredients: [
        MealIngredient(ingredientName: 'Pork liempo', quantity: 4, unit: 'cups'),
        MealIngredient(ingredientName: 'Gabi', quantity: 2, unit: 'cups'),
        MealIngredient(ingredientName: 'Sitaw', quantity: 3, unit: 'cups'),
        MealIngredient(ingredientName: 'Sinigang mix', quantity: 1, unit: 'pack'),
        MealIngredient(ingredientName: 'Kangkong', quantity: 0.5, unit: 'cups'),
      ],
      cookingInstructions: 'Step 1: Sauté tomato and pork; Step 2: Add water and simmer until pork is tender; Step 3: Add gabi, sitaw, sinigang mix, and kangkong then simmer until cooked.',
      healthConditions: HealthConditions.fromCsv(
        diabetes: 0, hypertension: 1, obesity: 1, underweight: 0,
        heartDisease: 0, anemia: 1, osteoporosis: 0, none: 1
      ),
      mealTiming: MealTiming.fromCsv(lunch: 1, dinner: 1, snack: 0),
      tags: ['Filipino', 'pork', 'sinigang', 'soup'],
      difficulty: 'Easy',
      prepTimeMinutes: 60,
      imageUrl: 'meals_pictures/pork_ginisang_sinigang_9.png',
    ),

    PredefinedMeal(
      id: 'fnri_010',
      recipeName: 'Sweet and sour meatballs',
      description: 'Upgrade children\'s meal by adding carrots and kamote tops which are good sources of vitamin A for healthy eyes and skin.',
      baseServings: 20,
      kcal: 589,
      funFact: 'Upgrade children\'s meal by adding carrots and kamote tops which are good sources of vitamin A for healthy eyes and skin.',
      ingredients: [
        MealIngredient(ingredientName: 'Eggs', quantity: 4, unit: 'pcs'),
        MealIngredient(ingredientName: 'Chicken breast', quantity: 3, unit: 'cups'),
        MealIngredient(ingredientName: 'Kamote tops', quantity: 4, unit: 'cups'),
        MealIngredient(ingredientName: 'Carrots', quantity: 1.5, unit: 'cups'),
        MealIngredient(ingredientName: 'Pineapple', quantity: 1, unit: 'can'),
      ],
      cookingInstructions: 'Step 1: Mix chicken, kamote tops, and eggs into balls then fry; Step 2: Saute garlic, onion, and carrots then add catsup, pineapple syrup, vinegar, and slurry; Step 3: Add meatballs with pineapple, simmer, and serve with spring onions.',
      healthConditions: HealthConditions.fromCsv(
        diabetes: 0, hypertension: 1, obesity: 1, underweight: 0,
        heartDisease: 0, anemia: 1, osteoporosis: 1, none: 1
      ),
      mealTiming: MealTiming.fromCsv(lunch: 1, dinner: 1, snack: 1),
      tags: ['Filipino', 'chicken', 'sweet and sour', 'meatballs'],
      difficulty: 'Medium',
      prepTimeMinutes: 45,
      imageUrl: 'meals_pictures/sweet_and_sour_meatballs_10.png',
    ),

    // Adding more key FNRI recipes from the CSV
    PredefinedMeal(
      id: 'fnri_013',
      recipeName: 'Cabbage and beef rolls',
      description: 'Steaming is a heart-healthy cooking method that helps retain the natural flavors and nutrients of the food.',
      baseServings: 5,
      kcal: 179,
      funFact: 'Steaming is a heart-healthy cooking method that helps retain the natural flavors and nutrients of the food.',
      ingredients: [
        MealIngredient(ingredientName: 'Ground beef', quantity: 1.25, unit: 'cups'),
        MealIngredient(ingredientName: 'Tokwa', quantity: 1, unit: 'cup'),
        MealIngredient(ingredientName: 'Red onion', quantity: 0.25, unit: 'cup'),
        MealIngredient(ingredientName: 'Garlic', quantity: 0.25, unit: 'cup'),
        MealIngredient(ingredientName: 'Carrot', quantity: 1, unit: 'cup'),
        MealIngredient(ingredientName: 'Kinchay', quantity: 0.33, unit: 'cup'),
        MealIngredient(ingredientName: 'Chicken egg', quantity: 1, unit: 'pc, medium'),
        MealIngredient(ingredientName: 'Chinese cabbage leaves, blanched', quantity: 15, unit: 'pcs'),
      ],
      cookingInstructions: 'Step 1: Mix ground beef, mashed tokwa, onion, garlic, carrot, kinchay, and beaten egg; Step 2: Wrap mixture in blanched Chinese cabbage leaves; Step 3: Steam until cooked and serve.',
      healthConditions: HealthConditions.fromCsv(
        diabetes: 0, hypertension: 1, obesity: 1, underweight: 0,
        heartDisease: 0, anemia: 1, osteoporosis: 1, none: 1
      ),
      mealTiming: MealTiming.fromCsv(lunch: 1, dinner: 1, snack: 1),
      tags: ['Filipino', 'beef', 'vegetables', 'steamed', 'healthy'],
      difficulty: 'Medium',
      prepTimeMinutes: 40,
      imageUrl: 'meals_pictures/cabbage_and_beef_rolls_13.png',
    ),

    PredefinedMeal(
      id: 'fnri_015',
      recipeName: 'Pan-fried tokwa curry',
      description: 'Curry contains a blend of various spices such as ginger, turmeric, coriander, and cayenne which help in lowering the blood pressure.',
      baseServings: 5,
      kcal: 276,
      funFact: 'Curry contains a blend of various spices such as ginger, turmeric, coriander, and cayenne which help in lowering the blood pressure.',
      ingredients: [
        MealIngredient(ingredientName: 'Cornstarch', quantity: 0.25, unit: 'cup'),
        MealIngredient(ingredientName: 'Salt, iodized', quantity: 0.75, unit: 'tsp'),
        MealIngredient(ingredientName: 'Tokwa, sliced', quantity: 15, unit: 'slices / 35g each'),
        MealIngredient(ingredientName: 'Cooking oil', quantity: 2, unit: 'Tbsps'),
        MealIngredient(ingredientName: 'Water', quantity: 2, unit: 'cups'),
        MealIngredient(ingredientName: 'Red onion, sliced', quantity: 0.25, unit: 'cup'),
        MealIngredient(ingredientName: 'Curry powder', quantity: 1, unit: 'Tbsp'),
        MealIngredient(ingredientName: 'Carrot, cubed', quantity: 1.5, unit: 'cups'),
        MealIngredient(ingredientName: 'Yellow kamote, cubed', quantity: 1.5, unit: 'cups'),
        MealIngredient(ingredientName: 'Black pepper, ground', quantity: 0.25, unit: 'tsp'),
        MealIngredient(ingredientName: 'Cabbage, shredded', quantity: 3, unit: 'cups'),
      ],
      cookingInstructions: 'Step 1: Coat tokwa in cornstarch and salt, then pan-fry until golden; Step 2: Boil water with onion, curry powder, carrot, kamote, salt, and pepper for 7 minutes; Step 3: Serve tokwa with shredded cabbage on the side.',
      healthConditions: HealthConditions.fromCsv(
        diabetes: 0, hypertension: 1, obesity: 1, underweight: 0,
        heartDisease: 0, anemia: 1, osteoporosis: 0, none: 1
      ),
      mealTiming: MealTiming.fromCsv(lunch: 1, dinner: 1, snack: 0),
      tags: ['Filipino', 'tokwa', 'curry', 'vegetarian', 'healthy'],
      difficulty: 'Easy',
      prepTimeMinutes: 25,
      imageUrl: 'meals_pictures/pan_fried_tokwa_curry_15.png',
    ),

    PredefinedMeal(
      id: 'fnri_024',
      recipeName: 'Tuna kinilaw with seaweed',
      description: 'Seaweeds are rich in potassium salts, giving a natural salty flavor that can replace table salt without raising blood pressure.',
      baseServings: 5,
      kcal: 153,
      funFact: 'Seaweeds are rich in potassium salts, giving a natural salty flavor that can replace table salt without raising blood pressure.',
      ingredients: [
        MealIngredient(ingredientName: 'Tuna, cubed', quantity: 1.5, unit: 'cups'),
        MealIngredient(ingredientName: 'White vinegar', quantity: 1, unit: 'cup'),
        MealIngredient(ingredientName: 'Water', quantity: 2, unit: 'cups'),
        MealIngredient(ingredientName: 'Guso, fresh, trimmed', quantity: 6, unit: 'cups'),
        MealIngredient(ingredientName: 'Red onion, sliced', quantity: 0.33, unit: 'cup'),
        MealIngredient(ingredientName: 'Tomato, chopped', quantity: 0.5, unit: 'cup'),
        MealIngredient(ingredientName: 'Ginger, chopped', quantity: 0.33, unit: 'cup'),
        MealIngredient(ingredientName: 'Calamansi juice, freshly squeezed', quantity: 0.25, unit: 'cup'),
        MealIngredient(ingredientName: 'Salt, iodized', quantity: 0.75, unit: 'tsp'),
        MealIngredient(ingredientName: 'Black pepper, ground', quantity: 0.5, unit: 'tsp'),
      ],
      cookingInstructions: 'Step 1: Soak tuna in vinegar for 30 minutes, drain, and set aside; Step 2: Boil water and blanch guso, then rinse; Step 3: Mix onion, tomato, ginger, calamansi juice, vinegar, salt, and pepper; Step 4: Add tuna and guso, mix well, cover, and marinate 30 minutes.',
      healthConditions: HealthConditions.fromCsv(
        diabetes: 0, hypertension: 1, obesity: 1, underweight: 0,
        heartDisease: 0, anemia: 1, osteoporosis: 1, none: 1
      ),
      mealTiming: MealTiming.fromCsv(lunch: 1, dinner: 1, snack: 1),
      tags: ['Filipino', 'tuna', 'kinilaw', 'seaweed', 'healthy'],
      difficulty: 'Easy',
      prepTimeMinutes: 20,
      imageUrl: 'meals_pictures/tuna_kinilaw_24.png',
    ),

    PredefinedMeal(
      id: 'fnri_028',
      recipeName: 'Go!-Conut',
      description: 'This beverage contains nutrients and electrolytes that are essential rehydration during prolonged physical activity',
      baseServings: 1,
      kcal: 31,
      funFact: 'This beverage contains nutrients and electrolytes that are essential rehydration during prolonged physical activity',
      ingredients: [
        MealIngredient(ingredientName: 'Coconut water', quantity: 2.5, unit: 'cups'),
        MealIngredient(ingredientName: 'Calamansi juice, freshly squeezed', quantity: 1, unit: 'Tbsp'),
        MealIngredient(ingredientName: 'Honey', quantity: 1, unit: 'tsp'),
        MealIngredient(ingredientName: 'Salt, iodized', quantity: 0.25, unit: 'tsp'),
        MealIngredient(ingredientName: 'Cold water', quantity: 2.5, unit: 'cups'),
      ],
      cookingInstructions: 'Step 1: In a pitcher, combine all the ingredients.',
      healthConditions: HealthConditions.fromCsv(
        diabetes: 1, hypertension: 0, obesity: 0, underweight: 1,
        heartDisease: 0, anemia: 0, osteoporosis: 0, none: 1
      ),
      mealTiming: MealTiming.fromCsv(lunch: 0, dinner: 0, snack: 1),
      tags: ['Filipino', 'beverage', 'coconut', 'healthy', 'drink'],
      difficulty: 'Easy',
      prepTimeMinutes: 5,
      imageUrl: 'meals_pictures/go_conut_28.png',
    ),

    PredefinedMeal(
      id: 'fnri_032',
      recipeName: 'No fry empanada',
      description: 'This Ilocos-inspired empanada is high in protein from eggs and longganisa, with less oil thanks to pan-grilled rice paper.',
      baseServings: 1,
      kcal: 233,
      funFact: 'This Ilocos-inspired empanada is high in protein from eggs and longganisa, with less oil thanks to pan-grilled rice paper.',
      ingredients: [
        MealIngredient(ingredientName: 'Cooking oil', quantity: 1, unit: 'Tbsp'),
        MealIngredient(ingredientName: 'Atsuete seeds', quantity: 2, unit: 'tsps'),
        MealIngredient(ingredientName: 'Garlic, chopped', quantity: 1, unit: 'Tbsp'),
        MealIngredient(ingredientName: 'Onion, chopped', quantity: 1, unit: 'Tbsp'),
        MealIngredient(ingredientName: 'Vigan or Lucban longganisa, mashed', quantity: 0.5, unit: 'cup'),
        MealIngredient(ingredientName: 'Green papaya, strips', quantity: 1.5, unit: 'cups'),
        MealIngredient(ingredientName: 'Black pepper', quantity: 0.125, unit: 'tsp'),
        MealIngredient(ingredientName: 'Rice paper, big', quantity: 5, unit: 'pcs'),
        MealIngredient(ingredientName: 'Quail eggs', quantity: 10, unit: 'pcs'),
      ],
      cookingInstructions: 'Step 1: Heat oil, add atsuete, extract oil for 1 minute then remove seeds; Step 2: Sauté garlic, onion, and longganisa for 5 minutes; Step 3: Add papaya and pepper, cook for 7 minutes then set aside; Step 4: Divide mixture into 5 portions, dip rice paper in water, add filling, make a well, crack in 2 quail eggs, fold and seal; Step 5: Pan grill empanada for 3 minutes per side.',
      healthConditions: HealthConditions.fromCsv(
        diabetes: 1, hypertension: 1, obesity: 0, underweight: 0,
        heartDisease: 1, anemia: 0, osteoporosis: 0, none: 1
      ),
      mealTiming: MealTiming.fromCsv(lunch: 1, dinner: 0, snack: 1),
      tags: ['Filipino', 'empanada', 'longganisa', 'healthy'],
      difficulty: 'Medium',
      prepTimeMinutes: 30,
      imageUrl: 'meals_pictures/no_fry_empanda_32.png',
    ),

    // Additional FNRI-inspired meals
    PredefinedMeal(
      id: 'fnri_011',
      recipeName: 'Fish Fillet and Potato Soup',
      description: 'A nutritious soup combining fish protein with potatoes for a filling, healthy meal.',
      baseServings: 4,
      kcal: 245,
      funFact: 'Fish provides lean protein and omega-3 fatty acids for brain health.',
      ingredients: [
        MealIngredient(ingredientName: 'Fish fillet, cubed', quantity: 2, unit: 'cups'),
        MealIngredient(ingredientName: 'Potatoes, cubed', quantity: 3, unit: 'cups'),
        MealIngredient(ingredientName: 'Onion, chopped', quantity: 0.5, unit: 'cup'),
        MealIngredient(ingredientName: 'Malunggay leaves', quantity: 1, unit: 'cup'),
        MealIngredient(ingredientName: 'Ginger, sliced', quantity: 2, unit: 'Tbsp'),
      ],
      cookingInstructions: 'Step 1: Sauté onion and ginger until fragrant; Step 2: Add water and bring to boil, add potatoes; Step 3: Add fish fillet and simmer until cooked; Step 4: Add malunggay leaves and season to taste.',
      healthConditions: HealthConditions.fromCsv(
        diabetes: 1, hypertension: 1, obesity: 1, underweight: 0,
        heartDisease: 1, anemia: 1, osteoporosis: 1, none: 1
      ),
      mealTiming: MealTiming.fromCsv(lunch: 1, dinner: 1, snack: 0),
      tags: ['Filipino', 'fish', 'soup', 'healthy'],
      difficulty: 'Easy',
      prepTimeMinutes: 25,
      imageUrl: 'meals_pictures/fish_fillet_and_potato_soup_11.png',
    ),

    PredefinedMeal(
      id: 'fnri_012',
      recipeName: 'Pork Veggie Embutido',
      description: 'A Filipino-style meatloaf packed with vegetables for added nutrition.',
      baseServings: 8,
      kcal: 320,
      funFact: 'Embutido gets its nutrients from a variety of colorful vegetables mixed with lean meat.',
      ingredients: [
        MealIngredient(ingredientName: 'Ground pork', quantity: 2, unit: 'cups'),
        MealIngredient(ingredientName: 'Carrots, diced', quantity: 1, unit: 'cup'),
        MealIngredient(ingredientName: 'Red bell pepper, diced', quantity: 0.5, unit: 'cup'),
        MealIngredient(ingredientName: 'Green peas', quantity: 0.5, unit: 'cup'),
        MealIngredient(ingredientName: 'Eggs, beaten', quantity: 2, unit: 'pcs'),
        MealIngredient(ingredientName: 'Bread crumbs', quantity: 0.5, unit: 'cup'),
      ],
      cookingInstructions: 'Step 1: Mix all ingredients in a large bowl; Step 2: Shape into a loaf and wrap in aluminum foil; Step 3: Steam for 45 minutes or until cooked through; Step 4: Cool and slice to serve.',
      healthConditions: HealthConditions.fromCsv(
        diabetes: 0, hypertension: 1, obesity: 1, underweight: 0,
        heartDisease: 0, anemia: 1, osteoporosis: 1, none: 1
      ),
      mealTiming: MealTiming.fromCsv(lunch: 1, dinner: 1, snack: 1),
      tags: ['Filipino', 'pork', 'vegetables', 'embutido'],
      difficulty: 'Medium',
      prepTimeMinutes: 60,
      imageUrl: 'meals_pictures/pork_veggie_embutido_12.png',
    ),

    PredefinedMeal(
      id: 'fnri_018',
      recipeName: 'Sautéed Kidney Beans',
      description: 'A protein-rich plant-based dish perfect for those looking to increase fiber intake.',
      baseServings: 4,
      kcal: 190,
      funFact: 'Kidney beans are excellent sources of protein, fiber, and folate for heart health.',
      ingredients: [
        MealIngredient(ingredientName: 'Kidney beans, cooked', quantity: 2, unit: 'cups'),
        MealIngredient(ingredientName: 'Onion, sliced', quantity: 1, unit: 'medium'),
        MealIngredient(ingredientName: 'Tomatoes, chopped', quantity: 2, unit: 'medium'),
        MealIngredient(ingredientName: 'Garlic, minced', quantity: 3, unit: 'cloves'),
        MealIngredient(ingredientName: 'Malunggay leaves', quantity: 1, unit: 'cup'),
      ],
      cookingInstructions: 'Step 1: Sauté garlic, onion, and tomatoes until soft; Step 2: Add cooked kidney beans and simmer for 10 minutes; Step 3: Add malunggay leaves and season with salt and pepper.',
      healthConditions: HealthConditions.fromCsv(
        diabetes: 1, hypertension: 1, obesity: 1, underweight: 0,
        heartDisease: 1, anemia: 1, osteoporosis: 1, none: 1
      ),
      mealTiming: MealTiming.fromCsv(lunch: 1, dinner: 1, snack: 0),
      tags: ['Filipino', 'beans', 'vegetarian', 'healthy', 'fiber'],
      difficulty: 'Easy',
      prepTimeMinutes: 20,
      imageUrl: 'meals_pictures/sauteed_kidney_beans_18.png',
    ),

    PredefinedMeal(
      id: 'fnri_031',
      recipeName: 'Watermelon Upo Juice',
      description: 'A refreshing and hydrating drink that combines the sweetness of watermelon with the subtle taste of upo.',
      baseServings: 2,
      kcal: 45,
      funFact: 'This unique combination provides natural electrolytes and helps with hydration.',
      ingredients: [
        MealIngredient(ingredientName: 'Watermelon, cubed', quantity: 2, unit: 'cups'),
        MealIngredient(ingredientName: 'Upo (bottle gourd), peeled and cubed', quantity: 1, unit: 'cup'),
        MealIngredient(ingredientName: 'Water', quantity: 1, unit: 'cup'),
        MealIngredient(ingredientName: 'Honey', quantity: 1, unit: 'tsp'),
        MealIngredient(ingredientName: 'Ice cubes', quantity: 6, unit: 'pcs'),
      ],
      cookingInstructions: 'Step 1: Blend watermelon and upo with water until smooth; Step 2: Add honey and blend again; Step 3: Strain if desired; Step 4: Serve over ice.',
      healthConditions: HealthConditions.fromCsv(
        diabetes: 1, hypertension: 1, obesity: 1, underweight: 1,
        heartDisease: 1, anemia: 0, osteoporosis: 0, none: 1
      ),
      mealTiming: MealTiming.fromCsv(lunch: 0, dinner: 0, snack: 1),
      tags: ['Filipino', 'beverage', 'watermelon', 'healthy', 'refreshing'],
      difficulty: 'Easy',
      prepTimeMinutes: 10,
      imageUrl: 'meals_pictures/watermelon_upo_juice_31.png',
    ),
  ];

  // Recent searches for UI
  static const List<String> recentSearches = [
    'chicken',
    'vegetables',
    'healthy',
    'tokwa',
    'soup',
    'pork',
    'fish'
  ];

  // Nutrition tips for UI
  static const List<String> nutritionTips = [
    'Malunggay leaves are rich in Vitamin A and C, boosting immunity',
    'Sardines provide calcium for strong bones and healthy teeth',
    'Kalabasa (squash) is high in beta-carotene for better vision',
    'Tokwa is a protein-rich, affordable meat substitute',
    'Steaming vegetables helps retain more nutrients than frying',
    'Adding liver to meals provides iron and Vitamin A',
    'Gabi root is rich in fiber for better digestive health',
    'Coconut water contains natural electrolytes for hydration'
  ];

  // Helper methods for filtering meals
  // Enhanced search with health filtering
  static List<PredefinedMeal> searchMealsWithHealthFilter(
    String query, 
    List<String>? userHealthConditions
  ) {
    if (query.isEmpty) {
      if (userHealthConditions == null || userHealthConditions.isEmpty) {
        return meals;
      } else {
        return getPersonalizedMeals(userHealthConditions, '');
      }
    }
    
    final lowercaseQuery = query.toLowerCase();
    List<PredefinedMeal> queryResults = meals.where((meal) {
      return meal.recipeName.toLowerCase().contains(lowercaseQuery) ||
             meal.description.toLowerCase().contains(lowercaseQuery) ||
             meal.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery)) ||
             meal.ingredients.any((ingredient) => 
               ingredient.ingredientName.toLowerCase().contains(lowercaseQuery));
    }).toList();

    // Apply health filtering if user has health conditions
    if (userHealthConditions != null && userHealthConditions.isNotEmpty) {
      queryResults = queryResults.where((meal) {
        bool healthMatch = true;
        for (String condition in userHealthConditions) {
          switch (condition.toLowerCase()) {
            case 'diabetes':
              if (!meal.healthConditions.diabetes) healthMatch = false;
              break;
            case 'hypertension':
              if (!meal.healthConditions.hypertension) healthMatch = false;
              break;
            case 'obesity':
              if (!meal.healthConditions.obesityOverweight) healthMatch = false;
              break;
            case 'underweight':
              if (!meal.healthConditions.underweightMalnutrition) healthMatch = false;
              break;
            case 'heart_disease':
              if (!meal.healthConditions.heartDiseaseChol) healthMatch = false;
              break;
            case 'anemia':
              if (!meal.healthConditions.anemia) healthMatch = false;
              break;
            case 'osteoporosis':
              if (!meal.healthConditions.osteoporosis) healthMatch = false;
              break;
          }
        }
        return healthMatch;
      }).toList();
    }

    return queryResults;
  }

  // Backward compatibility - original search method
  static List<PredefinedMeal> searchMeals(String query) {
    return searchMealsWithHealthFilter(query, null);
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

  // New health-based filtering methods for FNRI recipes
  static List<PredefinedMeal> getMealsForHealthCondition(String condition) {
    return meals.where((meal) {
      switch (condition.toLowerCase()) {
        case 'diabetes':
          return meal.healthConditions.diabetes;
        case 'hypertension':
          return meal.healthConditions.hypertension;
        case 'obesity':
          return meal.healthConditions.obesityOverweight;
        case 'underweight':
          return meal.healthConditions.underweightMalnutrition;
        case 'heart_disease':
          return meal.healthConditions.heartDiseaseChol;
        case 'anemia':
          return meal.healthConditions.anemia;
        case 'osteoporosis':
          return meal.healthConditions.osteoporosis;
        case 'none':
          return meal.healthConditions.none;
        default:
          return true;
      }
    }).toList();
  }

  static List<PredefinedMeal> getMealsForMealTime(String mealTime) {
    return meals.where((meal) {
      switch (mealTime.toLowerCase()) {
        case 'breakfast':
          return meal.mealTiming.breakfast;
        case 'lunch':
          return meal.mealTiming.lunch;
        case 'dinner':
          return meal.mealTiming.dinner;
        case 'snack':
          return meal.mealTiming.snack;
        default:
          return true;
      }
    }).toList();
  }

  // Get personalized meal recommendations based on multiple health conditions
  static List<PredefinedMeal> getPersonalizedMeals(List<String> healthConditions, String mealTime) {
    if (healthConditions.isEmpty) {
      return getMealsForMealTime(mealTime);
    }

    return meals.where((meal) {
      // Check meal timing suitability
      bool mealTimeMatch = false;
      switch (mealTime.toLowerCase()) {
        case 'breakfast':
          mealTimeMatch = meal.mealTiming.breakfast;
          break;
        case 'lunch':
          mealTimeMatch = meal.mealTiming.lunch;
          break;
        case 'dinner':
          mealTimeMatch = meal.mealTiming.dinner;
          break;
        case 'snack':
          mealTimeMatch = meal.mealTiming.snack;
          break;
        default:
          mealTimeMatch = true;
      }

      if (!mealTimeMatch) return false;

      // Check health condition suitability - meal must be safe for ALL conditions
      bool healthMatch = true;
      for (String condition in healthConditions) {
        switch (condition.toLowerCase()) {
          case 'diabetes':
            if (!meal.healthConditions.diabetes) healthMatch = false;
            break;
          case 'hypertension':
            if (!meal.healthConditions.hypertension) healthMatch = false;
            break;
          case 'obesity':
            if (!meal.healthConditions.obesityOverweight) healthMatch = false;
            break;
          case 'underweight':
            if (!meal.healthConditions.underweightMalnutrition) healthMatch = false;
            break;
          case 'heart_disease':
            if (!meal.healthConditions.heartDiseaseChol) healthMatch = false;
            break;
          case 'anemia':
            if (!meal.healthConditions.anemia) healthMatch = false;
            break;
          case 'osteoporosis':
            if (!meal.healthConditions.osteoporosis) healthMatch = false;
            break;
        }
      }
      
      return healthMatch;
    }).toList();
  }

  // Scale recipe for different number of people (PAX)
  static PredefinedMeal scaleRecipeForPax(PredefinedMeal meal, int targetPax) {
    final scaleFactor = targetPax / meal.baseServings;
    
    final scaledIngredients = meal.ingredients.map((ingredient) => 
      MealIngredient(
        ingredientName: ingredient.ingredientName,
        quantity: ingredient.quantity * scaleFactor,
        unit: ingredient.unit,
      )
    ).toList();

    return PredefinedMeal(
      id: meal.id,
      recipeName: meal.recipeName,
      description: meal.description,
      baseServings: targetPax,
      kcal: (meal.kcal * scaleFactor).round(),
      funFact: meal.funFact,
      ingredients: scaledIngredients,
      cookingInstructions: meal.cookingInstructions,
      healthConditions: meal.healthConditions,
      mealTiming: meal.mealTiming,
      tags: meal.tags,
      difficulty: meal.difficulty,
      prepTimeMinutes: meal.prepTimeMinutes,
    );
  }
}

