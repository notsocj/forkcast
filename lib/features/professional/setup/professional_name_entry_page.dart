import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants.dart';
import '../../../core/widgets/progress_pill.dart';
import 'professional_credentials_page.dart';

class ProfessionalNameEntryPage extends StatefulWidget {
  const ProfessionalNameEntryPage({super.key});

  @override
  State<ProfessionalNameEntryPage> createState() => _ProfessionalNameEntryPageState();
}

class _ProfessionalNameEntryPageState extends State<ProfessionalNameEntryPage> {
  final _fullNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fullNameController.addListener(() => setState(() {}));
    _phoneNumberController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneNumberController.dispose();
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
                current: 1,
                total: 4,
              ),
              
              const SizedBox(height: 40),
              
              // Title with medical emoji
              Row(
                children: [
                  Text(
                    "Professional Setup",
                    style: TextStyle(
                      fontFamily: AppConstants.headingFont,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: AppColors.blackText,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "🩺",
                    style: TextStyle(fontSize: 24),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Subtitle
              Text(
                "Welcome! Let's set up your professional profile to help users find and connect with you.",
                style: TextStyle(
                  fontFamily: AppConstants.primaryFont,
                  fontSize: 14,
                  color: AppColors.grayText,
                  height: 1.4,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Info Note
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.primaryAccent,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Your credentials will be verified before your profile goes live",
                        style: TextStyle(
                          fontFamily: AppConstants.primaryFont,
                          fontSize: 14,
                          color: AppColors.primaryAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Full Name Field
              Text(
                "Full Name",
                style: TextStyle(
                  fontFamily: AppConstants.primaryFont,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.blackText,
                ),
              ),
              
              const SizedBox(height: 12),
              
              Container(
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
                  controller: _fullNameController,
                  decoration: InputDecoration(
                    hintText: "Dr. Juan Dela Cruz",
                    hintStyle: TextStyle(
                      color: AppColors.grayText,
                      fontFamily: AppConstants.primaryFont,
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
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Phone Number Field
              Text(
                "Phone Number",
                style: TextStyle(
                  fontFamily: AppConstants.primaryFont,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.blackText,
                ),
              ),
              
              const SizedBox(height: 12),
              
              Container(
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
                  controller: _phoneNumberController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: "+63 912 345 6789",
                    hintStyle: TextStyle(
                      color: AppColors.grayText,
                      fontFamily: AppConstants.primaryFont,
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
                  ),
                ),
              ),
              
              const Spacer(),
              
              // Continue Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _fullNameController.text.isNotEmpty && _phoneNumberController.text.isNotEmpty
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfessionalCredentialsPage(
                              fullName: _fullNameController.text,
                              phoneNumber: _phoneNumberController.text,
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