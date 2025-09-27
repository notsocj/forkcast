import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants.dart';

class ManageUsersPage extends StatefulWidget {
  const ManageUsersPage({super.key});

  @override
  State<ManageUsersPage> createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedUserType = 'All';
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                child: _buildStatCard('Total Users', '1,234', Icons.people, AppColors.successGreen),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard('Active Users', '89', Icons.person, Colors.blue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard('New Users', '23', Icons.person_add, Colors.orange),
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
          const Text(
            'User Accounts',
            style: TextStyle(
              fontFamily: AppConstants.headingFont,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.blackText,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Users List
          ...List.generate(5, (index) => _buildUserCard(
            name: _getUserName(index),
            email: _getUserEmail(index),
            role: _getUserRole(index),
            status: _getUserStatus(index),
            joinDate: _getJoinDate(index),
          )),
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
          setState(() {
            _selectedUserType = value;
          });
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
  
  Widget _buildUserCard({
    required String name,
    required String email,
    required String role,
    required String status,
    required String joinDate,
  }) {
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
              name[0].toUpperCase(),
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
                  name,
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
                  email,
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
                    _buildRoleBadge(role),
                    _buildStatusBadge(status),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              _handleUserAction(value, name);
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
              const PopupMenuItem(
                value: 'suspend',
                child: Text('Suspend User'),
              ),
            ],
          ),
        ],
      ),
    );
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
  
  void _handleUserAction(String action, String userName) {
    // Handle user actions (placeholder)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$action action for $userName')),
    );
  }
  
  String _getUserName(int index) {
    final names = ['Maria Santos', 'Juan dela Cruz', 'Dr. Ana Garcia', 'Carlos Reyes', 'Lisa Tan'];
    return names[index];
  }
  
  String _getUserEmail(int index) {
    final emails = ['maria@example.com', 'juan@example.com', 'dr.ana@clinic.com', 'carlos@example.com', 'lisa@example.com'];
    return emails[index];
  }
  
  String _getUserRole(int index) {
    final roles = ['user', 'user', 'professional', 'user', 'admin'];
    return roles[index];
  }
  
  String _getUserStatus(int index) {
    final statuses = ['Active', 'Active', 'Active', 'Pending', 'Active'];
    return statuses[index];
  }
  
  String _getJoinDate(int index) {
    final dates = ['2024-01-15', '2024-02-20', '2024-03-10', '2024-03-25', '2024-01-05'];
    return dates[index];
  }
}
