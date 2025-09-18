import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants.dart';
import '../../core/widgets/progress_pill.dart';
import '../../providers/profile_setup_provider.dart';
import '../bmi/bmi_calculator_page.dart';

class MedicalConditionsPage extends StatefulWidget {
  const MedicalConditionsPage({super.key});

  @override
  State<MedicalConditionsPage> createState() => _MedicalConditionsPageState();
}

class _MedicalConditionsPageState extends State<MedicalConditionsPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Medical condition selection state
  String? _selectedCategory;
  String? _selectedSpecificCondition;
  // If the user specifies an "Other" condition text
  String? _otherConditionText;
  bool _canContinue = false;
  // we use modal bottom sheets for dropdowns to avoid overflow on small screens

  // Medical condition categories and specific conditions
  final Map<String, List<String>> _medicalConditions = {
    'Cardiovascular Diseases': [
      'Hypertension',
      'Heart Attack',
      'Stroke',
      'Atherosclerosis',
      'Heart Failure',
    ],
    'Respiratory Diseases': [
      'Asthma',
      'Chronic Bronchitis',
      'Emphysema',
      'Pneumonia',
      'Allergic Rhinitis',
    ],
    'Mental Health Disorders': [
      'Depression',
      'Anxiety Disorder',
      'Bipolar Disorder',
      'Stress-related Disorders',
      'Sleep Disorders',
    ],
    'Communicable Diseases': [
      'Tuberculosis',
      'Dengue Fever',
      'Malaria',
      'Pneumonia',
      'Gastroenteritis',
    ],
    'Non-Communicable Diseases': [
      'Diabetes',
      'Obesity',
      'Osteoporosis',
      'Anemia',
      'High Cholesterol',
    ],
  };

  List<String> get _categories => _medicalConditions.keys.toList();

  // Provide a 'None' option at the top of categories
  List<String> get _categoriesWithNone => ['None', ..._categories];
  
  List<String> get _specificConditions => 
      _selectedCategory != null ? _medicalConditions[_selectedCategory!] ?? [] : [];

  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = category;
      _selectedSpecificCondition = null; // Reset specific condition
      _otherConditionText = null; // Reset typed other
      // If user chooses 'None' immediately allow continue
      if (category == 'None') {
        _canContinue = true;
      }
      _updateContinueButton();
    });
  }

  void _selectSpecificCondition(String condition) {
    setState(() {
      _selectedSpecificCondition = condition;
      // Clear any previously typed other text when they pick a predefined one
      if (condition != 'Other') _otherConditionText = null;
      _updateContinueButton();
    });
  }

  // (previous toggle methods removed) Modal bottom sheets are used instead

  // Open a modal bottom sheet to select category
  void _openCategorySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.56,
          minChildSize: 0.32,
          maxChildSize: 0.92,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: AppColors.primaryBackground,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 12,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 48,
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.grayText.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Select Category',
                            style: TextStyle(
                              fontFamily: AppConstants.headingFont,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.blackText,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.close, color: AppColors.grayText),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      itemCount: _categoriesWithNone.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 6),
                      itemBuilder: (context, index) {
                        String category = _categoriesWithNone[index];
                        bool isSelected = _selectedCategory == category;
                        return GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            _selectCategory(category);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.successGreen.withOpacity(0.12) : AppColors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? AppColors.successGreen.withOpacity(0.3) : AppColors.lightGray,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppColors.successGreen : AppColors.lightGray,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Icon(
                                      isSelected ? Icons.check : Icons.category,
                                      color: isSelected ? AppColors.white : AppColors.grayText,
                                      size: 18,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    category,
                                    style: TextStyle(
                                      fontFamily: AppConstants.primaryFont,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.blackText,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Open a modal bottom sheet to select specific condition (includes 'Other')
  void _openSpecificSheet() {
    if (_selectedCategory == null || _selectedCategory == 'None') return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.56,
          minChildSize: 0.32,
          maxChildSize: 0.92,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: AppColors.primaryBackground,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 12,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 48,
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.grayText.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Select Condition',
                            style: TextStyle(
                              fontFamily: AppConstants.headingFont,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.blackText,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.close, color: AppColors.grayText),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      itemCount: _specificConditions.length + 1,
                      separatorBuilder: (_, __) => const SizedBox(height: 6),
                      itemBuilder: (context, index) {
                        final bool isOtherIndex = index == _specificConditions.length;
                        final String condition = isOtherIndex ? 'Other' : _specificConditions[index];
                        final bool isSelected = _selectedSpecificCondition == condition;
                        return GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            _selectSpecificCondition(condition);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.successGreen.withOpacity(0.12) : AppColors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? AppColors.successGreen.withOpacity(0.3) : AppColors.lightGray,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppColors.successGreen : AppColors.lightGray,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Icon(
                                      isSelected ? Icons.check : Icons.medical_services,
                                      color: isSelected ? AppColors.white : AppColors.grayText,
                                      size: 18,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    condition,
                                    style: TextStyle(
                                      fontFamily: AppConstants.primaryFont,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.blackText,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _updateContinueButton() {
    setState(() {
      // User can continue if they selected 'None', OR they've selected a category and
      // either picked a specific condition from the list, OR chose 'Other' and typed text.
      if (_selectedCategory == 'None') {
        _canContinue = true;
      } else if (_selectedCategory != null) {
        if (_selectedSpecificCondition == 'Other') {
          _canContinue = (_otherConditionText != null && _otherConditionText!.trim().isNotEmpty);
        } else {
          _canContinue = _selectedSpecificCondition != null;
        }
      } else {
        _canContinue = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
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
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Progress pill (8/8)
            const ProgressPill(current: 8, total: 8, width: 200),
            const SizedBox(width: 12),
            const Text(
              '8/8',
              style: TextStyle(
                fontFamily: AppConstants.primaryFont,
                fontSize: 14,
                color: AppColors.blackText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  // Top spacing and title
                  const SizedBox(height: 40),
                  const Text(
                    "Do you have any medical\nconditions?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppConstants.headingFont,
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                      color: AppColors.blackText,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Medical conditions selection section
                  // Category picker (opens bottom sheet)
                  GestureDetector(
                    onTap: _openCategorySheet,
                    child: Container(
                      width: 280,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                      decoration: BoxDecoration(
                        color: AppColors.lightGray.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.grayText.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedCategory ?? 'Select Category',
                            style: TextStyle(
                              fontFamily: AppConstants.primaryFont,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: _selectedCategory != null
                                  ? AppColors.blackText
                                  : AppColors.grayText,
                            ),
                          ),
                          const Icon(
                            Icons.keyboard_arrow_down,
                            color: AppColors.grayText,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Specific condition picker (opens bottom sheet)
                  GestureDetector(
                    onTap: _selectedCategory != null ? _openSpecificSheet : null,
                    child: Container(
                      width: 280,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                      decoration: BoxDecoration(
                        color: _selectedCategory != null
                            ? AppColors.lightGray.withOpacity(0.3)
                            : AppColors.grayText.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.grayText.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedSpecificCondition ?? 'Select specific Medical Condition',
                            style: TextStyle(
                              fontFamily: AppConstants.primaryFont,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: _selectedSpecificCondition != null
                                  ? AppColors.blackText
                                  : AppColors.grayText,
                            ),
                          ),
                          Icon(
                            Icons.keyboard_arrow_down,
                            color: _selectedCategory != null
                                ? AppColors.grayText
                                : AppColors.grayText.withOpacity(0.5),
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Selected condition pill (if both are selected)
                  if (_selectedCategory != null && _selectedSpecificCondition != null)
                    Container(
                      margin: const EdgeInsets.only(top: 20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.successGreen.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.successGreen.withOpacity(0.3)),
                        ),
                        child: Text(
                          // Show typed other text if user chose Other
                          _selectedSpecificCondition == 'Other' && _otherConditionText != null
                              ? _otherConditionText!
                              : _selectedSpecificCondition!,
                          style: const TextStyle(
                            fontFamily: AppConstants.primaryFont,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.successGreen,
                          ),
                        ),
                      ),
                    ),

                  // If user selected 'Other' show a text field to type the custom condition
                  if (_selectedSpecificCondition == 'Other')
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: SizedBox(
                        width: 280,
                        child: TextFormField(
                          initialValue: _otherConditionText,
                          decoration: const InputDecoration(
                            hintText: 'Please specify',
                          ),
                          onChanged: (val) {
                            setState(() {
                              _otherConditionText = val;
                              _updateContinueButton();
                            });
                          },
                          validator: (val) {
                            if (_selectedSpecificCondition == 'Other') {
                              if (val == null || val.trim().isEmpty) {
                                return 'Please specify your condition';
                              }
                            }
                            return null;
                          },
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Continue Button pinned to bottom
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _canContinue ? _handleContinue : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _canContinue
                            ? AppColors.successGreen
                            : AppColors.grayText.withOpacity(0.3),
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Continue",
                        style: TextStyle(
                          fontFamily: AppConstants.primaryFont,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleContinue() async {
    if (!_canContinue) return;

    // Get the profile setup provider
    final profileProvider = Provider.of<ProfileSetupProvider>(context, listen: false);

    // Build health conditions list
    List<String> healthConditions = [];
    if (_selectedCategory != null && _selectedCategory != 'None') {
      if (_selectedSpecificCondition != null) {
        if (_selectedSpecificCondition == 'Other') {
          // For 'Other', we could add the category name or handle custom input
          healthConditions.add('$_selectedCategory - Other');
        } else {
          healthConditions.add(_selectedSpecificCondition!);
        }
      } else {
        // If only category selected, add the category
        healthConditions.add(_selectedCategory!);
      }
    }

    // Save health conditions to profile
    profileProvider.setHealthConditions(healthConditions);

    // Save the complete profile to Firebase
    try {
      final success = await profileProvider.saveProfile();
      
      if (success) {
        // Navigate to BMI Calculator as the next step in profile flow
        Future.delayed(const Duration(milliseconds: 350), () {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const BMICalculatorPage()),
            );
          }
        });
      } else {
        // Show error message if save failed
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(profileProvider.error ?? 'Failed to save profile'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Show error message for any exceptions
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}