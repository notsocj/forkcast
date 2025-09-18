import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants.dart';

class BMICalculatorPage extends StatefulWidget {
  const BMICalculatorPage({super.key});

  @override
  State<BMICalculatorPage> createState() => _BMICalculatorPageState();
}

class _BMICalculatorPageState extends State<BMICalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  
  String _selectedGender = '';
  double? _calculatedBMI;
  String _bmiCategory = '';
  String _bmiAdvice = '';

  @override
  void dispose() {
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _calculateBMI() {
    if (_formKey.currentState!.validate() && _selectedGender.isNotEmpty) {
      final double weight = double.parse(_weightController.text);
      final double heightCm = double.parse(_heightController.text);
      final double heightM = heightCm / 100; // Convert cm to meters
      
      setState(() {
        _calculatedBMI = weight / (heightM * heightM);
        _setBMICategory();
      });
      
      // Show success feedback
      HapticFeedback.lightImpact();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields and select gender'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _setBMICategory() {
    if (_calculatedBMI == null) return;
    
    final double bmi = _calculatedBMI!;
    
    if (bmi < 18.5) {
      _bmiCategory = 'Underweight';
      _bmiAdvice = 'Consider a balanced diet with more calories';
    } else if (bmi >= 18.5 && bmi < 25) {
      _bmiCategory = 'Healthy';
      _bmiAdvice = 'Great! Maintain your current lifestyle';
    } else if (bmi >= 25 && bmi < 30) {
      _bmiCategory = 'Overweight';
      _bmiAdvice = 'Consider a balanced diet and regular exercise';
    } else {
      _bmiCategory = 'Obese';
      _bmiAdvice = 'Consult a healthcare professional';
    }
  }

  Color _getBMIColor() {
    if (_calculatedBMI == null) return AppColors.grayText;
    
    final double bmi = _calculatedBMI!;
    if (bmi < 18.5) return Colors.blue;
    if (bmi >= 18.5 && bmi < 25) return AppColors.successGreen;
    if (bmi >= 25 && bmi < 30) return Colors.orange;
    return Colors.red;
  }

  void _resetCalculator() {
    setState(() {
      _ageController.clear();
      _heightController.clear();
      _weightController.clear();
      _selectedGender = '';
      _calculatedBMI = null;
      _bmiCategory = '';
      _bmiAdvice = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.blackText,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'BMI Calculator',
          style: TextStyle(
            fontFamily: AppConstants.headingFont,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.blackText,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_calculatedBMI != null)
            IconButton(
              icon: const Icon(
                Icons.refresh,
                color: AppColors.blackText,
              ),
              onPressed: _resetCalculator,
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.successGreen.withOpacity(0.1),
                        AppColors.primaryAccent.withOpacity(0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.successGreen.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.calculate_outlined,
                        size: 48,
                        color: AppColors.successGreen,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Calculate Your BMI',
                        style: TextStyle(
                          fontFamily: AppConstants.headingFont,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.blackText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Body Mass Index (BMI) is a measure of body fat based on height and weight',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppConstants.primaryFont,
                          fontSize: 14,
                          color: AppColors.grayText,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Input Fields Section
                _buildInputSection(),
                
                const SizedBox(height: 32),
                
                // Gender Selection
                _buildGenderSelection(),
                
                const SizedBox(height: 32),
                
                // Calculate Button
                _buildCalculateButton(),
                
                const SizedBox(height: 32),
                
                // Results Section
                if (_calculatedBMI != null) _buildResultsSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputSection() {
    return Column(
      children: [
        // Age Input
        _buildInputField(
          controller: _ageController,
          label: 'Age',
          hint: 'Enter your age',
          suffix: 'years',
          validator: (value) {
            if (value == null || value.isEmpty) return 'Please enter your age';
            final age = int.tryParse(value);
            if (age == null || age < 1 || age > 120) {
              return 'Enter a valid age (1-120)';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 20),
        
        // Height Input
        _buildInputField(
          controller: _heightController,
          label: 'Height',
          hint: 'Enter your height',
          suffix: 'cm',
          validator: (value) {
            if (value == null || value.isEmpty) return 'Please enter your height';
            final height = double.tryParse(value);
            if (height == null || height < 50 || height > 300) {
              return 'Enter a valid height (50-300 cm)';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 20),
        
        // Weight Input
        _buildInputField(
          controller: _weightController,
          label: 'Weight',
          hint: 'Enter your weight',
          suffix: 'kg',
          validator: (value) {
            if (value == null || value.isEmpty) return 'Please enter your weight';
            final weight = double.tryParse(value);
            if (weight == null || weight < 1 || weight > 500) {
              return 'Enter a valid weight (1-500 kg)';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String suffix,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: AppConstants.primaryFont,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.blackText,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            validator: validator,
            decoration: InputDecoration(
              hintText: hint,
              suffixText: suffix,
              suffixStyle: TextStyle(
                fontFamily: AppConstants.primaryFont,
                color: AppColors.grayText,
                fontWeight: FontWeight.w500,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: AppColors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              hintStyle: TextStyle(
                color: AppColors.grayText,
                fontFamily: AppConstants.primaryFont,
              ),
            ),
            style: TextStyle(
              fontFamily: AppConstants.primaryFont,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.blackText,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender',
          style: TextStyle(
            fontFamily: AppConstants.primaryFont,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.blackText,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildGenderOption('Male', Icons.male),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildGenderOption('Female', Icons.female),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderOption(String gender, IconData icon) {
    final bool isSelected = _selectedGender == gender;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGender = gender;
        });
        HapticFeedback.selectionClick();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.successGreen : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
                ? AppColors.successGreen 
                : AppColors.grayText.withOpacity(0.2),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected 
                  ? AppColors.successGreen.withOpacity(0.3)
                  : Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? AppColors.white : AppColors.grayText,
            ),
            const SizedBox(height: 8),
            Text(
              gender,
              style: TextStyle(
                fontFamily: AppConstants.primaryFont,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.white : AppColors.blackText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculateButton() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.successGreen, AppColors.successGreen.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.successGreen.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _calculateBMI,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          'Calculate BMI',
          style: TextStyle(
            fontFamily: AppConstants.primaryFont,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildResultsSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Your BMI Result',
            style: TextStyle(
              fontFamily: AppConstants.headingFont,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.blackText,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // BMI Value Circle
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _getBMIColor().withOpacity(0.1),
              border: Border.all(
                color: _getBMIColor(),
                width: 4,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _calculatedBMI!.toStringAsFixed(1),
                    style: TextStyle(
                      fontFamily: AppConstants.primaryFont,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: _getBMIColor(),
                    ),
                  ),
                  Text(
                    'BMI',
                    style: TextStyle(
                      fontFamily: AppConstants.primaryFont,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _getBMIColor(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Category and Advice
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: _getBMIColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: _getBMIColor().withOpacity(0.3),
              ),
            ),
            child: Text(
              _bmiCategory,
              style: TextStyle(
                fontFamily: AppConstants.primaryFont,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _getBMIColor(),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Text(
            _bmiAdvice,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppConstants.primaryFont,
              fontSize: 14,
              color: AppColors.grayText,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // BMI Scale Reference
          _buildBMIScale(),
        ],
      ),
    );
  }

  Widget _buildBMIScale() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'BMI Scale Reference',
          style: TextStyle(
            fontFamily: AppConstants.primaryFont,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.blackText,
          ),
        ),
        const SizedBox(height: 12),
        _buildScaleItem('Underweight', '< 18.5', Colors.blue),
        _buildScaleItem('Healthy', '18.5 - 24.9', AppColors.successGreen),
        _buildScaleItem('Overweight', '25.0 - 29.9', Colors.orange),
        _buildScaleItem('Obese', '≥ 30.0', Colors.red),
      ],
    );
  }

  Widget _buildScaleItem(String category, String range, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            category,
            style: TextStyle(
              fontFamily: AppConstants.primaryFont,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.blackText,
            ),
          ),
          const Spacer(),
          Text(
            range,
            style: TextStyle(
              fontFamily: AppConstants.primaryFont,
              fontSize: 12,
              color: AppColors.grayText,
            ),
          ),
        ],
      ),
    );
  }
}