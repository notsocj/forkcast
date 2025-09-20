import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/predefined_meals.dart';
import '../../services/meal_logging_service.dart';

class NutritionFactsPage extends StatefulWidget {
  final PredefinedMeal meal;
  final double amount;
  final String measurement;

  const NutritionFactsPage({
    super.key,
    required this.meal,
    required this.amount,
    required this.measurement,
  });

  @override
  State<NutritionFactsPage> createState() => _NutritionFactsPageState();
}

class _NutritionFactsPageState extends State<NutritionFactsPage> {
  late double _currentAmount;
  final MealLoggingService _mealLoggingService = MealLoggingService();

  @override
  void initState() {
    super.initState();
    _currentAmount = widget.amount;
  }

  // Calculate nutrition values based on current amount and meal data
  Map<String, double> get _calculatedNutrition {
    final meal = widget.meal;
    final multiplier = _currentAmount / meal.servings; // Adjust for current amount vs servings
    
    // Since PredefinedMeal only has kcal, we'll estimate other nutrients
    // In a real app, these would come from a nutrition database
    final baseCalories = meal.kcal.toDouble();
    
    return {
      'calories': baseCalories * multiplier,
      'fat': (baseCalories * 0.25 / 9) * multiplier, // ~25% of calories from fat (9 cal/g)
      'carbohydrates': (baseCalories * 0.50 / 4) * multiplier, // ~50% from carbs (4 cal/g)
      'protein': (baseCalories * 0.25 / 4) * multiplier, // ~25% from protein (4 cal/g)
      'sodium': (baseCalories * 5) * multiplier, // Rough estimate: 5mg sodium per calorie
      'vitamin_a': 2.0 * multiplier, // Default values for vitamins (would come from meal data)
      'vitamin_c': 15.0 * multiplier,
      'calcium': 4.0 * multiplier,
      'iron': 8.0 * multiplier,
      'riboflavin': 15.0 * multiplier,
      'niacin': 35.0 * multiplier,
      'thiamin': 5.0 * multiplier,
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
              child: _buildNutritionContent(),
            ),
            // Bottom Section with Save Button and Numeric Keypad
            _buildBottomSection(),
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
                  'Amount per serving',
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
            Expanded(
              child: Row(
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
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

  Widget _buildBottomSection() {
    return Container(
      color: AppColors.primaryBackground,
      child: Column(
        children: [
          // Save Button
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: ElevatedButton(
              onPressed: () {
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
                elevation: 0,
              ),
              child: Text(
                'Save',
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          // Numeric Keypad
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.blackText.withOpacity(0.9),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
            ),
            child: _buildNumericKeypad(),
          ),
        ],
      ),
    );
  }

  Widget _buildNumericKeypad() {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildKeypadButton('1'),
        _buildKeypadButton('2'),
        _buildKeypadButton('3'),
        _buildKeypadButton('⌫', isIcon: true),
        _buildKeypadButton('4'),
        _buildKeypadButton('5'),
        _buildKeypadButton('6'),
        _buildKeypadButton('Done', isAction: true),
        _buildKeypadButton('7'),
        _buildKeypadButton('8'),
        _buildKeypadButton('9'),
        _buildKeypadButton('.'),
        _buildKeypadButton('0'),
      ],
    );
  }

  Widget _buildKeypadButton(String text, {bool isIcon = false, bool isAction = false}) {
    return GestureDetector(
      onTap: () {
        if (text == 'Done') {
          Navigator.pop(context);
        } else if (text == '⌫') {
          _handleBackspace();
        } else {
          _handleNumberInput(text);
        }
      },
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isAction 
              ? AppColors.successGreen 
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontFamily: 'Lato',
              fontSize: isAction ? 16 : 20,
              fontWeight: isAction ? FontWeight.bold : FontWeight.w500,
              color: AppColors.white,
            ),
          ),
        ),
      ),
    );
  }

  void _handleNumberInput(String number) {
    setState(() {
      if (number == '.') {
        if (!_currentAmount.toString().contains('.')) {
          _currentAmount = double.parse('${_currentAmount.toInt()}.');
        }
      } else {
        final currentStr = _currentAmount.toString();
        if (currentStr.contains('.')) {
          final parts = currentStr.split('.');
          if (parts[1].length < 2) {
            _currentAmount = double.parse('$currentStr$number');
          }
        } else {
          _currentAmount = double.parse('${_currentAmount.toInt()}$number');
        }
      }
    });
  }

  void _handleBackspace() {
    setState(() {
      final currentStr = _currentAmount.toString();
      if (currentStr.length > 1) {
        _currentAmount = double.parse(currentStr.substring(0, currentStr.length - 1));
      } else {
        _currentAmount = 0;
      }
    });
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
      await _mealLoggingService.logMeal(
        meal: widget.meal,
        mealType: mealType,
        amount: _currentAmount,
        measurement: widget.measurement,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${widget.meal.recipeName} logged for $mealType!',
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