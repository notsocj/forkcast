import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants.dart';

class ManageReportedContentPage extends StatefulWidget {
  const ManageReportedContentPage({super.key});

  @override
  State<ManageReportedContentPage> createState() => _ManageReportedContentPageState();
}

class _ManageReportedContentPageState extends State<ManageReportedContentPage> {
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
                  Icons.report_outlined,
                  size: 64,
                  color: AppColors.grayText.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Reported Content Management coming soon',
                  style: TextStyle(
                    fontFamily: AppConstants.primaryFont,
                    fontSize: 16,
                    color: AppColors.grayText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Review and moderate reported forum content.',
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
