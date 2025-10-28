import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants.dart';
import '../../../models/recipe.dart';
import '../../../services/recipe_service.dart';
import 'edit_recipe_page.dart';

class RecipeDetailPage extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailPage({
    super.key,
    required this.recipe,
  });

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  final RecipeService _recipeService = RecipeService();
  late Recipe _currentRecipe;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentRecipe = widget.recipe;
  }

  Future<void> _reloadRecipe() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Force clear cache to ensure fresh data
      _recipeService.clearCache();
      
      final updatedRecipe = await _recipeService.getRecipeById(_currentRecipe.id);
      if (updatedRecipe != null) {
        setState(() {
          _currentRecipe = updatedRecipe;
          _isLoading = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Recipe updated successfully')),
          );
        }
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error reloading recipe: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.successGreen,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : CustomScrollView(
              slivers: [
                // Simple App Bar
                SliverAppBar(
                  pinned: true,
                  backgroundColor: AppColors.successGreen,
                  elevation: 0,
                  title: const Text(
                    'Recipe',
                    style: TextStyle(
                      fontFamily: AppConstants.headingFont,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  centerTitle: true,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context, true),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white),
                      onPressed: () async {
                        // Navigate to edit page
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditRecipePage(recipe: _currentRecipe),
                          ),
                        );

                        // Reload recipe if it was updated
                        if (result == true) {
                          await _reloadRecipe();
                        }
                      },
                    ),
                  ],
                ),

                // Content with image
                SliverToBoxAdapter(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primaryBackground,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Framed Image at top of content
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                          child: Container(
                            width: double.infinity,
                            height: 180,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 12,
                                  offset: Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  // Recipe Image
                                  if (_currentRecipe.imageUrl.isNotEmpty)
                                    Image.network(
                                      _currentRecipe.imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Container(
                                        color: AppColors.successGreen.withOpacity(0.2),
                                        child: const Icon(
                                          Icons.restaurant,
                                          size: 60,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    )
                                  else
                                    Container(
                                      color: AppColors.successGreen.withOpacity(0.3),
                                      child: const Icon(
                                        Icons.restaurant,
                                        size: 60,
                                        color: Colors.white70,
                                      ),
                                    ),

                                  // Bottom gradient for text legibility
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black.withOpacity(0.5),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // Title overlay inside the framed image
                                  Positioned(
                                    left: 16,
                                    right: 16,
                                    bottom: 16,
                                    child: Text(
                                      _currentRecipe.recipeName,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontFamily: AppConstants.headingFont,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        height: 1.2,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Recipe Header (card beneath framed image)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Recipe Name
                                Text(
                                  _currentRecipe.recipeName,
                                  style: const TextStyle(
                                    fontFamily: AppConstants.headingFont,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.blackText,
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Quick Stats
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 8,
                                  children: [
                                    _buildQuickStat(Icons.local_fire_department, '${_currentRecipe.kcal} kcal', AppColors.primaryAccent),
                                    _buildQuickStat(Icons.access_time, '${_currentRecipe.prepTimeMinutes} min', AppColors.successGreen),
                                    _buildQuickStat(Icons.restaurant, '${_currentRecipe.baseServings} servings', Colors.blue),
                                    _buildQuickStat(
                                      Icons.attach_money,
                                      _currentRecipe.averagePrice != null 
                                          ? '₱${_currentRecipe.averagePrice!.toStringAsFixed(2)}' 
                                          : '₱000 (not set)',
                                      Colors.orange,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                // Difficulty Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _getDifficultyColor(_currentRecipe.difficulty).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: _getDifficultyColor(_currentRecipe.difficulty).withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.star,
                                        color: _getDifficultyColor(_currentRecipe.difficulty),
                                        size: 18,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        _currentRecipe.difficulty,
                                        style: TextStyle(
                                          fontFamily: AppConstants.primaryFont,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: _getDifficultyColor(_currentRecipe.difficulty),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Main Content
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Description Section
                              _wrapSection(_buildSection(
                                'Description',
                                Icons.description_outlined,
                                _currentRecipe.description,
                              )),

                              const SizedBox(height: 16),

                              // Fun Fact Section
                              if (_currentRecipe.funFact.isNotEmpty && _currentRecipe.funFact != 'No fun fact available.') ...[
                                const SizedBox(height: 4),
                                _wrapSection(_buildFunFactSection(_currentRecipe.funFact)),
                                const SizedBox(height: 16),
                              ],

                              // Ingredients Section
                              _wrapSection(_buildIngredientsSection(_currentRecipe.ingredients)),

                              const SizedBox(height: 16),

                              // Cooking Instructions Section
                              _wrapSection(_buildSection(
                                'Cooking Instructions',
                                Icons.restaurant_menu,
                                _currentRecipe.cookingInstructions,
                              )),

                              const SizedBox(height: 16),

                              // Health Conditions Section
                              _wrapSection(_buildHealthConditionsSection(_currentRecipe.healthConditions)),

                              const SizedBox(height: 16),

                              // Meal Timing Section
                              _wrapSection(_buildMealTimingSection(_currentRecipe.mealTiming)),

                              const SizedBox(height: 16),

                              // Tags Section
                              if (_currentRecipe.tags.isNotEmpty) ...[
                                _wrapSection(_buildTagsSection(_currentRecipe.tags)),
                                const SizedBox(height: 16),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildQuickStat(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontFamily: AppConstants.primaryFont,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return AppColors.successGreen;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return AppColors.grayText;
    }
  }

  Widget _buildSection(String title, IconData icon, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.successGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: AppColors.successGreen,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontFamily: AppConstants.headingFont,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.blackText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.successGreen.withOpacity(0.06),
            ),
          ),
          child: Text(
            content,
            style: const TextStyle(
              fontFamily: AppConstants.primaryFont,
              fontSize: 15,
              color: AppColors.grayText,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }

  Widget _wrapSection(Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.successGreen.withOpacity(0.03)),
      ),
      child: child,
    );
  }

  Widget _buildFunFactSection(String funFact) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryAccent.withOpacity(0.08),
            AppColors.successGreen.withOpacity(0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryAccent.withOpacity(0.18),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryAccent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.lightbulb_outline,
              color: AppColors.primaryAccent,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Fun Fact 💡',
                  style: TextStyle(
                    fontFamily: AppConstants.headingFont,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryAccent,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  funFact,
                  style: const TextStyle(
                    fontFamily: AppConstants.primaryFont,
                    fontSize: 14,
                    color: AppColors.grayText,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsSection(List<RecipeIngredient> ingredients) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.successGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.shopping_cart_outlined,
                color: AppColors.successGreen,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Ingredients',
              style: TextStyle(
                fontFamily: AppConstants.headingFont,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.blackText,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.successGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${ingredients.length} items',
                style: const TextStyle(
                  fontFamily: AppConstants.primaryFont,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.successGreen,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.successGreen.withOpacity(0.06),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: ingredients.asMap().entries.map((entry) {
              final index = entry.key;
              final ingredient = entry.value;
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index < ingredients.length - 1 ? 12 : 0,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.successGreen.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontFamily: AppConstants.primaryFont,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.successGreen,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ingredient.ingredientName,
                            style: const TextStyle(
                              fontFamily: AppConstants.primaryFont,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.blackText,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${ingredient.quantity} ${ingredient.unit}',
                            style: TextStyle(
                              fontFamily: AppConstants.primaryFont,
                              fontSize: 14,
                              color: AppColors.grayText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildHealthConditionsSection(RecipeHealthConditions healthConditions) {
    List<Map<String, dynamic>> conditions = [];

    if (healthConditions.diabetes) {
      conditions.add({'name': 'Diabetes', 'icon': Icons.medication});
    }
    if (healthConditions.hypertension) {
      conditions.add({'name': 'Hypertension', 'icon': Icons.favorite});
    }
    if (healthConditions.obesityOverweight) {
      conditions.add({'name': 'Weight Management', 'icon': Icons.scale});
    }
    if (healthConditions.underweightMalnutrition) {
      conditions.add({'name': 'Underweight', 'icon': Icons.restaurant});
    }
    if (healthConditions.heartDiseaseChol) {
      conditions.add({'name': 'Heart Health', 'icon': Icons.favorite_border});
    }
    if (healthConditions.anemia) {
      conditions.add({'name': 'Anemia', 'icon': Icons.water_drop});
    }
    if (healthConditions.osteoporosis) {
      conditions.add({'name': 'Osteoporosis', 'icon': Icons.accessibility_new});
    }
    if (healthConditions.none) {
      conditions.add({'name': 'Healthy Individuals', 'icon': Icons.health_and_safety});
    }

    if (conditions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.successGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.health_and_safety,
                color: AppColors.successGreen,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Suitable For',
              style: TextStyle(
                fontFamily: AppConstants.headingFont,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.blackText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: conditions.map((condition) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.successGreen.withOpacity(0.18),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    condition['icon'] as IconData,
                    color: AppColors.successGreen,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    condition['name'] as String,
                    style: const TextStyle(
                      fontFamily: AppConstants.primaryFont,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.successGreen,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMealTimingSection(RecipeMealTiming mealTiming) {
    List<Map<String, dynamic>> timings = [];

    if (mealTiming.breakfast) {
      timings.add({'name': 'Breakfast', 'icon': Icons.wb_sunny, 'color': Colors.orange});
    }
    if (mealTiming.lunch) {
      timings.add({'name': 'Lunch', 'icon': Icons.wb_sunny_outlined, 'color': Colors.amber});
    }
    if (mealTiming.dinner) {
      timings.add({'name': 'Dinner', 'icon': Icons.nights_stay, 'color': Colors.indigo});
    }
    if (mealTiming.snack) {
      timings.add({'name': 'Snack', 'icon': Icons.local_cafe, 'color': Colors.brown});
    }

    if (timings.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.schedule,
                color: AppColors.primaryAccent,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Meal Timing',
              style: TextStyle(
                fontFamily: AppConstants.headingFont,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.blackText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: timings.map((timing) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: (timing['color'] as Color).withOpacity(0.18),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    timing['icon'] as IconData,
                    color: timing['color'] as Color,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    timing['name'] as String,
                    style: TextStyle(
                      fontFamily: AppConstants.primaryFont,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: timing['color'] as Color,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTagsSection(List<String> tags) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.label_outline,
                color: Colors.blue,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Tags',
              style: TextStyle(
                fontFamily: AppConstants.headingFont,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.blackText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: tags.map((tag) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.blue.withOpacity(0.18),
                ),
              ),
              child: Text(
                tag,
                style: const TextStyle(
                  fontFamily: AppConstants.primaryFont,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
