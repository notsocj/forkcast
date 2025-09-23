import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants.dart';
import '../../../core/widgets/progress_pill.dart';
import '../professional_navigation_wrapper.dart';

class ProfessionalCompletionPage extends StatefulWidget {
  final String fullName;
  final String phoneNumber;
  final String specialization;
  final String licenseNumber;
  final String experience;
  final String consultationFee;
  final String bio;
  
  const ProfessionalCompletionPage({
    super.key,
    required this.fullName,
    required this.phoneNumber,
    required this.specialization,
    required this.licenseNumber,
    required this.experience,
    required this.consultationFee,
    required this.bio,
  });

  @override
  State<ProfessionalCompletionPage> createState() => _ProfessionalCompletionPageState();
}

class _ProfessionalCompletionPageState extends State<ProfessionalCompletionPage> {
  
  void _completeProfessionalSetup() {
    // TODO: Save professional data to Firebase
    // For now, navigate to professional dashboard
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfessionalNavigationWrapper(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.blackText,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                
                // Progress indicator
                const ProgressPill(
                  current: 4,
                  total: 4,
                ),
                
                const SizedBox(height: 40),
                
                // Success Icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.successGreen.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    size: 60,
                    color: AppColors.successGreen,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Title
                Text(
                  "Setup Complete! 🩺",
                  style: TextStyle(
                    fontFamily: AppConstants.headingFont,
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                    color: AppColors.blackText,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 16),
                
                // Subtitle
                Text(
                  "Welcome to ForkCast Professional! Your profile has been created successfully.",
                  style: TextStyle(
                    fontFamily: AppConstants.primaryFont,
                    fontSize: 16,
                    color: AppColors.grayText,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 40),
                
                // Profile Summary Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Profile Summary",
                        style: TextStyle(
                          fontFamily: AppConstants.headingFont,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.blackText,
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      _buildSummaryRow("Name", widget.fullName),
                      _buildSummaryRow("Phone", widget.phoneNumber),
                      _buildSummaryRow("Specialization", widget.specialization),
                      _buildSummaryRow("License No.", widget.licenseNumber),
                      _buildSummaryRow("Experience", widget.experience),
                      _buildSummaryRow("Consultation Fee", "₱${widget.consultationFee}"),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // What's Next Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primaryAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppColors.primaryAccent,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "What's Next?",
                            style: TextStyle(
                              fontFamily: AppConstants.headingFont,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryAccent,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      
                      Text(
                        "• Your profile will be reviewed by our team\n"
                        "• You'll receive verification within 24-48 hours\n"
                        "• Start managing consultations and helping patients\n"
                        "• Set your availability and consultation preferences",
                        style: TextStyle(
                          fontFamily: AppConstants.primaryFont,
                          fontSize: 14,
                          color: AppColors.primaryAccent,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Continue Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _completeProfessionalSetup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.successGreen,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      "Continue to Dashboard",
                      style: TextStyle(
                        fontFamily: AppConstants.primaryFont,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: AppConstants.primaryFont,
                fontSize: 14,
                color: AppColors.grayText,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontFamily: AppConstants.primaryFont,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.blackText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
