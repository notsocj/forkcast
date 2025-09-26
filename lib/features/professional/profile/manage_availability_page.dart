import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/professional_service.dart';

// Add blackText color extension
extension AppColorsExtension on AppColors {
  static const Color blackText = Color(0xFF2D2D2D);
}

class ManageAvailabilityPage extends StatefulWidget {
  const ManageAvailabilityPage({super.key});

  @override
  State<ManageAvailabilityPage> createState() => _ManageAvailabilityPageState();
}

class _ManageAvailabilityPageState extends State<ManageAvailabilityPage> {
  final ProfessionalService _professionalService = ProfessionalService();
  
  final List<String> _weekDays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];
  
  final List<String> _timeSlots = [
    '8:00 AM', '9:00 AM', '10:00 AM', '11:00 AM', '12:00 PM',
    '1:00 PM', '2:00 PM', '3:00 PM', '4:00 PM', '5:00 PM', '6:00 PM'
  ];
  
  Map<String, List<bool>> _availability = {};
  bool _isLoading = true;
  bool _isSaving = false;
  
  @override
  void initState() {
    super.initState();
    _loadAvailabilityData();
  }
  
  Future<void> _loadAvailabilityData() async {
    setState(() => _isLoading = true);
    
    try {
      _availability = await _professionalService.getProfessionalAvailability();
      
      // Initialize availability for days that don't exist in Firebase
      for (String day in _weekDays) {
        _availability.putIfAbsent(day, () => List.generate(_timeSlots.length, (index) => false));
      }
    } catch (e) {
      print('Error loading availability data: $e');
      _initializeDefaultAvailability();
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  void _initializeDefaultAvailability() {
    for (String day in _weekDays) {
      _availability[day] = List.generate(_timeSlots.length, (index) => false);
    }
  }

  Future<void> _saveAvailability() async {
    setState(() => _isSaving = true);
    
    try {
      await _professionalService.saveProfessionalAvailability(_availability);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Availability saved successfully'),
            backgroundColor: AppColors.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving availability: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isSaving = false);
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
            // Page Title
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Text(
                'Manage Hours',
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColorsExtension.blackText,
                ),
              ),
            ),
            // Content
            Expanded(
              child: RefreshIndicator(
                color: AppColors.successGreen,
                onRefresh: _loadAvailabilityData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Quick Stats
                      _buildQuickStats(),
                      const SizedBox(height: 24),
                      
                      // Weekly Schedule
                      _buildWeeklySchedule(),
                      const SizedBox(height: 24),
                      
                      // Quick Actions
                      _buildQuickActions(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: "save_availability_fab",
        onPressed: _saveAvailability,
        backgroundColor: AppColors.successGreen,
        icon: Icon(
          Icons.save,
          color: AppColors.white,
        ),
        label: Text(
          'Save Changes',
          style: TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    int totalSlots = _weekDays.length * _timeSlots.length;
    int availableSlots = 0;
    
    for (String day in _weekDays) {
      availableSlots += _availability[day]?.where((slot) => slot).length ?? 0;
    }
    
    double availabilityPercentage = (availableSlots / totalSlots) * 100;
    
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
              title: 'Available Slots',
              value: '$availableSlots',
              subtitle: 'out of $totalSlots',
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
              icon: Icons.trending_up,
              title: 'Availability',
              value: '${availabilityPercentage.toInt()}%',
              subtitle: 'weekly coverage',
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
              icon: Icons.schedule,
              title: 'Time Slots',
              value: '${_timeSlots.length}',
              subtitle: 'available hours',
              color: AppColors.primaryAccent,
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
          value,
          style: TextStyle(
            fontFamily: 'Lato',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.blackText,
          ),
        ),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.blackText,
          ),
        ),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 9,
            color: AppColors.grayText,
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklySchedule() {
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.successGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.calendar_view_week,
                  color: AppColors.successGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Weekly Schedule',
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.blackText,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: _toggleAllAvailability,
                child: Text(
                  'Toggle All',
                  style: TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.successGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Time header
          Row(
            children: [
              SizedBox(
                width: 80,
                child: Text(
                  'Time',
                  style: TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.grayText,
                  ),
                ),
              ),
              ..._weekDays.map((day) => 
                Expanded(
                  child: Text(
                    day.substring(0, 3),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'OpenSans',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grayText,
                    ),
                  ),
                )
              ).toList(),
            ],
          ),
          const SizedBox(height: 8),
          
          // Schedule grid
          ...List.generate(_timeSlots.length, (timeIndex) => 
            Container(
              margin: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(
                      _timeSlots[timeIndex],
                      style: TextStyle(
                        fontFamily: 'OpenSans',
                        fontSize: 10,
                        color: AppColors.grayText,
                      ),
                    ),
                  ),
                  ..._weekDays.map((day) => 
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _availability[day]![timeIndex] = !_availability[day]![timeIndex];
                          });
                        },
                        child: Container(
                          height: 28,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: _availability[day]![timeIndex] 
                              ? AppColors.successGreen
                              : AppColors.lightGray.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: _availability[day]![timeIndex]
                            ? Icon(
                                Icons.check,
                                color: AppColors.white,
                                size: 16,
                              )
                            : null,
                        ),
                      ),
                    )
                  ).toList(),
                ],
              ),
            )
          ).toList(),
          
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.successGreen,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Available',
                style: TextStyle(
                  fontFamily: 'OpenSans',
                  fontSize: 12,
                  color: AppColors.grayText,
                ),
              ),
              const SizedBox(width: 20),
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.lightGray.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Unavailable',
                style: TextStyle(
                  fontFamily: 'OpenSans',
                  fontSize: 12,
                  color: AppColors.grayText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
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
          Text(
            'Quick Actions',
            style: TextStyle(
              fontFamily: 'Lato',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.blackText,
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.work_history,
                  title: 'Business Hours',
                  subtitle: 'Set standard hours',
                  onTap: _setBusinessHours,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.clear_all,
                  title: 'Clear All',
                  subtitle: 'Reset schedule',
                  onTap: _clearAllAvailability,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.copy,
                  title: 'Copy Week',
                  subtitle: 'Duplicate schedule',
                  onTap: _copyWeekSchedule,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.restore,
                  title: 'Reset',
                  subtitle: 'Default schedule',
                  onTap: _resetToDefault,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primaryBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: AppColors.primaryAccent,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Lato',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.blackText,
              ),
            ),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 10,
                color: AppColors.grayText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleAllAvailability() {
    setState(() {
      bool hasAnyAvailable = false;
      
      // Check if any slot is available
      for (String day in _weekDays) {
        if (_availability[day]?.any((slot) => slot) ?? false) {
          hasAnyAvailable = true;
          break;
        }
      }
      
      // If any slot is available, turn all off. Otherwise, turn all on.
      for (String day in _weekDays) {
        for (int i = 0; i < _timeSlots.length; i++) {
          _availability[day]![i] = !hasAnyAvailable;
        }
      }
    });
  }

  void _setBusinessHours() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Set Business Hours',
          style: TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.bold,
            color: AppColors.blackText,
          ),
        ),
        content: Text(
          'Set Monday-Friday 9AM-5PM as available?',
          style: TextStyle(
            fontFamily: 'OpenSans',
            color: AppColors.blackText,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.grayText),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                for (int dayIndex = 0; dayIndex < 5; dayIndex++) { // Mon-Fri
                  String day = _weekDays[dayIndex];
                  for (int timeIndex = 0; timeIndex < _timeSlots.length; timeIndex++) {
                    _availability[day]![timeIndex] = timeIndex >= 1 && timeIndex <= 9; // 9AM-5PM
                  }
                }
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.successGreen,
            ),
            child: Text(
              'Apply',
              style: TextStyle(color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _clearAllAvailability() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Clear All Availability',
          style: TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.bold,
            color: AppColors.blackText,
          ),
        ),
        content: Text(
          'This will clear all your availability settings. Are you sure?',
          style: TextStyle(
            fontFamily: 'OpenSans',
            color: AppColors.blackText,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.grayText),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                for (String day in _weekDays) {
                  for (int i = 0; i < _timeSlots.length; i++) {
                    _availability[day]![i] = false;
                  }
                }
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryAccent,
            ),
            child: Text(
              'Clear All',
              style: TextStyle(color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _copyWeekSchedule() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Copy week schedule feature coming soon!',
          style: TextStyle(color: AppColors.white),
        ),
        backgroundColor: AppColors.primaryAccent,
      ),
    );
  }

  void _resetToDefault() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Reset to Default',
          style: TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.bold,
            color: AppColors.blackText,
          ),
        ),
        content: Text(
          'Reset to default schedule (Mon-Fri 9AM-5PM, Sat 10AM-4PM)?',
          style: TextStyle(
            fontFamily: 'OpenSans',
            color: AppColors.blackText,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.grayText),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Reset to default availability
              setState(() {
                _initializeDefaultAvailability();
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.successGreen,
            ),
            child: Text(
              'Reset',
              style: TextStyle(color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'How to Manage Availability',
          style: TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.bold,
            color: AppColors.blackText,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '• Tap time slots to toggle availability\n'
              '• Green slots are available for booking\n'
              '• Gray slots are unavailable\n'
              '• Use special dates for holidays or exceptions\n'
              '• Save changes to update your schedule',
              style: TextStyle(
                fontFamily: 'OpenSans',
                color: AppColors.blackText,
                height: 1.5,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.successGreen,
            ),
            child: Text(
              'Got it',
              style: TextStyle(color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }
}