import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants.dart';
import '../../../core/widgets/progress_pill.dart';
import 'professional_bio_page.dart';

class ProfessionalCredentialsPage extends StatefulWidget {
  final String fullName;
  final String phoneNumber;
  
  const ProfessionalCredentialsPage({
    super.key,
    required this.fullName,
    required this.phoneNumber,
  });

  @override
  State<ProfessionalCredentialsPage> createState() => _ProfessionalCredentialsPageState();
}

class _ProfessionalCredentialsPageState extends State<ProfessionalCredentialsPage> {
  final _specializationController = TextEditingController();
  final _licenseController = TextEditingController();
  final _experienceController = TextEditingController();
  final _consultationFeeController = TextEditingController();
  
  String _selectedSpecialization = 'Registered Nutritionist-Dietitian';
  
  final List<String> _specializations = [
    'Registered Nutritionist-Dietitian',
    'Clinical Nutritionist',
    'Sports Nutritionist',
    'Pediatric Nutritionist',
    'Geriatric Nutritionist',
    'Community Nutritionist',
  ];

  @override
  void initState() {
    super.initState();
    _specializationController.text = _selectedSpecialization;
  }

  @override
  void dispose() {
    _specializationController.dispose();
    _licenseController.dispose();
    _experienceController.dispose();
    _consultationFeeController.dispose();
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
                current: 2,
                total: 4,
              ),
              
              const SizedBox(height: 40),
              
              // Title
              Text(
                "Professional Credentials",
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
                "Provide your professional qualifications and experience",
                style: TextStyle(
                  fontFamily: AppConstants.primaryFont,
                  fontSize: 14,
                  color: AppColors.grayText,
                  height: 1.4,
                ),
              ),
              
              const SizedBox(height: 32),
              
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Specialization Field
                      Text(
                        "Specialization",
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
                        child: DropdownButtonFormField<String>(
                          value: _selectedSpecialization,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: AppColors.white,
                            contentPadding: const EdgeInsets.all(20),
                          ),
                          items: _specializations.map((String specialization) {
                            return DropdownMenuItem<String>(
                              value: specialization,
                              child: Text(
                                specialization,
                                style: TextStyle(
                                  fontFamily: AppConstants.primaryFont,
                                  color: AppColors.blackText,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedSpecialization = newValue!;
                              _specializationController.text = newValue;
                            });
                          },
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // License Number Field
                      Text(
                        "License Number",
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
                          controller: _licenseController,
                          decoration: InputDecoration(
                            hintText: "e.g., RND-12345",
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
                      
                      // Years of Experience Field
                      Text(
                        "Years of Experience",
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
                          controller: _experienceController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: "5",
                            hintStyle: TextStyle(
                              color: AppColors.grayText,
                              fontFamily: AppConstants.primaryFont,
                            ),
                            suffixText: "years",
                            suffixStyle: TextStyle(
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
                      
                      // Consultation Fee Field
                      Text(
                        "Consultation Fee",
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
                          controller: _consultationFeeController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: "500",
                            hintStyle: TextStyle(
                              color: AppColors.grayText,
                              fontFamily: AppConstants.primaryFont,
                            ),
                            prefixText: "₱ ",
                            prefixStyle: TextStyle(
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
                      
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
              
              // Continue Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isFormValid() ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfessionalBioPage(
                          fullName: widget.fullName,
                          phoneNumber: widget.phoneNumber,
                          specialization: _selectedSpecialization,
                          licenseNumber: _licenseController.text,
                          experience: _experienceController.text,
                          consultationFee: _consultationFeeController.text,
                        ),
                      ),
                    );
                  } : null,
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

  bool _isFormValid() {
    return _licenseController.text.isNotEmpty &&
           _experienceController.text.isNotEmpty &&
           _consultationFeeController.text.isNotEmpty;
  }
}
