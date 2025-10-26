import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_colors.dart';
import '../../services/consultation_service.dart';
import 'booking_confirmation_page.dart';

class BookConsultationSchedulePage extends StatefulWidget {
  final Map<String, dynamic> professional;

  const BookConsultationSchedulePage({
    super.key,
    required this.professional,
  });

  @override
  State<BookConsultationSchedulePage> createState() => _BookConsultationSchedulePageState();
}

class _BookConsultationSchedulePageState extends State<BookConsultationSchedulePage> {
  // Initialize to tomorrow (minimum 1 day ahead booking)
  DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
  String? selectedTime;
  final TextEditingController _topicController = TextEditingController();
  final ConsultationService _consultationService = ConsultationService();
  
  bool _isLoading = false;
  bool _isLoadingCalendar = false;
  List<String> _availableTimeSlots = [];
  DateTime _currentMonth = DateTime.now();
  List<DateTime> _availableDates = [];

  // Available time slots
  final List<String> availableTimes = [
    '9:00 AM',
    '10:00 AM',
    '11:00 AM',
    '1:00 PM',
    '2:00 PM',
    '3:00 PM',
    '4:00 PM',
  ];

  @override
  void initState() {
    super.initState();
    _loadAvailableDates();
    _loadAvailableTimeSlots();
  }

  Future<void> _loadAvailableDates() async {
    setState(() => _isLoadingCalendar = true);
    
    try {
      final professionalId = widget.professional['id'] ?? widget.professional['professionalId'];
      if (professionalId != null) {
        // For now, we'll generate available dates and later integrate with professional availability
        // This can be enhanced when professional availability system is implemented
        setState(() {
          _availableDates = _generateFutureDates(60); // 60 days into the future
          _isLoadingCalendar = false;
        });
      } else {
        // Fallback: all future dates are available
        setState(() {
          _availableDates = _generateFutureDates(60);
          _isLoadingCalendar = false;
        });
      }
    } catch (e) {
      print('Error loading available dates: $e');
      setState(() {
        _availableDates = _generateFutureDates(60);
        _isLoadingCalendar = false;
      });
    }
  }

  void _changeMonth(int direction) {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + direction, 1);
    });
    _loadAvailableDates();
  }

  bool _isDateAvailable(DateTime date) {
    final today = DateTime.now();
    final dateOnly = DateTime(date.year, date.month, date.day);
    final todayOnly = DateTime(today.year, today.month, today.day);
    final tomorrow = todayOnly.add(const Duration(days: 1));
    
    // Date must be tomorrow or later (no same-day booking)
    if (dateOnly.isBefore(tomorrow)) return false;
    
    // Check if date is in available dates
    return _availableDates.any((availableDate) {
      final availableOnly = DateTime(availableDate.year, availableDate.month, availableDate.day);
      return availableOnly == dateOnly;
    });
  }

  bool _isDateSelected(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    final selectedOnly = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    return dateOnly == selectedOnly;
  }

  List<DateTime> _generateFutureDates(int days) {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
    // Generate dates starting from tomorrow (index 0 = tomorrow, not today)
    return List.generate(days, (index) => tomorrow.add(Duration(days: index)));
  }

  Future<void> _loadAvailableTimeSlots() async {
    setState(() => _isLoading = true);
    
    try {
      final professionalId = widget.professional['id'] ?? widget.professional['professionalId'];
      if (professionalId != null) {
        final slots = await _consultationService.getAvailableTimeSlots(professionalId, selectedDate);
        setState(() {
          _availableTimeSlots = slots;
          selectedTime = slots.isNotEmpty ? slots.first : null;
          _isLoading = false;
        });
      } else {
        // Fallback to default time slots if no professional ID
        setState(() {
          _availableTimeSlots = availableTimes;
          selectedTime = availableTimes.first;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading available time slots: $e');
      setState(() {
        _availableTimeSlots = availableTimes;
        selectedTime = availableTimes.first;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.successGreen,
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button and title
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      // Professional info card
                      _buildProfessionalCard(),
                      const SizedBox(height: 24),
                      // Date section
                      _buildDateSection(),
                      const SizedBox(height: 24),
                      // Time section
                      _buildTimeSection(),
                      const SizedBox(height: 24),
                      // Topic section
                      _buildTopicSection(),
                      const SizedBox(height: 32),
                      // Book appointment button
                      _buildBookButton(),
                      const SizedBox(height: 20),
                    ],
                  ),
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
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.arrow_back,
                color: AppColors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Title
          Text(
            'Book Consultation',
            style: TextStyle(
              fontFamily: 'Lato',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalCard() {
    return Container(
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
                widget.professional['avatar'] ?? 'P',
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
                  widget.professional['name'] ?? 'Professional',
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.blackText,
                  ),
                ),
                Text(
                  widget.professional['specialization'] ?? 'Specialist',
                  style: TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 12,
                    color: AppColors.grayText,
                  ),
                ),
                if (widget.professional['rating'] != null) ...[
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
                        '${widget.professional['rating']}',
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
        ],
      ),
    );
  }

  Widget _buildDateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date',
          style: TextStyle(
            fontFamily: 'Lato',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.blackText,
          ),
        ),
        const SizedBox(height: 16),
        Container(
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
          child: _isLoadingCalendar 
              ? Container(
                  height: 200,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.successGreen,
                    ),
                  ),
                )
              : _buildCalendar(),
        ),
      ],
    );
  }

  Widget _buildCalendar() {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Calendar header with navigation
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.successGreen,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => _changeMonth(-1),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.chevron_left,
                      color: AppColors.white,
                      size: 20,
                    ),
                  ),
                ),
                Text(
                  '${months[_currentMonth.month - 1].toUpperCase()} ${_currentMonth.year}',
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
                GestureDetector(
                  onTap: () => _changeMonth(1),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.chevron_right,
                      color: AppColors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Days of week
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'].map((day) {
              return Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: TextStyle(
                      fontFamily: 'OpenSans',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grayText,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          // Calendar grid
          _buildCalendarGrid(),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    // Get first day of the month and number of days
    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final firstWeekday = firstDayOfMonth.weekday % 7; // Sunday = 0, Monday = 1, etc.

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: 42, // 6 weeks
      itemBuilder: (context, index) {
        // Calculate the day
        final dayIndex = index - firstWeekday;
        
        if (dayIndex < 0 || dayIndex >= daysInMonth) {
          return const SizedBox(); // Empty cells
        }
        
        final day = dayIndex + 1;
        final currentDate = DateTime(_currentMonth.year, _currentMonth.month, day);
        
        final isSelected = _isDateSelected(currentDate);
        final isAvailable = _isDateAvailable(currentDate);
        final isToday = _isToday(currentDate);

        return GestureDetector(
          onTap: isAvailable ? () {
            setState(() {
              selectedDate = currentDate;
            });
            // Reload available time slots for the new date
            _loadAvailableTimeSlots();
          } : null,
          child: Container(
            decoration: BoxDecoration(
              color: isSelected 
                  ? AppColors.successGreen 
                  : isToday && isAvailable
                      ? AppColors.successGreen.withOpacity(0.2)
                      : isAvailable
                          ? Colors.transparent
                          : AppColors.grayText.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: isSelected 
                  ? Border.all(color: AppColors.successGreen, width: 2)
                  : isToday
                      ? Border.all(color: AppColors.successGreen, width: 1)
                      : null,
            ),
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    '$day',
                    style: TextStyle(
                      fontFamily: 'OpenSans',
                      fontSize: 14,
                      fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                      color: isSelected 
                          ? AppColors.white
                          : isAvailable
                              ? AppColors.blackText
                              : AppColors.grayText,
                    ),
                  ),
                  // Add a small dot for available dates
                  if (isAvailable && !isSelected && !isToday)
                    Positioned(
                      bottom: 4,
                      child: Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.successGreen,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  Widget _buildTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Available Times',
              style: TextStyle(
                fontFamily: 'Lato',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.blackText,
              ),
            ),
            const SizedBox(width: 8),
            if (_isLoading)
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  color: AppColors.successGreen,
                  strokeWidth: 2,
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Show selected date info
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.successGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.successGreen.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 16,
                color: AppColors.successGreen,
              ),
              const SizedBox(width: 8),
              Text(
                'Selected: ${_formatSelectedDate()}',
                style: TextStyle(
                  fontFamily: 'OpenSans',
                  fontSize: 12,
                  color: AppColors.successGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        // Time slots grid
        if (_availableTimeSlots.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableTimeSlots.map((time) {
              final isSelected = selectedTime == time;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedTime = time;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.successGreen : AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? AppColors.successGreen : AppColors.grayText.withOpacity(0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    time,
                    style: TextStyle(
                      fontFamily: 'OpenSans',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.white : AppColors.blackText,
                    ),
                  ),
                ),
              );
            }).toList(),
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.grayText.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.grayText.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.schedule_outlined,
                  size: 32,
                  color: AppColors.grayText.withOpacity(0.5),
                ),
                const SizedBox(height: 8),
                Text(
                  'No available time slots',
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.grayText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Please select another date',
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
    );
  }

  String _formatSelectedDate() {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    return '${months[selectedDate.month - 1]} ${selectedDate.day}, ${selectedDate.year}';
  }

  Widget _buildTopicSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What do you want to talk about?',
          style: TextStyle(
            fontFamily: 'Lato',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.blackText,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 120,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.grayText.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _topicController,
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            style: TextStyle(
              fontFamily: 'OpenSans',
              fontSize: 14,
              color: AppColors.blackText,
            ),
            decoration: InputDecoration(
              hintText: 'Type here...',
              hintStyle: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 14,
                color: AppColors.grayText,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBookButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _bookAppointment,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.successGreen,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: AppColors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                'Book Appointment',
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
      ),
    );
  }

  Future<void> _bookAppointment() async {
    if (selectedTime == null || selectedTime!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a time slot'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Get professional ID
      final professionalId = widget.professional['id'] ?? widget.professional['professionalId'];
      if (professionalId == null) {
        throw Exception('Professional ID not found');
      }

      // Book consultation through Firebase
      final consultationId = await _consultationService.bookConsultation(
        professionalId: professionalId,
        consultationDate: selectedDate,
        consultationTime: selectedTime!,
        topic: _topicController.text.trim(),
      );

      setState(() => _isLoading = false);

      // Navigate to confirmation page with booking details
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BookingConfirmationPage(
            professional: widget.professional,
            selectedDate: selectedDate,
            selectedTime: selectedTime!,
            topic: _topicController.text.trim(),
            consultationId: consultationId,
          ),
        ),
      ).then((result) {
        // If confirmed, go back to previous page
        if (result == 'confirmed') {
          Navigator.pop(context, {
            'success': true,
            'consultation_id': consultationId,
          });
        }
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error booking appointment: $e');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to book appointment. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}