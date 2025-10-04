import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants.dart';
import '../../../services/recipe_service.dart';
import '../../../services/cloudinary_service.dart';
import '../../../models/recipe.dart';
import 'recipe_detail_page.dart';
import 'edit_recipe_page.dart';

class ManageRecipesPage extends StatefulWidget {
  const ManageRecipesPage({super.key});

  @override
  State<ManageRecipesPage> createState() => _ManageRecipesPageState();
}

class _ManageRecipesPageState extends State<ManageRecipesPage> {
  final TextEditingController _searchController = TextEditingController();
  final RecipeService _recipeService = RecipeService();
  final CloudinaryService _cloudinaryService = CloudinaryService();
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
      // Force clear cache to ensure fresh data from Firebase
      _recipeService.clearCache();
      
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
          // Search Bar with Refresh Button
          Row(
            children: [
              Expanded(
                child: Container(
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
              ),
              const SizedBox(width: 12),
              // Refresh Button
              IconButton(
                onPressed: _isLoading ? null : () async {
                  setState(() {
                    _isLoading = true;
                  });
                  await _loadRecipes();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Recipes refreshed successfully'),
                        backgroundColor: AppColors.successGreen,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                icon: Icon(
                  Icons.refresh_rounded,
                  color: _isLoading ? AppColors.grayText : AppColors.successGreen,
                  size: 28,
                ),
                tooltip: 'Refresh recipes',
              ),
            ],
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
          
          // Recipe Database Header with Add Button
          Row(
            children: [
              const Text(
                'Recipe Database',
                style: TextStyle(
                  fontFamily: AppConstants.headingFont,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.blackText,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _showAddRecipeDialog,
                icon: const Icon(Icons.add, color: AppColors.white),
                label: const Text(
                  'Add Recipe',
                  style: TextStyle(
                    fontFamily: AppConstants.primaryFont,
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.successGreen,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
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
                  const PopupMenuItem(
                    value: 'view', 
                    child: Row(
                      children: [
                        Icon(Icons.visibility, size: 18),
                        SizedBox(width: 8),
                        Text('View Recipe'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'edit', 
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 18, color: Colors.orange),
                        SizedBox(width: 8),
                        Text('Edit Recipe'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete', 
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 18, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete Recipe', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
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
    } else if (action == 'edit') {
      _showEditRecipeDialog(meal);
    } else if (action == 'delete') {
      _confirmDeleteRecipe(meal);
    }
  }
  
  void _showRecipeDetails(Recipe meal) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeDetailPage(recipe: meal),
      ),
    );
    
    // Reload recipes if recipe was updated from detail page
    if (result == true) {
      await _loadRecipes();
    }
  }

  // ==================== EDIT RECIPE FUNCTIONALITY ====================
  
  void _showAddRecipeDialog() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EditRecipePage(),
      ),
    );

    // Reload recipes if recipe was added
    if (result == true) {
      await _loadRecipes();
    }
  }

  // ==================== EDIT RECIPE FUNCTIONALITY ====================
  
  void _showEditRecipeDialog(Recipe recipe) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditRecipePage(recipe: recipe),
      ),
    );

    // Reload recipes if recipe was updated
    if (result == true) {
      await _loadRecipes();
    }
  }

  // ==================== DELETE RECIPE FUNCTIONALITY ====================
  
  void _confirmDeleteRecipe(Recipe recipe) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Recipe'),
          content: Text('Are you sure you want to delete "${recipe.recipeName}"? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _deleteRecipe(recipe);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteRecipe(Recipe recipe) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final success = await _recipeService.deleteRecipe(recipe.id);
      
      if (mounted) Navigator.pop(context); // Close loading

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Recipe deleted successfully')),
          );
        }
        await _loadRecipes(); // Reload recipes
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete recipe')),
          );
        }
      }
    } catch (e) {
      if (mounted) Navigator.pop(context); // Close loading
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  // ==================== RECIPE FORM DIALOG (ADD/EDIT) ====================
  
  void _showRecipeFormDialog(BuildContext context, Recipe? existingRecipe) {
    final isEditing = existingRecipe != null;
    
    // Controllers for all fields
    final nameController = TextEditingController(text: existingRecipe?.recipeName ?? '');
    final descriptionController = TextEditingController(text: existingRecipe?.description ?? '');
    final instructionsController = TextEditingController(text: existingRecipe?.cookingInstructions ?? '');
    final funFactController = TextEditingController(text: existingRecipe?.funFact ?? '');
    final prepTimeController = TextEditingController(text: existingRecipe?.prepTimeMinutes.toString() ?? '');
    final servingsController = TextEditingController(text: existingRecipe?.baseServings.toString() ?? '');
    final kcalController = TextEditingController(text: existingRecipe?.kcal.toString() ?? '');
    
    // Image
    String? imageUrl = existingRecipe?.imageUrl;
    File? selectedImageFile;
    
    // Ingredients list
    List<Map<String, dynamic>> ingredients = existingRecipe?.ingredients.map((ing) => {
      'name': ing.ingredientName,
      'quantity': ing.quantity.toString(),
      'unit': ing.unit,
    }).toList() ?? [{'name': '', 'quantity': '', 'unit': ''}];
    
    // Health Conditions
    Map<String, bool> healthConditions = {
      'Diabetes': existingRecipe?.healthConditions.diabetes ?? false,
      'Hypertension': existingRecipe?.healthConditions.hypertension ?? false,
      'Obesity/Overweight': existingRecipe?.healthConditions.obesityOverweight ?? false,
      'Underweight/Malnutrition': existingRecipe?.healthConditions.underweightMalnutrition ?? false,
      'Heart Disease/High Cholesterol': existingRecipe?.healthConditions.heartDiseaseChol ?? false,
      'Anemia': existingRecipe?.healthConditions.anemia ?? false,
      'Osteoporosis': existingRecipe?.healthConditions.osteoporosis ?? false,
      'None/Healthy': existingRecipe?.healthConditions.none ?? true,
    };
    
    // Meal Timing
    Map<String, bool> mealTiming = {
      'Breakfast': existingRecipe?.mealTiming.breakfast ?? false,
      'Lunch': existingRecipe?.mealTiming.lunch ?? false,
      'Dinner': existingRecipe?.mealTiming.dinner ?? false,
      'Snack': existingRecipe?.mealTiming.snack ?? false,
    };
    
    // Tags
    List<String> tags = List<String>.from(existingRecipe?.tags ?? []);
    final tagController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.95,
                height: MediaQuery.of(context).size.height * 0.9,
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
                            child: Text(
                              isEditing ? 'Edit Recipe' : 'Add New Recipe',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                fontFamily: AppConstants.headingFont,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    // Form Content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Image Upload Section
                            _buildImageUploadSection(
                              imageUrl, 
                              selectedImageFile,
                              (file) {
                                setDialogState(() {
                                  selectedImageFile = file;
                                });
                              },
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Basic Information
                            _buildSectionHeader('Basic Information'),
                            _buildTextField('Recipe Name*', nameController),
                            _buildTextField('Description*', descriptionController, maxLines: 3),
                            Row(
                              children: [
                                Expanded(child: _buildTextField('Prep Time (minutes)*', prepTimeController, isNumber: true)),
                                const SizedBox(width: 12),
                                Expanded(child: _buildTextField('Servings*', servingsController, isNumber: true)),
                                const SizedBox(width: 12),
                                Expanded(child: _buildTextField('Calories (kcal)*', kcalController, isNumber: true)),
                              ],
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Ingredients Section
                            _buildSectionHeader('Ingredients'),
                            ...List.generate(ingredients.length, (index) {
                              return _buildIngredientRow(
                                index,
                                ingredients[index],
                                () {
                                  setDialogState(() {
                                    ingredients.removeAt(index);
                                  });
                                },
                              );
                            }),
                            TextButton.icon(
                              onPressed: () {
                                setDialogState(() {
                                  ingredients.add({'name': '', 'quantity': '', 'unit': ''});
                                });
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Add Ingredient'),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Cooking Instructions
                            _buildSectionHeader('Cooking Instructions'),
                            _buildTextField('Instructions*', instructionsController, maxLines: 5),
                            
                            const SizedBox(height: 24),
                            
                            // Fun Fact
                            _buildSectionHeader('Fun Fact (Optional)'),
                            _buildTextField('Fun Fact', funFactController, maxLines: 2),
                            
                            const SizedBox(height: 24),
                            
                            // Health Conditions
                            _buildSectionHeader('Suitable For (Health Conditions)'),
                            _buildCheckboxGrid(healthConditions, setDialogState),
                            
                            const SizedBox(height: 24),
                            
                            // Meal Timing
                            _buildSectionHeader('Meal Timing'),
                            _buildCheckboxGrid(mealTiming, setDialogState),
                            
                            const SizedBox(height: 24),
                            
                            // Tags
                            _buildSectionHeader('Tags'),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                ...tags.map((tag) => Chip(
                                  label: Text(tag),
                                  onDeleted: () {
                                    setDialogState(() {
                                      tags.remove(tag);
                                    });
                                  },
                                )),
                                ActionChip(
                                  avatar: const Icon(Icons.add, size: 18),
                                  label: const Text('Add Tag'),
                                  onPressed: () {
                                    _showAddTagDialog(tagController, (newTag) {
                                      setDialogState(() {
                                        if (newTag.isNotEmpty && !tags.contains(newTag)) {
                                          tags.add(newTag);
                                        }
                                      });
                                    });
                                  },
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 32),
                            
                            // Save Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () async {
                                  await _saveRecipe(
                                    context: dialogContext,
                                    isEditing: isEditing,
                                    existingRecipeId: existingRecipe?.id,
                                    nameController: nameController,
                                    descriptionController: descriptionController,
                                    instructionsController: instructionsController,
                                    funFactController: funFactController,
                                    prepTimeController: prepTimeController,
                                    servingsController: servingsController,
                                    kcalController: kcalController,
                                    ingredients: ingredients,
                                    healthConditions: healthConditions,
                                    mealTiming: mealTiming,
                                    tags: tags,
                                    selectedImageFile: selectedImageFile,
                                    existingImageUrl: imageUrl,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.successGreen,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  isEditing ? 'Update Recipe' : 'Add Recipe',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
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
      },
    );
  }

  // ==================== FORM HELPER WIDGETS ====================

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: AppConstants.headingFont,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.successGreen,
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    bool isNumber = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        inputFormatters: isNumber ? [FilteringTextInputFormatter.digitsOnly] : null,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.successGreen, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildIngredientRow(
    int index,
    Map<String, dynamic> ingredient,
    VoidCallback onRemove,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: TextField(
              controller: TextEditingController(text: ingredient['name']),
              onChanged: (value) => ingredient['name'] = value,
              decoration: const InputDecoration(
                labelText: 'Ingredient Name',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 1,
            child: TextField(
              controller: TextEditingController(text: ingredient['quantity']),
              onChanged: (value) => ingredient['quantity'] = value,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Qty',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 1,
            child: TextField(
              controller: TextEditingController(text: ingredient['unit']),
              onChanged: (value) => ingredient['unit'] = value,
              decoration: const InputDecoration(
                labelText: 'Unit',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.delete, color: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxGrid(Map<String, bool> options, StateSetter setDialogState) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: options.entries.map((entry) {
        return InkWell(
          onTap: () {
            setDialogState(() {
              options[entry.key] = !entry.value;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: entry.value 
                  ? AppColors.successGreen.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: entry.value ? AppColors.successGreen : Colors.grey,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  entry.value ? Icons.check_box : Icons.check_box_outline_blank,
                  color: entry.value ? AppColors.successGreen : Colors.grey,
                  size: 20,
                ),
                const SizedBox(width: 6),
                Text(
                  entry.key,
                  style: TextStyle(
                    color: entry.value ? AppColors.successGreen : Colors.grey,
                    fontWeight: entry.value ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildImageUploadSection(
    String? currentImageUrl,
    File? selectedFile,
    Function(File?) onImageSelected,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Recipe Image'),
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            color: AppColors.primaryBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.successGreen.withOpacity(0.3)),
          ),
          child: selectedFile != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(selectedFile, fit: BoxFit.cover),
                )
              : (currentImageUrl != null && currentImageUrl.isNotEmpty)
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(currentImageUrl, fit: BoxFit.cover),
                    )
                  : const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image, size: 48, color: AppColors.grayText),
                          SizedBox(height: 8),
                          Text('No image selected'),
                        ],
                      ),
                    ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () async {
                  final file = await _cloudinaryService.pickImageFromGallery();
                  onImageSelected(file);
                },
                icon: const Icon(Icons.photo_library),
                label: const Text('Choose from Gallery'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () async {
                  final file = await _cloudinaryService.pickImageFromCamera();
                  onImageSelected(file);
                },
                icon: const Icon(Icons.camera_alt),
                label: const Text('Take Photo'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showAddTagDialog(TextEditingController controller, Function(String) onAdd) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Tag'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Tag Name',
              hintText: 'e.g., Filipino, Healthy',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                onAdd(controller.text.trim());
                controller.clear();
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  // ==================== SAVE RECIPE ====================

  Future<void> _saveRecipe({
    required BuildContext context,
    required bool isEditing,
    String? existingRecipeId,
    required TextEditingController nameController,
    required TextEditingController descriptionController,
    required TextEditingController instructionsController,
    required TextEditingController funFactController,
    required TextEditingController prepTimeController,
    required TextEditingController servingsController,
    required TextEditingController kcalController,
    required List<Map<String, dynamic>> ingredients,
    required Map<String, bool> healthConditions,
    required Map<String, bool> mealTiming,
    required List<String> tags,
    File? selectedImageFile,
    String? existingImageUrl,
  }) async {
    // Validation
    if (nameController.text.trim().isEmpty ||
        descriptionController.text.trim().isEmpty ||
        instructionsController.text.trim().isEmpty ||
        prepTimeController.text.trim().isEmpty ||
        servingsController.text.trim().isEmpty ||
        kcalController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    // Validate ingredients
    if (ingredients.isEmpty || ingredients.any((ing) => 
        ing['name'].toString().trim().isEmpty ||
        ing['quantity'].toString().trim().isEmpty ||
        ing['unit'].toString().trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all ingredient fields')),
      );
      return;
    }

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Upload image to Cloudinary if new image was selected
      String? finalImageUrl = existingImageUrl;
      if (selectedImageFile != null) {
        finalImageUrl = await _cloudinaryService.uploadImage(
          selectedImageFile,
          title: nameController.text.trim(),
          description: 'Recipe image for ${nameController.text.trim()}',
        );
        
        if (finalImageUrl == null) {
          if (mounted) Navigator.pop(context); // Close loading
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to upload image. Please try again.')),
            );
          }
          return;
        }
      }

      // Create Recipe object
      final recipe = Recipe(
        id: existingRecipeId ?? '',
        recipeName: nameController.text.trim(),
        description: descriptionController.text.trim(),
        cookingInstructions: instructionsController.text.trim(),
        funFact: funFactController.text.trim().isEmpty 
            ? 'No fun fact available.' 
            : funFactController.text.trim(),
        prepTimeMinutes: int.parse(prepTimeController.text.trim()),
        baseServings: int.parse(servingsController.text.trim()),
        kcal: int.parse(kcalController.text.trim()),
        imageUrl: finalImageUrl ?? '',
        tags: tags,
        difficulty: 'Medium', // Default difficulty
        createdAt: DateTime.now(),
        ingredients: ingredients.map((ing) => RecipeIngredient(
          ingredientName: ing['name'].toString().trim(),
          quantity: double.parse(ing['quantity'].toString()),
          unit: ing['unit'].toString().trim(),
        )).toList(),
        healthConditions: RecipeHealthConditions(
          diabetes: healthConditions['Diabetes'] ?? false,
          hypertension: healthConditions['Hypertension'] ?? false,
          obesityOverweight: healthConditions['Obesity/Overweight'] ?? false,
          underweightMalnutrition: healthConditions['Underweight/Malnutrition'] ?? false,
          heartDiseaseChol: healthConditions['Heart Disease/High Cholesterol'] ?? false,
          anemia: healthConditions['Anemia'] ?? false,
          osteoporosis: healthConditions['Osteoporosis'] ?? false,
          none: healthConditions['None/Healthy'] ?? false,
        ),
        mealTiming: RecipeMealTiming(
          breakfast: mealTiming['Breakfast'] ?? false,
          lunch: mealTiming['Lunch'] ?? false,
          dinner: mealTiming['Dinner'] ?? false,
          snack: mealTiming['Snack'] ?? false,
        ),
      );

      // Save to Firebase
      bool success;
      if (isEditing && existingRecipeId != null) {
        success = await _recipeService.updateRecipe(existingRecipeId, recipe);
      } else {
        final recipeId = await _recipeService.addRecipe(recipe);
        success = recipeId != null;
      }

      if (mounted) Navigator.pop(context); // Close loading
      if (mounted) Navigator.pop(context); // Close form dialog

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isEditing 
                  ? 'Recipe updated successfully' 
                  : 'Recipe added successfully'),
            ),
          );
        }
        await _loadRecipes(); // Reload recipes
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isEditing 
                  ? 'Failed to update recipe' 
                  : 'Failed to add recipe'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) Navigator.pop(context); // Close loading
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}
