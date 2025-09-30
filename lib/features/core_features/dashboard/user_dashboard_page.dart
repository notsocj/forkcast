import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/auth_service.dart';
import '../../../services/user_service.dart';
import '../../../services/meal_logging_service.dart';
import '../../../models/user.dart';
import '../main_navigation_wrapper.dart';

class UserDashboardPage extends StatefulWidget {
  const UserDashboardPage({super.key});

  @override
  State<UserDashboardPage> createState() => _UserDashboardPageState();
}

class _UserDashboardPageState extends State<UserDashboardPage> {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  final MealLoggingService _mealLoggingService = MealLoggingService();
  
  User? _currentUser;
  Map<String, dynamic>? _todaysMealStatus;
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
        // Load user data and today's meals in parallel
        final futures = await Future.wait([
          _userService.getUser(currentUser.uid),
          _mealLoggingService.getTodaysMealStatus(),
        ]);
        
        setState(() {
          _currentUser = futures[0] as User;
          _todaysMealStatus = futures[1] as Map<String, dynamic>;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'No authenticated user';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Dashboard - Error loading user data: $e');
      setState(() {
        _error = 'Failed to load user data: $e';
        _isLoading = false;
      });
    }
  }

  /// Calculate total calories consumed today
  double _getConsumedCalories() {
    if (_todaysMealStatus == null) return 0.0;
    
    double totalCalories = 0.0;
    
    for (String mealType in ['Breakfast', 'Lunch', 'Dinner', 'Snack']) {
      final mealData = _todaysMealStatus![mealType];
      if (mealData != null && mealData['logged'] == true) {
        final data = mealData['data'] as Map<String, dynamic>?;
        if (data != null && data['scaled_kcal'] != null) {
          totalCalories += (data['scaled_kcal'] as num).toDouble();
        }
      }
    }
    
    return totalCalories;
  }

  /// Calculate daily calorie limit based on user profile (simplified version)
  double _getDailyCalorieLimit() {
    if (_currentUser == null) return 2000.0; // default
    
    // This is a simplified calculation. In a real app, you'd use more complex formulas
    // like Harris-Benedict or Mifflin-St Jeor equations
    double baseCalories = 1800; // base for adults
    
    // Adjust based on age (simplified)
    int age = DateTime.now().year - _currentUser!.birthdate.year;
    if (age > 50) {
      baseCalories -= 100;
    } else if (age < 25) {
      baseCalories += 100;
    }
    
    // Adjust based on gender (simplified)
    if (_currentUser!.gender.toLowerCase() == 'male') {
      baseCalories += 300;
    }
    
    // Adjust based on weight (simplified)
    double weight = _currentUser!.weightKg;
    if (weight > 70) {
      baseCalories += (weight - 70) * 10;
    } else if (weight < 60) {
      baseCalories -= (60 - weight) * 8;
    }
    
    return baseCalories;
  }

  /// Get health status based on BMI only
  String _getHealthStatus() {
    if (_currentUser == null) return 'Unknown';
    
    final bmi = _currentUser!.bmi ?? _currentUser!.calculatedBmi;
    
    if (bmi < 18.5) {
      return 'Underweight';
    } else if (bmi < 25.0) {
      return 'Healthy';
    } else if (bmi < 30.0) {
      return 'Overweight';
    } else {
      return 'Obese';
    }
  }

  /// Get meal data for a specific meal type
  Map<String, dynamic> _getMealDataForType(String mealType) {
    if (_todaysMealStatus == null) {
      return {
        'name': 'No meal logged',
        'calories': '0 kcal',
        'hasData': false,
        'source': 'none',
      };
    }
    
    final mealData = _todaysMealStatus![mealType];
    if (mealData != null && mealData['logged'] == true) {
      final data = mealData['data'] as Map<String, dynamic>?;
      final source = mealData['source'] as String? ?? 'today';
      if (data != null) {
        return {
          'name': data['recipe_name'] ?? 'Unknown meal',
          'calories': '${data['scaled_kcal']?.toInt() ?? 0} kcal',
          'hasData': true,
          'source': source,
        };
      }
    }
    
    return {
      'name': 'No meal logged',
      'calories': '0 kcal',
      'hasData': false,
      'source': 'none',
    };
  }

  /// Get meal icon for meal type
  String _getMealIcon(String mealType) {
    switch (mealType) {
      case 'BREAKFAST':
        return '🥐';
      case 'LUNCH':
        return '🍽️';
      case 'DINNER':
        return '🥗';
      case 'SNACK':
        return '🍎';
      default:
        return '🍴';
    }
  }

  /// Get meal color for meal type
  Color _getMealColor(String mealType) {
    switch (mealType) {
      case 'BREAKFAST':
        return AppColors.primaryAccent;
      case 'LUNCH':
        return AppColors.successGreen;
      case 'DINNER':
        return AppColors.purpleAccent;
      case 'SNACK':
        return Colors.orange;
      default:
        return AppColors.grayText;
    }
  }

  /// Calculate total nutrients consumed today
  Map<String, double> _getTodayNutrients() {
    if (_todaysMealStatus == null) {
      return {'protein': 0.0, 'carbs': 0.0, 'fat': 0.0};
    }
    
    double totalProtein = 0.0;
    double totalCarbs = 0.0;
    double totalFat = 0.0;
    
    for (String mealType in ['Breakfast', 'Lunch', 'Dinner', 'Snack']) {
      final mealData = _todaysMealStatus![mealType];
      if (mealData != null && mealData['logged'] == true) {
        final data = mealData['data'] as Map<String, dynamic>?;
        if (data != null) {
          // These are estimated from calories since we don't have exact macros
          // In a real app, you'd store protein/carbs/fat values in Firebase
          final calories = (data['scaled_kcal'] as num?)?.toDouble() ?? 0.0;
          
          // Rough estimation: 
          // - Breakfast/Snack: more carbs (60% carbs, 20% protein, 20% fat)
          // - Lunch/Dinner: balanced (40% carbs, 30% protein, 30% fat)
          if (mealType == 'Breakfast' || mealType == 'Snack') {
            totalCarbs += (calories * 0.60) / 4; // 4 calories per gram of carbs
            totalProtein += (calories * 0.20) / 4; // 4 calories per gram of protein
            totalFat += (calories * 0.20) / 9; // 9 calories per gram of fat
          } else {
            totalCarbs += (calories * 0.40) / 4;
            totalProtein += (calories * 0.30) / 4;
            totalFat += (calories * 0.30) / 9;
          }
        }
      }
    }
    
    return {
      'protein': totalProtein,
      'carbs': totalCarbs,
      'fat': totalFat,
    };
  }

  /// Get daily nutrient targets based on user profile
  Map<String, double> _getNutrientTargets() {
    if (_currentUser == null) {
      return {'protein': 50.0, 'carbs': 250.0, 'fat': 65.0}; // default values
    }
    
    final dailyCalories = _getDailyCalorieLimit();
    final weight = _currentUser!.weightKg;
    
    // Calculate targets based on standard recommendations
    final proteinTarget = weight * 0.8; // 0.8g per kg body weight
    final fatTarget = (dailyCalories * 0.25) / 9; // 25% of calories from fat
    final carbsTarget = (dailyCalories - (proteinTarget * 4) - (fatTarget * 9)) / 4; // remaining calories from carbs
    
    return {
      'protein': proteinTarget,
      'carbs': carbsTarget,
      'fat': fatTarget,
    };
  }

  /// Get nutrient progress (0.0 to 1.0)
  double _getNutrientProgress(String nutrient) {
    final consumed = _getTodayNutrients();
    final targets = _getNutrientTargets();
    
    final consumedAmount = consumed[nutrient] ?? 0.0;
    final targetAmount = targets[nutrient] ?? 1.0;
    
    return (consumedAmount / targetAmount).clamp(0.0, 1.0);
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
          // Enhanced Header with Icon and Description
          _buildEnhancedHeader(),
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
                child: RefreshIndicator(
                  onRefresh: _loadUserData,
                  color: AppColors.successGreen,
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
          ),
        ],
      ),
      
    );
  }

  Widget _buildEnhancedHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.successGreen,
            AppColors.successGreen.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.successGreen.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.dashboard_outlined,
                color: AppColors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dashboard',
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Welcome back, ${_currentUser?.fullName.split(' ').first ?? 'User'}! Track your daily nutrition',
                    style: TextStyle(
                      fontFamily: 'OpenSans',
                      fontSize: 14,
                      color: AppColors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            // Profile Icon with User Initials
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.white.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  _getUserInitials(_currentUser?.fullName ?? 'User'),
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
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
                value: '${_getConsumedCalories().toInt()}',
                color: AppColors.primaryAccent,
              ),
              _buildCalorieItem(
                icon: Icons.local_fire_department_outlined,
                title: 'Daily Limit',
                value: '${_getDailyCalorieLimit().toInt()}',
                color: AppColors.successGreen,
              ),
              _buildCalorieItem(
                icon: Icons.fitness_center_outlined,
                title: 'Health Status',
                value: _getHealthStatus(),
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
    // Check if value is numeric for styling
    final isNumeric = double.tryParse(value) != null;
    
    return Expanded(
      child: Column(
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
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Lato',
              fontSize: isNumeric ? 20 : 14,
              fontWeight: FontWeight.bold,
              color: AppColors.blackText,
            ),
          ),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 12,
            color: AppColors.grayText,
          ),
        ),
      ],
      ),
    );
  }  Widget _buildNutrientBreakdownCard() {
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
          _buildNutrientProgressBar('Protein', _getNutrientProgress('protein'), AppColors.primaryAccent),
          const SizedBox(height: 12),
          _buildNutrientProgressBar('Carbs', _getNutrientProgress('carbs'), AppColors.successGreen),
          const SizedBox(height: 12),
          _buildNutrientProgressBar('Fat', _getNutrientProgress('fat'), AppColors.purpleAccent),
        ],
      ),
    );
  }

  Widget _buildNutrientProgressBar(String nutrient, double progress, Color color) {
    final consumed = _getTodayNutrients()[nutrient.toLowerCase()] ?? 0.0;
    final target = _getNutrientTargets()[nutrient.toLowerCase()] ?? 1.0;
    
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
              '${consumed.toInt()}g / ${target.toInt()}g',
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
            GestureDetector(
              onTap: () {
                // Navigate to MainNavigationWrapper with Meal Plan tab selected (index 2)
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MainNavigationWrapper(initialTab: 2),
                  ),
                );
              },
              child: Text(
                'See all',
                style: TextStyle(
                  fontFamily: 'OpenSans',
                  fontSize: 14,
                  color: AppColors.primaryAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Dynamic meal cards based on Firebase data
        ...['Breakfast', 'Lunch', 'Dinner', 'Snack'].map((mealType) {
          final mealData = _getMealDataForType(mealType);
          return Column(
            children: [
              _buildMealCard(
                mealType: mealType.toUpperCase(), // Display as uppercase
                mealName: mealData['name'],
                calories: mealData['calories'],
                icon: _getMealIcon(mealType.toUpperCase()),
                color: _getMealColor(mealType.toUpperCase()),
                hasData: mealData['hasData'],
                source: mealData['source'],
              ),
              const SizedBox(height: 12),
            ],
          );
        }).toList(),
      ],
    );
  }

  Widget _buildMealCard({
    required String mealType,
    required String mealName,
    required String calories,
    required String icon,
    required Color color,
    required bool hasData,
    String source = 'none',
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: source == 'yesterday' ? Border.all(color: AppColors.primaryAccent.withOpacity(0.3), width: 1) : null,
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
                  hasData ? mealName : 'No meal logged',
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: hasData ? AppColors.blackText : AppColors.grayText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (hasData) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        calories,
                        style: TextStyle(
                          fontFamily: 'OpenSans',
                          fontSize: 12,
                          color: AppColors.grayText,
                        ),
                      ),
                      if (source == 'yesterday') ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryAccent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Yesterday',
                            style: TextStyle(
                              fontFamily: 'OpenSans',
                              fontSize: 10,
                              color: AppColors.primaryAccent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
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

  String _getUserInitials(String fullName) {
    if (fullName.isEmpty) return 'U';
    
    final nameParts = fullName.trim().split(' ');
    if (nameParts.length == 1) {
      return nameParts[0][0].toUpperCase();
    } else {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    }
  }
}