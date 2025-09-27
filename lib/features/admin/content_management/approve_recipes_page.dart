import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants.dart';

class ApproveRecipesPage extends StatefulWidget {
  const ApproveRecipesPage({super.key});

  @override
  State<ApproveRecipesPage> createState() => _ApproveRecipesPageState();
}

class _ApproveRecipesPageState extends State<ApproveRecipesPage> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.primaryBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.successGreen.withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.check_circle_outlined,
                  size: 64,
                  color: AppColors.grayText.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Recipe Approval coming soon',
                  style: TextStyle(
                    fontFamily: AppConstants.primaryFont,
                    fontSize: 16,
                    color: AppColors.grayText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Review and approve submitted recipes.',
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
        ],
      ),
    );
  }
}
