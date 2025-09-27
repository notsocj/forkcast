import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants.dart';
import '../../../services/user_management_service.dart';
import '../../../models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfilesPage extends StatefulWidget {
  const UserProfilesPage({super.key});

  @override
  State<UserProfilesPage> createState() => _UserProfilesPageState();
}

class _UserProfilesPageState extends State<UserProfilesPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  bool _isLoading = true;
  List<Map<String, dynamic>> _profiles = [];
  Map<String, int> _analytics = {};
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load analytics and profiles concurrently
      final results = await Future.wait([
        UserManagementService.getHealthAnalytics(),
        UserManagementService.getUserHealthProfiles(
          healthConditionFilter: _selectedFilter,
        ),
      ]);

      final analytics = results[0] as Map<String, dynamic>;
      final profiles = results[1] as List<Map<String, dynamic>>;

      setState(() {
        _analytics = {
          'totalProfiles': analytics['totalProfiles'] ?? 0,
          'profilesWithHealthIssues': analytics['profilesWithHealthIssues'] ?? 0,
          'activeThisWeek': analytics['activeThisWeek'] ?? 0,
        };
        _profiles = profiles;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading profiles data: $e');
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _performSearch() {
    // For now, we'll filter locally. In production, consider server-side search
    if (_searchController.text.isEmpty) {
      _loadData();
      return;
    }

    final searchTerm = _searchController.text.toLowerCase();
    final filteredProfiles = _profiles.where((profile) {
      final user = profile['user'] as User;
      return user.fullName.toLowerCase().contains(searchTerm) ||
             user.email.toLowerCase().contains(searchTerm);
    }).toList();

    setState(() {
      _profiles = filteredProfiles;
    });
  }

  void _filterByCondition(String condition) {
    setState(() {
      _selectedFilter = condition;
    });
    _loadData();
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
          // Title and Refresh
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'User Health Profiles',
                style: TextStyle(
                  fontFamily: AppConstants.headingFont,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.blackText,
                ),
              ),
              IconButton(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh),
                color: AppColors.successGreen,
              ),
            ],
          ),
          const SizedBox(height: 24),
          
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
                          onChanged: (value) {
                            // Debounce search
                            Future.delayed(const Duration(milliseconds: 500), () {
                              if (_searchController.text == value) {
                                _performSearch();
                              }
                            });
                          },
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
                        if (value != null) {
                          _filterByCondition(value);
                        }
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
                child: _buildAnalyticsCard('Total Profiles', '${_analytics['totalProfiles'] ?? 0}', Icons.people, AppColors.successGreen),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAnalyticsCard('With Health Issues', '${_analytics['profilesWithHealthIssues'] ?? 0}', Icons.medical_services, Colors.red),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAnalyticsCard('Active This Week', '${_analytics['activeThisWeek'] ?? 0}', Icons.trending_up, Colors.blue),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Health Profile Details',
                style: TextStyle(
                  fontFamily: AppConstants.headingFont,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.blackText,
                ),
              ),
              Text(
                '${_profiles.length} ${_profiles.length == 1 ? 'profile' : 'profiles'} found',
                style: const TextStyle(
                  fontFamily: AppConstants.primaryFont,
                  fontSize: 14,
                  color: AppColors.grayText,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Profile Cards
          if (_profiles.isEmpty)
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.successGreen.withOpacity(0.2)),
              ),
              child: const Center(
                child: Text(
                  'No profiles found',
                  style: TextStyle(
                    fontFamily: AppConstants.primaryFont,
                    fontSize: 16,
                    color: AppColors.grayText,
                  ),
                ),
              ),
            )
          else
            ..._profiles.map((profile) => _buildProfileCard(profile: profile)),
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
  
  Widget _buildProfileCard({required Map<String, dynamic> profile}) {
    final user = profile['user'] as User;
    final healthConditions = profile['healthConditions'] as List<String>? ?? [];
    final lastLogin = profile['lastLogin'] as Timestamp?;
    
    final bmi = user.bmi ?? user.calculatedBmi;
    Color bmiColor = bmi < 18.5 ? Colors.blue :
                    bmi < 25 ? AppColors.successGreen :
                    bmi < 30 ? Colors.orange : Colors.red;
    String bmiCategory = bmi < 18.5 ? 'Underweight' :
                        bmi < 25 ? 'Normal' :
                        bmi < 30 ? 'Overweight' : 'Obese';
    
    String lastActive = lastLogin != null 
        ? UserManagementService.formatTimeAgo(lastLogin)
        : 'Never';
    
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
              user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U',
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
                        user.fullName,
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
                      '(${user.age} yrs)',
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
                if (healthConditions.isNotEmpty)
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: healthConditions.map((condition) => Container(
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
              _handleProfileAction(value, user);
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
  
  void _handleProfileAction(String action, User user) {
    switch (action) {
      case 'view':
        _showProfileDetailsDialog(user);
        break;
      case 'meals':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Meal history for ${user.fullName} - Coming Soon'),
            backgroundColor: AppColors.successGreen,
          ),
        );
        break;
      case 'health':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Health data for ${user.fullName} - Coming Soon'),
            backgroundColor: AppColors.successGreen,
          ),
        );
        break;
    }
  }

  void _showProfileDetailsDialog(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Health Profile: ${user.fullName}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Email: ${user.email}'),
              Text('Age: ${user.age} years'),
              Text('Gender: ${user.gender}'),
              Text('Height: ${user.heightCm.toStringAsFixed(1)} cm'),
              Text('Weight: ${user.weightKg.toStringAsFixed(1)} kg'),
              Text('BMI: ${(user.bmi ?? user.calculatedBmi).toStringAsFixed(1)}'),
              Text('Household Size: ${user.householdSize} people'),
              Text('Weekly Budget: ₱${user.weeklyBudgetMin} - ₱${user.weeklyBudgetMax}'),
              if (user.createdAt != null)
                Text('Joined: ${user.createdAt!.day}/${user.createdAt!.month}/${user.createdAt!.year}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
