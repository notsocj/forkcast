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

  /// Calculate nutrient density score for today's meals
  double _getNutrientDensityScore() {
    if (_todaysMealStatus == null) return 0.0;
    
    int mealsLogged = 0;
    double totalScore = 0.0;
    
    for (String mealType in ['Breakfast', 'Lunch', 'Dinner', 'Snack']) {
      final mealData = _todaysMealStatus![mealType];
      if (mealData != null && mealData['logged'] == true) {
        final data = mealData['data'] as Map<String, dynamic>?;
        if (data != null) {
          mealsLogged++;
          // Score based on balanced nutrition (simplified scoring)
          totalScore += 85.0; // Each logged meal contributes to nutritional variety
        }
      }
    }
    
    return mealsLogged > 0 ? totalScore / mealsLogged : 0.0;
  }

  /// Get nutritional variety target (number of different food groups consumed)
  int _getNutritionalVarietyTarget() {
    // Target: consume from 5-6 different food groups daily
    // (Grains, Vegetables, Fruits, Protein, Dairy, Healthy Fats)
    return 5;
  }
  
  /// Calculate current nutritional variety score
  int _getCurrentNutritionalVariety() {
    if (_todaysMealStatus == null) return 0;
    
    Set<String> foodGroups = <String>{};
    
    for (String mealType in ['Breakfast', 'Lunch', 'Dinner', 'Snack']) {
      final mealData = _todaysMealStatus![mealType];
      if (mealData != null && mealData['logged'] == true) {
        final data = mealData['data'] as Map<String, dynamic>?;
        if (data != null) {
          // Simulate food group identification based on meal name
          String mealName = (data['recipe_name'] ?? '').toString().toLowerCase();
          
          // Add food groups based on common Filipino ingredients
          if (mealName.contains('rice') || mealName.contains('bread') || mealName.contains('noodle')) {
            foodGroups.add('Grains');
          }
          if (mealName.contains('chicken') || mealName.contains('fish') || mealName.contains('pork') || 
              mealName.contains('beef') || mealName.contains('egg') || mealName.contains('tofu')) {
            foodGroups.add('Protein');
          }
          if (mealName.contains('vegetable') || mealName.contains('malunggay') || mealName.contains('kangkong') ||
              mealName.contains('cabbage') || mealName.contains('spinach') || mealName.contains('tomato')) {
            foodGroups.add('Vegetables');
          }
          if (mealName.contains('banana') || mealName.contains('apple') || mealName.contains('orange') ||
              mealName.contains('mango') || mealName.contains('fruit')) {
            foodGroups.add('Fruits');
          }
          if (mealName.contains('milk') || mealName.contains('cheese') || mealName.contains('yogurt')) {
            foodGroups.add('Dairy');
          }
          if (mealName.contains('oil') || mealName.contains('nuts') || mealName.contains('avocado')) {
            foodGroups.add('Healthy Fats');
          }
          
          // Default: add at least one food group for any logged meal
          if (foodGroups.isEmpty) {
            foodGroups.add('Mixed Foods');
          }
        }
      }
    }
    
    return foodGroups.length;
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

  /// Calculate key nutrients consumed today focusing on micronutrients
  Map<String, double> _getTodayNutrients() {
    if (_todaysMealStatus == null) {
      return {'vitamin_c': 0.0, 'iron': 0.0, 'calcium': 0.0, 'fiber': 0.0};
    }
    
    double totalVitaminC = 0.0;
    double totalIron = 0.0;
    double totalCalcium = 0.0;
    double totalFiber = 0.0;
    
    for (String mealType in ['Breakfast', 'Lunch', 'Dinner', 'Snack']) {
      final mealData = _todaysMealStatus![mealType];
      if (mealData != null && mealData['logged'] == true) {
        final data = mealData['data'] as Map<String, dynamic>?;
        if (data != null) {
          String mealName = (data['recipe_name'] ?? '').toString().toLowerCase();
          
          // Estimate nutrient content based on Filipino food knowledge
          // Vitamin C rich foods
          if (mealName.contains('malunggay') || mealName.contains('guava') || 
              mealName.contains('papaya') || mealName.contains('citrus')) {
            totalVitaminC += 25.0; // mg
          } else if (mealName.contains('vegetable') || mealName.contains('fruit')) {
            totalVitaminC += 10.0;
          }
          
          // Iron rich foods
          if (mealName.contains('meat') || mealName.contains('liver') || 
              mealName.contains('fish') || mealName.contains('malunggay')) {
            totalIron += 2.5; // mg
          } else if (mealName.contains('egg') || mealName.contains('beans')) {
            totalIron += 1.2;
          }
          
          // Calcium rich foods
          if (mealName.contains('milk') || mealName.contains('cheese') || 
              mealName.contains('sardines') || mealName.contains('malunggay')) {
            totalCalcium += 150.0; // mg
          } else if (mealName.contains('vegetable') || mealName.contains('tofu')) {
            totalCalcium += 80.0;
          }
          
          // Fiber rich foods
          if (mealName.contains('rice') && mealName.contains('brown')) {
            totalFiber += 8.0; // g
          } else if (mealName.contains('vegetable') || mealName.contains('fruit') || 
                     mealName.contains('beans') || mealName.contains('whole')) {
            totalFiber += 5.0;
          } else if (mealName.contains('rice') || mealName.contains('bread')) {
            totalFiber += 2.0;
          }
        }
      }
    }
    
    return {
      'vitamin_c': totalVitaminC,
      'iron': totalIron,
      'calcium': totalCalcium,
      'fiber': totalFiber,
    };
  }

  /// Get daily nutrient targets for key micronutrients
  Map<String, double> _getNutrientTargets() {
    if (_currentUser == null) {
      return {
        'vitamin_c': 65.0, // mg - RDA for adults
        'iron': 8.0, // mg - RDA for adults (varies by gender)
        'calcium': 1000.0, // mg - RDA for adults
        'fiber': 25.0, // g - recommended daily intake
      };
    }
    
    // Adjust targets based on user profile
    double vitaminCTarget = 65.0; // Base RDA
    double ironTarget = 8.0; // Base for males
    double calciumTarget = 1000.0; // Base for adults
    double fiberTarget = 25.0; // Base recommendation
    
    // Adjust based on gender
    if (_currentUser!.gender.toLowerCase() == 'female') {
      ironTarget = 18.0; // Higher iron requirement for women
    }
    
    // Adjust based on age
    int age = DateTime.now().year - _currentUser!.birthdate.year;
    if (age > 50) {
      calciumTarget = 1200.0; // Higher calcium for older adults
      vitaminCTarget = 75.0; // Slightly higher Vitamin C
    } else if (age < 25) {
      calciumTarget = 1300.0; // Higher calcium for young adults
      fiberTarget = 30.0; // Higher fiber for young adults
    }
    
    return {
      'vitamin_c': vitaminCTarget,
      'iron': ironTarget,
      'calcium': calciumTarget,
      'fiber': fiberTarget,
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
                      // Nutritional Overview Card
                      _buildNutritionalOverviewCard(),
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

  Widget _buildNutritionalOverviewCard() {
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
            'Nutritional Overview',
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
              _buildNutritionalItem(
                icon: Icons.eco_outlined,
                title: 'Food Groups',
                value: '${_getCurrentNutritionalVariety()}/${_getNutritionalVarietyTarget()}',
                color: AppColors.successGreen,
              ),
              _buildNutritionalItem(
                icon: Icons.psychology_outlined,
                title: 'Quality Score',
                value: '${_getNutrientDensityScore().toInt()}%',
                color: AppColors.primaryAccent,
              ),
              _buildNutritionalItem(
                icon: Icons.favorite_outline,
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

  Widget _buildNutritionalItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    // Check if value contains numbers or percentages for styling
    final hasNumbers = RegExp(r'\d').hasMatch(value);
    final isPercentage = value.contains('%');
    final isFraction = value.contains('/');
    
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
              fontSize: (hasNumbers && (isPercentage || isFraction)) ? 16 : 14,
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
            'Key Nutrients Today',
            style: TextStyle(
              fontFamily: 'Lato',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.blackText,
            ),
          ),
          const SizedBox(height: 16),
          _buildNutrientProgressBar('Vitamin C', _getNutrientProgress('vitamin_c'), AppColors.primaryAccent),
          const SizedBox(height: 12),
          _buildNutrientProgressBar('Iron', _getNutrientProgress('iron'), AppColors.successGreen),
          const SizedBox(height: 12),
          _buildNutrientProgressBar('Calcium', _getNutrientProgress('calcium'), Colors.blue),
          const SizedBox(height: 12),
          _buildNutrientProgressBar('Fiber', _getNutrientProgress('fiber'), AppColors.purpleAccent),
        ],
      ),
    );
  }

  Widget _buildNutrientProgressBar(String nutrient, double progress, Color color) {
    final nutrientKey = nutrient.toLowerCase().replaceAll(' ', '_');
    final consumed = _getTodayNutrients()[nutrientKey] ?? 0.0;
    final target = _getNutrientTargets()[nutrientKey] ?? 1.0;
    
    // Get appropriate unit for each nutrient
    String unit = 'mg';
    String consumedStr = consumed.toInt().toString();
    String targetStr = target.toInt().toString();
    
    if (nutrient == 'Fiber') {
      unit = 'g';
    } else if (nutrient == 'Vitamin C' || nutrient == 'Iron') {
      unit = 'mg';
      // Show decimal for iron since targets are smaller
      if (nutrient == 'Iron') {
        consumedStr = consumed.toStringAsFixed(1);
        targetStr = target.toStringAsFixed(1);
      }
    } else if (nutrient == 'Calcium') {
      unit = 'mg';
    }
    
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
              '$consumedStr$unit / $targetStr$unit',
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