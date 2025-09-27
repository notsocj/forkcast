import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants.dart';

class StatusLogsPage extends StatefulWidget {
  const StatusLogsPage({super.key});

  @override
  State<StatusLogsPage> createState() => _StatusLogsPageState();
}

class _StatusLogsPageState extends State<StatusLogsPage> {
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
                  Icons.monitor_heart_outlined,
                  size: 64,
                  color: AppColors.grayText.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                const Text(
                  'System Status Logs coming soon',
                  style: TextStyle(
                    fontFamily: AppConstants.primaryFont,
                    fontSize: 16,
                    color: AppColors.grayText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Monitor system health and application logs.',
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
