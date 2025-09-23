import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants.dart';
import '../../../core/widgets/progress_pill.dart';
import 'professional_completion_page.dart';

class ProfessionalBioPage extends StatefulWidget {
  final String fullName;
  final String phoneNumber;
  final String specialization;
  final String licenseNumber;
  final String experience;
  final String consultationFee;
  
  const ProfessionalBioPage({
    super.key,
    required this.fullName,
    required this.phoneNumber,
    required this.specialization,
    required this.licenseNumber,
    required this.experience,
    required this.consultationFee,
  });

  @override
  State<ProfessionalBioPage> createState() => _ProfessionalBioPageState();
}

class _ProfessionalBioPageState extends State<ProfessionalBioPage> {
  final _bioController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _bioController.addListener(() => setState(() {}));
  }
  
  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              
              // Progress indicator
              ProgressPill(
                current: 3,
                total: 4,
              ),
              
              const SizedBox(height: 40),
              
              // Title
              Text(
                "Professional Bio",
                style: TextStyle(
                  fontFamily: AppConstants.headingFont,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: AppColors.blackText,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Subtitle
              Text(
                "Tell patients about your expertise and approach to nutrition counseling",
                style: TextStyle(
                  fontFamily: AppConstants.primaryFont,
                  fontSize: 14,
                  color: AppColors.grayText,
                  height: 1.4,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Bio Text Area
              Text(
                "About You",
                style: TextStyle(
                  fontFamily: AppConstants.primaryFont,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.blackText,
                ),
              ),
              
              const SizedBox(height: 12),
              
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _bioController,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: InputDecoration(
                      hintText: "Share your experience, approach to patient care, specialties, and what makes you unique as a nutrition professional...\n\nExample: I am a registered nutritionist-dietitian with 8 years of experience in clinical nutrition and weight management. I specialize in creating personalized meal plans for patients with diabetes and hypertension, using evidence-based approaches combined with Filipino cuisine preferences.",
                      hintStyle: TextStyle(
                        color: AppColors.grayText,
                        fontFamily: AppConstants.primaryFont,
                        fontSize: 14,
                        height: 1.5,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppColors.white,
                      contentPadding: const EdgeInsets.all(20),
                    ),
                    style: TextStyle(
                      fontFamily: AppConstants.primaryFont,
                      fontSize: 16,
                      color: AppColors.blackText,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Guidelines
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: AppColors.primaryAccent,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Bio Guidelines",
                          style: TextStyle(
                            fontFamily: AppConstants.primaryFont,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryAccent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "• Mention your qualifications and experience\n"
                      "• Describe your specialties and approach\n"
                      "• Share what makes you unique\n"
                      "• Keep it professional and patient-focused",
                      style: TextStyle(
                        fontFamily: AppConstants.primaryFont,
                        fontSize: 12,
                        color: AppColors.primaryAccent,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Continue Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _bioController.text.isNotEmpty 
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfessionalCompletionPage(
                              fullName: widget.fullName,
                              phoneNumber: widget.phoneNumber,
                              specialization: widget.specialization,
                              licenseNumber: widget.licenseNumber,
                              experience: widget.experience,
                              consultationFee: widget.consultationFee,
                              bio: _bioController.text,
                            ),
                          ),
                        );
                      }
                    : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.successGreen,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    disabledBackgroundColor: AppColors.grayText.withOpacity(0.3),
                  ),
                  child: Text(
                    "Continue",
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
    );
  }
}
