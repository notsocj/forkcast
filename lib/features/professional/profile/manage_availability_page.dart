import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ManageAvailabilityPage extends StatefulWidget {
  const ManageAvailabilityPage({super.key});

  @override
  State<ManageAvailabilityPage> createState() => _ManageAvailabilityPageState();
}

class _ManageAvailabilityPageState extends State<ManageAvailabilityPage> {
  final List<String> _weekDays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];
  
  final List<String> _timeSlots = [
    '8:00 AM', '9:00 AM', '10:00 AM', '11:00 AM', '12:00 PM',
    '1:00 PM', '2:00 PM', '3:00 PM', '4:00 PM', '5:00 PM', '6:00 PM'
  ];
  
  // Track availability for each day and time slot
  final Map<String, List<bool>> _availability = {};
  
  // Track special dates (blocked/available)
  final Map<DateTime, bool> _specialDates = {};
  
  @override
  void initState() {
    super.initState();
    _initializeAvailability();
  }
  
  void _initializeAvailability() {
    // Initialize with sample availability data
    for (String day in _weekDays) {
      _availability[day] = List.generate(_timeSlots.length, (index) {
        // Sample: Available Monday-Friday 9AM-5PM, weekends partial
        if (day == 'Saturday' || day == 'Sunday') {
          return index >= 2 && index <= 6; // 10AM-4PM weekends
        } else {
          return index >= 1 && index <= 9; // 9AM-5PM weekdays
        }
      });
    }
    
    // Sample special dates
    _specialDates[DateTime.now().add(const Duration(days: 5))] = false; // Blocked
    _specialDates[DateTime.now().add(const Duration(days: 12))] = false; // Blocked
  }

  @override
  Widget build(BuildContext context) {
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
                    // Quick Stats
                    _buildQuickStats(),
                    const SizedBox(height: 24),
                    
                    // Weekly Schedule
                    _buildWeeklySchedule(),
                    const SizedBox(height: 24),
                    
                    // Special Dates
                    _buildSpecialDates(),
                    const SizedBox(height: 24),
                    
                    // Quick Actions
                    _buildQuickActions(),
                    const SizedBox(height: 20),
                  ],
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Manage Availability',
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
                Text(
                  'Set your consultation hours',
                  style: TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 14,
                    color: AppColors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _showHelpDialog,
            icon: Icon(
              Icons.help_outline,
              color: AppColors.white,
            ),
          ),
        ],
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
              icon: Icons.block,
              title: 'Blocked Days',
              value: '${_specialDates.values.where((blocked) => blocked == false).length}',
              subtitle: 'special dates',
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

  Widget _buildSpecialDates() {
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
                  color: AppColors.primaryAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.event_busy,
                  color: AppColors.primaryAccent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Special Dates',
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.blackText,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: _addSpecialDate,
                icon: Icon(
                  Icons.add,
                  color: AppColors.primaryAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (_specialDates.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 48,
                    color: AppColors.grayText.withOpacity(0.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No special dates set',
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grayText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Add blocked dates or special availability',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'OpenSans',
                      fontSize: 12,
                      color: AppColors.grayText,
                    ),
                  ),
                ],
              ),
            )
          else
            ..._specialDates.entries.map((entry) => 
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: entry.value 
                          ? AppColors.successGreen.withOpacity(0.1)
                          : AppColors.primaryAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        entry.value ? Icons.check_circle : Icons.block,
                        color: entry.value ? AppColors.successGreen : AppColors.primaryAccent,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${entry.key.day}/${entry.key.month}/${entry.key.year}',
                            style: TextStyle(
                              fontFamily: 'Lato',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.blackText,
                            ),
                          ),
                          Text(
                            entry.value ? 'Special availability' : 'Blocked day',
                            style: TextStyle(
                              fontFamily: 'OpenSans',
                              fontSize: 12,
                              color: AppColors.grayText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _specialDates.remove(entry.key);
                        });
                      },
                      icon: Icon(
                        Icons.delete_outline,
                        color: AppColors.grayText,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              )
            ).toList(),
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

  void _addSpecialDate() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    ).then((date) {
      if (date != null) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'Set Special Date',
              style: TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.bold,
                color: AppColors.blackText,
              ),
            ),
            content: Text(
              'What would you like to do on ${date.day}/${date.month}/${date.year}?',
              style: TextStyle(
                fontFamily: 'OpenSans',
                color: AppColors.blackText,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _specialDates[date] = false; // Blocked
                  });
                  Navigator.pop(context);
                },
                child: Text(
                  'Block Day',
                  style: TextStyle(color: AppColors.primaryAccent),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _specialDates[date] = true; // Available
                  });
                  Navigator.pop(context);
                },
                child: Text(
                  'Add Availability',
                  style: TextStyle(color: AppColors.successGreen),
                ),
              ),
            ],
          ),
        );
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
              setState(() {
                _initializeAvailability();
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

  void _saveAvailability() {
    // Simulate saving to Firebase
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Availability schedule saved successfully!',
          style: TextStyle(color: AppColors.white),
        ),
        backgroundColor: AppColors.successGreen,
        action: SnackBarAction(
          label: 'View',
          textColor: AppColors.white,
          onPressed: () {
            // Navigate to schedule view or dashboard
          },
        ),
      ),
    );
  }
}