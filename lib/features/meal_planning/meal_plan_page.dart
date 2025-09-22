import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_colors.dart';
import '../../data/predefined_meals.dart';
import '../../services/meal_logging_service.dart';
import '../../services/personalized_meal_service.dart';
import 'meal_search_results_page.dart';
import 'recipe_detail_page.dart';

class MealPlanPage extends StatefulWidget {
  const MealPlanPage({super.key});

  @override
  State<MealPlanPage> createState() => _MealPlanPageState();
}

class _MealPlanPageState extends State<MealPlanPage> {
  final TextEditingController _searchController = TextEditingController();
  final MealLoggingService _mealLoggingService = MealLoggingService();
  final PersonalizedMealService _personalizedMealService = PersonalizedMealService();
  
  // Recent searches from predefined data
  final List<String> _recentSearches = PredefinedMealsData.recentSearches;
  
  // Today's meals data loaded from Firebase
  List<Map<String, dynamic>> _todaysMeals = [];
  bool _isLoadingMeals = true;
  bool _isGeneratingAISuggestions = false;

  @override
  void initState() {
    super.initState();
    _loadTodaysMeals();
  }

  Future<void> _loadTodaysMeals() async {
    setState(() {
      _isLoadingMeals = true;
    });

    try {
      final mealStatus = await _mealLoggingService.getTodaysMealStatus();
      
      setState(() {
        _todaysMeals = [
          {
            'type': 'BREAKFAST',
            'name': mealStatus['Breakfast']!['logged'] 
                ? mealStatus['Breakfast']!['data']['recipe_name'] ?? 'Unknown meal'
                : 'No meal logged',
            'calories': mealStatus['Breakfast']!['logged']
                ? '${mealStatus['Breakfast']!['data']['kcal_min']} kcal'
                : '0 kcal',
            'isEmpty': !mealStatus['Breakfast']!['logged'],
            'color': Colors.orange,
            'data': mealStatus['Breakfast']!['data'],
          },
          {
            'type': 'LUNCH',
            'name': mealStatus['Lunch']!['logged'] 
                ? mealStatus['Lunch']!['data']['recipe_name'] ?? 'Unknown meal'
                : 'No meal logged',
            'calories': mealStatus['Lunch']!['logged']
                ? '${mealStatus['Lunch']!['data']['kcal_min']} kcal'
                : '0 kcal',
            'isEmpty': !mealStatus['Lunch']!['logged'],
            'color': Colors.red,
            'data': mealStatus['Lunch']!['data'],
          },
          {
            'type': 'DINNER',
            'name': mealStatus['Dinner']!['logged'] 
                ? mealStatus['Dinner']!['data']['recipe_name'] ?? 'Unknown meal'
                : 'No meal logged',
            'calories': mealStatus['Dinner']!['logged']
                ? '${mealStatus['Dinner']!['data']['kcal_min']} kcal'
                : '0 kcal',
            'isEmpty': !mealStatus['Dinner']!['logged'],
            'color': Colors.green,
            'data': mealStatus['Dinner']!['data'],
          },
          {
            'type': 'SNACK',
            'name': mealStatus['Snack']!['logged'] 
                ? mealStatus['Snack']!['data']['recipe_name'] ?? 'Unknown meal'
                : 'No meal logged',
            'calories': mealStatus['Snack']!['logged']
                ? '${mealStatus['Snack']!['data']['kcal_min']} kcal'
                : '0 kcal',
            'isEmpty': !mealStatus['Snack']!['logged'],
            'color': Colors.purple,
            'data': mealStatus['Snack']!['data'],
          },
        ];
        _isLoadingMeals = false;
      });
    } catch (e) {
      print('Error loading today\'s meals: $e');
      // Fallback to empty state
      setState(() {
        _todaysMeals = [
          {
            'type': 'BREAKFAST',
            'name': 'No meal logged',
            'calories': '0 kcal',
            'isEmpty': true,
            'color': Colors.orange,
          },
          {
            'type': 'LUNCH',
            'name': 'No meal logged',
            'calories': '0 kcal',
            'isEmpty': true,
            'color': Colors.red,
          },
          {
            'type': 'DINNER',
            'name': 'No meal logged',
            'calories': '0 kcal',
            'isEmpty': true,
            'color': Colors.green,
          },
          {
            'type': 'SNACK',
            'name': 'No meal logged',
            'calories': '0 kcal',
            'isEmpty': true,
            'color': Colors.purple,
          },
        ];
        _isLoadingMeals = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.successGreen,
      body: SafeArea(
        child: Column(
          children: [
            // Header with search
            _buildHeader(),
            // Main content
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primaryBackground,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                ),
                child: RefreshIndicator(
                  onRefresh: _loadTodaysMeals,
                  color: AppColors.successGreen,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRecentSearches(),
                      const SizedBox(height: 24),
                      _buildDidYouKnowSection(),
                      const SizedBox(height: 24),
                      _buildTodaysMealsSection(),
                    ],
                  ),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MealSearchResultsPage(searchQuery: value.trim()),
                      ),
                    );
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: TextStyle(
                    color: AppColors.grayText,
                    fontFamily: 'OpenSans',
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColors.grayText,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.menu,
              color: AppColors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSearches() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Searches',
          style: TextStyle(
            fontFamily: 'Lato',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.blackText,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Wrap(
            spacing: 12,
            runSpacing: 8,
            children: _recentSearches.map((search) => _buildSearchChip(search)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchChip(String text) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MealSearchResultsPage(searchQuery: text),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primaryBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.lightGray,
            width: 1,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 14,
            color: AppColors.blackText,
          ),
        ),
      ),
    );
  }

  Widget _buildDidYouKnowSection() {
    // Use random nutrition tip from predefined data
    final tips = PredefinedMealsData.nutritionTips;
    final randomTip = tips[(DateTime.now().day) % tips.length];
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.successGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppColors.successGreen.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.successGreen.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.lightbulb_outline,
              color: AppColors.successGreen,
              size: 20,
            ),
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
                  randomTip,
                  style: TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 12,
                    color: AppColors.blackText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodaysMealsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Today\'s Meals',
              style: TextStyle(
                fontFamily: 'Lato',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.blackText,
              ),
            ),
            GestureDetector(
              onTap: _isGeneratingAISuggestions ? null : _generateAIMealPlan,
              child: Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    size: 14,
                    color: _isGeneratingAISuggestions 
                        ? AppColors.grayText 
                        : AppColors.successGreen,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _isGeneratingAISuggestions ? 'GENERATING...' : 'AI SUGGESTIONS',
                    style: TextStyle(
                      fontFamily: 'OpenSans',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _isGeneratingAISuggestions 
                          ? AppColors.grayText 
                          : AppColors.successGreen,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _isLoadingMeals
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.successGreen,
                ),
              )
            : Column(
                children: _todaysMeals.map((meal) => _buildMealCard(meal)).toList(),
              ),
      ],
    );
  }

  Widget _buildMealCard(Map<String, dynamic> meal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Meal image placeholder
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: meal['color'].withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: meal['color'].withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(
              _getMealIcon(meal['type']),
              color: meal['color'],
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          // Meal info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal['type'],
                  style: TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: meal['color'],
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  meal['name'],
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.blackText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  meal['calories'],
                  style: TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 12,
                    color: AppColors.grayText,
                  ),
                ),
              ],
            ),
          ),
          // Action buttons
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  if (meal['isEmpty']) {
                    _navigateToMealSearch(meal['type']);
                  } else {
                    _showMealOptions(meal);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: meal['isEmpty'] 
                        ? AppColors.successGreen.withOpacity(0.1)
                        : AppColors.primaryBackground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    meal['isEmpty'] ? Icons.add : Icons.more_horiz,
                    color: meal['isEmpty'] 
                        ? AppColors.successGreen
                        : AppColors.grayText,
                    size: 16,
                  ),
                ),
              ),
              if (!meal['isEmpty']) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _generateMealTypeSuggestions(meal['type']),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.successGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.successGreen.withOpacity(0.3),
                      ),
                    ),
                    child: Icon(
                      Icons.auto_awesome,
                      color: AppColors.successGreen,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  IconData _getMealIcon(String mealType) {
    switch (mealType) {
      case 'BREAKFAST':
        return Icons.free_breakfast;
      case 'LUNCH':
        return Icons.lunch_dining;
      case 'DINNER':
        return Icons.dinner_dining;
      case 'SNACK':
        return Icons.cake;
      default:
        return Icons.restaurant;
    }
  }

  void _navigateToMealSearch(String mealType) {
    // Navigate to search page with empty query to show all meals
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MealSearchResultsPage(
          searchQuery: '', // Use the correct parameter name
        ),
      ),
    ).then((_) {
      // Refresh meals when returning from search
      _loadTodaysMeals();
    });
  }

  void _showMealOptions(Map<String, dynamic> meal) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grayText.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                meal['name'],
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.blackText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${meal['type']} • ${meal['calories']}',
                style: TextStyle(
                  fontFamily: 'OpenSans',
                  fontSize: 14,
                  color: AppColors.grayText,
                ),
              ),
              const SizedBox(height: 24),
              _buildOptionButton(
                icon: Icons.visibility,
                title: 'View Details',
                subtitle: 'See nutrition facts and ingredients',
                onTap: () {
                  Navigator.pop(context);
                  _viewMealDetails(meal);
                },
              ),
              const SizedBox(height: 12),
              _buildOptionButton(
                icon: Icons.refresh,
                title: 'Replace Meal',
                subtitle: 'Choose a different meal for ${meal['type'].toLowerCase()}',
                onTap: () {
                  Navigator.pop(context);
                  _navigateToMealSearch(meal['type']);
                },
              ),
              const SizedBox(height: 12),
              _buildOptionButton(
                icon: Icons.delete_outline,
                title: 'Remove Meal',
                subtitle: 'Remove this meal from today\'s plan',
                onTap: () {
                  Navigator.pop(context);
                  _removeMeal(meal);
                },
                isDestructive: true,
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primaryBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive ? Colors.red : AppColors.grayText,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDestructive ? Colors.red : AppColors.blackText,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'OpenSans',
                      fontSize: 12,
                      color: AppColors.grayText,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.grayText,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _viewMealDetails(Map<String, dynamic> meal) {
    // Find the predefined meal by ID if available
    if (meal['data'] != null && meal['data']['recipe_id'] != null) {
      final mealId = meal['data']['recipe_id'];
      final predefinedMeal = PredefinedMealsData.getMealById(mealId);
      
      if (predefinedMeal != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeDetailPage(meal: predefinedMeal),
          ),
        );
        return;
      }
    }

    // Fallback: show a simple dialog with available info
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(meal['name']),
        content: Text('Calories: ${meal['calories']}\nMeal Type: ${meal['type']}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _removeMeal(Map<String, dynamic> meal) async {
    if (meal['data'] != null && meal['data']['id'] != null) {
      try {
        await _mealLoggingService.deleteMeal(meal['data']['id']);
        _loadTodaysMeals(); // Refresh the meal list
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${meal['name']} removed from today\'s meals'),
              backgroundColor: AppColors.successGreen,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to remove meal: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  /// Generate AI meal plan suggestions for entire day and log them directly
  Future<void> _generateAIMealPlan() async {
    setState(() {
      _isGeneratingAISuggestions = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Get AI meal plan suggestions
      Map<String, List<PredefinedMeal>> dailyPlan = 
          await _personalizedMealService.generateDailyMealPlan(user.uid);

      // Automatically log all AI suggestions to today's meals
      await _logDailyMealPlan(dailyPlan);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('AI meal plan generated and logged successfully!'),
            backgroundColor: AppColors.successGreen,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      // Refresh today's meals to show the new suggestions
      await _loadTodaysMeals();

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate AI meal plan: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingAISuggestions = false;
        });
      }
    }
  }

  /// Generate AI meal suggestions for specific meal type and log directly
  Future<void> _generateMealTypeSuggestions(String mealType) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: AppColors.white,
                  strokeWidth: 2,
                ),
              ),
              const SizedBox(width: 12),
              Text('Generating AI suggestions for ${mealType.toLowerCase()}...'),
            ],
          ),
          backgroundColor: AppColors.successGreen,
          duration: const Duration(seconds: 2),
        ),
      );

      // Get AI meal type suggestions (get multiple for variety)
      List<PredefinedMeal> suggestions = await _personalizedMealService
          .generateMealTypeSuggestions(user.uid, mealType.toLowerCase());

      if (suggestions.isNotEmpty) {
        // Select first suggestion to log automatically
        PredefinedMeal selectedMeal = suggestions.first;
        
        // Log the meal directly with default PAX (1)
        await _mealLoggingService.logMeal(
          meal: selectedMeal,
          mealType: mealType,
          amount: 1.0,
          measurement: 'serving',
          pax: 1,
        );

        // Refresh today's meals to show the new suggestion
        await _loadTodaysMeals();

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${selectedMeal.recipeName} added to your ${mealType.toLowerCase()}!'),
              backgroundColor: AppColors.successGreen,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate suggestions: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Show AI meal plan dialog for entire day
  // ignore: unused_element
  void _showAIMealPlanDialog(Map<String, List<PredefinedMeal>> dailyPlan) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
              maxWidth: MediaQuery.of(context).size.width * 0.9,
            ),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.successGreen,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.auto_awesome, color: AppColors.white, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'AI Daily Meal Plan',
                          style: TextStyle(
                            fontFamily: 'Lato',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(Icons.close, color: AppColors.white, size: 24),
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
                      children: dailyPlan.entries.map((entry) {
                        return _buildMealPlanSection(entry.key, entry.value);
                      }).toList(),
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

  /// Show meal type suggestions dialog
  // ignore: unused_element
  void _showMealTypeSuggestionsDialog(String mealType, List<PredefinedMeal> suggestions) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
              maxWidth: MediaQuery.of(context).size.width * 0.9,
            ),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.successGreen,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.auto_awesome, color: AppColors.white, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'AI $mealType Suggestions',
                          style: TextStyle(
                            fontFamily: 'Lato',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(Icons.close, color: AppColors.white, size: 24),
                      ),
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: suggestions.map((meal) {
                        return _buildSuggestionMealCard(meal);
                      }).toList(),
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

  /// Build meal plan section for daily plan dialog
  Widget _buildMealPlanSection(String mealType, List<PredefinedMeal> meals) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            mealType.toUpperCase(),
            style: TextStyle(
              fontFamily: 'Lato',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.blackText,
            ),
          ),
          const SizedBox(height: 12),
          ...meals.map((meal) => _buildSuggestionMealCard(meal)),
        ],
      ),
    );
  }

  /// Build individual meal suggestion card
  Widget _buildSuggestionMealCard(PredefinedMeal meal) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context); // Close dialog
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeDetailPage(meal: meal),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primaryBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.successGreen.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            // Meal info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal.recipeName,
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.blackText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${meal.kcal} kcal • ${meal.prepTimeMinutes} min',
                    style: TextStyle(
                      fontFamily: 'OpenSans',
                      fontSize: 12,
                      color: AppColors.grayText,
                    ),
                  ),
                ],
              ),
            ),
            // Arrow
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.grayText,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  /// Log daily meal plan suggestions automatically
  Future<void> _logDailyMealPlan(Map<String, List<PredefinedMeal>> dailyPlan) async {
    for (String mealType in dailyPlan.keys) {
      final meals = dailyPlan[mealType];
      if (meals != null && meals.isNotEmpty) {
        // Select the first meal suggestion for each meal type
        final selectedMeal = meals.first;
        
        // Log the meal with default settings
        await _mealLoggingService.logMeal(
          meal: selectedMeal,
          mealType: mealType,
          amount: 1.0,
          measurement: 'serving',
          pax: 1,
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}