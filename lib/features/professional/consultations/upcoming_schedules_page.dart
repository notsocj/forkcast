import 'package:flutter/material.dart';
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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUpcomingSchedules();
  }

  Future<void> _loadUpcomingSchedules() async {
    setState(() => _isLoading = true);
    
    try {
      _upcomingAppointments = await _professionalService.getUpcomingConsultations();
    } catch (e) {
      print('Error loading upcoming schedules: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.primaryBackground,
        body: const Center(
          child: CircularProgressIndicator(
            color: AppColors.successGreen,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            // Content
            Expanded(
              child: SingleChildScrollView(
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
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: BoxDecoration(
        color: AppColors.successGreen,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back,
              color: AppColors.white,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Upcoming Schedules',
            style: TextStyle(
              fontFamily: 'Lato',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStats() {
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
              value: '2',
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
              value: '4',
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
              value: '1',
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
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.successGreen,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'All',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Today',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grayText,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Week',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grayText,
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
        if (_upcomingAppointments.isEmpty)
          _buildEmptySchedule()
        else
          ..._upcomingAppointments.map((appointment) => 
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
                    appointment['avatar'],
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
                          appointment['patientName'],
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
                      'Age: ${appointment['patientAge']}',
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
                      '${appointment['date']} • ${appointment['time']}',
                      style: TextStyle(
                        fontFamily: 'OpenSans',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.blackText,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      appointment['duration'],
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
                        appointment['topic'],
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
            'No Upcoming Appointments',
            style: TextStyle(
              fontFamily: 'Lato',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.grayText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your schedule is currently clear',
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
              'Name: ${appointment['patientName']}',
              style: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 14,
                color: AppColors.blackText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Age: ${appointment['patientAge']} years',
              style: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 14,
                color: AppColors.blackText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Contact: ${appointment['contactInfo']}',
              style: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 14,
                color: AppColors.blackText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Consultation Topic: ${appointment['topic']}',
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
          'Starting consultation with ${appointment['patientName']}. You will be connected shortly.',
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
}