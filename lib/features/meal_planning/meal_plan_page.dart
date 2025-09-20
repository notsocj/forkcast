import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'meal_search_results_page.dart';

class MealPlanPage extends StatefulWidget {
  const MealPlanPage({super.key});

  @override
  State<MealPlanPage> createState() => _MealPlanPageState();
}

class _MealPlanPageState extends State<MealPlanPage> {
  final TextEditingController _searchController = TextEditingController();
  
  // Sample data for recent searches
  final List<String> _recentSearches = ['Avocado', 'Chicken', 'Egg'];
  
  // Sample data for today's meals
  final List<Map<String, dynamic>> _todaysMeals = [
    {
      'type': 'BREAKFAST',
      'name': 'Chicken Adobo',
      'calories': '140-160 kcal',
      'image': 'assets/images/chicken_adobo.jpg',
      'color': Colors.orange,
    },
    {
      'type': 'LUNCH',
      'name': 'Beef Stew',
      'calories': '330-360 kcal',
      'image': 'assets/images/beef_stew.jpg',
      'color': Colors.red,
    },
    {
      'type': 'DINNER',
      'name': 'Grilled Fish',
      'calories': '190-200 kcal',
      'image': 'assets/images/grilled_fish.jpg',
      'color': Colors.green,
    },
    {
      'type': 'SNACK',
      'name': 'Mixed Fruits',
      'calories': '250-300 kcal',
      'image': 'assets/images/mixed_fruits.jpg',
      'color': Colors.purple,
    },
  ];

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
                  'Malunggay/Moringa contains 4x more vitamin A than carrots and 7x more vitamin C than oranges!',
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
            Text(
              'REFRESH ALL',
              style: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.successGreen,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Column(
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.add,
                  color: AppColors.grayText,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.refresh,
                  color: AppColors.grayText,
                  size: 16,
                ),
              ),
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}