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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('User Details: ${user.fullName}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Email: ${user.email}'),
              Text('Role: ${user.role.toUpperCase()}'),
              Text('Gender: ${user.gender}'),
              Text('Age: ${user.age} years'),
              if (user.phoneNumber != null) Text('Phone: ${user.phoneNumber}'),
              if (user.specialization != null) Text('Specialization: ${user.specialization}'),
              Text('BMI: ${user.bmi?.toStringAsFixed(1) ?? user.calculatedBmi.toStringAsFixed(1)}'),
              Text('Household Size: ${user.householdSize}'),
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

  void _showEditUserDialog(User user) {
    // Placeholder for edit functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Edit functionality for ${user.fullName} - Coming Soon'),
        backgroundColor: AppColors.successGreen,
      ),
    );
  }

  void _confirmUserStatusChange(User user, String newStatus) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${newStatus == 'suspended' ? 'Suspend' : 'Activate'} User'),
        content: Text(
          'Are you sure you want to ${newStatus == 'suspended' ? 'suspend' : 'activate'} ${user.fullName}?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await UserManagementService.updateUserStatus(user.id!, newStatus);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('User ${newStatus == 'suspended' ? 'suspended' : 'activated'} successfully'),
                    backgroundColor: AppColors.successGreen,
                  ),
                );
                _loadData(); // Reload data
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to update user status'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text(newStatus == 'suspended' ? 'Suspend' : 'Activate'),
          ),
        ],
      ),
    );
  }

  void _confirmUserDeletion(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete ${user.fullName}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await UserManagementService.deleteUser(user.id!);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('User deleted successfully'),
                    backgroundColor: AppColors.successGreen,
                  ),
                );
                _loadData(); // Reload data
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to delete user'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
