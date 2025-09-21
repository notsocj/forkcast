import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class BookingConfirmationPage extends StatelessWidget {
  final Map<String, dynamic> professional;
  final DateTime selectedDate;
  final String selectedTime;
  final String topic;

  const BookingConfirmationPage({
    super.key,
    required this.professional,
    required this.selectedDate,
    required this.selectedTime,
    required this.topic,
  });

  @override
  Widget build(BuildContext context) {
    // Generate a random reference number for demo
    final referenceNo = (DateTime.now().millisecondsSinceEpoch % 1000000).toString();
    
    return Scaffold(
      backgroundColor: AppColors.successGreen,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Spacer(),
              // Main confirmation card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Success checkmark
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.successGreen,
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Icon(
                        Icons.check,
                        color: AppColors.white,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Success message
                    Text(
                      'Your appointment\nis booked!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.blackText,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Professional info
                    _buildProfessionalInfo(),
                    const SizedBox(height: 24),
                    // Appointment details
                    _buildAppointmentDetails(referenceNo),
                    const SizedBox(height: 32),
                    // Go to My Appointments button
                    _buildGoToAppointmentsButton(context),
                  ],
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfessionalInfo() {
    return Row(
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
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppointmentDetails(String referenceNo) {
    // Format the date
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final formattedDate = '${months[selectedDate.month - 1]} ${selectedDate.day}, ${selectedDate.year}';

    return Column(
      children: [
        // Date and time
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
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
                '$formattedDate at $selectedTime',
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.blackText,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'Reference no. ',
                    style: TextStyle(
                      fontFamily: 'OpenSans',
                      fontSize: 12,
                      color: AppColors.grayText,
                    ),
                  ),
                  Text(
                    referenceNo,
                    style: TextStyle(
                      fontFamily: 'OpenSans',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.blackText,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (topic.isNotEmpty) ...[
          const SizedBox(height: 12),
          // Topic details
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
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
                  'Topic:',
                  style: TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 12,
                    color: AppColors.grayText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  topic,
                  style: TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 14,
                    color: AppColors.blackText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildGoToAppointmentsButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () {
          // Close confirmation page and pass confirmed result
          Navigator.pop(context, 'confirmed');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.successGreen,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 0,
        ),
        child: Text(
          'Go to My Appointments',
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
}