import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants.dart';
import '../../core/widgets/progress_pill.dart';
import 'birthday_entry_page.dart';

class GenderSelectionPage extends StatefulWidget {
  const GenderSelectionPage({super.key});

  @override
  State<GenderSelectionPage> createState() => _GenderSelectionPageState();
}

class _GenderSelectionPageState extends State<GenderSelectionPage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedGender;
  bool _canContinue = false;

  @override
  void initState() {
    super.initState();
  }

  void _selectGender(String gender) {
    setState(() {
      _selectedGender = gender;
      _canContinue = true;
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
            const ProgressPill(current: 2, total: 8, width: 200),
            const SizedBox(width: 12),
            const Text(
              '2/8',
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
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                // small top spacing, title slightly moved down
                  const SizedBox(height: 40),
                  Text(
                    "What's your gender?",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: AppConstants.headingFont,
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                      color: AppColors.blackText,
                    ),
                  ),
                  // center the options block in the remaining space
                  const SizedBox(height: 20),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildGenderOption(
                                gender: 'Male',
                                icon: Icons.male,
                                isSelected: _selectedGender == 'Male',
                                color: AppColors.successGreen,
                                size: 120,
                                iconSize: 56,
                              ),
                              _buildGenderOption(
                                gender: 'Female',
                                icon: Icons.female,
                                isSelected: _selectedGender == 'Female',
                                color: AppColors.successGreen,
                                size: 120,
                                iconSize: 56,
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: 260,
                            height: 48,
                            child: OutlinedButton(
                              onPressed: () => _selectGender('Prefer not to say'),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: _selectedGender == 'Prefer not to say'
                                    ? AppColors.successGreen.withOpacity(0.15)
                                    : Colors.transparent,
                                side: BorderSide(
                                  color: _selectedGender == 'Prefer not to say'
                                      ? AppColors.successGreen
                                      : AppColors.grayText.withOpacity(0.3),
                                  width: 1,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              child: Text(
                                'Prefer not to say',
                                style: TextStyle(
                                  fontFamily: AppConstants.primaryFont,
                                  fontSize: 16,
                                  color: _selectedGender == 'Prefer not to say'
                                      ? AppColors.successGreen
                                      : AppColors.blackText,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
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

  Widget _buildGenderOption({
    required String gender,
    required IconData icon,
    required bool isSelected,
    required Color color,
    double size = 100,
    double iconSize = 48,
  }) {
    return GestureDetector(
      onTap: () => _selectGender(gender),
      child: Column(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: isSelected ? color : AppColors.lightGray,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: iconSize,
              color: isSelected ? AppColors.white : AppColors.grayText,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            gender,
            style: TextStyle(
              fontFamily: AppConstants.primaryFont,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isSelected ? color : AppColors.blackText,
            ),
          ),
        ],
      ),
    );
  }

  void _handleContinue() {
    if (_selectedGender != null) {
      // TODO: Save gender to user profile and navigate to next setup page
      // Navigate to birthday entry page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const BirthdayEntryPage()),
      );
    }
  }
        // Toast removed: previously showed a SnackBar after selecting gender
}