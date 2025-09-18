import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants.dart';
import '../../core/widgets/progress_pill.dart';
import 'medical_conditions_page.dart';

class HouseholdSizePage extends StatefulWidget {
  const HouseholdSizePage({super.key});

  @override
  State<HouseholdSizePage> createState() => _HouseholdSizePageState();
}

class _HouseholdSizePageState extends State<HouseholdSizePage> {
  final _formKey = GlobalKey<FormState>();
  
  // Household size state
  int _householdSize = 1;
  bool _canContinue = true; // Start with true since 1 is valid

  void _updateHouseholdSize(int newSize) {
    setState(() {
      _householdSize = newSize.clamp(1, 99); // Minimum 1, maximum 99
      _canContinue = _householdSize > 0;
    });
  }

  void _incrementSize() {
    _updateHouseholdSize(_householdSize + 1);
  }

  void _decrementSize() {
    _updateHouseholdSize(_householdSize - 1);
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
            const ProgressPill(current: 7, total: 8, width: 200),
            const SizedBox(width: 12),
            const Text(
              '7/8',
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                // Top spacing and title
                const SizedBox(height: 40),
                Text(
                  "How many pax are you\nin the family?",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: AppConstants.headingFont,
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                    color: AppColors.blackText,
                  ),
                ),
                const SizedBox(height: 60),
                
                // Number input with +/- buttons
                Container(
                  width: 200,
                  height: 60,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.successGreen, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      // Minus button
                      GestureDetector(
                        onTap: _householdSize > 1 ? _decrementSize : null,
                        child: Container(
                          width: 50,
                          height: 60,
                          decoration: BoxDecoration(
                            color: _householdSize > 1 
                                ? AppColors.successGreen 
                                : AppColors.grayText.withOpacity(0.3),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(6),
                              bottomLeft: Radius.circular(6),
                            ),
                          ),
                          child: Icon(
                            Icons.remove,
                            color: AppColors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      // Number display
                      Expanded(
                        child: Container(
                          alignment: Alignment.center,
                          child: Text(
                            '$_householdSize',
                            style: const TextStyle(
                              fontFamily: AppConstants.primaryFont,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.blackText,
                            ),
                          ),
                        ),
                      ),
                      // Plus button
                      GestureDetector(
                        onTap: _householdSize < 99 ? _incrementSize : null,
                        child: Container(
                          width: 50,
                          height: 60,
                          decoration: BoxDecoration(
                            color: _householdSize < 99 
                                ? AppColors.successGreen 
                                : AppColors.grayText.withOpacity(0.3),
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(6),
                              bottomRight: Radius.circular(6),
                            ),
                          ),
                          child: Icon(
                            Icons.add,
                            color: AppColors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Number pad
                Expanded(
                  child: Center(
                    child: Container(
                      width: 280,
                      child: GridView.count(
                        shrinkWrap: true,
                        crossAxisCount: 3,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.2,
                        children: [
                          _buildNumberButton(1),
                          _buildNumberButton(2),
                          _buildNumberButton(3),
                          _buildNumberButton(4),
                          _buildNumberButton(5),
                          _buildNumberButton(6),
                          _buildNumberButton(7),
                          _buildNumberButton(8),
                          _buildNumberButton(9),
                        ],
                      ),
                    ),
                  ),
                ),
                
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
    );
  }

  Widget _buildNumberButton(int number) {
    bool isHighlighted = _householdSize == number;
    return GestureDetector(
      onTap: () => _updateHouseholdSize(number),
      child: Container(
        decoration: BoxDecoration(
          color: isHighlighted 
              ? AppColors.successGreen 
              : AppColors.lightGray,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isHighlighted ? [
            BoxShadow(
              color: AppColors.successGreen.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Center(
          child: Text(
            '$number',
            style: TextStyle(
              fontFamily: AppConstants.primaryFont,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isHighlighted ? AppColors.white : AppColors.blackText,
            ),
          ),
        ),
      ),
    );
  }

  void _handleContinue() {
    if (_householdSize > 0) {
      // TODO: Save household size to user profile and navigate to next setup page
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Household size saved: $_householdSize'),
          backgroundColor: AppColors.successGreen,
        ),
      );
      // Navigate to medical conditions page
      Navigator.push(
        context, 
        MaterialPageRoute(builder: (context) => const MedicalConditionsPage())
      );
    }
  }
}