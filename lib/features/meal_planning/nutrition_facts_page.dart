import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_colors.dart';
import '../../data/predefined_meals.dart';
import '../../services/meal_logging_service.dart';
import '../../services/user_service.dart';

class NutritionFactsPage extends StatefulWidget {
  final PredefinedMeal meal;

  const NutritionFactsPage({
    super.key,
    required this.meal,
  });

  @override
  State<NutritionFactsPage> createState() => _NutritionFactsPageState();
}

class _NutritionFactsPageState extends State<NutritionFactsPage> {
  int _userPax = 1; // User's household size
  final MealLoggingService _mealLoggingService = MealLoggingService();
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
  // Formula: (totalCalories / servings) * userPax
  Map<String, double> get _calculatedNutrition {
    final meal = widget.meal;
    final totalCalories = meal.kcal.toDouble();
    final servings = meal.baseServings.toDouble();
    
    // Calculate calories per serving, then multiply by user's PAX
    final caloriesPerServing = totalCalories / servings;
    final finalCalories = caloriesPerServing * _userPax;
    
    // Calculate other nutrients based on final calories
    // Since PredefinedMeal only has kcal, we'll estimate other nutrients
    return {
      'calories': finalCalories,
      'fat': (finalCalories * 0.25 / 9), // ~25% of calories from fat (9 cal/g)
      'carbohydrates': (finalCalories * 0.50 / 4), // ~50% from carbs (4 cal/g)
      'protein': (finalCalories * 0.25 / 4), // ~25% from protein (4 cal/g)
      'sodium': (finalCalories * 5), // Rough estimate: 5mg sodium per calorie
      'vitamin_a': 2.0 * _userPax, // Scale vitamins by PAX
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
            // Nutrition Facts Content
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  // Simple refresh for nutrition facts
                  await Future.delayed(const Duration(milliseconds: 500));
                },
                color: AppColors.successGreen,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 100), // room for save button
                  child: Column(
                    children: [
                      _buildNutritionContent(),
                      _buildPaxInfo(),
                    ],
                  ),
                ),
              ),
            ),
            // Bottom Section with Save Button only
            _buildSaveButton(),
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

  Widget _buildNutritionContent() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.successGreen,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Title and Amount
            Column(
              children: [
                Text(
                  'Nutrition Facts',
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isLoadingUserData 
                      ? 'Loading...'
                      : 'For $_userPax person${_userPax > 1 ? 's' : ''}',
                  style: TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 14,
                    color: AppColors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Calories
            Text(
              '${_calculatedNutrition['calories']!.round()}',
              style: TextStyle(
                fontFamily: 'Lato',
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
            Text(
              'calories',
              style: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 16,
                color: AppColors.white.withOpacity(0.9),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Nutrition Details
            Row(
              children: [
                  // Left Column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildNutritionItem('Fat', '${_calculatedNutrition['fat']!.toStringAsFixed(1)}g'),
                        _buildNutritionItem('Carbohydrates', '${_calculatedNutrition['carbohydrates']!.toStringAsFixed(1)}g'),
                        _buildNutritionItem('Protein', '${_calculatedNutrition['protein']!.toStringAsFixed(1)}g'),
                        _buildNutritionItem('Sodium', '${_calculatedNutrition['sodium']!.toStringAsFixed(0)}mg'),
                        const SizedBox(height: 16),
                        Text(
                          'Micronutrients',
                          style: TextStyle(
                            fontFamily: 'Lato',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildMicronutrientItem('Vitamin A', '${_calculatedNutrition['vitamin_a']!.toStringAsFixed(0)}%'),
                        _buildMicronutrientItem('Vitamin C', '${_calculatedNutrition['vitamin_c']!.toStringAsFixed(0)}%'),
                        _buildMicronutrientItem('Calcium', '${_calculatedNutrition['calcium']!.toStringAsFixed(0)}%'),
                        _buildMicronutrientItem('Iron', '${_calculatedNutrition['iron']!.toStringAsFixed(0)}%'),
                      ],
                    ),
                  ),
                  
                  // Right Column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildNutritionItem('64.1g', '', isRight: true),
                        _buildNutritionItem('36.1g', '', isRight: true),
                        _buildNutritionItem('20.1g', '', isRight: true),
                        _buildNutritionItem('890mg', '', isRight: true),
                        const SizedBox(height: 40),
                        const SizedBox(height: 8),
                        _buildMicronutrientItem('210%', '', isRight: true),
                        _buildMicronutrientItem('15%', '', isRight: true),
                        _buildMicronutrientItem('14%', '', isRight: true),
                        _buildMicronutrientItem('8%', '', isRight: true),
                      ],
                    ),
                  ),
                ], // end Row children
            ), // end Row
            ], // end Column children
        ), // end Column
      ), // end Padding
    ); // end Container
  }

  Widget _buildNutritionItem(String label, String value, {bool isRight = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: isRight ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Text(
            isRight ? value : label,
            style: TextStyle(
              fontFamily: 'OpenSans',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.white,
            ),
          ),
          if (!isRight && value.isNotEmpty) ...[
            const Spacer(),
            Text(
              value,
              style: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMicronutrientItem(String label, String value, {bool isRight = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: isRight ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Text(
            isRight ? value : label,
            style: TextStyle(
              fontFamily: 'OpenSans',
              fontSize: 12,
              color: AppColors.white.withOpacity(0.9),
            ),
          ),
          if (!isRight && value.isNotEmpty) ...[
            const Spacer(),
            Text(
              value,
              style: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 12,
                color: AppColors.white.withOpacity(0.9),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaxInfo() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.successGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.people,
                  color: AppColors.successGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Household Size',
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.blackText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (_isLoadingUserData)
            Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.successGreen),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Loading your household size...',
                  style: TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 14,
                    color: AppColors.grayText,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$_userPax person${_userPax > 1 ? 's' : ''}',
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.successGreen,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Nutrition values calculated for your household size',
                  style: TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 12,
                    color: AppColors.grayText,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      color: AppColors.primaryBackground,
      padding: const EdgeInsets.all(20),
      child: ElevatedButton(
        onPressed: _isLoadingUserData ? null : () {
          // Save the nutrition data and navigate back
          _saveMealLog();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.successGreen,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 4,
          disabledBackgroundColor: AppColors.grayText.withOpacity(0.3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.save,
              color: AppColors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              _isLoadingUserData ? 'Loading...' : 'Save Meal',
              style: TextStyle(
                fontFamily: 'Lato',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveMealLog() {
    // Show meal type selection dialog
    _showMealTypeSelectionDialog();
  }

  void _showMealTypeSelectionDialog() {
    final mealTypes = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 20),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grayText.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Title
              Text(
                'Log meal for:',
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.blackText,
                ),
              ),
              const SizedBox(height: 20),
              
              // Meal type options
              ...mealTypes.map((mealType) => _buildMealTypeOption(mealType)),
              
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMealTypeOption(String mealType) {
    IconData icon;
    Color color;
    
    switch (mealType) {
      case 'Breakfast':
        icon = Icons.free_breakfast;
        color = Colors.orange;
        break;
      case 'Lunch':
        icon = Icons.lunch_dining;
        color = Colors.red;
        break;
      case 'Dinner':
        icon = Icons.dinner_dining;
        color = Colors.green;
        break;
      case 'Snack':
        icon = Icons.cake;
        color = Colors.purple;
        break;
      default:
        icon = Icons.restaurant;
        color = AppColors.grayText;
    }
    
    return GestureDetector(
      onTap: () {
        Navigator.pop(context); // Close dialog
        _logMealToFirebase(mealType);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primaryBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                mealType,
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.blackText,
                ),
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

  Future<void> _logMealToFirebase(String mealType) async {
    try {
      // Calculate calories using the formula: (totalCalories / servings) * userPax
      final totalCalories = widget.meal.kcal.toDouble();
      final servings = widget.meal.baseServings.toDouble();
      final caloriesPerServing = totalCalories / servings;
      final finalCalories = caloriesPerServing * _userPax;
      
      await _mealLoggingService.logMeal(
        meal: widget.meal,
        mealType: mealType,
        amount: _userPax.toDouble(), // Use PAX as amount
        measurement: 'serving${_userPax > 1 ? 's' : ''}', // Auto-set measurement
        pax: _userPax,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${widget.meal.recipeName} (${finalCalories.round()} cal for $_userPax person${_userPax > 1 ? 's' : ''}) logged for $mealType!',
              style: TextStyle(
                fontFamily: 'OpenSans',
                color: AppColors.white,
              ),
            ),
            backgroundColor: AppColors.successGreen,
            duration: const Duration(seconds: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
        
        // Navigate back to the main dashboard or meal plan page
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to log meal: $e',
              style: TextStyle(
                fontFamily: 'OpenSans',
                color: AppColors.white,
              ),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}