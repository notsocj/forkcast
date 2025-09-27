import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants.dart';

class UserProfilesPage extends StatefulWidget {
  const UserProfilesPage({super.key});

  @override
  State<UserProfilesPage> createState() => _UserProfilesPageState();
}

class _UserProfilesPageState extends State<UserProfilesPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search and Filters
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.successGreen.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: AppColors.grayText.withOpacity(0.7)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            hintText: 'Search profiles...',
                            hintStyle: TextStyle(
                              fontFamily: AppConstants.primaryFont,
                              color: AppColors.grayText,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.successGreen.withOpacity(0.3)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedFilter,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(value: 'All', child: Text('All Conditions')),
                        DropdownMenuItem(value: 'Diabetes', child: Text('Diabetes')),
                        DropdownMenuItem(value: 'Hypertension', child: Text('Hypertension')),
                        DropdownMenuItem(value: 'Obesity', child: Text('Obesity')),
                        DropdownMenuItem(value: 'None', child: Text('No Conditions')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedFilter = value!;
                        });
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Analytics Cards
          Row(
            children: [
              Expanded(
                child: _buildAnalyticsCard('Total Profiles', '1,156', Icons.people, AppColors.successGreen),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAnalyticsCard('With Health Issues', '342', Icons.medical_services, Colors.red),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAnalyticsCard('Active This Week', '89', Icons.trending_up, Colors.blue),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          const Text(
            'User Health Profiles',
            style: TextStyle(
              fontFamily: AppConstants.headingFont,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.blackText,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Profile Cards
          ...List.generate(6, (index) => _buildProfileCard(
            name: _getProfileName(index),
            age: _getProfileAge(index),
            bmi: _getProfileBMI(index),
            conditions: _getHealthConditions(index),
            lastActive: _getLastActive(index),
          )),
        ],
      ),
    );
  }
  
  Widget _buildAnalyticsCard(String title, String value, IconData icon, Color color) {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const Spacer(),
              Flexible(
                child: Text(
                  value,
                  style: TextStyle(
                    fontFamily: AppConstants.headingFont,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: AppConstants.primaryFont,
                fontSize: 11,
                color: AppColors.grayText,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildProfileCard({
    required String name,
    required int age,
    required double bmi,
    required List<String> conditions,
    required String lastActive,
  }) {
    Color bmiColor = bmi < 18.5 ? Colors.blue :
                    bmi < 25 ? AppColors.successGreen :
                    bmi < 30 ? Colors.orange : Colors.red;
    String bmiCategory = bmi < 18.5 ? 'Underweight' :
                        bmi < 25 ? 'Normal' :
                        bmi < 30 ? 'Overweight' : 'Obese';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.successGreen.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.successGreen.withOpacity(0.2),
            child: Text(
              name[0].toUpperCase(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.successGreen,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontFamily: AppConstants.primaryFont,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.blackText,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '($age yrs)',
                      style: const TextStyle(
                        fontFamily: AppConstants.primaryFont,
                        fontSize: 14,
                        color: AppColors.grayText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: bmiColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'BMI: ${bmi.toStringAsFixed(1)} ($bmiCategory)',
                          style: TextStyle(
                            fontFamily: AppConstants.primaryFont,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: bmiColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (conditions.isNotEmpty)
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: conditions.map((condition) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        condition,
                        style: const TextStyle(
                          fontFamily: AppConstants.primaryFont,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                    )).toList(),
                  ),
                const SizedBox(height: 6),
                Text(
                  'Last active: $lastActive',
                  style: const TextStyle(
                    fontFamily: AppConstants.primaryFont,
                    fontSize: 11,
                    color: AppColors.grayText,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              _handleProfileAction(value, name);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'view',
                child: Text('View Profile'),
              ),
              const PopupMenuItem(
                value: 'meals',
                child: Text('Meal History'),
              ),
              const PopupMenuItem(
                value: 'health',
                child: Text('Health Data'),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  void _handleProfileAction(String action, String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$action for $name')),
    );
  }
  
  String _getProfileName(int index) {
    final names = ['Maria Santos', 'Juan dela Cruz', 'Ana Garcia', 'Carlos Reyes', 'Lisa Tan', 'Pedro Rodriguez'];
    return names[index];
  }
  
  int _getProfileAge(int index) {
    final ages = [34, 28, 45, 52, 29, 38];
    return ages[index];
  }
  
  double _getProfileBMI(int index) {
    final bmis = [22.5, 26.8, 19.2, 31.4, 24.1, 28.9];
    return bmis[index];
  }
  
  List<String> _getHealthConditions(int index) {
    final List<List<String>> conditions = [
      [], 
      ['Hypertension'], 
      [], 
      ['Diabetes', 'Obesity'], 
      [], 
      ['Hypertension', 'High Cholesterol']
    ];
    return conditions[index];
  }
  
  String _getLastActive(int index) {
    final activities = ['2 hours ago', '1 day ago', '3 hours ago', '5 days ago', '1 hour ago', '2 days ago'];
    return activities[index];
  }
}
