import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants.dart';
import '../../../services/consultation_management_service.dart';

class ManageProfessionalsPage extends StatefulWidget {
  const ManageProfessionalsPage({super.key});

  @override
  State<ManageProfessionalsPage> createState() => _ManageProfessionalsPageState();
}

class _ManageProfessionalsPageState extends State<ManageProfessionalsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = 'All';
  bool _isLoading = true;
  List<Map<String, dynamic>> _professionals = [];
  Map<String, dynamic> _stats = {};
  
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
      // Load stats and professionals concurrently
      final results = await Future.wait([
        ConsultationManagementService.getProfessionalStats(),
        ConsultationManagementService.getAllProfessionals(
          status: _selectedStatus == 'All' ? null : _selectedStatus.toLowerCase(),
          searchTerm: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
        ),
      ]);

      setState(() {
        _stats = results[0] as Map<String, dynamic>;
        _professionals = results[1] as List<Map<String, dynamic>>;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading professionals data: $e');
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

  void _filterByStatus(String status) {
    setState(() {
      _selectedStatus = status;
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
          // Title
          const Text(
            'Manage Healthcare Professionals',
            style: TextStyle(
              fontFamily: AppConstants.headingFont,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.blackText,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Search and Filter
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by name, email, or specialization...',
                    hintStyle: const TextStyle(
                      fontFamily: AppConstants.primaryFont,
                      color: AppColors.grayText,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.grayText,
                    ),
                    suffixIcon: IconButton(
                      onPressed: _performSearch,
                      icon: const Icon(
                        Icons.search,
                        color: AppColors.successGreen,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.successGreen.withOpacity(0.3),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.successGreen.withOpacity(0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.successGreen,
                        width: 2,
                      ),
                    ),
                  ),
                  onSubmitted: (_) => _performSearch(),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.successGreen.withOpacity(0.3),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButton<String>(
                  value: _selectedStatus,
                  underline: const SizedBox(),
                  onChanged: (value) {
                    if (value != null) {
                      _filterByStatus(value);
                    }
                  },
                  items: const [
                    DropdownMenuItem(value: 'All', child: Text('All Status')),
                    DropdownMenuItem(value: 'Verified', child: Text('Verified')),
                    DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                    DropdownMenuItem(value: 'Suspended', child: Text('Suspended')),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Statistics
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Professionals',
                  _stats['totalProfessionals']?.toString() ?? '0',
                  Icons.people,
                  AppColors.successGreen,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Verified',
                  _stats['verifiedProfessionals']?.toString() ?? '0',
                  Icons.verified,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Pending Review',
                  _stats['pendingProfessionals']?.toString() ?? '0',
                  Icons.pending,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Active Consults',
                  _stats['activeConsultations']?.toString() ?? '0',
                  Icons.medical_services,
                  AppColors.primaryAccent,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          const Text(
            'Healthcare Professionals',
            style: TextStyle(
              fontFamily: AppConstants.headingFont,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.blackText,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Professional Cards
          if (_professionals.isEmpty)
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
                    Icons.medical_services_outlined,
                    size: 64,
                    color: AppColors.grayText.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No professionals found',
                    style: TextStyle(
                      fontFamily: AppConstants.primaryFont,
                      fontSize: 16,
                      color: AppColors.grayText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Try adjusting your search or filter criteria.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppConstants.primaryFont,
                      fontSize: 14,
                      color: AppColors.grayText,
                    ),
                  ),
                ],
              ),
            )
          else
            ..._professionals.map((professional) => _buildProfessionalCard(professional)),
        ],
      ),
    );
  }
  
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(12),
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
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 16,
                ),
              ),
              const Spacer(),
              Flexible(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontFamily: AppConstants.headingFont,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.blackText,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
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
  
  Widget _buildProfessionalCard(Map<String, dynamic> professional) {
    final fullName = professional['full_name'] ?? 'Unknown';
    final specialization = professional['specialization'] ?? 'Not specified';
    final licenseNumber = professional['license_number'] ?? 'Not provided';
    final yearsExperience = professional['years_experience'] ?? 0;
    final consultationFee = professional['consultation_fee'] ?? 0.0;
    final isVerified = professional['is_verified'] ?? false;
    final accountStatus = professional['account_status'] ?? 'active';
    final createdAt = professional['created_at'] as Timestamp?;
    final totalConsultations = professional['total_consultations'] ?? 0;
    final averageRating = professional['average_rating'] ?? 0.0;
    
    String status = accountStatus == 'suspended' ? 'Suspended' :
                   isVerified ? 'Verified' : 'Pending';
    
    String joinDate = createdAt != null 
        ? ConsultationManagementService.formatDate(createdAt)
        : 'Unknown';

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
              fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U',
              style: const TextStyle(
                fontFamily: AppConstants.primaryFont,
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
                    Expanded(
                      child: Text(
                        'Dr. $fullName',
                        style: const TextStyle(
                          fontFamily: AppConstants.primaryFont,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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
                    color: AppColors.successGreen,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'License: $licenseNumber',
                            style: const TextStyle(
                              fontFamily: AppConstants.primaryFont,
                              fontSize: 10,
                              color: AppColors.grayText,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Experience: $yearsExperience years',
                            style: const TextStyle(
                              fontFamily: AppConstants.primaryFont,
                              fontSize: 10,
                              color: AppColors.grayText,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Fee: ₱${consultationFee.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontFamily: AppConstants.primaryFont,
                              fontSize: 10,
                              color: AppColors.grayText,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                size: 12,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 2),
                              Flexible(
                                child: Text(
                                  averageRating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontFamily: AppConstants.primaryFont,
                                    fontSize: 10,
                                    color: AppColors.grayText,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '$totalConsultations consultations',
                            style: const TextStyle(
                              fontFamily: AppConstants.primaryFont,
                              fontSize: 10,
                              color: AppColors.grayText,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Joined: $joinDate',
                            style: const TextStyle(
                              fontFamily: AppConstants.primaryFont,
                              fontSize: 10,
                              color: AppColors.grayText,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              _handleProfessionalAction(value, professional);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'view',
                child: Row(
                  children: [
                    Icon(Icons.visibility, size: 16),
                    SizedBox(width: 8),
                    Text('View Details'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: isVerified ? 'unverify' : 'verify',
                child: Row(
                  children: [
                    Icon(
                      isVerified ? Icons.cancel : Icons.verified,
                      size: 16,
                      color: isVerified ? Colors.orange : Colors.green,
                    ),
                    const SizedBox(width: 8),
                    Text(isVerified ? 'Remove Verification' : 'Verify Professional'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: accountStatus == 'suspended' ? 'activate' : 'suspend',
                child: Row(
                  children: [
                    Icon(
                      accountStatus == 'suspended' ? Icons.play_arrow : Icons.block,
                      size: 16,
                      color: accountStatus == 'suspended' ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Text(accountStatus == 'suspended' ? 'Activate Account' : 'Suspend Account'),
                  ],
                ),
              ),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontFamily: AppConstants.primaryFont,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
  
  void _handleProfessionalAction(String action, Map<String, dynamic> professional) async {
    switch (action) {
      case 'view':
        _showProfessionalDetailsDialog(professional);
        break;
      case 'verify':
      case 'unverify':
        _confirmVerificationChange(professional, action == 'verify');
        break;
      case 'suspend':
      case 'activate':
        _confirmStatusChange(professional, action == 'activate' ? 'active' : 'suspended');
        break;
    }
  }

  void _showProfessionalDetailsDialog(Map<String, dynamic> professional) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: AppColors.white,
        contentPadding: EdgeInsets.zero,
        titlePadding: EdgeInsets.zero,
        title: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: AppColors.successGreen,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Text(
            'Professional Details: ${professional['full_name']}',
            style: const TextStyle(
              fontFamily: AppConstants.primaryFont,
              color: AppColors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        content: Container(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                _buildDetailRow('Email', professional['email'] ?? 'Not provided'),
                _buildDetailRow('Phone', professional['phone_number'] ?? 'Not provided'),
                _buildDetailRow('Specialization', professional['specialization'] ?? 'Not specified'),
                _buildDetailRow('License Number', professional['license_number'] ?? 'Not provided'),
                _buildDetailRow('Experience', '${professional['years_experience'] ?? 0} years'),
                _buildDetailRow('Consultation Fee', '₱${(professional['consultation_fee'] ?? 0.0).toStringAsFixed(0)}'),
                _buildDetailRow('Total Consultations', '${professional['total_consultations'] ?? 0}'),
                _buildDetailRow('Average Rating', '${(professional['average_rating'] ?? 0.0).toStringAsFixed(1)} ⭐'),
                _buildDetailRow('Verified', (professional['is_verified'] ?? false) ? 'Yes' : 'No'),
                _buildDetailRow('Account Status', professional['account_status'] ?? 'active'),
                if (professional['bio'] != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBackground,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.successGreen.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bio:',
                          style: TextStyle(
                            fontFamily: AppConstants.primaryFont,
                            fontWeight: FontWeight.bold,
                            color: AppColors.blackText,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          professional['bio'],
                          style: const TextStyle(
                            fontFamily: AppConstants.primaryFont,
                            color: AppColors.grayText,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
              ),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.successGreen,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Close',
                  style: TextStyle(
                    fontFamily: AppConstants.primaryFont,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.primaryBackground.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.successGreen.withOpacity(0.2),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 120,
              child: Text(
                '$label:',
                style: const TextStyle(
                  fontFamily: AppConstants.primaryFont,
                  fontWeight: FontWeight.w600,
                  color: AppColors.successGreen,
                  fontSize: 13,
                ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                  fontFamily: AppConstants.primaryFont,
                  color: AppColors.blackText,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmVerificationChange(Map<String, dynamic> professional, bool verify) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${verify ? 'Verify' : 'Remove Verification'} Professional'),
        content: Text(
          'Are you sure you want to ${verify ? 'verify' : 'remove verification from'} ${professional['full_name']}?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: verify ? AppColors.successGreen : Colors.orange,
            ),
            child: Text(
              verify ? 'Verify' : 'Remove Verification',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ConsultationManagementService.updateProfessionalVerification(
          professionalId: professional['id'],
          isVerified: verify,
          adminNotes: '${verify ? 'Verified' : 'Verification removed'} by admin',
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Professional ${verify ? 'verified' : 'verification removed'} successfully'),
            backgroundColor: AppColors.successGreen,
          ),
        );

        _loadData(); // Refresh data
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update verification: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _confirmStatusChange(Map<String, dynamic> professional, String newStatus) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${newStatus == 'active' ? 'Activate' : 'Suspend'} Account'),
        content: Text(
          'Are you sure you want to ${newStatus == 'active' ? 'activate' : 'suspend'} ${professional['full_name']}\'s account?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: newStatus == 'active' ? AppColors.successGreen : Colors.red,
            ),
            child: Text(
              newStatus == 'active' ? 'Activate' : 'Suspend',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ConsultationManagementService.updateProfessionalStatus(
          professionalId: professional['id'],
          status: newStatus,
          reason: 'Account ${newStatus == 'active' ? 'activated' : 'suspended'} by admin',
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Account ${newStatus == 'active' ? 'activated' : 'suspended'} successfully'),
            backgroundColor: AppColors.successGreen,
          ),
        );

        _loadData(); // Refresh data
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
