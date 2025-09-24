import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/professional_service.dart';
import '../../../models/user.dart';

// Add blackText color extension
extension AppColorsExtension on AppColors {
  static const Color blackText = Color(0xFF2D2D2D);
}

class ConsultationDashboardPage extends StatefulWidget {
  const ConsultationDashboardPage({super.key});

  @override
  State<ConsultationDashboardPage> createState() => _ConsultationDashboardPageState();
}

class _ConsultationDashboardPageState extends State<ConsultationDashboardPage> {
  final ProfessionalService _professionalService = ProfessionalService();
  
  User? _currentProfessional;
  Map<String, dynamic> _dashboardStats = {
    'todayConsultations': 0,
    'weeklyConsultations': 0,
    'totalPatients': 0,
    'rating': 0,
  };
  List<Map<String, dynamic>> _todayConsultations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    
    try {
      // Load professional data
      _currentProfessional = await _professionalService.getCurrentProfessional();
      
      // Load dashboard stats
      _dashboardStats = await _professionalService.getDashboardStats();
      
      // Load today's consultations
      _todayConsultations = await _professionalService.getTodaysConsultations();
      
    } catch (e) {
      print('Error loading dashboard data: $e');
      // Keep default/empty values on error
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
                    // Dashboard Stats
                    _buildDashboardStats(),
                    const SizedBox(height: 24),
                    
                    // Quick Actions
                    _buildQuickActions(),
                    const SizedBox(height: 24),
                    
                    // Today's Consultations
                    _buildTodaysConsultations(),
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
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Good Morning!',
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 16,
                      color: AppColors.white.withOpacity(0.9),
                    ),
                  ),
                  Text(
                    _currentProfessional?.fullName ?? 'Professional',
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
              // Profile Avatar
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: AppColors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.person,
                    color: AppColors.white,
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Quick overview cards
          Row(
            children: [
              Expanded(
                child: _buildHeaderCard(
                  'Today',
                  _dashboardStats['todayConsultations'].toString(),
                  Icons.today,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildHeaderCard(
                  'This Week',
                  _dashboardStats['weeklyConsultations'].toString(),
                  Icons.calendar_month,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.white,
            size: 24,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'OpenSans',
                  fontSize: 12,
                  color: AppColors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: TextStyle(
            fontFamily: 'Lato',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColorsExtension.blackText,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Patients',
                _dashboardStats['totalPatients'].toString(),
                Icons.people_outline,
                AppColors.primaryAccent,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Rating',
                _dashboardStats['rating'].toString(),
                Icons.star_outline,
                AppColors.successGreen,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Lato',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColorsExtension.blackText,
            ),
          ),
          Text(
            title,
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

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontFamily: 'Lato',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColorsExtension.blackText,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                'Set Availability',
                'Manage your schedule',
                Icons.schedule_outlined,
                AppColors.successGreen,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionCard(
                'Patient Notes',
                'View consultation history',
                Icons.note_alt_outlined,
                AppColors.primaryAccent,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(String title, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Icon(
                icon,
                color: AppColors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Lato',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColorsExtension.blackText,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontFamily: 'OpenSans',
              fontSize: 12,
              color: AppColors.grayText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodaysConsultations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Today\'s Consultations',
              style: TextStyle(
                fontFamily: 'Lato',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColorsExtension.blackText,
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to full schedule
              },
              child: Text(
                'View All',
                style: TextStyle(
                  fontFamily: 'OpenSans',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.successGreen,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...(_todayConsultations.isEmpty ? [_buildEmptyState()] : _todayConsultations.map((consultation) =>
            _buildConsultationCard(consultation)
        ).toList()),
      ],
    );
  }

  Widget _buildConsultationCard(Map<String, dynamic> consultation) {
    // Generate avatar initials from patient name
    String getInitials(String name) {
      final parts = name.split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return parts[0].length >= 2 ? parts[0].substring(0, 2).toUpperCase() : parts[0][0].toUpperCase();
    }

    final patientName = consultation['patient_name'] ?? 'Unknown Patient';
    final consultationTime = consultation['consultation_time'] ?? 'Time TBD';
    final topic = consultation['topic'] ?? 'General consultation';
    final status = consultation['status'] ?? 'Scheduled';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Row(
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
                getInitials(patientName),
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
          // Consultation Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      patientName,
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColorsExtension.blackText,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: status == 'Completed' 
                            ? AppColors.successGreen.withOpacity(0.1)
                            : AppColors.primaryAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontFamily: 'OpenSans',
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: status == 'Completed' 
                              ? AppColors.successGreen
                              : AppColors.primaryAccent,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  topic,
                  style: TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 13,
                    color: AppColors.grayText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  consultationTime,
                  style: TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColorsExtension.blackText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.event_available_outlined,
            size: 64,
            color: AppColors.grayText.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Consultations Today',
            style: TextStyle(
              fontFamily: 'Lato',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.grayText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your consultation schedule is clear for today',
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
}