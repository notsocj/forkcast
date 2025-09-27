import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants.dart';
import '../../../services/user_management_service.dart';
import '../../../models/user.dart';

class ManageUsersPage extends StatefulWidget {
  const ManageUsersPage({super.key});

  @override
  State<ManageUsersPage> createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedUserType = 'All';
  bool _isLoading = true;
  List<User> _users = [];
  Map<String, int> _statistics = {};
  
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
      // Load statistics and users concurrently
      final results = await Future.wait([
        UserManagementService.getUserStatistics(),
        UserManagementService.getAllUsers(
          roleFilter: _selectedUserType,
          searchQuery: _searchController.text,
        ),
      ]);

      final statistics = results[0] as Map<String, dynamic>;
      final usersData = results[1] as Map<String, dynamic>;

      setState(() {
        _statistics = {
          'totalUsers': statistics['roleCounts']['total'] ?? 0,
          'activeUsers': statistics['statusCounts']['active'] ?? 0,
          'newUsers': statistics['newUsersThisMonth'] ?? 0,
        };
        _users = usersData['users'] as List<User>;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
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
    _loadData();
  }

  void _filterByType(String type) {
    setState(() {
      _selectedUserType = type;
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
          // Refresh Button and Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'User Management',
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
          
          // Search Bar
          Container(
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
                      // Debounce search to avoid too many API calls
                      Future.delayed(const Duration(milliseconds: 500), () {
                        if (_searchController.text == value) {
                          _performSearch();
                        }
                      });
                    },
                    decoration: const InputDecoration(
                      hintText: 'Search users by name or email...',
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
          
          const SizedBox(height: 24),
          
          // Statistics Cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard('Total Users', '${_statistics['totalUsers'] ?? 0}', Icons.people, AppColors.successGreen),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard('Active Users', '${_statistics['activeUsers'] ?? 0}', Icons.person, Colors.blue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard('New Users', '${_statistics['newUsers'] ?? 0}', Icons.person_add, Colors.orange),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Filter Tabs
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.primaryBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.successGreen.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                _buildFilterTab('All', 'All'),
                _buildFilterTab('Users', 'Users'),
                _buildFilterTab('Professionals', 'Professionals'), 
                _buildFilterTab('Admins', 'Admins'),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Users Table Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'User Accounts',
                style: TextStyle(
                  fontFamily: AppConstants.headingFont,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.blackText,
                ),
              ),
              Text(
                '${_users.length} ${_users.length == 1 ? 'user' : 'users'} found',
                style: const TextStyle(
                  fontFamily: AppConstants.primaryFont,
                  fontSize: 14,
                  color: AppColors.grayText,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Users List
          if (_users.isEmpty)
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.successGreen.withOpacity(0.2)),
              ),
              child: const Center(
                child: Text(
                  'No users found',
                  style: TextStyle(
                    fontFamily: AppConstants.primaryFont,
                    fontSize: 16,
                    color: AppColors.grayText,
                  ),
                ),
              ),
            )
          else
            ..._users.map((user) => _buildUserCard(user: user)),
        ],
      ),
    );
  }
  
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
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
  
  Widget _buildFilterTab(String label, String value) {
    final isSelected = _selectedUserType == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _filterByType(value);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.successGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppConstants.primaryFont,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSelected ? AppColors.white : AppColors.grayText,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
  
  Widget _buildUserCard({required User user}) {
    // Get account status from user data or default to 'active'
    final status = _getDisplayStatus(user);
    final joinDate = user.createdAt != null 
        ? '${user.createdAt!.year}-${user.createdAt!.month.toString().padLeft(2, '0')}-${user.createdAt!.day.toString().padLeft(2, '0')}'
        : 'Unknown';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.successGreen.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.successGreen.withOpacity(0.2),
            child: Text(
              user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U',
              style: const TextStyle(
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
                Text(
                  user.fullName,
                  style: const TextStyle(
                    fontFamily: AppConstants.primaryFont,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.blackText,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  user.email,
                  style: const TextStyle(
                    fontFamily: AppConstants.primaryFont,
                    fontSize: 13,
                    color: AppColors.grayText,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    _buildRoleBadge(user.role),
                    _buildStatusBadge(status),
                  ],
                ),
                if (user.role == 'professional' && user.specialization != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Specialization: ${user.specialization}',
                    style: const TextStyle(
                      fontFamily: AppConstants.primaryFont,
                      fontSize: 11,
                      color: AppColors.grayText,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              _handleUserAction(value, user);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'view',
                child: Text('View Details'),
              ),
              const PopupMenuItem(
                value: 'edit',
                child: Text('Edit User'),
              ),
              if (status != 'Suspended')
                const PopupMenuItem(
                  value: 'suspend',
                  child: Text('Suspend User'),
                )
              else
                const PopupMenuItem(
                  value: 'activate',
                  child: Text('Activate User'),
                ),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Delete User'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getDisplayStatus(User user) {
    // Since User model doesn't have account_status, we'll determine from other fields
    // In production, you might want to add account_status to User model
    return 'Active'; // Default status for now
  }
  
  Widget _buildRoleBadge(String role) {
    Color color = role == 'professional' ? Colors.blue : 
                 role == 'admin' ? Colors.purple : AppColors.successGreen;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        role.toUpperCase(),
        style: TextStyle(
          fontFamily: AppConstants.primaryFont,
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: color,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
  
  Widget _buildStatusBadge(String status) {
    Color color = status == 'Active' ? AppColors.successGreen : 
                 status == 'Suspended' ? Colors.red : Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontFamily: AppConstants.primaryFont,
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: color,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
  
  void _handleUserAction(String action, User user) async {
    switch (action) {
      case 'view':
        _showUserDetailsDialog(user);
        break;
      case 'edit':
        _showEditUserDialog(user);
        break;
      case 'suspend':
        _confirmUserStatusChange(user, 'suspended');
        break;
      case 'activate':
        _confirmUserStatusChange(user, 'active');
        break;
      case 'delete':
        _confirmUserDeletion(user);
        break;
    }
  }

  void _showUserDetailsDialog(User user) {
    final bmi = user.bmi ?? user.calculatedBmi;
    Color bmiColor = bmi < 18.5 ? Colors.blue :
                    bmi < 25 ? AppColors.successGreen :
                    bmi < 30 ? Colors.orange : Colors.red;
    String bmiCategory = bmi < 18.5 ? 'Underweight' :
                        bmi < 25 ? 'Normal' :
                        bmi < 30 ? 'Overweight' : 'Obese';

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: AppColors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with user info
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.successGreen, AppColors.successGreen.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.white.withOpacity(0.3),
                      child: Text(
                        user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.fullName,
                            style: const TextStyle(
                              fontFamily: AppConstants.headingFont,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              user.role.toUpperCase(),
                              style: const TextStyle(
                                fontFamily: AppConstants.primaryFont,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailSection('Contact Information', [
                        _buildDetailRow(Icons.email, 'Email', user.email),
                        if (user.phoneNumber != null)
                          _buildDetailRow(Icons.phone, 'Phone', user.phoneNumber!),
                      ]),
                      const SizedBox(height: 20),
                      _buildDetailSection('Personal Information', [
                        _buildDetailRow(Icons.person, 'Gender', user.gender),
                        _buildDetailRow(Icons.cake, 'Age', '${user.age} years'),
                        if (user.specialization != null)
                          _buildDetailRow(Icons.work, 'Specialization', user.specialization!),
                      ]),
                      const SizedBox(height: 20),
                      _buildDetailSection('Health Information', [
                        _buildDetailRow(Icons.height, 'Height', '${user.heightCm.toStringAsFixed(1)} cm'),
                        _buildDetailRow(Icons.monitor_weight, 'Weight', '${user.weightKg.toStringAsFixed(1)} kg'),
                        _buildDetailRowWithColor(Icons.fitness_center, 'BMI', 
                          '${bmi.toStringAsFixed(1)} ($bmiCategory)', bmiColor),
                      ]),
                      const SizedBox(height: 20),
                      _buildDetailSection('Household Information', [
                        _buildDetailRow(Icons.family_restroom, 'Household Size', '${user.householdSize} people'),
                        _buildDetailRow(Icons.attach_money, 'Weekly Budget', 
                          '₱${user.weeklyBudgetMin} - ₱${user.weeklyBudgetMax}'),
                      ]),
                      if (user.createdAt != null) ...[
                        const SizedBox(height: 20),
                        _buildDetailSection('Account Information', [
                          _buildDetailRow(Icons.calendar_today, 'Joined', 
                            '${user.createdAt!.day}/${user.createdAt!.month}/${user.createdAt!.year}'),
                        ]),
                      ],
                    ],
                  ),
                ),
              ),
              // Actions
              Container(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _showEditUserDialog(user);
                        },
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text('Edit User'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.successGreen,
                          side: const BorderSide(color: AppColors.successGreen),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, size: 18),
                        label: const Text('Close'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.successGreen,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditUserDialog(User user) {
    final nameController = TextEditingController(text: user.fullName);
    final emailController = TextEditingController(text: user.email);
    final phoneController = TextEditingController(text: user.phoneNumber ?? '');
    final heightController = TextEditingController(text: user.heightCm.toString());
    final weightController = TextEditingController(text: user.weightKg.toString());
    final budgetMinController = TextEditingController(text: user.weeklyBudgetMin.toString());
    final budgetMaxController = TextEditingController(text: user.weeklyBudgetMax.toString());
    final householdController = TextEditingController(text: user.householdSize.toString());
    
    String selectedGender = user.gender;
    String selectedRole = user.role;
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: AppColors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.successGreen, AppColors.successGreen.withOpacity(0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.edit, color: AppColors.white, size: 28),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Edit User',
                              style: TextStyle(
                                fontFamily: AppConstants.headingFont,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.white,
                              ),
                            ),
                            Text(
                              user.fullName,
                              style: TextStyle(
                                fontFamily: AppConstants.primaryFont,
                                fontSize: 14,
                                color: AppColors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildEditSection('Basic Information', [
                          _buildTextField('Full Name', nameController, Icons.person),
                          const SizedBox(height: 16),
                          _buildTextField('Email', emailController, Icons.email, enabled: false),
                          const SizedBox(height: 16),
                          _buildTextField('Phone Number', phoneController, Icons.phone),
                          const SizedBox(height: 16),
                          _buildDropdownField('Gender', selectedGender, 
                            ['Male', 'Female', 'Prefer not to say'], (value) {
                            setState(() {
                              selectedGender = value!;
                            });
                          }),
                          const SizedBox(height: 16),
                          _buildDropdownField('Role', selectedRole,
                            ['user', 'professional', 'admin'], (value) {
                            setState(() {
                              selectedRole = value!;
                            });
                          }),
                        ]),
                        const SizedBox(height: 20),
                        _buildEditSection('Physical Information', [
                          _buildTextField('Height (cm)', heightController, Icons.height,
                            keyboardType: TextInputType.number),
                          const SizedBox(height: 16),
                          _buildTextField('Weight (kg)', weightController, Icons.monitor_weight,
                            keyboardType: TextInputType.number),
                        ]),
                        const SizedBox(height: 20),
                        _buildEditSection('Household Information', [
                          _buildTextField('Household Size', householdController, Icons.family_restroom,
                            keyboardType: TextInputType.number),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField('Min Budget', budgetMinController, Icons.attach_money,
                                  keyboardType: TextInputType.number),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildTextField('Max Budget', budgetMaxController, Icons.attach_money,
                                  keyboardType: TextInputType.number),
                              ),
                            ],
                          ),
                        ]),
                      ],
                    ),
                  ),
                ),
                // Actions
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: isLoading ? null : () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.grayText,
                            side: const BorderSide(color: AppColors.grayText),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isLoading ? null : () async {
                            setState(() {
                              isLoading = true;
                            });
                            
                            try {
                              final updatedData = {
                                'full_name': nameController.text.trim(),
                                'phone_number': phoneController.text.trim().isEmpty 
                                  ? null : phoneController.text.trim(),
                                'gender': selectedGender,
                                'role': selectedRole,
                                'height_cm': double.tryParse(heightController.text) ?? user.heightCm,
                                'weight_kg': double.tryParse(weightController.text) ?? user.weightKg,
                                'household_size': int.tryParse(householdController.text) ?? user.householdSize,
                                'weekly_budget_min': int.tryParse(budgetMinController.text) ?? user.weeklyBudgetMin,
                                'weekly_budget_max': int.tryParse(budgetMaxController.text) ?? user.weeklyBudgetMax,
                              };
                              
                              // Calculate BMI
                              final height = updatedData['height_cm'] as double;
                              final weight = updatedData['weight_kg'] as double;
                              updatedData['bmi'] = weight / ((height / 100) * (height / 100));
                              
                              final success = await UserManagementService.updateUser(user.id!, updatedData);
                              
                              if (success && mounted) {
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('User updated successfully'),
                                    backgroundColor: AppColors.successGreen,
                                  ),
                                );
                                _loadData(); // Reload data
                              } else if (mounted) {
                                setState(() {
                                  isLoading = false;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Failed to update user'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            } catch (e) {
                              setState(() {
                                isLoading = false;
                              });
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          child: isLoading 
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                                ),
                              )
                            : const Text('Save Changes'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.successGreen,
                            foregroundColor: AppColors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmUserStatusChange(User user, String newStatus) {
    bool isLoading = false;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(
                newStatus == 'suspended' ? Icons.block : Icons.check_circle,
                color: newStatus == 'suspended' ? Colors.orange : AppColors.successGreen,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                '${newStatus == 'suspended' ? 'Suspend' : 'Activate'} User',
                style: const TextStyle(
                  fontFamily: AppConstants.headingFont,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: newStatus == 'suspended' 
                    ? Colors.orange.withOpacity(0.1)
                    : AppColors.successGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: newStatus == 'suspended' 
                      ? Colors.orange.withOpacity(0.3)
                      : AppColors.successGreen.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.successGreen.withOpacity(0.2),
                      child: Text(
                        user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.successGreen,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.fullName,
                            style: const TextStyle(
                              fontFamily: AppConstants.primaryFont,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.blackText,
                            ),
                          ),
                          Text(
                            user.email,
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
              const SizedBox(height: 16),
              Text(
                newStatus == 'suspended'
                  ? 'This will suspend the user\'s account. They will not be able to access the app until reactivated.'
                  : 'This will reactivate the user\'s account. They will regain full access to the app.',
                style: const TextStyle(
                  fontFamily: AppConstants.primaryFont,
                  fontSize: 14,
                  color: AppColors.grayText,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isLoading ? null : () async {
                setState(() {
                  isLoading = true;
                });
                
                final success = await UserManagementService.updateUserStatus(user.id!, newStatus);
                
                if (success && mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('User ${newStatus == 'suspended' ? 'suspended' : 'activated'} successfully'),
                      backgroundColor: AppColors.successGreen,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                  _loadData(); // Reload data
                } else if (mounted) {
                  setState(() {
                    isLoading = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to update user status'),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: newStatus == 'suspended' ? Colors.orange : AppColors.successGreen,
                foregroundColor: AppColors.white,
              ),
              child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                    ),
                  )
                : Text(newStatus == 'suspended' ? 'Suspend' : 'Activate'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmUserDeletion(User user) {
    bool isLoading = false;
    final confirmController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(
                Icons.delete_forever,
                color: Colors.red,
                size: 28,
              ),
              SizedBox(width: 12),
              Text(
                'Delete User',
                style: TextStyle(
                  fontFamily: AppConstants.headingFont,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.red.withOpacity(0.2),
                      child: Text(
                        user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.fullName,
                            style: const TextStyle(
                              fontFamily: AppConstants.primaryFont,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.blackText,
                            ),
                          ),
                          Text(
                            user.email,
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
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning, color: Colors.amber, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Warning: This action cannot be undone!',
                        style: TextStyle(
                          fontFamily: AppConstants.primaryFont,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.amber,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'This will permanently delete the user account and all associated data. The user will be unable to access the app and all their information will be lost.',
                style: TextStyle(
                  fontFamily: AppConstants.primaryFont,
                  fontSize: 14,
                  color: AppColors.grayText,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Type "DELETE" to confirm:',
                style: TextStyle(
                  fontFamily: AppConstants.primaryFont,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.blackText,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: confirmController,
                onChanged: (value) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Type DELETE to confirm',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                style: const TextStyle(
                  fontFamily: AppConstants.primaryFont,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isLoading || confirmController.text != 'DELETE' ? null : () async {
                setState(() {
                  isLoading = true;
                });
                
                final success = await UserManagementService.deleteUser(user.id!);
                
                if (success && mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('User deleted successfully'),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                    ),
                  );
                  _loadData(); // Reload data
                } else if (mounted) {
                  setState(() {
                    isLoading = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to delete user'),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: AppColors.white,
                disabledBackgroundColor: Colors.grey.withOpacity(0.3),
              ),
              child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                    ),
                  )
                : const Text('Delete User'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: AppConstants.headingFont,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.blackText,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primaryBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.successGreen.withOpacity(0.2)),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon,
      {TextInputType keyboardType = TextInputType.text, bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: AppConstants.primaryFont,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.grayText,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          enabled: enabled,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: enabled ? AppColors.successGreen : AppColors.grayText),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.grayText),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.successGreen, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.grayText.withOpacity(0.3)),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.grayText.withOpacity(0.2)),
            ),
            filled: true,
            fillColor: enabled ? AppColors.white : AppColors.grayText.withOpacity(0.1),
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          ),
          style: TextStyle(
            fontFamily: AppConstants.primaryFont,
            fontSize: 14,
            color: enabled ? AppColors.blackText : AppColors.grayText,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, String value, List<String> options, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: AppConstants.primaryFont,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.grayText,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.grayText),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.successGreen, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.grayText.withOpacity(0.3)),
            ),
            filled: true,
            fillColor: AppColors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          ),
          items: options.map((String option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(
                option,
                style: const TextStyle(
                  fontFamily: AppConstants.primaryFont,
                  fontSize: 14,
                  color: AppColors.blackText,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: AppConstants.headingFont,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.blackText,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primaryBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.successGreen.withOpacity(0.2)),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.successGreen),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: AppConstants.primaryFont,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.grayText,
                  ),
                ),
                Flexible(
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontFamily: AppConstants.primaryFont,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.blackText,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRowWithColor(IconData icon, String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.successGreen),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: AppConstants.primaryFont,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.grayText,
                  ),
                ),
                Flexible(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontFamily: AppConstants.primaryFont,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: valueColor,
                    ),
                    overflow: TextOverflow.ellipsis,
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
