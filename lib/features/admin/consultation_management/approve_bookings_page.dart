import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants.dart';
import '../../../services/consultation_management_service.dart';

class ApproveBookingsPage extends StatefulWidget {
  const ApproveBookingsPage({super.key});

  @override
  State<ApproveBookingsPage> createState() => _ApproveBookingsPageState();
}

class _ApproveBookingsPageState extends State<ApproveBookingsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = 'All';
  bool _isLoading = true;
  List<Map<String, dynamic>> _consultations = [];
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
      // Load consultation stats and bookings concurrently
      final results = await Future.wait([
        ConsultationManagementService.getConsultationStats(),
        ConsultationManagementService.getConsultationBookings(
          status: _selectedStatus == 'All' ? null : _selectedStatus.toLowerCase(),
          searchTerm: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
        ),
      ]);

      setState(() {
        _stats = results[0] as Map<String, dynamic>;
        _consultations = results[1] as List<Map<String, dynamic>>;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading consultation data: $e');
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
          // Title and Refresh
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Approve Consultation Bookings',
                style: TextStyle(
                  fontFamily: AppConstants.headingFont,
                  fontSize: 20,
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
          
          // Search and Filter
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by patient name, professional, or topic...',
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
                    DropdownMenuItem(value: 'Scheduled', child: Text('Scheduled')),
                    DropdownMenuItem(value: 'Confirmed', child: Text('Confirmed')),
                    DropdownMenuItem(value: 'In Progress', child: Text('In Progress')),
                    DropdownMenuItem(value: 'Completed', child: Text('Completed')),
                    DropdownMenuItem(value: 'Cancelled', child: Text('Cancelled')),
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
                  'Total Bookings',
                  _stats['totalConsultations']?.toString() ?? '0',
                  Icons.calendar_today,
                  AppColors.successGreen,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Pending Approval',
                  _stats['pendingApproval']?.toString() ?? '0',
                  Icons.pending_actions,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Confirmed Today',
                  _stats['todayConfirmed']?.toString() ?? '0',
                  Icons.today,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Completed',
                  _stats['completedConsultations']?.toString() ?? '0',
                  Icons.done,
                  AppColors.primaryAccent,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Consultation Bookings',
                style: TextStyle(
                  fontFamily: AppConstants.headingFont,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.blackText,
                ),
              ),
              Text(
                '${_consultations.length} bookings found',
                style: const TextStyle(
                  fontFamily: AppConstants.primaryFont,
                  fontSize: 14,
                  color: AppColors.grayText,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Consultation Cards
          if (_consultations.isEmpty)
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
                    Icons.event_note_outlined,
                    size: 64,
                    color: AppColors.grayText.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No consultation bookings found',
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
            ..._consultations.map((consultation) => _buildConsultationCard(consultation)),
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
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 18,
                ),
              ),
              const Spacer(),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: AppConstants.headingFont,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.blackText,
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
                fontSize: 12,
                color: AppColors.grayText,
              ),
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildConsultationCard(Map<String, dynamic> consultation) {
    final patientName = consultation['patient_name'] ?? 'Unknown Patient';
    final professionalName = consultation['professional_name'] ?? 'Unknown Professional';
    final professionalSpecialization = consultation['professional_specialization'] ?? 'Healthcare Professional';
    final consultationDate = consultation['consultation_date'] as Timestamp?;
    final consultationTime = consultation['consultation_time'] ?? 'Not specified';
    final topic = consultation['topic'] ?? 'General consultation';
    final status = consultation['status'] ?? 'Scheduled';
    final referenceNo = consultation['reference_no'] ?? 'N/A';
    final duration = consultation['duration'] ?? 30;
    final createdAt = consultation['created_at'] as Timestamp?;
    final patientAge = consultation['patient_age'];
    final patientContact = consultation['patient_contact'] ?? 'Not provided';
    
    String formattedDate = consultationDate != null 
        ? ConsultationManagementService.formatDate(consultationDate)
        : 'Not specified';
    
    String bookingDate = createdAt != null 
        ? ConsultationManagementService.formatDate(createdAt)
        : 'Unknown';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.successGreen.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.person,
                          size: 16,
                          color: AppColors.successGreen,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            patientName,
                            style: const TextStyle(
                              fontFamily: AppConstants.primaryFont,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.blackText,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.medical_services,
                          size: 14,
                          color: AppColors.grayText,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Dr. $professionalName ($professionalSpecialization)',
                            style: const TextStyle(
                              fontFamily: AppConstants.primaryFont,
                              fontSize: 13,
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
              _buildStatusBadge(status),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Consultation Details
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailItem(Icons.calendar_today, 'Date', formattedDate),
                          const SizedBox(height: 8),
                          _buildDetailItem(Icons.access_time, 'Time', consultationTime),
                          const SizedBox(height: 8),
                          _buildDetailItem(Icons.timer, 'Duration', '$duration minutes'),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailItem(Icons.confirmation_number, 'Reference', referenceNo),
                          const SizedBox(height: 8),
                          if (patientAge != null)
                            _buildDetailItem(Icons.cake, 'Age', '$patientAge years'),
                          const SizedBox(height: 8),
                          _buildDetailItem(Icons.contact_mail, 'Contact', patientContact),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildDetailItem(Icons.topic, 'Topic', topic),
                const SizedBox(height: 8),
                _buildDetailItem(Icons.schedule, 'Booked', bookingDate),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showConsultationDetails(consultation),
                  icon: const Icon(
                    Icons.visibility,
                    size: 16,
                    color: AppColors.successGreen,
                  ),
                  label: const Text(
                    'View Details',
                    style: TextStyle(
                      color: AppColors.successGreen,
                      fontSize: 12,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.successGreen),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              if (status == 'Scheduled') ...[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _confirmConsultation(consultation),
                    icon: const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Confirm',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.successGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _cancelConsultation(consultation),
                    icon: const Icon(
                      Icons.close,
                      size: 16,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ] else if (status == 'Confirmed') ...[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _markInProgress(consultation),
                    icon: const Icon(
                      Icons.play_arrow,
                      size: 16,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Start Session',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ] else if (status == 'In Progress') ...[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _completeConsultation(consultation),
                    icon: const Icon(
                      Icons.done,
                      size: 16,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Complete',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 14,
          color: AppColors.grayText,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: AppConstants.primaryFont,
                  fontSize: 11,
                  color: AppColors.grayText,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: AppConstants.primaryFont,
                  fontSize: 12,
                  color: AppColors.blackText,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildStatusBadge(String status) {
    Color color;
    IconData icon;
    
    switch (status.toLowerCase()) {
      case 'scheduled':
        color = Colors.orange;
        icon = Icons.schedule;
        break;
      case 'confirmed':
        color = AppColors.successGreen;
        icon = Icons.check_circle;
        break;
      case 'in progress':
        color = Colors.blue;
        icon = Icons.play_circle;
        break;
      case 'completed':
        color = AppColors.primaryAccent;
        icon = Icons.done_all;
        break;
      case 'cancelled':
        color = Colors.red;
        icon = Icons.cancel;
        break;
      default:
        color = AppColors.grayText;
        icon = Icons.help;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              fontFamily: AppConstants.primaryFont,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showConsultationDetails(Map<String, dynamic> consultation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Consultation Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Patient', consultation['patient_name'] ?? 'Unknown'),
              _buildDetailRow('Professional', 'Dr. ${consultation['professional_name'] ?? 'Unknown'}'),
              _buildDetailRow('Specialization', consultation['professional_specialization'] ?? 'Not specified'),
              _buildDetailRow('Date', consultation['consultation_date'] != null 
                  ? ConsultationManagementService.formatDate(consultation['consultation_date'])
                  : 'Not specified'),
              _buildDetailRow('Time', consultation['consultation_time'] ?? 'Not specified'),
              _buildDetailRow('Duration', '${consultation['duration'] ?? 30} minutes'),
              _buildDetailRow('Reference No.', consultation['reference_no'] ?? 'N/A'),
              _buildDetailRow('Status', consultation['status'] ?? 'Unknown'),
              _buildDetailRow('Patient Contact', consultation['patient_contact'] ?? 'Not provided'),
              if (consultation['patient_age'] != null)
                _buildDetailRow('Patient Age', '${consultation['patient_age']} years'),
              if (consultation['topic'] != null) ...[
                const SizedBox(height: 16),
                const Text(
                  'Consultation Topic:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(consultation['topic']),
              ],
              if (consultation['notes'] != null && consultation['notes'].isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Notes:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(consultation['notes']),
              ],
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.grayText,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.blackText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmConsultation(Map<String, dynamic> consultation) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Consultation'),
        content: Text(
          'Confirm consultation for ${consultation['patient_name']} with Dr. ${consultation['professional_name']}?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.successGreen,
            ),
            child: const Text(
              'Confirm',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ConsultationManagementService.updateConsultationStatus(
          consultationId: consultation['id'],
          newStatus: 'Confirmed',
          adminNotes: 'Consultation confirmed by admin',
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Consultation confirmed successfully'),
            backgroundColor: AppColors.successGreen,
          ),
        );

        _loadData(); // Refresh data
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to confirm consultation: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _cancelConsultation(Map<String, dynamic> consultation) async {
    final TextEditingController reasonController = TextEditingController();
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Consultation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cancel consultation for ${consultation['patient_name']} with Dr. ${consultation['professional_name']}?'
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Cancellation Reason',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text(
              'Cancel Consultation',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ConsultationManagementService.updateConsultationStatus(
          consultationId: consultation['id'],
          newStatus: 'Cancelled',
          adminNotes: 'Consultation cancelled by admin. Reason: ${reasonController.text.trim()}',
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Consultation cancelled successfully'),
            backgroundColor: AppColors.successGreen,
          ),
        );

        _loadData(); // Refresh data
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to cancel consultation: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _markInProgress(Map<String, dynamic> consultation) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start Consultation Session'),
        content: Text(
          'Mark consultation as "In Progress" for ${consultation['patient_name']}?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
            ),
            child: const Text(
              'Start Session',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ConsultationManagementService.updateConsultationStatus(
          consultationId: consultation['id'],
          newStatus: 'In Progress',
          adminNotes: 'Consultation session started',
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Consultation session started'),
            backgroundColor: AppColors.successGreen,
          ),
        );

        _loadData(); // Refresh data
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start session: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _completeConsultation(Map<String, dynamic> consultation) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Consultation'),
        content: Text(
          'Mark consultation as "Completed" for ${consultation['patient_name']}?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryAccent,
            ),
            child: const Text(
              'Complete',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ConsultationManagementService.updateConsultationStatus(
          consultationId: consultation['id'],
          newStatus: 'Completed',
          adminNotes: 'Consultation completed successfully',
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Consultation completed successfully'),
            backgroundColor: AppColors.successGreen,
          ),
        );

        _loadData(); // Refresh data
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to complete consultation: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
