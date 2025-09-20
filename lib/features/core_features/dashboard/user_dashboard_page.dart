import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/auth_service.dart';
import '../../../services/user_service.dart';
import '../../../models/user.dart';

class UserDashboardPage extends StatefulWidget {
  const UserDashboardPage({super.key});

  @override
  State<UserDashboardPage> createState() => _UserDashboardPageState();
}

class _UserDashboardPageState extends State<UserDashboardPage> {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  
  User? _currentUser;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser != null) {
        final userData = await _userService.getUser(currentUser.uid);
        setState(() {
          _currentUser = userData;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'No authenticated user';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load user data: $e';
        _isLoading = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.successGreen,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.white),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: AppColors.successGreen,
        body: Center(
          child: Text(
            _error!,
            style: const TextStyle(color: AppColors.white),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.successGreen,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppColors.successGreen,
            child: SafeArea(
              bottom: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Welcome, ${_currentUser?.fullName.split(' ').first ?? 'User'}!',
                    style: const TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.primaryAccent,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () {
                        // TODO: Navigate to user profile page
                      },
                      icon: const Icon(
                        Icons.person,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              clipBehavior: Clip.hardEdge,
              child: Container(
                width: double.infinity,
                color: AppColors.primaryBackground,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      // Calorie Overview Card
                      _buildCalorieOverviewCard(),
                      const SizedBox(height: 20),
                      
                      // Nutrient Breakdown Card
                      _buildNutrientBreakdownCard(),
                      const SizedBox(height: 20),
                      
                      // Daily Meal Plan Section
                      _buildDailyMealPlanSection(),
                      const SizedBox(height: 20),
                      
                      // Weekly Progress Card
                      _buildWeeklyProgressCard(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      
    );
  }

  Widget _buildCalorieOverviewCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Health Overview',
            style: TextStyle(
              fontFamily: 'Lato',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.blackText,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCalorieItem(
                icon: Icons.restaurant_outlined,
                title: 'Consumed',
                value: 'TODO', // TODO: Implement meal tracking
                color: AppColors.primaryAccent,
              ),
              _buildCalorieItem(
                icon: Icons.local_fire_department_outlined,
                title: 'Calories Limit',
                value: 'TODO', // TODO: Calculate based on user profile
                color: AppColors.successGreen,
              ),
              _buildCalorieItem(
                icon: Icons.fitness_center_outlined,
                title: 'BMI',
                value: _currentUser?.bmi?.toStringAsFixed(1) ?? _currentUser?.calculatedBmi.toStringAsFixed(1) ?? '0.0',
                color: AppColors.purpleAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalorieItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Lato',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.blackText,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 12,
            color: AppColors.grayText,
          ),
        ),
      ],
    );
  }

  Widget _buildNutrientBreakdownCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nutrient Breakdown',
            style: TextStyle(
              fontFamily: 'Lato',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.blackText,
            ),
          ),
          const SizedBox(height: 16),
          // TODO: Connect to meal tracking to show real nutrient data
          _buildNutrientProgressBar('Protein', 0.0, AppColors.primaryAccent), // TODO: Calculate from meals
          const SizedBox(height: 12),
          _buildNutrientProgressBar('Carbs', 0.0, AppColors.successGreen), // TODO: Calculate from meals
          const SizedBox(height: 12),
          _buildNutrientProgressBar('Fat', 0.0, AppColors.purpleAccent), // TODO: Calculate from meals
        ],
      ),
    );
  }

  Widget _buildNutrientProgressBar(String nutrient, double progress, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              nutrient,
              style: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.blackText,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 12,
                color: AppColors.grayText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.lightGray,
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDailyMealPlanSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Daily Meal Plan',
              style: TextStyle(
                fontFamily: 'Lato',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.blackText,
              ),
            ),
            Text(
              'See all',
              style: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 14,
                color: AppColors.primaryAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // TODO: Connect to meal plan service to show personalized meal plans
        _buildMealCard(
          mealType: 'BREAKFAST',
          calories: 'TODO', // TODO: Calculate based on user profile and health conditions
          icon: '🥐',
          color: AppColors.primaryAccent,
        ),
        const SizedBox(height: 12),
        _buildMealCard(
          mealType: 'LUNCH',
          calories: 'TODO', // TODO: Calculate based on user profile and health conditions
          icon: '🍽️',
          color: AppColors.successGreen,
        ),
        const SizedBox(height: 12),
        _buildMealCard(
          mealType: 'DINNER',
          calories: 'TODO', // TODO: Calculate based on user profile and health conditions
          icon: '🥗',
          color: AppColors.purpleAccent,
        ),
        const SizedBox(height: 12),
        _buildMealCard(
          mealType: 'SNACK',
          calories: 'TODO', // TODO: Calculate based on user profile and health conditions
          icon: '🍎',
          color: AppColors.primaryAccent,
        ),
      ],
    );
  }

  Widget _buildMealCard({
    required String mealType,
    required String calories,
    required String icon,
    required Color color,
  }) {
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
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                icon,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mealType,
                  style: TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  calories,
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.blackText,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.add,
                  color: color,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.delete_outline,
                  color: AppColors.primaryAccent,
                  size: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyProgressCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Progress',
            style: TextStyle(
              fontFamily: 'Lato',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.blackText,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.successGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.trending_up,
                  color: AppColors.successGreen,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'This week, you lost 1.2 kg',
                        style: TextStyle(
                          fontFamily: 'Lato',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.blackText,
                        ),
                      ),
                      Text(
                        'You are well on track for your 4.5 kg current weight goal',
                        style: TextStyle(
                          fontFamily: 'OpenSans',
                          fontSize: 12,
                          color: AppColors.grayText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}