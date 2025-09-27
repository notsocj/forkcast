import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants.dart';
import '../../../services/analytics_service.dart';

class AppAnalyticsPage extends StatefulWidget {
  const AppAnalyticsPage({super.key});

  @override
  State<AppAnalyticsPage> createState() => _AppAnalyticsPageState();
}

class _AppAnalyticsPageState extends State<AppAnalyticsPage> {
  bool _isLoading = true;
  Map<String, int> _userCounts = {};
  int _activeToday = 0;
  int _totalMealPlans = 0;
  int _totalQnAQuestions = 0;
  Map<String, int> _dailyActiveUsers = {};
  Map<String, double> _featureUsage = {};
  List<Map<String, dynamic>> _recentActivities = [];
  Map<String, String> _growthStats = {};

  @override
  void initState() {
    super.initState();
    _loadAnalyticsData();
  }

  Future<void> _loadAnalyticsData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load all analytics data concurrently for better performance
      final results = await Future.wait([
        AnalyticsService.getUserCountByRole(),
        AnalyticsService.getActiveUsersToday(),
        AnalyticsService.getTotalMealPlans(),
        AnalyticsService.getTotalQnAQuestions(),
        AnalyticsService.getDailyActiveUsers(),
        AnalyticsService.getFeatureUsage(),
        AnalyticsService.getRecentActivities(limit: 5),
        AnalyticsService.getGrowthStats(),
      ]);

      setState(() {
        _userCounts = results[0] as Map<String, int>;
        _activeToday = results[1] as int;
        _totalMealPlans = results[2] as int;
        _totalQnAQuestions = results[3] as int;
        _dailyActiveUsers = results[4] as Map<String, int>;
        _featureUsage = results[5] as Map<String, double>;
        _recentActivities = results[6] as List<Map<String, dynamic>>;
        _growthStats = results[7] as Map<String, String>;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading analytics data: $e');
      setState(() {
        _isLoading = false;
      });
      
      // Show error message to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load analytics data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.successGreen,
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Refresh Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Analytics Dashboard',
                style: TextStyle(
                  fontFamily: AppConstants.headingFont,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.blackText,
                ),
              ),
              IconButton(
                onPressed: _loadAnalyticsData,
                icon: const Icon(Icons.refresh),
                color: AppColors.successGreen,
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Overview Statistics
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Users',
                  '${_userCounts['total'] ?? 0}',
                  Icons.people,
                  AppColors.successGreen,
                  _growthStats['users'] ?? '+0%',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Active Today',
                  '$_activeToday',
                  Icons.person_outline,
                  Colors.blue,
                  _growthStats['active_today'] ?? '+0%',
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
                  '$_totalMealPlans',
                  Icons.restaurant_menu,
                  Colors.orange,
                  _growthStats['meal_plans'] ?? '+0%',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Q&A Posts',
                  '$_totalQnAQuestions',
                  Icons.forum,
                  Colors.purple,
                  _growthStats['qna_posts'] ?? '+0%',
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

  /// Helper method to calculate relative height for chart bars
  double _getRelativeHeight(int value) {
    if (_dailyActiveUsers.isEmpty) return 0.1;
    
    final maxValue = _dailyActiveUsers.values.reduce((a, b) => a > b ? a : b);
    if (maxValue == 0) return 0.1;
    
    return (value / maxValue).clamp(0.1, 1.0);
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
                _buildChartBar('Mon', _getRelativeHeight(_dailyActiveUsers['Mon'] ?? 0)),
                _buildChartBar('Tue', _getRelativeHeight(_dailyActiveUsers['Tue'] ?? 0)),
                _buildChartBar('Wed', _getRelativeHeight(_dailyActiveUsers['Wed'] ?? 0)),
                _buildChartBar('Thu', _getRelativeHeight(_dailyActiveUsers['Thu'] ?? 0)),
                _buildChartBar('Fri', _getRelativeHeight(_dailyActiveUsers['Fri'] ?? 0)),
                _buildChartBar('Sat', _getRelativeHeight(_dailyActiveUsers['Sat'] ?? 0)),
                _buildChartBar('Sun', _getRelativeHeight(_dailyActiveUsers['Sun'] ?? 0)),
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
      {'name': 'Meal Planning', 'usage': '${(_featureUsage['Meal Planning'] ?? 0).toInt()}%', 'icon': Icons.restaurant_menu},
      {'name': 'Market Prices', 'usage': '${(_featureUsage['Market Prices'] ?? 0).toInt()}%', 'icon': Icons.store},
      {'name': 'Q&A Forum', 'usage': '${(_featureUsage['Q&A Forum'] ?? 0).toInt()}%', 'icon': Icons.forum},
      {'name': 'Teleconsultation', 'usage': '${(_featureUsage['Teleconsultation'] ?? 0).toInt()}%', 'icon': Icons.video_call},
      {'name': 'BMI Calculator', 'usage': '${(_featureUsage['BMI Calculator'] ?? 0).toInt()}%', 'icon': Icons.calculate},
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
    if (_recentActivities.isEmpty) {
      return Container(
        height: 200,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.successGreen.withOpacity(0.2)),
        ),
        child: const Center(
          child: Text(
            'No recent activities found',
            style: TextStyle(
              fontFamily: AppConstants.primaryFont,
              fontSize: 16,
              color: AppColors.grayText,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.successGreen.withOpacity(0.2)),
      ),
      child: Column(
        children: _recentActivities.map((activity) {
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
                    _getIconData(activity['icon'] ?? 'circle'),
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
                        activity['action'] ?? 'Unknown action',
                        style: const TextStyle(
                          fontFamily: AppConstants.primaryFont,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.blackText,
                        ),
                      ),
                      Text(
                        'by ${activity['user'] ?? 'Unknown user'}',
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
                  activity['time'] ?? 'Unknown time',
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

  /// Helper method to convert icon string to IconData
  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'person_add':
        return Icons.person_add;
      case 'restaurant_menu':
        return Icons.restaurant_menu;
      case 'help_outline':
        return Icons.help_outline;
      case 'video_call':
        return Icons.video_call;
      case 'star':
        return Icons.star;
      default:
        return Icons.circle;
    }
  }
}