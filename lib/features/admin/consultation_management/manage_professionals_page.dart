import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants.dart';

class ManageProfessionalsPage extends StatefulWidget {
  const ManageProfessionalsPage({super.key});

  @override
  State<ManageProfessionalsPage> createState() => _ManageProfessionalsPageState();
}

class _ManageProfessionalsPageState extends State<ManageProfessionalsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = 'All';
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search and Filter
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
                            hintText: 'Search professionals...',
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
                      value: _selectedStatus,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(value: 'All', child: Text('All Status')),
                        DropdownMenuItem(value: 'Verified', child: Text('Verified')),
                        DropdownMenuItem(value: 'Pending', child: Text('Pending Verification')),
                        DropdownMenuItem(value: 'Suspended', child: Text('Suspended')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedStatus = value!;
                        });
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Statistics
          Row(
            children: [
              Expanded(
                child: _buildStatCard('Total Professionals', '45', Icons.medical_services, AppColors.successGreen),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard('Verified', '32', Icons.verified, Colors.blue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard('Pending', '13', Icons.pending, Colors.orange),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          const Text(
            'Healthcare Professionals',
            style: TextStyle(
              fontFamily: AppConstants.headingFont,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.blackText,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Professional Cards
          ...List.generate(5, (index) => _buildProfessionalCard(
            name: _getProfessionalName(index),
            specialization: _getSpecialization(index),
            license: _getLicense(index),
            experience: _getExperience(index),
            rating: _getRating(index),
            consultations: _getConsultations(index),
            status: _getStatus(index),
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
  
  Widget _buildProfessionalCard({
    required String name,
    required String specialization,
    required String license,
    required int experience,
    required double rating,
    required int consultations,
    required String status,
    required String joinDate,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
                fontSize: 16,
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
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontFamily: AppConstants.primaryFont,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.blackText,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _buildStatusBadge(status),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  specialization,
                  style: const TextStyle(
                    fontFamily: AppConstants.primaryFont,
                    fontSize: 13,
                    color: AppColors.grayText,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'License: $license',
                        style: const TextStyle(
                          fontFamily: AppConstants.primaryFont,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.successGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$experience yrs exp',
                        style: const TextStyle(
                          fontFamily: AppConstants.primaryFont,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.successGreen,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 14),
                    Text(
                      ' ${rating.toStringAsFixed(1)}',
                      style: const TextStyle(
                        fontFamily: AppConstants.primaryFont,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.grayText,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '$consultations consultations',
                        style: const TextStyle(
                          fontFamily: AppConstants.primaryFont,
                          fontSize: 11,
                          color: AppColors.grayText,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              _handleProfessionalAction(value, name);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'view', child: Text('View Profile')),
              const PopupMenuItem(value: 'verify', child: Text('Verify License')),
              const PopupMenuItem(value: 'suspend', child: Text('Suspend Account')),
              const PopupMenuItem(value: 'consultations', child: Text('View Consultations')),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatusBadge(String status) {
    Color color = status == 'Verified' ? AppColors.successGreen : 
                 status == 'Pending' ? Colors.orange : Colors.red;
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
  
  void _handleProfessionalAction(String action, String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$action for Dr. $name')),
    );
  }
  
  String _getProfessionalName(int index) {
    final names = ['Ana Garcia', 'Miguel Santos', 'Sofia Reyes', 'Carlos Mendoza', 'Isabel Cruz'];
    return names[index];
  }
  
  String _getSpecialization(int index) {
    final specializations = ['Registered Nutritionist-Dietitian', 'Clinical Nutritionist', 'Sports Nutritionist', 'Pediatric Nutritionist', 'Geriatric Nutrition Specialist'];
    return specializations[index];
  }
  
  String _getLicense(int index) {
    final licenses = ['RND-2019-001', 'RND-2020-045', 'RND-2018-089', 'RND-2021-012', 'RND-2017-234'];
    return licenses[index];
  }
  
  int _getExperience(int index) {
    final experiences = [8, 5, 12, 3, 15];
    return experiences[index];
  }
  
  double _getRating(int index) {
    final ratings = [4.9, 4.7, 4.8, 4.5, 4.6];
    return ratings[index];
  }
  
  int _getConsultations(int index) {
    final consultations = [156, 89, 234, 45, 312];
    return consultations[index];
  }
  
  String _getStatus(int index) {
    final statuses = ['Verified', 'Verified', 'Verified', 'Pending', 'Verified'];
    return statuses[index];
  }
  
  String _getJoinDate(int index) {
    final dates = ['Jan 2023', 'Mar 2023', 'Nov 2022', 'Jun 2024', 'Aug 2022'];
    return dates[index];
  }
}
