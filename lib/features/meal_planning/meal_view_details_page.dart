import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_colors.dart';
import '../../data/predefined_meals.dart';
import '../../services/user_service.dart';

class MealViewDetailsPage extends StatefulWidget {
  final PredefinedMeal meal;

  const MealViewDetailsPage({
    super.key,
    required this.meal,
  });

  @override
  State<MealViewDetailsPage> createState() => _MealViewDetailsPageState();
}

class _MealViewDetailsPageState extends State<MealViewDetailsPage> {
  int _userPax = 1; // User's household size
  final UserService _userService = UserService();
  bool _isLoadingUserData = true;

  @override
  void initState() {
    super.initState();
    _loadUserHouseholdSize();
  }

  // Load user's household size automatically
  Future<void> _loadUserHouseholdSize() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final userData = await _userService.getUser(currentUser.uid);
        if (userData != null && userData.householdSize > 0) {
          setState(() {
            _userPax = userData.householdSize;
            _isLoadingUserData = false;
          });
          return;
        }
      }
    } catch (e) {
      print('Error loading user household size: $e');
    }
    
    // Fallback to default PAX of 1 if loading fails
    setState(() {
      _isLoadingUserData = false;
    });
  }

  // Calculate nutrition values based on user's PAX
  Map<String, double> get _calculatedNutrition {
    final meal = widget.meal;
    final totalCalories = meal.kcal.toDouble();
    final servings = meal.baseServings.toDouble();
    
    // Calculate calories per serving, then multiply by user's PAX
    final caloriesPerServing = totalCalories / servings;
    final finalCalories = caloriesPerServing * _userPax;
    
    // Calculate other nutrients based on final calories
    return {
      'calories': finalCalories,
      'fat': (finalCalories * 0.25 / 9), // ~25% of calories from fat (9 cal/g)
      'carbohydrates': (finalCalories * 0.50 / 4), // ~50% from carbs (4 cal/g)
      'protein': (finalCalories * 0.25 / 4), // ~25% from protein (4 cal/g)
      'sodium': (finalCalories * 5), // Rough estimate: 5mg sodium per calorie
      'vitamin_a': 2.0 * _userPax,
      'vitamin_c': 15.0 * _userPax,
      'calcium': 4.0 * _userPax,
      'iron': 8.0 * _userPax,
      'riboflavin': 15.0 * _userPax,
      'niacin': 35.0 * _userPax,
      'thiamin': 5.0 * _userPax,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            // Content
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await Future.delayed(const Duration(milliseconds: 500));
                },
                color: AppColors.successGreen,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMealImage(),
                      const SizedBox(height: 20),
                      _buildMealDescription(),
                      const SizedBox(height: 24),
                      _buildPaxSelector(),
                      const SizedBox(height: 24),
                      _buildNutritionFacts(),
                      const SizedBox(height: 24),
                      _buildIngredientsList(),
                      const SizedBox(height: 24),
                      _buildCookingInstructions(),
                      const SizedBox(height: 24),
                      _buildHealthInfo(),
                      const SizedBox(height: 24),
                      _buildMealTimingInfo(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.grayText.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.arrow_back,
                color: AppColors.blackText,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              widget.meal.recipeName,
              style: TextStyle(
                fontFamily: 'Lato',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.blackText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealImage() {
    return Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: widget.meal.imageUrl.isNotEmpty
            ? Image.network(
                widget.meal.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildPlaceholderImage();
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _buildPlaceholderImage();
                },
              )
            : _buildPlaceholderImage(),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: AppColors.successGreen.withOpacity(0.2),
      child: Center(
        child: Icon(
          Icons.restaurant_menu,
          size: 60,
          color: AppColors.successGreen,
        ),
      ),
    );
  }

  Widget _buildMealDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.restaurant,
              color: AppColors.successGreen,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'About this meal',
              style: TextStyle(
                fontFamily: 'Lato',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.blackText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            widget.meal.description,
            style: TextStyle(
              fontFamily: 'OpenSans',
              fontSize: 14,
              color: AppColors.grayText,
              height: 1.5,
            ),
          ),
        ),
        if (widget.meal.funFact.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.successGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.successGreen.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: AppColors.successGreen,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Did you know?',
                        style: TextStyle(
                          fontFamily: 'Lato',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.successGreen,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.meal.funFact,
                        style: TextStyle(
                          fontFamily: 'OpenSans',
                          fontSize: 13,
                          color: AppColors.grayText,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPaxSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.people,
                color: AppColors.successGreen,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Number of People (PAX)',
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.blackText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _isLoadingUserData
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(
                      color: AppColors.successGreen,
                      strokeWidth: 2,
                    ),
                  ),
                )
              : Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBackground,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: _userPax,
                            isExpanded: true,
                            dropdownColor: AppColors.white,
                            icon: Icon(Icons.arrow_drop_down, color: AppColors.successGreen),
                            style: TextStyle(
                              fontFamily: 'OpenSans',
                              fontSize: 14,
                              color: AppColors.blackText,
                              fontWeight: FontWeight.w500,
                            ),
                            items: List.generate(10, (index) => index + 1).map((int value) {
                              return DropdownMenuItem<int>(
                                value: value,
                                child: Text('$value ${value == 1 ? 'person' : 'people'}'),
                              );
                            }).toList(),
                            onChanged: (int? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _userPax = newValue;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
          const SizedBox(height: 8),
          Text(
            'Nutrition values are calculated for $_userPax ${_userPax == 1 ? 'person' : 'people'}',
            style: TextStyle(
              fontFamily: 'OpenSans',
              fontSize: 12,
              color: AppColors.grayText,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionFacts() {
    final nutrition = _calculatedNutrition;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.bar_chart,
              color: AppColors.successGreen,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Nutrition Facts',
              style: TextStyle(
                fontFamily: 'Lato',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.blackText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Calories (main)
              _buildMainNutrientRow(
                'Calories',
                '${nutrition['calories']!.toStringAsFixed(0)} kcal',
              ),
              Divider(color: AppColors.grayText.withOpacity(0.2), height: 24),
              
              // Macronutrients
              _buildNutrientRow('Total Fat', '${nutrition['fat']!.toStringAsFixed(1)}g'),
              _buildNutrientRow('Carbohydrates', '${nutrition['carbohydrates']!.toStringAsFixed(1)}g'),
              _buildNutrientRow('Protein', '${nutrition['protein']!.toStringAsFixed(1)}g'),
              _buildNutrientRow('Sodium', '${nutrition['sodium']!.toStringAsFixed(0)}mg'),
              
              Divider(color: AppColors.grayText.withOpacity(0.2), height: 24),
              
              // Micronutrients
              Text(
                'Vitamins & Minerals',
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.blackText,
                ),
              ),
              const SizedBox(height: 12),
              _buildNutrientRow('Vitamin A', '${nutrition['vitamin_a']!.toStringAsFixed(1)}% DV'),
              _buildNutrientRow('Vitamin C', '${nutrition['vitamin_c']!.toStringAsFixed(1)}% DV'),
              _buildNutrientRow('Calcium', '${nutrition['calcium']!.toStringAsFixed(1)}% DV'),
              _buildNutrientRow('Iron', '${nutrition['iron']!.toStringAsFixed(1)}% DV'),
              _buildNutrientRow('Riboflavin', '${nutrition['riboflavin']!.toStringAsFixed(1)}% DV'),
              _buildNutrientRow('Niacin', '${nutrition['niacin']!.toStringAsFixed(1)}% DV'),
              _buildNutrientRow('Thiamin', '${nutrition['thiamin']!.toStringAsFixed(1)}% DV'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMainNutrientRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Lato',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.blackText,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Lato',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.successGreen,
          ),
        ),
      ],
    );
  }

  Widget _buildNutrientRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'OpenSans',
              fontSize: 14,
              color: AppColors.grayText,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'OpenSans',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.blackText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.shopping_basket,
              color: AppColors.successGreen,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Ingredients',
              style: TextStyle(
                fontFamily: 'Lato',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.blackText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.meal.ingredients.isEmpty)
                Text(
                  'No ingredients listed',
                  style: TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 14,
                    color: AppColors.grayText,
                    fontStyle: FontStyle.italic,
                  ),
                )
              else
                ...widget.meal.ingredients.asMap().entries.map((entry) {
                  final index = entry.key;
                  final ingredient = entry.value;
                  
                  // Scale ingredient quantities based on PAX
                  final scaledQuantity = (ingredient.quantity * _userPax / widget.meal.baseServings).toStringAsFixed(1);
                  
                  return Padding(
                    padding: EdgeInsets.only(bottom: index < widget.meal.ingredients.length - 1 ? 12 : 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 6),
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: AppColors.successGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontFamily: 'OpenSans',
                                fontSize: 14,
                                color: AppColors.blackText,
                                height: 1.4,
                              ),
                              children: [
                                TextSpan(
                                  text: '$scaledQuantity ${ingredient.unit}',
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                TextSpan(text: ' ${ingredient.ingredientName}'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCookingInstructions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.auto_stories,
              color: AppColors.successGreen,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Cooking Instructions',
              style: TextStyle(
                fontFamily: 'Lato',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.blackText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildInfoChip(Icons.timer, '${widget.meal.prepTimeMinutes} min'),
                  const SizedBox(width: 8),
                  _buildInfoChip(Icons.trending_up, widget.meal.difficulty),
                  const SizedBox(width: 8),
                  _buildInfoChip(Icons.restaurant, '${widget.meal.baseServings} servings'),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                widget.meal.cookingInstructions,
                style: TextStyle(
                  fontFamily: 'OpenSans',
                  fontSize: 14,
                  color: AppColors.grayText,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.successGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.successGreen),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'OpenSans',
              fontSize: 12,
              color: AppColors.successGreen,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthInfo() {
    final healthConditions = widget.meal.healthConditions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.health_and_safety,
              color: AppColors.successGreen,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Health Information',
              style: TextStyle(
                fontFamily: 'Lato',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.blackText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Safe for:',
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.blackText,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (healthConditions.diabetes) _buildHealthBadge('Diabetes', Colors.blue),
                  if (healthConditions.hypertension) _buildHealthBadge('Hypertension', Colors.red),
                  if (healthConditions.obesityOverweight) _buildHealthBadge('Obesity', Colors.orange),
                  if (healthConditions.underweightMalnutrition) _buildHealthBadge('Underweight', Colors.purple),
                  if (healthConditions.heartDiseaseChol) _buildHealthBadge('Heart Disease', Colors.pink),
                  if (healthConditions.anemia) _buildHealthBadge('Anemia', Colors.teal),
                  if (healthConditions.osteoporosis) _buildHealthBadge('Osteoporosis', Colors.brown),
                  if (healthConditions.none) _buildHealthBadge('Healthy', Colors.green),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHealthBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'OpenSans',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealTimingInfo() {
    final mealTiming = widget.meal.mealTiming;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.access_time,
              color: AppColors.successGreen,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Best Time to Eat',
              style: TextStyle(
                fontFamily: 'Lato',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.blackText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (mealTiming.breakfast) 
                _buildTimingChip('Breakfast', Icons.wb_sunny, Colors.orange),
              if (mealTiming.lunch) 
                _buildTimingChip('Lunch', Icons.wb_sunny_outlined, Colors.red),
              if (mealTiming.dinner) 
                _buildTimingChip('Dinner', Icons.nightlight, Colors.indigo),
              if (mealTiming.snack) 
                _buildTimingChip('Snack', Icons.cookie, Colors.purple),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimingChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'OpenSans',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
