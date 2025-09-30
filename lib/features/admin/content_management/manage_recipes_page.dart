import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants.dart';
import '../../../services/recipe_service.dart';
import '../../../models/recipe.dart';

class ManageRecipesPage extends StatefulWidget {
  const ManageRecipesPage({super.key});

  @override
  State<ManageRecipesPage> createState() => _ManageRecipesPageState();
}

class _ManageRecipesPageState extends State<ManageRecipesPage> {
  final TextEditingController _searchController = TextEditingController();
  final RecipeService _recipeService = RecipeService();
  String _selectedCategory = 'All';
  List<Recipe> _allRecipes = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }
  
  Future<void> _loadRecipes() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final recipes = await _recipeService.getAllRecipes();
      setState(() {
        _allRecipes = recipes;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading recipes: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // Get filtered meals based on search and category
  List<Recipe> get filteredMeals {
    List<Recipe> meals = _allRecipes;
    
    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      meals = meals.where((meal) {
        return meal.recipeName.toLowerCase().contains(query) ||
               meal.description.toLowerCase().contains(query) ||
               meal.tags.any((tag) => tag.toLowerCase().contains(query)) ||
               meal.ingredients.any((ing) => ing.ingredientName.toLowerCase().contains(query));
      }).toList();
    }
    
    // Apply category filter
    if (_selectedCategory != 'All') {
      meals = meals.where((meal) {
        switch (_selectedCategory) {
          case 'Filipino':
            return meal.tags.any((tag) => tag.toLowerCase().contains('filipino'));
          case 'Healthy':
            return meal.healthConditions.none || meal.tags.any((tag) => tag.toLowerCase().contains('healthy'));
          case 'Vegetarian':
            return meal.tags.any((tag) => 
              tag.toLowerCase().contains('vegetarian') || 
              tag.toLowerCase().contains('tokwa') || 
              tag.toLowerCase().contains('vegetables'));
          case 'Low Sodium':
            return meal.healthConditions.hypertension;
          case 'Diabetes-Friendly':
            return meal.healthConditions.diabetes;
          default:
            return true;
        }
      }).toList();
    }
    
    return meals;
  }
  
  // Helper method to convert Recipe to display tags
  List<String> _getMealTags(Recipe meal) {
    List<String> tags = [];
    
    // Add original tags
    tags.addAll(meal.tags);
    
    // Add health condition tags
    if (meal.healthConditions.diabetes) tags.add('Diabetes-Safe');
    if (meal.healthConditions.hypertension) tags.add('Low Sodium');
    if (meal.healthConditions.obesityOverweight) tags.add('Weight Management');
    if (meal.healthConditions.underweightMalnutrition) tags.add('Nutrient Dense');
    if (meal.healthConditions.heartDiseaseChol) tags.add('Heart Healthy');
    if (meal.healthConditions.anemia) tags.add('Iron Rich');
    if (meal.healthConditions.osteoporosis) tags.add('Calcium Rich');
    
    // Add meal timing tags
    if (meal.mealTiming.breakfast) tags.add('Breakfast');
    if (meal.mealTiming.lunch) tags.add('Lunch');
    if (meal.mealTiming.dinner) tags.add('Dinner');
    if (meal.mealTiming.snack) tags.add('Snack');
    
    // Limit to 3 most relevant tags
    return tags.take(3).toList();
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.successGreen),
        ),
      );
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.successGreen.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: AppColors.grayText.withOpacity(0.7)),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {});
                    },
                    decoration: const InputDecoration(
                      hintText: 'Search recipes by name or ingredients...',
                      hintStyle: TextStyle(
                        fontFamily: AppConstants.primaryFont,
                        color: AppColors.grayText,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Statistics - Total Recipes Only
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildStatCard(
                  'Total Recipes', 
                  _allRecipes.length.toString(), 
                  Icons.restaurant_menu, 
                  AppColors.successGreen
                ),
              ),
              const SizedBox(width: 12),
              // Removed Published and Pending Review cards
              const Expanded(flex: 3, child: SizedBox()),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Category Filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCategoryChip('All'),
                _buildCategoryChip('Filipino'),
                _buildCategoryChip('Healthy'),
                _buildCategoryChip('Vegetarian'),
                _buildCategoryChip('Low Sodium'),
                _buildCategoryChip('Diabetes-Friendly'),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          const Text(
            'Recipe Database',
            style: TextStyle(
              fontFamily: AppConstants.headingFont,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.blackText,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Recipe Cards from FNRI Data
          ...filteredMeals.map((meal) => _buildRecipeCard(
            name: meal.recipeName,
            description: meal.description,
            kcal: meal.kcal,
            servings: meal.baseServings,
            tags: _getMealTags(meal),
            rating: 4.5, // Default rating since FNRI data doesn't include ratings
            status: 'Published', // All FNRI recipes are published
            meal: meal,
          )),
        ],
      ),
    );
  }
  
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const Spacer(),
              Flexible(
                child: Text(
                  value,
                  style: TextStyle(
                    fontFamily: AppConstants.headingFont,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: AppConstants.primaryFont,
                fontSize: 11,
                color: AppColors.grayText,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCategoryChip(String category) {
    final isSelected = _selectedCategory == category;
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedCategory = category;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.successGreen : AppColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.successGreen : AppColors.successGreen.withOpacity(0.3),
            ),
          ),
          child: Text(
            category,
            style: TextStyle(
              fontFamily: AppConstants.primaryFont,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? AppColors.white : AppColors.grayText,
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildRecipeCard({
    required String name,
    required String description,
    required int kcal,
    required int servings,
    required List<String> tags,
    required double rating,
    required String status,
    Recipe? meal,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.successGreen.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.successGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.restaurant,
                  color: AppColors.successGreen,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(
                              fontFamily: AppConstants.primaryFont,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.blackText,
                            ),
                          ),
                        ),
                        _buildStatusBadge(status),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        fontFamily: AppConstants.primaryFont,
                        fontSize: 14,
                        color: AppColors.grayText,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.successGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$kcal kcal',
                            style: const TextStyle(
                              fontFamily: AppConstants.primaryFont,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.successGreen,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$servings servings',
                            style: const TextStyle(
                              fontFamily: AppConstants.primaryFont,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 16),
                            Text(
                              rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontFamily: AppConstants.primaryFont,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.grayText,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  _handleRecipeAction(value, meal!);
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'view', child: Text('View Recipe')),
                ],
              ),
            ],
          ),
          if (tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: tags.map((tag) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.successGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  tag,
                  style: const TextStyle(
                    fontFamily: AppConstants.primaryFont,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.successGreen,
                  ),
                ),
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildStatusBadge(String status) {
    Color color = status == 'Published' ? AppColors.successGreen : 
                 status == 'Pending' ? Colors.orange : Colors.red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontFamily: AppConstants.primaryFont,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
  
  void _handleRecipeAction(String action, Recipe meal) {
    if (action == 'view') {
      _showRecipeDetails(meal);
    }
  }
  
  void _showRecipeDetails(Recipe meal) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: AppColors.successGreen,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              meal.recipeName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                fontFamily: AppConstants.headingFont,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${meal.kcal} kcal • ${meal.baseServings} servings • ${meal.prepTimeMinutes} min',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Description
                        _buildDetailSection(
                          'Description',
                          Icons.description,
                          meal.description,
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Fun Fact
                        _buildDetailSection(
                          'Fun Fact',
                          Icons.lightbulb_outline,
                          meal.funFact,
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Ingredients
                        _buildIngredientsSection(meal.ingredients),
                        
                        const SizedBox(height: 20),
                        
                        // Cooking Instructions
                        _buildDetailSection(
                          'Cooking Instructions',
                          Icons.restaurant_menu,
                          meal.cookingInstructions,
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Health Conditions
                        _buildHealthConditionsSection(meal.healthConditions),
                        
                        const SizedBox(height: 20),
                        
                        // Meal Timing
                        _buildMealTimingSection(meal.mealTiming),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildDetailSection(String title, IconData icon, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.successGreen, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontFamily: AppConstants.headingFont,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.blackText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primaryBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.successGreen.withOpacity(0.2)),
          ),
          child: Text(
            content,
            style: const TextStyle(
              fontFamily: AppConstants.primaryFont,
              fontSize: 14,
              color: AppColors.grayText,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildIngredientsSection(List<RecipeIngredient> ingredients) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.shopping_cart, color: AppColors.successGreen, size: 20),
            SizedBox(width: 8),
            Text(
              'Ingredients',
              style: TextStyle(
                fontFamily: AppConstants.headingFont,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.blackText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primaryBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.successGreen.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: ingredients.map((ingredient) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '• ',
                    style: TextStyle(
                      color: AppColors.successGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '${ingredient.quantity} ${ingredient.unit} ${ingredient.ingredientName}',
                      style: const TextStyle(
                        fontFamily: AppConstants.primaryFont,
                        fontSize: 14,
                        color: AppColors.grayText,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }
  
  Widget _buildHealthConditionsSection(RecipeHealthConditions healthConditions) {
    List<String> suitableConditions = [];
    
    if (healthConditions.diabetes) suitableConditions.add('Diabetes');
    if (healthConditions.hypertension) suitableConditions.add('Hypertension');
    if (healthConditions.obesityOverweight) suitableConditions.add('Obesity/Overweight');
    if (healthConditions.underweightMalnutrition) suitableConditions.add('Underweight/Malnutrition');
    if (healthConditions.heartDiseaseChol) suitableConditions.add('Heart Disease/High Cholesterol');
    if (healthConditions.anemia) suitableConditions.add('Anemia');
    if (healthConditions.osteoporosis) suitableConditions.add('Osteoporosis');
    if (healthConditions.none) suitableConditions.add('Healthy Individuals');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.health_and_safety, color: AppColors.successGreen, size: 20),
            SizedBox(width: 8),
            Text(
              'Suitable Health Conditions',
              style: TextStyle(
                fontFamily: AppConstants.headingFont,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.blackText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: suitableConditions.map((condition) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.successGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.successGreen.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  color: AppColors.successGreen,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  condition,
                  style: const TextStyle(
                    fontFamily: AppConstants.primaryFont,
                    fontSize: 12,
                    color: AppColors.successGreen,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )).toList(),
        ),
      ],
    );
  }
  
  Widget _buildMealTimingSection(RecipeMealTiming mealTiming) {
    List<String> suitableTimes = [];
    
    if (mealTiming.breakfast) suitableTimes.add('Breakfast');
    if (mealTiming.lunch) suitableTimes.add('Lunch');
    if (mealTiming.dinner) suitableTimes.add('Dinner');
    if (mealTiming.snack) suitableTimes.add('Snack');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.schedule, color: AppColors.successGreen, size: 20),
            SizedBox(width: 8),
            Text(
              'Meal Timing',
              style: TextStyle(
                fontFamily: AppConstants.headingFont,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.blackText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: suitableTimes.map((time) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primaryAccent.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getMealTimeIcon(time),
                  color: AppColors.primaryAccent,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  time,
                  style: const TextStyle(
                    fontFamily: AppConstants.primaryFont,
                    fontSize: 12,
                    color: AppColors.primaryAccent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )).toList(),
        ),
      ],
    );
  }
  
  IconData _getMealTimeIcon(String mealTime) {
    switch (mealTime.toLowerCase()) {
      case 'breakfast':
        return Icons.wb_sunny;
      case 'lunch':
        return Icons.wb_sunny_outlined;
      case 'dinner':
        return Icons.nights_stay;
      case 'snack':
        return Icons.local_cafe;
      default:
        return Icons.restaurant;
    }
  }
}
