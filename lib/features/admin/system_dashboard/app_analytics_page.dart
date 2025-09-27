import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants.dart';

class AppAnalyticsPage extends StatefulWidget {
  const AppAnalyticsPage({super.key});

  @override
  State<AppAnalyticsPage> createState() => _AppAnalyticsPageState();
}

class _AppAnalyticsPageState extends State<AppAnalyticsPage> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overview Statistics
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Users',
                  '2,847',
                  Icons.people,
                  AppColors.successGreen,
                  '+12%',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Active Today',
                  '892',
                  Icons.person_outline,
                  Colors.blue,
                  '+5%',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Meal Plans',
                  '15,234',
                  Icons.restaurant_menu,
                  Colors.orange,
                  '+18%',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Q&A Posts',
                  '1,456',
                  Icons.forum,
                  Colors.purple,
                  '+8%',
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // User Activity Section
          const Text(
            'User Activity',
            style: TextStyle(
              fontFamily: AppConstants.primaryFont,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.blackText,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildActivityChart(),
          
          const SizedBox(height: 32),

          // Feature Usage Section
          const Text(
            'Feature Usage',
            style: TextStyle(
              fontFamily: AppConstants.primaryFont,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.blackText,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildFeatureUsageList(),
          
          const SizedBox(height: 32),

          // Recent Activity Section
          const Text(
            'Recent Activity',
            style: TextStyle(
              fontFamily: AppConstants.primaryFont,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.blackText,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildRecentActivityList(),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, String change) {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.successGreen.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 16,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.successGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  change,
                  style: const TextStyle(
                    fontFamily: AppConstants.primaryFont,
                    fontSize: 9,
                    color: AppColors.successGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontFamily: AppConstants.primaryFont,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.blackText,
            ),
          ),
          const SizedBox(height: 2),
          Flexible(
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: AppConstants.primaryFont,
                fontSize: 10,
                color: AppColors.grayText,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityChart() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.successGreen.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daily Active Users (Last 7 days)',
            style: TextStyle(
              fontFamily: AppConstants.primaryFont,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.blackText,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildChartBar('Mon', 0.6),
                _buildChartBar('Tue', 0.8),
                _buildChartBar('Wed', 0.7),
                _buildChartBar('Thu', 0.9),
                _buildChartBar('Fri', 1.0),
                _buildChartBar('Sat', 0.5),
                _buildChartBar('Sun', 0.4),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartBar(String day, double height) {
    return Flexible(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 20,
            height: 70 * height,
            decoration: BoxDecoration(
              color: AppColors.successGreen,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            day,
            style: const TextStyle(
              fontFamily: AppConstants.primaryFont,
              fontSize: 10,
              color: AppColors.grayText,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureUsageList() {
    final features = [
      {'name': 'Meal Planning', 'usage': '85%', 'icon': Icons.restaurant_menu},
      {'name': 'Market Prices', 'usage': '72%', 'icon': Icons.store},
      {'name': 'Q&A Forum', 'usage': '68%', 'icon': Icons.forum},
      {'name': 'Teleconsultation', 'usage': '45%', 'icon': Icons.video_call},
      {'name': 'BMI Calculator', 'usage': '92%', 'icon': Icons.calculate},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.successGreen.withOpacity(0.2)),
      ),
      child: Column(
        children: features.map((feature) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.successGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    feature['icon'] as IconData,
                    color: AppColors.successGreen,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    feature['name'] as String,
                    style: const TextStyle(
                      fontFamily: AppConstants.primaryFont,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.blackText,
                    ),
                  ),
                ),
                Text(
                  feature['usage'] as String,
                  style: const TextStyle(
                    fontFamily: AppConstants.primaryFont,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.successGreen,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRecentActivityList() {
    final activities = [
      {
        'action': 'New user registration',
        'user': 'Maria Santos',
        'time': '5 minutes ago',
        'icon': Icons.person_add,
      },
      {
        'action': 'Meal plan created',
        'user': 'Juan Dela Cruz',
        'time': '12 minutes ago',
        'icon': Icons.restaurant_menu,
      },
      {
        'action': 'Q&A question posted',
        'user': 'Anna Reyes',
        'time': '18 minutes ago',
        'icon': Icons.help_outline,
      },
      {
        'action': 'Teleconsultation booked',
        'user': 'Carlos Garcia',
        'time': '25 minutes ago',
        'icon': Icons.video_call,
      },
      {
        'action': 'Recipe rated',
        'user': 'Lisa Gonzales',
        'time': '32 minutes ago',
        'icon': Icons.star,
      },
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.successGreen.withOpacity(0.2)),
      ),
      child: Column(
        children: activities.map((activity) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBackground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    activity['icon'] as IconData,
                    color: AppColors.grayText,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity['action'] as String,
                        style: const TextStyle(
                          fontFamily: AppConstants.primaryFont,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.blackText,
                        ),
                      ),
                      Text(
                        'by ${activity['user']}',
                        style: const TextStyle(
                          fontFamily: AppConstants.primaryFont,
                          fontSize: 12,
                          color: AppColors.grayText,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  activity['time'] as String,
                  style: const TextStyle(
                    fontFamily: AppConstants.primaryFont,
                    fontSize: 12,
                    color: AppColors.grayText,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}