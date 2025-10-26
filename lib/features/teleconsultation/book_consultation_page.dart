import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_colors.dart';
import '../../services/professional_service.dart';
import '../../services/consultation_service.dart';
import 'book_consultation_schedule_page.dart';

class BookConsultationPage extends StatefulWidget {
  const BookConsultationPage({super.key});

  @override
  State<BookConsultationPage> createState() => _BookConsultationPageState();
}

class _BookConsultationPageState extends State<BookConsultationPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final ProfessionalService _professionalService = ProfessionalService();
  final ConsultationService _consultationService = ConsultationService();
  
  List<Map<String, dynamic>> _professionals = [];
  List<Map<String, dynamic>> _appointments = [];
  bool _isLoadingProfessionals = true;
  bool _isLoadingAppointments = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadProfessionals();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    setState(() => _isLoadingAppointments = true);
    
    try {
      final appointments = await _consultationService.getUserConsultations();
      setState(() {
        _appointments = appointments;
        _isLoadingAppointments = false;
      });
    } catch (e) {
      print('BookConsultationPage: Error loading appointments: $e');
      setState(() {
        _appointments = [];
        _isLoadingAppointments = false;
      });
    }
  }

  Future<void> _loadProfessionals() async {
    setState(() => _isLoadingProfessionals = true);
    
    try {
      print('BookConsultationPage: Loading professionals...');
      final professionals = await _professionalService.getAllProfessionalsWithAvailability();
      print('BookConsultationPage: Loaded ${professionals.length} professionals');
      
      setState(() {
        _professionals = professionals;
        _isLoadingProfessionals = false;
      });
    } catch (e) {
      print('BookConsultationPage: Error loading professionals: $e');
      setState(() {
        _professionals = [];
        _isLoadingProfessionals = false;
      });
      
      // Show error message to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load professionals. Please try again.'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _loadProfessionals(),
            ),
          ),
        );
      }
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error making phone call: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.successGreen,
      body: SafeArea(
        child: Column(
          children: [
            // Header with tabs
            _buildHeader(),
            // Main content area
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primaryBackground,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                ),
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildBookConsultationTab(),
                    _buildMyAppointmentsTab(),
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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.successGreen,
            AppColors.successGreen.withOpacity(0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
          child: Column(
            children: [
              // Header with icon and title
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.medical_services_outlined,
                      color: AppColors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Teleconsultation',
                          style: TextStyle(
                            fontFamily: 'Lato',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Book appointments and manage consultations with professionals',
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
              const SizedBox(height: 20),
              // Tab segmentation control
              Container(
                height: 48,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.white.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  indicatorPadding: EdgeInsets.zero,
                  labelPadding: EdgeInsets.zero,
                  labelColor: AppColors.successGreen,
                  unselectedLabelColor: AppColors.white,
                  labelStyle: const TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  dividerColor: Colors.transparent,
                  splashFactory: NoSplash.splashFactory,
                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                  tabs: const [
                    Tab(text: 'Book Consultation'),
                    Tab(text: 'My Appointments'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookConsultationTab() {
    return RefreshIndicator(
      onRefresh: () async {
        await _loadProfessionals();
      },
      color: AppColors.successGreen,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Search bar
                  _buildSearchBar(),
                  const SizedBox(height: 24),
                  // Status indicator
                  if (_isLoadingProfessionals)
                    Container(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: AppColors.successGreen,
                              strokeWidth: 2,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Loading professionals...',
                            style: TextStyle(
                              fontFamily: 'Lato',
                              fontSize: 14,
                              color: AppColors.grayText,
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (_professionals.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppColors.grayText.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                Icons.person_search,
                                size: 48,
                                color: AppColors.grayText.withOpacity(0.5),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No professionals available',
                              style: TextStyle(
                                fontFamily: 'Lato',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.grayText,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Pull to refresh or check back later',
                              style: TextStyle(
                                fontFamily: 'OpenSans',
                                fontSize: 14,
                                color: AppColors.grayText.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Professionals count
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            '${_professionals.length} professional${_professionals.length != 1 ? 's' : ''} available',
                            style: TextStyle(
                              fontFamily: 'Lato',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.grayText,
                            ),
                          ),
                        ),
                        // Professionals list
                        ..._professionals.map((professional) => 
                          _buildProfessionalCard(professional)
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyAppointmentsTab() {
    return RefreshIndicator(
      onRefresh: () async {
        // Refresh appointments data
        await _loadAppointments();
      },
      color: AppColors.successGreen,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  if (_isLoadingAppointments)
                    Center(
                      child: CircularProgressIndicator(
                        color: AppColors.successGreen,
                      ),
                    )
                  else if (_appointments.isEmpty)
                    _buildEmptyAppointments()
                  else
                    ..._appointments.map((appointment) => 
                      _buildAppointmentCard(appointment)
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        style: TextStyle(
          fontFamily: 'OpenSans',
          fontSize: 14,
          color: AppColors.blackText,
        ),
        decoration: InputDecoration(
          hintText: 'Search',
          hintStyle: TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 14,
            color: AppColors.grayText,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.grayText,
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildProfessionalCard(Map<String, dynamic> professional) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Professional info row
          Row(
            children: [
              // Professional avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.successGreen,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Center(
                  child: Text(
                    professional['avatar'] ?? 'P',
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Professional details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      professional['name'] ?? 'Professional',
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.blackText,
                      ),
                    ),
                    Text(
                      professional['specialization'] ?? 'Specialist',
                      style: TextStyle(
                        fontFamily: 'OpenSans',
                        fontSize: 12,
                        color: AppColors.grayText,
                      ),
                    ),
                    if (professional['rating'] != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 14,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${professional['rating']}',
                            style: TextStyle(
                              fontFamily: 'OpenSans',
                              fontSize: 12,
                              color: AppColors.grayText,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              // Status indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: professional['isAvailable'] == true
                      ? AppColors.successGreen.withOpacity(0.1)
                      : AppColors.grayText.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  professional['isAvailable'] == true ? 'Available' : 'Busy',
                  style: TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: professional['isAvailable'] == true
                        ? AppColors.successGreen
                        : AppColors.grayText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Availability toggle section
          _buildAvailabilityToggleSection(professional),
          
          const SizedBox(height: 16),
          
          // Action buttons row
          Row(
            children: [
              // Phone call button
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: professional['phoneNumber'] != null && 
                             professional['phoneNumber'].toString().isNotEmpty
                      ? () => _makePhoneCall(professional['phoneNumber'])
                      : null,
                  icon: Icon(
                    Icons.phone,
                    size: 18,
                    color: professional['phoneNumber'] != null && 
                           professional['phoneNumber'].toString().isNotEmpty
                        ? AppColors.successGreen
                        : AppColors.grayText,
                  ),
                  label: Text(
                    'Call',
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: professional['phoneNumber'] != null && 
                             professional['phoneNumber'].toString().isNotEmpty
                          ? AppColors.successGreen
                          : AppColors.grayText,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: professional['phoneNumber'] != null && 
                             professional['phoneNumber'].toString().isNotEmpty
                          ? AppColors.successGreen
                          : AppColors.grayText.withOpacity(0.3),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Book consultation button
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: professional['isAvailable'] == true
                      ? () async {
                          // Navigate to book consultation schedule page
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BookConsultationSchedulePage(
                                professional: professional,
                              ),
                            ),
                          );
                          
                          // If a booking was made, add it to appointments and switch tabs
                          if (result != null && result is Map<String, dynamic> && mounted && result['success'] == true) {
                            await _loadAppointments(); // Refresh appointments from Firebase
                            setState(() {
                              _tabController.animateTo(1); // Switch to "My Appointments" tab
                            });
                            
                            // Show success message
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Appointment booked successfully!',
                                  style: TextStyle(
                                    fontFamily: 'OpenSans',
                                    color: AppColors.white,
                                  ),
                                ),
                                backgroundColor: AppColors.successGreen,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.successGreen,
                    disabledBackgroundColor: AppColors.grayText.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Book Consultation',
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

  Widget _buildAvailabilityToggleSection(Map<String, dynamic> professional) {
    Map<String, List<String>> availabilityByDay = 
        professional['availabilityByDay'] ?? {};
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Availability',
              style: TextStyle(
                fontFamily: 'Lato',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.blackText,
              ),
            ),
            const Spacer(),
            if (availabilityByDay.isNotEmpty)
              TextButton(
                onPressed: () => _showFullAvailabilityDialog(professional),
                child: Text(
                  'View All',
                  style: TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 12,
                    color: AppColors.successGreen,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        
        if (availabilityByDay.isEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.grayText.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                'No availability set',
                style: TextStyle(
                  fontFamily: 'OpenSans',
                  fontSize: 12,
                  color: AppColors.grayText,
                ),
              ),
            ),
          )
        else
          // Show next 3 days with availability
          ...availabilityByDay.entries.take(3).map((entry) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(
                      entry.key,
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.blackText,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: entry.value.take(4).map((time) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.successGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            time,
                            style: TextStyle(
                              fontFamily: 'OpenSans',
                              fontSize: 10,
                              color: AppColors.successGreen,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  if (entry.value.length > 4)
                    Text(
                      '+${entry.value.length - 4}',
                      style: TextStyle(
                        fontFamily: 'OpenSans',
                        fontSize: 10,
                        color: AppColors.grayText,
                      ),
                    ),
                ],
              ),
            );
          }),
      ],
    );
  }

  void _showFullAvailabilityDialog(Map<String, dynamic> professional) {
    Map<String, List<String>> availabilityByDay = 
        professional['availabilityByDay'] ?? {};
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 500),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Weekly Availability',
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.blackText,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close,
                      color: AppColors.grayText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              Text(
                professional['name'] ?? 'Professional',
                style: TextStyle(
                  fontFamily: 'OpenSans',
                  fontSize: 14,
                  color: AppColors.grayText,
                ),
              ),
              const SizedBox(height: 16),
              
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      if (availabilityByDay.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(20),
                          child: Center(
                            child: Text(
                              'No availability set',
                              style: TextStyle(
                                fontFamily: 'OpenSans',
                                color: AppColors.grayText,
                              ),
                            ),
                          ),
                        )
                      else
                        ...availabilityByDay.entries.map((entry) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBackground,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.key,
                                  style: TextStyle(
                                    fontFamily: 'Lato',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.blackText,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: entry.value.map((time) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.successGreen.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        time,
                                        style: TextStyle(
                                          fontFamily: 'OpenSans',
                                          fontSize: 12,
                                          color: AppColors.successGreen,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> appointment) {
    // Extract professional data properly from the Firebase response
    final professionalName = appointment['professional_name'] ?? 'Professional';
    final specialization = appointment['professional_specialization'] ?? 'Specialist';
    final professionalPhone = appointment['professional_phone'] ?? appointment['professional_contact'] ?? '';
    final consultationDate = appointment['formatted_date'] ?? appointment['consultation_date']?.toString() ?? 'Not scheduled';
    final consultationTime = appointment['consultation_time'] ?? 'Not set';
    final status = appointment['status'] ?? 'Scheduled';
    final referenceNo = appointment['reference_no'] ?? '';
    
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Professional info row
          Row(
            children: [
              // Professional avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.successGreen,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Center(
                  child: Text(
                    professionalName.split(' ').map((n) => n.isNotEmpty ? n[0] : '').join('').toUpperCase(),
                    style: const TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Professional details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      professionalName,
                      style: const TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D2D2D),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      specialization,
                      style: TextStyle(
                        fontFamily: 'OpenSans',
                        fontSize: 12,
                        color: AppColors.grayText,
                      ),
                    ),
                  ],
                ),
              ),
              // Phone button
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.successGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.phone,
                    color: AppColors.successGreen,
                    size: 20,
                  ),
                  onPressed: professionalPhone.isNotEmpty 
                      ? () => _makePhoneCall(professionalPhone)
                      : null,
                  tooltip: professionalPhone.isNotEmpty 
                      ? 'Call $professionalName' 
                      : 'No phone number available',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getStatusColor(status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getStatusColor(status).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              status.toUpperCase(),
              style: TextStyle(
                fontFamily: 'Lato',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _getStatusColor(status),
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Scheduled appointment details
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.grayText.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Scheduled at',
                  style: TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 12,
                    color: AppColors.grayText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$consultationDate at $consultationTime',
                  style: const TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
                if (referenceNo.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Reference: $referenceNo',
                    style: TextStyle(
                      fontFamily: 'OpenSans',
                      fontSize: 11,
                      color: AppColors.grayText,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Action buttons
          Row(
            children: [
              // Cancel button
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: OutlinedButton(
                    onPressed: () {
                      _showCancelDialog(appointment);
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: AppColors.grayText.withOpacity(0.5),
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.grayText,
                      ),
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

  // Helper method to get status color
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
      case 'confirmed':
        return AppColors.successGreen;
      case 'in progress':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return AppColors.grayText;
    }
  }

  Widget _buildEmptyAppointments() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.event_note,
            size: 64,
            color: AppColors.grayText.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Appointments Yet',
            style: TextStyle(
              fontFamily: 'Lato',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.grayText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Book a consultation to see your appointments here',
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

  void _showCancelDialog(Map<String, dynamic> appointment) {
    final professionalName = appointment['professional_name'] ?? 'this professional';
    
    // Check if cancellation is allowed (no same-day cancellation)
    final consultationDate = appointment['consultation_date'];
    if (consultationDate is Timestamp) {
      final appointmentDateTime = consultationDate.toDate();
      final appointmentDateOnly = DateTime(appointmentDateTime.year, appointmentDateTime.month, appointmentDateTime.day);
      final today = DateTime.now();
      final todayOnly = DateTime(today.year, today.month, today.day);
      
      // If appointment is today, prevent cancellation
      if (appointmentDateOnly.isAtSameMomentAs(todayOnly)) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.primaryAccent, size: 28),
                  const SizedBox(width: 8),
                  Text(
                    'Cannot Cancel',
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.blackText,
                    ),
                  ),
                ],
              ),
              content: Text(
                'You cannot cancel an appointment on the same day. Please contact the professional directly if you need to reschedule.',
                style: TextStyle(
                  fontFamily: 'OpenSans',
                  fontSize: 14,
                  color: AppColors.grayText,
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.successGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'OK',
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ],
            );
          },
        );
        return;
      }
    }
    
    // Show normal cancellation dialog if not same-day
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Cancel Appointment',
            style: TextStyle(
              fontFamily: 'Lato',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.blackText,
            ),
          ),
          content: Text(
            'Are you sure you want to cancel your appointment with $professionalName?',
            style: TextStyle(
              fontFamily: 'OpenSans',
              fontSize: 14,
              color: AppColors.grayText,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Keep',
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grayText,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _cancelAppointment(appointment);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _cancelAppointment(Map<String, dynamic> appointment) async {
    try {
      // Cancel the appointment in Firebase
      final consultationId = appointment['id'];
      if (consultationId != null) {
        await _consultationService.cancelConsultation(consultationId, reason: 'Cancelled by user');
      }
      
      // Refresh appointments
      await _loadAppointments();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Appointment cancelled successfully',
            style: TextStyle(
              fontFamily: 'OpenSans',
              color: AppColors.white,
            ),
          ),
          backgroundColor: AppColors.successGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (e) {
      print('Error cancelling appointment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to cancel appointment. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}