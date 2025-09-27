import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants.dart';

class ModeratePostsPage extends StatefulWidget {
  const ModeratePostsPage({super.key});

  @override
  State<ModeratePostsPage> createState() => _ModeratePostsPageState();
}

class _ModeratePostsPageState extends State<ModeratePostsPage> {
  String _selectedTab = 'Reported';
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [            
          // Tab Bar
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.primaryBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.successGreen.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTab = 'Reported';
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _selectedTab == 'Reported' ? AppColors.successGreen : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Reported (0)',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppConstants.primaryFont,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _selectedTab == 'Reported' ? AppColors.white : AppColors.grayText,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTab = 'Recent';
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _selectedTab == 'Recent' ? AppColors.successGreen : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Recent Posts',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppConstants.primaryFont,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _selectedTab == 'Recent' ? AppColors.white : AppColors.grayText,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedTab == 'Reported' ? 'Reported Posts' : 'Recent Forum Posts',
                    style: const TextStyle(
                      fontFamily: AppConstants.headingFont,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.blackText,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
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
                          _selectedTab == 'Reported' 
                              ? Icons.report_outlined
                              : Icons.chat_bubble_outline,
                          size: 64,
                          color: AppColors.grayText.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _selectedTab == 'Reported' 
                              ? 'No reported posts'
                              : 'No recent posts',
                          style: const TextStyle(
                            fontFamily: AppConstants.primaryFont,
                            fontSize: 16,
                            color: AppColors.grayText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _selectedTab == 'Reported' 
                              ? 'Posts reported by users will appear here for moderation.'
                              : 'Recent forum posts will be displayed here for monitoring.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
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
            ),
          ),
        ],
      ),
    );
  }
}