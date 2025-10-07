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
  int _getTotalCaloriesToday() {
    if (_todaysMealStatus == null) return 0;
    
    int totalCalories = 0;
    
    for (String mealType in ['Breakfast', 'Lunch', 'Dinner', 'Snack']) {
      final mealData = _todaysMealStatus![mealType];
      if (mealData != null && mealData['logged'] == true) {
        final data = mealData['data'] as Map<String, dynamic>?;
        if (data != null) {
          totalCalories += (data['scaled_kcal'] as num?)?.toInt() ?? 0;
        }
      }
    }
    
    return totalCalories;
  }

  /// Calculate Energy Intake percentage based on family needs
  /// Formula: (Plan kcal ÷ Family Need) × 100
  /// Family Need = 2000 kcal × household_size
  Map<String, dynamic> _getEnergyIntakeData() {
    final householdSize = _currentUser?.householdSize ?? 1;
    final familyNeed = 2000 * householdSize; // FNRI/DOST PDRI standard
    final planKcal = _getTotalCaloriesToday();
    final percentage = familyNeed > 0 ? ((planKcal / familyNeed) * 100).round() : 0;
    
    return {
      'planKcal': planKcal,
      'familyNeed': familyNeed,
      'percentage': percentage,
      'display': '$planKcal / ${familyNeed.toStringAsFixed(0)} kcal ($percentage%)'
    };
  }

  /// Calculate Nutrition Score based on FNRI nutrient requirements
  /// Formula: Average of all nutrient coverage percentages (capped at 100%)
  Map<String, dynamic> _getNutritionScoreData() {
    if (_currentUser == null) return {'score': 0, 'rating': 'Unknown'};
    
    final householdSize = _currentUser!.householdSize;
    final todayNutrients = _getTodayNutrients();
    
    // FNRI/PDRI daily requirements per person
    final Map<String, double> dailyRequirements = {
      'protein': 60.0, // g - adult average
      'iron': 18.0, // mg - considering higher need for women
      'calcium': 1000.0, // mg - adult
      'vitamin_c': 60.0, // mg - FNRI standard
      'fiber': 25.0, // g - recommended
    };
    
    // Calculate family needs and coverage percentages
    List<double> coveragePercentages = [];
    
    // Energy coverage (separate calculation)
    final energyData = _getEnergyIntakeData();
    final energyCoverage = (energyData['percentage'] as int).toDouble();
    coveragePercentages.add(energyCoverage.clamp(0.0, 100.0));
    
    // Add estimated protein from meals
    double totalProtein = 0.0;
    for (String mealType in ['Breakfast', 'Lunch', 'Dinner', 'Snack']) {
      final mealData = _todaysMealStatus?[mealType];
      if (mealData != null && mealData['logged'] == true) {
        final data = mealData['data'] as Map<String, dynamic>?;
        if (data != null) {
          String mealName = (data['recipe_name'] ?? '').toString().toLowerCase();
          // Estimate protein based on meal type and ingredients
          if (mealName.contains('chicken') || mealName.contains('beef') || mealName.contains('pork')) {
            totalProtein += 25.0; // High protein meat
          } else if (mealName.contains('fish') || mealName.contains('egg')) {
            totalProtein += 20.0; // Good protein sources
          } else if (mealName.contains('tofu') || mealName.contains('beans')) {
            totalProtein += 15.0; // Plant protein
          } else {
            totalProtein += 8.0; // Base protein from other foods
          }
        }
      }
    }
    
    // Calculate coverage for each nutrient
    final familyProteinNeed = dailyRequirements['protein']! * householdSize;
    final proteinCoverage = ((totalProtein / familyProteinNeed) * 100).clamp(0.0, 100.0);
    coveragePercentages.add(proteinCoverage);
    
    // Other nutrients (iron, calcium, vitamin C, fiber)
    for (String nutrient in ['iron', 'calcium', 'vitamin_c', 'fiber']) {
      final familyNeed = dailyRequirements[nutrient]! * householdSize;
      final consumed = todayNutrients[nutrient] ?? 0.0;
      final coverage = ((consumed / familyNeed) * 100).clamp(0.0, 100.0);
      coveragePercentages.add(coverage);
    }
    
    // Calculate average score
    final averageScore = coveragePercentages.isNotEmpty 
        ? (coveragePercentages.reduce((a, b) => a + b) / coveragePercentages.length).round()
        : 0;
    
    // Determine rating based on score
    String rating;
    if (averageScore >= 80) {
      rating = 'Excellent';
    } else if (averageScore >= 65) {
      rating = 'Good';
    } else if (averageScore >= 50) {
      rating = 'Fair';
    } else if (averageScore >= 35) {
      rating = 'Poor';
    } else {
      rating = 'Very Poor';
    }
    
    return {
      'score': averageScore,
      'rating': rating,
      'display': '$averageScore% $rating'
    };
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
          'image_url': data['image_url'], // Add image URL from Firebase
        };
      }
    }
    
    return {
      'name': 'No meal logged',
      'calories': '0 kcal',
      'hasData': false,
      'source': 'none',
      'image_url': null,
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

  /// Calculate key nutrients consumed today focusing on micronutrients and macronutrients
  Map<String, double> _getTodayNutrients() {
    if (_todaysMealStatus == null) {
      return {
        'energy': 0.0,
        'protein': 0.0,
        'vitamin_c': 0.0,
        'iron': 0.0,
        'calcium': 0.0,
        'fiber': 0.0,
        'fat': 0.0,
        'carbs': 0.0,
      };
    }
    
    double totalEnergy = 0.0;
    double totalProtein = 0.0;
    double totalVitaminC = 0.0;
    double totalIron = 0.0;
    double totalCalcium = 0.0;
    double totalFiber = 0.0;
    double totalFat = 0.0;
    double totalCarbs = 0.0;
    
    for (String mealType in ['Breakfast', 'Lunch', 'Dinner', 'Snack']) {
      final mealData = _todaysMealStatus![mealType];
      if (mealData != null && mealData['logged'] == true) {
        final data = mealData['data'] as Map<String, dynamic>?;
        if (data != null) {
          // Get scaled calories directly from logged meal
          final scaledKcal = (data['scaled_kcal'] ?? data['kcal_min'] ?? 0) as num;
          totalEnergy += scaledKcal.toDouble();
          
          String mealName = (data['recipe_name'] ?? '').toString().toLowerCase();
          
          // Estimate macronutrients based on calories (rough approximation)
          // Filipino meals typically: 50-60% carbs, 15-20% protein, 25-30% fat
          totalCarbs += (scaledKcal * 0.55) / 4; // 55% from carbs, 4 kcal per gram
          totalProtein += (scaledKcal * 0.18) / 4; // 18% from protein, 4 kcal per gram
          totalFat += (scaledKcal * 0.27) / 9; // 27% from fat, 9 kcal per gram
          
          // Estimate micronutrient content based on Filipino food knowledge
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
      'energy': totalEnergy,
      'protein': totalProtein,
      'vitamin_c': totalVitaminC,
      'iron': totalIron,
      'calcium': totalCalcium,
      'fiber': totalFiber,
      'fat': totalFat,
      'carbs': totalCarbs,
    };
  }

  /// Get daily nutrient targets for key micronutrients and macronutrients
  Map<String, double> _getNutrientTargets() {
    if (_currentUser == null) {
      return {
        'energy': 2000.0, // kcal - FNRI standard
        'protein': 60.0, // g - RDA for adults
        'vitamin_c': 65.0, // mg - RDA for adults
        'iron': 8.0, // mg - RDA for adults (varies by gender)
        'calcium': 1000.0, // mg - RDA for adults
        'fiber': 25.0, // g - recommended daily intake
        'fat': 65.0, // g - AMDR (20-35% of 2000 kcal)
        'carbs': 275.0, // g - AMDR (45-65% of 2000 kcal)
      };
    }
    
    // Base on household size for family needs (2000 kcal per adult - FNRI/PDRI)
    final householdSize = _currentUser!.householdSize;
    double energyTarget = 2000.0 * householdSize;
    
    // Adjust targets based on user profile
    double proteinTarget = 60.0 * householdSize; // ~1g per kg body weight
    double vitaminCTarget = 65.0; // Base RDA
    double ironTarget = 8.0; // Base for males
    double calciumTarget = 1000.0; // Base for adults
    double fiberTarget = 25.0; // Base recommendation
    double fatTarget = (energyTarget * 0.30) / 9; // 30% of energy from fat
    double carbsTarget = (energyTarget * 0.55) / 4; // 55% of energy from carbs
    
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
      'energy': energyTarget,
      'protein': proteinTarget,
      'vitamin_c': vitaminCTarget,
      'iron': ironTarget,
      'calcium': calciumTarget,
      'fiber': fiberTarget,
      'fat': fatTarget,
      'carbs': carbsTarget,
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
                      
                      // Weekly Progress Card removed per design
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
    final energyData = _getEnergyIntakeData();
    final nutritionData = _getNutritionScoreData();
    
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
                icon: Icons.local_fire_department_outlined,
                title: 'Energy Intake',
                value: '${energyData['percentage']}%',
                subtitle: '${energyData['planKcal']} / ${energyData['familyNeed']} kcal',
                color: AppColors.primaryAccent,
              ),
              _buildNutritionalItem(
                icon: Icons.favorite_outline,
                title: 'Nutrition Score',
                value: '${nutritionData['score']}%',
                subtitle: nutritionData['rating'],
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
    String? subtitle,
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
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 10,
                color: AppColors.grayText.withOpacity(0.8),
              ),
            ),
          ],
          const SizedBox(height: 4),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              Icon(
                Icons.swipe_left_outlined,
                size: 16,
                color: AppColors.grayText.withOpacity(0.5),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Horizontal scrollable nutrient list
          SizedBox(
            height: 80, // Fixed height for horizontal scroll
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildCompactNutrientCard('Energy', _getNutrientProgress('energy'), AppColors.primaryAccent, 'kcal'),
                const SizedBox(width: 12),
                _buildCompactNutrientCard('Protein', _getNutrientProgress('protein'), AppColors.successGreen, 'g'),
                const SizedBox(width: 12),
                _buildCompactNutrientCard('Vitamin C', _getNutrientProgress('vitamin_c'), Colors.orange, 'mg'),
                const SizedBox(width: 12),
                _buildCompactNutrientCard('Iron', _getNutrientProgress('iron'), Colors.red, 'mg'),
                const SizedBox(width: 12),
                _buildCompactNutrientCard('Calcium', _getNutrientProgress('calcium'), Colors.blue, 'mg'),
                const SizedBox(width: 12),
                _buildCompactNutrientCard('Fiber', _getNutrientProgress('fiber'), AppColors.purpleAccent, 'g'),
                const SizedBox(width: 12),
                _buildCompactNutrientCard('Fat', _getNutrientProgress('fat'), Colors.amber, 'g'),
                const SizedBox(width: 12),
                _buildCompactNutrientCard('Carbs', _getNutrientProgress('carbs'), Colors.teal, 'g'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactNutrientCard(String nutrient, double progress, Color color, String unit) {
    final nutrientKey = nutrient.toLowerCase().replaceAll(' ', '_');
    final consumed = _getTodayNutrients()[nutrientKey] ?? 0.0;
    final target = _getNutrientTargets()[nutrientKey] ?? 1.0;
    
    // Format consumed and target values
    String consumedStr = consumed >= 100 ? consumed.toInt().toString() : consumed.toStringAsFixed(1);
    String targetStr = target >= 100 ? target.toInt().toString() : target.toStringAsFixed(1);
    
    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                nutrient,
                style: TextStyle(
                  fontFamily: 'OpenSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.blackText,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Progress bar
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.lightGray.withOpacity(0.5),
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$consumedStr / $targetStr $unit',
            style: TextStyle(
              fontFamily: 'OpenSans',
              fontSize: 10,
              color: AppColors.grayText,
            ),
          ),
        ],
      ),
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
                imageUrl: mealData['image_url'], // Pass image URL from Firebase
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
    String? imageUrl,
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
          // Meal image or icon
          _buildDashboardMealImage(hasData, imageUrl, icon, color),
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
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  // Weekly progress card removed as requested.

  Widget _buildDashboardMealImage(bool hasData, String? imageUrl, String icon, Color color) {
    // If no data or no image URL, show emoji icon
    if (!hasData || imageUrl == null || imageUrl.isEmpty) {
      return Container(
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
      );
    }

    // Check if it's a Cloudinary URL (network image)
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          imageUrl,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                      : null,
                  strokeWidth: 2,
                  color: color,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            // Fallback to emoji icon on error
            return Container(
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
            );
          },
        ),
      );
    }

    // Local asset image
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.asset(
        'assets/images/$imageUrl',
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // Fallback to emoji icon on error
          return Container(
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
          );
        },
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