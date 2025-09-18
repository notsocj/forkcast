import 'package:flutter/material.dart';
import 'bmi_calculator_page.dart';

/// Example navigation helper for BMI Calculator
/// Can be integrated into main app navigation
class BMINavigation {
  /// Navigate to BMI Calculator page
  static void navigateToBMICalculator(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BMICalculatorPage(),
      ),
    );
  }
  
  /// Navigate to BMI Calculator page and replace current route
  static void navigateToBMICalculatorReplacement(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const BMICalculatorPage(),
      ),
    );
  }
}

/// Example usage widget - can be added to any page
class BMICalculatorTile extends StatelessWidget {
  const BMICalculatorTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: const Icon(
          Icons.calculate,
          color: Color(0xFF91C789),
          size: 32,
        ),
        title: const Text(
          'BMI Calculator',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: const Text(
          'Calculate your Body Mass Index',
          style: TextStyle(
            color: Color(0xFF676767),
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () => BMINavigation.navigateToBMICalculator(context),
      ),
    );
  }
}