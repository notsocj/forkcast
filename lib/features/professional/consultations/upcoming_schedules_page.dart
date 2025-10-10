import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/professional_service.dart';

// Add blackText color extension
extension AppColorsExtension on AppColors {
  static const Color blackText = Color(0xFF2D2D2D);
}

class UpcomingSchedulesPage extends StatefulWidget {
  const UpcomingSchedulesPage({super.key});

  @override
  State<UpcomingSchedulesPage> createState() => _UpcomingSchedulesPageState();
}

class _UpcomingSchedulesPageState extends State<UpcomingSchedulesPage> {
  final ProfessionalService _professionalService = ProfessionalService();
  List<Map<String, dynamic>> _upcomingAppointments = [];
  List<Map<String, dynamic>> _filteredAppointments = [];
  bool _isLoading = true;
  int _selectedFilterIndex = 0; // 0: All, 1: Today, 2: Week

  @override
  void initState() {
    super.initState();
    _loadUpcomingSchedules();
  }

  Future<void> _loadUpcomingSchedules() async {
    setState(() => _isLoading = true);
    
    try {
      _upcomingAppointments = await _professionalService.getUpcomingConsultations();
      _applyFilter();
    } catch (e) {
      print('Error loading upcoming schedules: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _applyFilter() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = today.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 7));

    switch (_selectedFilterIndex) {
      case 0: // All
        _filteredAppointments = _upcomingAppointments;
        break;
      case 1: // Today
        _filteredAppointments = _upcomingAppointments.where((appointment) {
          if (appointment['consultation_date'] == null) return false;
          try {
            final timestamp = appointment['consultation_date'] as Timestamp;
            final appointmentDate = timestamp.toDate();
            final appointmentDay = DateTime(appointmentDate.year, appointmentDate.month, appointmentDate.day);
            return appointmentDay == today;
          } catch (e) {
            return false;
          }
        }).toList();
        break;
      case 2: // Week
        _filteredAppointments = _upcomingAppointments.where((appointment) {
          if (appointment['consultation_date'] == null) return false;
          try {
            final timestamp = appointment['consultation_date'] as Timestamp;
            final appointmentDate = timestamp.toDate();
            return appointmentDate.isAfter(weekStart.subtract(const Duration(days: 1))) && 
                   appointmentDate.isBefore(weekEnd);
          } catch (e) {
            return false;
          }
        }).toList();
        break;
    }
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.successGreen,
            AppColors.successGreen.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.successGreen.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.schedule,
              color: AppColors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upcoming Schedules',
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage your appointments',
                  style: TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 14,
                    color: AppColors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onFilterChanged(int index) {
    setState(() {
      _selectedFilterIndex = index;
      _applyFilter();
    });
  }

  String _formatDateTime(Map<String, dynamic> appointment) {
    if (appointment['consultation_date'] == null) return 'N/A';
    
    try {
      final timestamp = appointment['consultation_date'] as Timestamp;
      final date = timestamp.toDate();
      
      // Format: "Jun 27, 2025"
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    } catch (e) {
      return 'N/A';
    }
  }

  String _formatTime(Map<String, dynamic> appointment) {
    // consultation_time is stored as string in Firebase (e.g., "11:00 AM")
    return appointment['consultation_time'] ?? 'N/A';
  }

  String _getPatientInitial(String? patientName) {
    if (patientName == null || patientName.isEmpty) return 'P';
    return patientName[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.successGreen,
        body: const Center(
          child: CircularProgressIndicator(
            color: AppColors.white,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.successGreen,
      body: SafeArea(
        child: Column(
          children: [
            // Green Header
            _buildHeader(),
            // White Content Container
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: RefreshIndicator(
                  color: AppColors.successGreen,
                  onRefresh: _loadUpcomingSchedules,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Summary Stats
                        _buildSummaryStats(),
                        const SizedBox(height: 24),
                        
                        // Filter Tabs
                        _buildFilterTabs(),
                        const SizedBox(height: 24),
                        
                        // Appointments List
                        _buildAppointmentsList(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryStats() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = today.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 7));

    // Calculate today's appointments
    final todayAppointments = _upcomingAppointments.where((appointment) {
      if (appointment['consultation_date'] == null) return false;
      try {
        final timestamp = appointment['consultation_date'] as Timestamp;
        final appointmentDate = timestamp.toDate();
        final appointmentDay = DateTime(appointmentDate.year, appointmentDate.month, appointmentDate.day);
        return appointmentDay == today;
      } catch (e) {
        return false;
      }
    }).length;

    // Calculate this week's appointments
    final weekAppointments = _upcomingAppointments.where((appointment) {
      if (appointment['consultation_date'] == null) return false;
      try {
        final timestamp = appointment['consultation_date'] as Timestamp;
        final appointmentDate = timestamp.toDate();
        return appointmentDate.isAfter(weekStart.subtract(const Duration(days: 1))) && 
               appointmentDate.isBefore(weekEnd);
      } catch (e) {
        return false;
      }
    }).length;

    // Calculate pending appointments (scheduled status)
    final pendingAppointments = _upcomingAppointments.where((appointment) {
      return appointment['status'] == 'Scheduled';
    }).length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              icon: Icons.schedule,
              title: 'Today',
              value: todayAppointments.toString(),
              subtitle: 'Appointments',
              color: AppColors.primaryAccent,
            ),
          ),
          Container(
            width: 1,
            height: 50,
            color: AppColors.lightGray,
          ),
          Expanded(
            child: _buildStatItem(
              icon: Icons.calendar_month,
              title: 'This Week',
              value: weekAppointments.toString(),
              subtitle: 'Appointments',
              color: AppColors.successGreen,
            ),
          ),
          Container(
            width: 1,
            height: 50,
            color: AppColors.lightGray,
          ),
          Expanded(
            child: _buildStatItem(
              icon: Icons.pending_actions,
              title: 'Pending',
              value: pendingAppointments.toString(),
              subtitle: 'Confirmations',
              color: Colors.amber,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 12,
            color: AppColors.grayText,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Lato',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.blackText,
          ),
        ),
        Text(
          subtitle,
          style: TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 10,
            color: AppColors.grayText,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.successGreen.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _onFilterChanged(0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedFilterIndex == 0 ? AppColors.successGreen : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'All',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _selectedFilterIndex == 0 ? AppColors.white : AppColors.grayText,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => _onFilterChanged(1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Today',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _selectedFilterIndex == 1 ? AppColors.white : AppColors.grayText,
                  ),
                ),
                decoration: BoxDecoration(
                  color: _selectedFilterIndex == 1 ? AppColors.successGreen : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => _onFilterChanged(2),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Week',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _selectedFilterIndex == 2 ? AppColors.white : AppColors.grayText,
                  ),
                ),
                decoration: BoxDecoration(
                  color: _selectedFilterIndex == 2 ? AppColors.successGreen : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upcoming Appointments',
          style: TextStyle(
            fontFamily: 'Lato',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.blackText,
          ),
        ),
        const SizedBox(height: 16),
        if (_filteredAppointments.isEmpty)
          _buildEmptySchedule()
        else
          ..._filteredAppointments.map((appointment) => 
            _buildAppointmentCard(appointment)
          ).toList(),
      ],
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> appointment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Patient Info Row
          Row(
            children: [
              // Patient Avatar
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.successGreen,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Center(
                  child: Text(
                    _getPatientInitial(appointment['patient_name']),
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Patient Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          appointment['patient_name'] ?? 'Unknown Patient',
                          style: TextStyle(
                            fontFamily: 'Lato',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.blackText,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: appointment['status'] == 'Confirmed' 
                                ? AppColors.successGreen.withOpacity(0.1)
                                : Colors.amber.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            appointment['status'],
                            style: TextStyle(
                              fontFamily: 'OpenSans',
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: appointment['status'] == 'Confirmed' 
                                  ? AppColors.successGreen
                                  : Colors.amber.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Age: ${appointment['patient_age'] ?? 'N/A'}',
                      style: TextStyle(
                        fontFamily: 'OpenSans',
                        fontSize: 12,
                        color: AppColors.grayText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Appointment Details
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 16,
                      color: AppColors.grayText,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_formatDateTime(appointment)} • ${_formatTime(appointment)}',
                      style: TextStyle(
                        fontFamily: 'OpenSans',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.blackText,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${appointment['duration'] ?? 60} mins',
                      style: TextStyle(
                        fontFamily: 'OpenSans',
                        fontSize: 12,
                        color: AppColors.grayText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.topic,
                      size: 16,
                      color: AppColors.grayText,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        appointment['topic'] ?? 'General consultation',
                        style: TextStyle(
                          fontFamily: 'OpenSans',
                          fontSize: 13,
                          color: AppColors.grayText,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Action Buttons
          Row(
            children: [
              // Call Button
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    final phoneNumber = appointment['patient_phone'] ?? '';
                    _makePhoneCall(phoneNumber);
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: AppColors.successGreen.withOpacity(0.5),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: Icon(
                    Icons.phone,
                    size: 18,
                    color: AppColors.successGreen,
                  ),
                  label: Text(
                    'Call',
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.successGreen,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Message Button
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    final phoneNumber = appointment['patient_phone'] ?? '';
                    _sendMessage(phoneNumber);
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: Colors.blue.withOpacity(0.5),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: Icon(
                    Icons.message,
                    size: 18,
                    color: Colors.blue,
                  ),
                  label: Text(
                    'Message',
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _showPatientDetails(appointment);
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: AppColors.grayText.withOpacity(0.5),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'View Details',
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grayText,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    _startConsultation(appointment);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.successGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Start Session',
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySchedule() {
    String title;
    String subtitle;
    
    switch (_selectedFilterIndex) {
      case 1: // Today
        title = 'No Appointments Today';
        subtitle = 'You have no consultations scheduled for today';
        break;
      case 2: // Week
        title = 'No Appointments This Week';
        subtitle = 'You have no consultations scheduled this week';
        break;
      default: // All
        title = 'No Upcoming Appointments';
        subtitle = 'Your schedule is currently clear';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.event_available,
            size: 64,
            color: AppColors.grayText.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Lato',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.grayText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'OpenSans',
              fontSize: 14,
              color: AppColors.grayText,
            ),
          ),
        ],
      ),
    );
  }

  void _showPatientDetails(Map<String, dynamic> appointment) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Patient Details',
              style: TextStyle(
                fontFamily: 'Lato',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.blackText,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Name: ${appointment['patient_name'] ?? 'Unknown'}',
              style: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 14,
                color: AppColors.blackText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Age: ${appointment['patient_age'] ?? 'N/A'} years',
              style: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 14,
                color: AppColors.blackText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Phone: ${appointment['patient_phone'] ?? 'Not available'}',
              style: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 14,
                color: AppColors.blackText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Consultation Topic: ${appointment['topic'] ?? 'General consultation'}',
              style: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 14,
                color: AppColors.blackText,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.successGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Close',
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startConsultation(Map<String, dynamic> appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Start Consultation',
          style: TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.bold,
            color: AppColors.blackText,
          ),
        ),
        content: Text(
          'Starting consultation with ${appointment['patient_name'] ?? 'patient'}. You will be connected shortly.',
          style: TextStyle(
            fontFamily: 'OpenSans',
            color: AppColors.grayText,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'OpenSans',
                color: AppColors.grayText,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Integrate with video call functionality
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Starting consultation with ${appointment['patientName']}...',
                    style: TextStyle(color: AppColors.white),
                  ),
                  backgroundColor: AppColors.successGreen,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.successGreen,
            ),
            child: Text(
              'Connect',
              style: TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Launch phone call
  Future<void> _makePhoneCall(String phoneNumber) async {
    if (phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Patient phone number not available'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final Uri launchUri = Uri(
        scheme: 'tel',
        path: phoneNumber,
      );
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not launch phone app'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Error making phone call: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to make call. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Launch SMS app
  Future<void> _sendMessage(String phoneNumber) async {
    if (phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Patient phone number not available'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final Uri launchUri = Uri(
        scheme: 'sms',
        path: phoneNumber,
      );
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not launch messaging app'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Error sending message: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open messaging app. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
