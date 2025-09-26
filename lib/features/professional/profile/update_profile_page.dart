import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/professional_service.dart';
import '../../../models/user.dart';
import '../../auth/sign_in_page.dart';

// Add blackText color extension
extension AppColorsExtension on AppColors {
  static const Color blackText = Color(0xFF2D2D2D);
}

class UpdateProfilePage extends StatefulWidget {
  const UpdateProfilePage({super.key});

  @override
  State<UpdateProfilePage> createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  final ProfessionalService _professionalService = ProfessionalService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _licenseController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _consultationFeeController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _certificationController = TextEditingController();
  final TextEditingController _customSpecializationController = TextEditingController();
  
  String _selectedSpecialization = 'Nutritionist';
  bool _isCustomSpecialization = false;
  bool _isLoading = false;
  bool _isSaving = false;
  User? _currentProfessional;
  
  final List<String> _specializations = [
    'Nutritionist',
    'Dietitian',
    'Clinical Nutritionist',
    'Sports Nutritionist',
    'Pediatric Nutritionist',
    'Geriatric Nutritionist',
    'Other (Specify)',
  ];

  final List<String> _selectedCertifications = [];

  @override
  void initState() {
    super.initState();
    _loadProfessionalData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _licenseController.dispose();
    _experienceController.dispose();
    _consultationFeeController.dispose();
    _bioController.dispose();
    _certificationController.dispose();
    _customSpecializationController.dispose();
    super.dispose();
  }

  Future<void> _loadProfessionalData() async {
    setState(() => _isLoading = true);
    
    try {
      _currentProfessional = await _professionalService.getCurrentProfessional();
      
      if (_currentProfessional != null) {
        _nameController.text = _currentProfessional!.fullName;
        _emailController.text = _currentProfessional!.email;
        _phoneController.text = _currentProfessional!.phoneNumber ?? '';
        _licenseController.text = _currentProfessional!.licenseNumber ?? '';
        _experienceController.text = _currentProfessional!.yearsExperience?.toString() ?? '';
        _consultationFeeController.text = _currentProfessional!.consultationFee?.toString() ?? '';
        _bioController.text = _currentProfessional!.bio ?? '';
        
        // Handle specialization - check if it's a predefined option or custom
        String userSpecialization = _currentProfessional!.specialization ?? 'Nutritionist';
        if (_specializations.contains(userSpecialization) && userSpecialization != 'Other (Specify)') {
          _selectedSpecialization = userSpecialization;
          _isCustomSpecialization = false;
        } else {
          _selectedSpecialization = 'Other (Specify)';
          _isCustomSpecialization = true;
          _customSpecializationController.text = userSpecialization;
        }
        
        _selectedCertifications.clear();
        _selectedCertifications.addAll(_currentProfessional!.certifications ?? []);
      }
    } catch (e) {
      print('Error loading professional data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSaving = true);
    
    try {
      // Determine the final specialization value
      String finalSpecialization = _isCustomSpecialization 
          ? _customSpecializationController.text.trim()
          : _selectedSpecialization;
          
      await _professionalService.updateProfessionalProfile(
        fullName: _nameController.text,
        phoneNumber: _phoneController.text,
        specialization: finalSpecialization,
        licenseNumber: _licenseController.text,
        yearsExperience: int.tryParse(_experienceController.text) ?? 0,
        consultationFee: double.tryParse(_consultationFeeController.text) ?? 0.0,
        bio: _bioController.text,
        certifications: _selectedCertifications,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: AppColors.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
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
                'Update Profile',
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Picture Section
                      _buildProfilePictureSection(),
                      const SizedBox(height: 24),
                      
                      // Basic Information
                      _buildSectionCard(
                        title: 'Basic Information',
                        icon: Icons.person,
                        children: [
                          _buildTextField(
                            controller: _nameController,
                            label: 'Full Name',
                            icon: Icons.person_outline,
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Please enter your full name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _emailController,
                            label: 'Email Address',
                            icon: Icons.email_outlined,
                            enabled: false,
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Please enter your email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _phoneController,
                            label: 'Phone Number',
                            icon: Icons.phone_outlined,
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Please enter your phone number';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      // Professional Information
                      _buildSectionCard(
                        title: 'Professional Information',
                        icon: Icons.work,
                        children: [
                          _buildSpecializationField(),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _licenseController,
                            label: 'License Number',
                            icon: Icons.badge_outlined,
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Please enter your license number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _experienceController,
                            label: 'Years of Experience',
                            icon: Icons.timeline_outlined,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Please enter your years of experience';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _consultationFeeController,
                            label: 'Consultation Fee (PHP)',
                            icon: Icons.attach_money_outlined,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Please enter your consultation fee';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      // Certifications
                      _buildCertificationsSection(),
                      const SizedBox(height: 20),
                      
                      // Bio Section
                      _buildSectionCard(
                        title: 'Professional Bio',
                        icon: Icons.description,
                        children: [
                          _buildTextAreaField(
                            controller: _bioController,
                            label: 'About You',
                            hintText: 'Tell patients about your expertise, approach, and what makes you unique...',
                            maxLines: 5,
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Please enter your professional bio';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      
                      // Logout Button
                      _buildLogoutButton(),
                      const SizedBox(height: 16),
                      
                      // Save Button
                      _buildSaveButton(),
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

  Widget _buildProfilePictureSection() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.successGreen,
              borderRadius: BorderRadius.circular(60),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                'SJ',
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {
              // Handle profile picture change
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Profile picture update feature coming soon!',
                    style: TextStyle(color: AppColors.white),
                  ),
                  backgroundColor: AppColors.successGreen,
                ),
              );
            },
            icon: Icon(
              Icons.camera_alt_outlined,
              color: AppColors.successGreen,
            ),
            label: Text(
              'Change Photo',
              style: TextStyle(
                fontFamily: 'OpenSans',
                fontWeight: FontWeight.w600,
                color: AppColors.successGreen,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.successGreen),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
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
                  icon,
                  color: AppColors.successGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.blackText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontFamily: 'OpenSans',
          color: AppColors.grayText,
        ),
        prefixIcon: Icon(
          icon,
          color: enabled ? AppColors.grayText : AppColors.grayText.withOpacity(0.5),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.lightGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.lightGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.successGreen),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.lightGray.withOpacity(0.5)),
        ),
        filled: !enabled,
        fillColor: !enabled ? AppColors.lightGray.withOpacity(0.1) : null,
      ),
      style: TextStyle(
        fontFamily: 'OpenSans',
        color: enabled ? AppColors.blackText : AppColors.grayText,
      ),
    );
  }

  Widget _buildSpecializationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: _selectedSpecialization,
          onChanged: (String? newValue) {
            setState(() {
              _selectedSpecialization = newValue!;
              _isCustomSpecialization = newValue == 'Other (Specify)';
              if (!_isCustomSpecialization) {
                _customSpecializationController.clear();
              }
            });
          },
          decoration: InputDecoration(
            labelText: 'Specialization',
            labelStyle: TextStyle(
              fontFamily: 'OpenSans',
              color: AppColors.grayText,
            ),
            prefixIcon: Icon(
              Icons.work_outline,
              color: AppColors.grayText,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.lightGray),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.lightGray),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.successGreen),
            ),
          ),
          items: _specializations.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: TextStyle(
                  fontFamily: 'OpenSans',
                  color: AppColors.blackText,
                ),
              ),
            );
          }).toList(),
          style: TextStyle(
            fontFamily: 'OpenSans',
            color: AppColors.blackText,
          ),
        ),
        
        // Custom Specialization Input Field (shown when "Other" is selected)
        if (_isCustomSpecialization) ...[
          const SizedBox(height: 16),
          TextFormField(
            controller: _customSpecializationController,
            decoration: InputDecoration(
              labelText: 'Specify Your Specialization',
              hintText: 'e.g., Oncology Nutrition, Eating Disorders Specialist',
              labelStyle: TextStyle(
                fontFamily: 'OpenSans',
                color: AppColors.grayText,
              ),
              hintStyle: TextStyle(
                fontFamily: 'OpenSans',
                color: AppColors.grayText.withOpacity(0.7),
              ),
              prefixIcon: Icon(
                Icons.edit_outlined,
                color: AppColors.grayText,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.lightGray),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.lightGray),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.successGreen),
              ),
            ),
            style: TextStyle(
              fontFamily: 'OpenSans',
              color: AppColors.blackText,
            ),
            validator: (value) {
              if (_isCustomSpecialization && (value?.isEmpty ?? true)) {
                return 'Please specify your specialization';
              }
              return null;
            },
          ),
        ],
      ],
    );
  }

  Widget _buildTextAreaField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    int maxLines = 3,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        labelStyle: TextStyle(
          fontFamily: 'OpenSans',
          color: AppColors.grayText,
        ),
        hintStyle: TextStyle(
          fontFamily: 'OpenSans',
          color: AppColors.grayText.withOpacity(0.7),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.lightGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.lightGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.successGreen),
        ),
        alignLabelWithHint: true,
      ),
      style: TextStyle(
        fontFamily: 'OpenSans',
        color: AppColors.blackText,
      ),
    );
  }

  Widget _buildCertificationsSection() {
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
                  Icons.verified,
                  color: AppColors.primaryAccent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Certifications',
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.blackText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Certification Input Field
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _certificationController,
                  decoration: InputDecoration(
                    hintText: 'Enter a certification (e.g., RDN, CDN, etc.)',
                    hintStyle: TextStyle(
                      fontFamily: 'OpenSans',
                      color: AppColors.grayText,
                      fontSize: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.grayText.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.primaryAccent),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.grayText.withOpacity(0.3)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  style: TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 14,
                    color: AppColors.blackText,
                  ),
                  onFieldSubmitted: (_) => _addCertification(),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                height: 48,
                child: ElevatedButton(
                  onPressed: _addCertification,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: Icon(
                    Icons.add,
                    color: AppColors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Current Certifications
          if (_selectedCertifications.isNotEmpty) ...[
            Text(
              'Current Certifications:',
              style: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.grayText,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _selectedCertifications.map((cert) => 
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.successGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.successGreen.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        cert,
                        style: TextStyle(
                          fontFamily: 'OpenSans',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.successGreen,
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCertifications.remove(cert);
                          });
                        },
                        child: Icon(
                          Icons.close,
                          size: 16,
                          color: AppColors.successGreen,
                        ),
                      ),
                    ],
                  ),
                )
              ).toList(),
            ),
            const SizedBox(height: 8),
          ],
          
          // Helper Text
          Text(
            'Add your professional certifications, licenses, or qualifications. Press Enter or tap the + button to add.',
            style: TextStyle(
              fontFamily: 'OpenSans',
              fontSize: 12,
              color: AppColors.grayText,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.successGreen,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
          ? SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: AppColors.white,
                strokeWidth: 2,
              ),
            )
          : Text(
              'Save Changes',
              style: TextStyle(
                fontFamily: 'Lato',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
      ),
    );
  }

  void _addCertification() {
    String certification = _certificationController.text.trim();
    if (certification.isNotEmpty && !_selectedCertifications.contains(certification)) {
      setState(() {
        _selectedCertifications.add(certification);
        _certificationController.clear();
      });
      
      // Show success feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Certification added: $certification'),
          backgroundColor: AppColors.successGreen,
          duration: const Duration(seconds: 2),
        ),
      );
    } else if (_selectedCertifications.contains(certification)) {
      // Show error for duplicate
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This certification is already added'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: _logout,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.red),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        icon: Icon(
          Icons.logout,
          color: Colors.red,
        ),
        label: Text(
          'Logout',
          style: TextStyle(
            fontFamily: 'Lato',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Logout',
          style: TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.bold,
            color: AppColors.blackText,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(
            fontFamily: 'OpenSans',
            color: AppColors.grayText,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'OpenSans',
                color: AppColors.grayText,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Close dialog first
              Navigator.pop(context);
              
              // Navigate to sign in page and clear all routes
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const SignInPage(),
                ),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Logout',
              style: TextStyle(
                fontFamily: 'OpenSans',
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}