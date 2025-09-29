import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/auth_service.dart';
import '../../../services/user_service.dart';
import '../../../models/user.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  
  // Controllers for form fields
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _birthdateController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _householdSizeController = TextEditingController();
  final _weeklyBudgetController = TextEditingController();
  final _healthConditionsController = TextEditingController();
  final _foodAllergiesController = TextEditingController();
  
  String _selectedGender = 'Male';
  User? _currentUser;
  bool _isLoading = true;
  bool _isSaving = false;
  
  // Health conditions dropdown data
  final List<String> _availableHealthConditions = [
    'Diabetes',
    'Hypertension',
    'Obesity / Overweight',
    'Underweight / Malnutrition',
    'Heart Disease / High Cholesterol',
    'Anemia (Iron-deficiency)',
    'Osteoporosis (Bone health / calcium deficiency)',
    'None (healthy profile, no NCDs)',
  ];
  
  List<String> _selectedHealthConditions = [];
  
  @override
  void initState() {
    super.initState();
    // Initialize with current user data
    _loadUserData();
  }
  
  Future<void> _loadUserData() async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser != null) {
        final userData = await _userService.getUser(currentUser.uid);
        if (userData != null) {
          setState(() {
            _currentUser = userData;
            _populateForm(userData);
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load user data: $e')),
      );
    }
  }
  
  void _populateForm(User user) {
    _fullNameController.text = user.fullName;
    _emailController.text = user.email;
    _phoneController.text = user.phoneNumber ?? '';
    _birthdateController.text = '${user.birthdate.day.toString().padLeft(2, '0')}-${user.birthdate.month.toString().padLeft(2, '0')}-${user.birthdate.year}';
    _weightController.text = '${user.weightKg.toStringAsFixed(1)} kg';
    _heightController.text = '${user.heightCm.toStringAsFixed(0)} cm';
    _householdSizeController.text = '${user.householdSize} people';
    _weeklyBudgetController.text = user.weeklyBudgetMin == user.weeklyBudgetMax 
        ? '₱${user.weeklyBudgetMin}' 
        : '₱${user.weeklyBudgetMin}-${user.weeklyBudgetMax}';
    _selectedGender = user.gender;
    
    // Initialize selected health conditions
    _selectedHealthConditions = user.healthConditions ?? [];
    _healthConditionsController.text = user.healthConditions?.join(', ') ?? '';
    _foodAllergiesController.text = user.foodAllergies?.join(', ') ?? '';
  }
  
  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _birthdateController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _householdSizeController.dispose();
    _weeklyBudgetController.dispose();
    _healthConditionsController.dispose();
    _foodAllergiesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.primaryBackground,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.successGreen),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Header with Back Button
            _buildHeader(),
            // Form Content
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadUserData,
                color: AppColors.successGreen,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Profile Picture Section
                      _buildProfilePictureSection(),
                      const SizedBox(height: 24),
                      
                      // Full Name
                      _buildTextField(
                        controller: _fullNameController,
                        label: 'Full Name',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your full name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Email (Non-editable)
                      _buildTextField(
                        controller: _emailController,
                        label: 'Email (Cannot be changed)',
                        keyboardType: TextInputType.emailAddress,
                        readOnly: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!value.contains('@')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Phone Number
                      _buildTextField(
                        controller: _phoneController,
                        label: 'Phone Number',
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      
                      // Gender Dropdown
                      _buildDropdownField(
                        label: 'Gender',
                        value: _selectedGender,
                        items: ['Male', 'Female', 'Prefer not to say'],
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Birthdate with calendar picker
                      _buildDateField(),
                      const SizedBox(height: 16),
                      
                      // Weight and Height Row
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _weightController,
                              label: 'Weight',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              controller: _heightController,
                              label: 'Height',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Weekly Budget Text Input
                      _buildTextField(
                        controller: _weeklyBudgetController,
                        label: 'Weekly Budget',
                        keyboardType: TextInputType.text,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your weekly budget';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Household Size
                      _buildTextField(
                        controller: _householdSizeController,
                        label: 'Household Size',
                      ),
                      const SizedBox(height: 16),
                      
                      // Health Conditions dropdown
                      _buildHealthConditionsDropdown(),
                      const SizedBox(height: 16),
                      
                      // Food Allergies with Add New button
                      _buildExpandableField(
                        controller: _foodAllergiesController,
                        label: 'Food Allergies',
                        addButtonText: 'Add New',
                        onAddPressed: () {
                          _showAddFoodAllergyDialog();
                        },
                      ),
                      const SizedBox(height: 32),
                      
                      // Save Button
                      _buildSaveButton(),
                      const SizedBox(height: 20),
                    ],
                  ),
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
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        color: AppColors.successGreen,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(18),
          bottomRight: Radius.circular(18),
        ),
      ),
      child: Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(32),
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'Edit Profile',
            style: TextStyle(
              fontFamily: 'Lato',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildProfilePictureSection() {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryAccent,
                border: Border.all(color: AppColors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  _currentUser?.fullName.isNotEmpty == true 
                      ? _currentUser!.fullName[0].toUpperCase()
                      : 'U',
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.successGreen,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 2),
                ),
                child: const Icon(
                  Icons.edit,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.blackText,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          readOnly: readOnly,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.white,
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
              borderSide: BorderSide(color: AppColors.successGreen, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          style: TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 14,
            color: AppColors.blackText,
          ),
        ),
      ],
    );
  }
  
  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.blackText,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.lightGray),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 14,
                    color: AppColors.blackText,
                  ),
                ),
              );
            }).toList(),
            onChanged: onChanged,
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.grayText,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Birthdate',
          style: TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.blackText,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _birthdateController,
          readOnly: true,
          onTap: () async {
            // Parse current date from controller to set as initial date
            DateTime initialDate = DateTime(2001, 11, 26); // Default fallback
            try {
              final currentText = _birthdateController.text.trim();
              if (currentText.isNotEmpty) {
                final parts = currentText.split('-');
                if (parts.length == 3) {
                  final day = int.parse(parts[0]);
                  final month = int.parse(parts[1]);
                  final year = int.parse(parts[2]);
                  initialDate = DateTime(year, month, day);
                }
              }
            } catch (e) {
              // Use default if parsing fails
            }

            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: initialDate,
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              setState(() {
                _birthdateController.text = 
                    '${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}';
              });
            }
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.white,
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
              borderSide: BorderSide(color: AppColors.successGreen, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            suffixIcon: Icon(
              Icons.calendar_today,
              color: AppColors.grayText,
              size: 20,
            ),
          ),
          style: TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 14,
            color: AppColors.blackText,
          ),
        ),
      ],
    );
  }
  
  Widget _buildExpandableField({
    required TextEditingController controller,
    required String label,
    required String addButtonText,
    required VoidCallback onAddPressed,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.blackText,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.white,
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
              borderSide: BorderSide(color: AppColors.successGreen, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          style: TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 14,
            color: AppColors.blackText,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onAddPressed,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.lightGray),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.add_circle_outline,
                  color: AppColors.successGreen,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  addButtonText,
                  style: TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 14,
                    color: AppColors.successGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildHealthConditionsDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Health Conditions',
          style: TextStyle(
            fontFamily: 'Lato',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.blackText,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.lightGray),
          ),
          child: Column(
            children: [
              // Display selected conditions
              if (_selectedHealthConditions.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _selectedHealthConditions.map((condition) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.successGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.successGreen.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              condition,
                              style: TextStyle(
                                fontFamily: 'OpenSans',
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.successGreen,
                              ),
                            ),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedHealthConditions.remove(condition);
                                  _healthConditionsController.text = _selectedHealthConditions.join(', ');
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
                      );
                    }).toList(),
                  ),
                ),
              
              // Dropdown for available conditions
              GestureDetector(
                onTap: () {
                  _showHealthConditionsDialog();
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    border: _selectedHealthConditions.isNotEmpty 
                        ? Border(top: BorderSide(color: AppColors.lightGray))
                        : null,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.add_circle_outline,
                        color: AppColors.successGreen,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _selectedHealthConditions.isEmpty 
                            ? 'Select health conditions' 
                            : 'Add more conditions',
                        style: TextStyle(
                          fontFamily: 'OpenSans',
                          fontSize: 14,
                          color: AppColors.grayText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isSaving ? null : () {
          if (_formKey.currentState!.validate()) {
            _saveProfile();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.successGreen,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isSaving 
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                'Save Changes',
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
  
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isSaving = true;
    });
    
    try {
      final currentUser = _authService.currentUser;
      if (currentUser != null && _currentUser != null) {
        // Parse form data
        final weightText = _weightController.text.replaceAll(RegExp(r'[^0-9.]'), '');
        final heightText = _heightController.text.replaceAll(RegExp(r'[^0-9.]'), '');
        final householdText = _householdSizeController.text.replaceAll(RegExp(r'[^0-9]'), '');
        
        // Parse birthdate from controller (DD-MM-YYYY format)
        DateTime? parsedBirthdate;
        try {
          final birthdateText = _birthdateController.text.trim();
          if (birthdateText.isNotEmpty) {
            final parts = birthdateText.split('-');
            if (parts.length == 3) {
              final day = int.parse(parts[0]);
              final month = int.parse(parts[1]);
              final year = int.parse(parts[2]);
              parsedBirthdate = DateTime(year, month, day);
            }
          }
        } catch (e) {
          // If parsing fails, keep the original birthdate
          parsedBirthdate = _currentUser!.birthdate;
        }
        
        // Parse budget from text input
        int budgetMin, budgetMax;
        try {
          final budgetText = _weeklyBudgetController.text.trim();
          
          // Handle different formats: "₱1000-2000", "1000-2000", "₱1500", "1500"
          final budgetClean = budgetText.replaceAll('₱', '').replaceAll(',', '');
          
          if (budgetClean.contains('-')) {
            // Range format: "1000-2000"
            final parts = budgetClean.split('-');
            if (parts.length == 2) {
              budgetMin = int.parse(parts[0].trim());
              budgetMax = int.parse(parts[1].trim());
            } else {
              // Fallback to current values
              budgetMin = _currentUser!.weeklyBudgetMin;
              budgetMax = _currentUser!.weeklyBudgetMax;
            }
          } else {
            // Single value format: "1500" - treat as both min and max
            final amount = int.parse(budgetClean);
            budgetMin = amount;
            budgetMax = amount;
          }
        } catch (e) {
          // If parsing fails, keep the original budget
          budgetMin = _currentUser!.weeklyBudgetMin;
          budgetMax = _currentUser!.weeklyBudgetMax;
        }
        
        // Use selected health conditions from dropdown
        List<String> healthConditions = List.from(_selectedHealthConditions);
        
        // Parse food allergies
        List<String> foodAllergies = _foodAllergiesController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
        
        // Create updated user object
        User updatedUser = _currentUser!.copyWith(
          fullName: _fullNameController.text.trim(),
          phoneNumber: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
          gender: _selectedGender,
          birthdate: parsedBirthdate ?? _currentUser!.birthdate,
          weightKg: double.tryParse(weightText) ?? _currentUser!.weightKg,
          heightCm: double.tryParse(heightText) ?? _currentUser!.heightCm,
          householdSize: int.tryParse(householdText) ?? _currentUser!.householdSize,
          weeklyBudgetMin: budgetMin,
          weeklyBudgetMax: budgetMax,
          healthConditions: healthConditions.isEmpty ? null : healthConditions,
          foodAllergies: foodAllergies.isEmpty ? null : foodAllergies,
        );
        
        // Save to Firebase
        await _userService.createOrUpdateUser(updatedUser);
        
        // Update health conditions subcollection
        if (healthConditions.isNotEmpty) {
          await _userService.updateHealthConditions(currentUser.uid, healthConditions);
        }
        
        setState(() {
          _isSaving = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: AppColors.successGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }
  
  void _showHealthConditionsDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header with gradient background
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.successGreen,
                            AppColors.successGreen.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.health_and_safety,
                                  color: AppColors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Select Health Conditions',
                                  style: TextStyle(
                                    fontFamily: 'Lato',
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Select all conditions that apply to you:',
                            style: TextStyle(
                              fontFamily: 'OpenSans',
                              fontSize: 14,
                              color: AppColors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Content area with conditions
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        child: SingleChildScrollView(
                          child: Column(
                            children: _availableHealthConditions.map((condition) {
                              final isSelected = _selectedHealthConditions.contains(condition);
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: isSelected 
                                      ? AppColors.successGreen.withOpacity(0.1)
                                      : AppColors.primaryBackground,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected 
                                        ? AppColors.successGreen.withOpacity(0.3)
                                        : AppColors.lightGray.withOpacity(0.5),
                                    width: 1.5,
                                  ),
                                ),
                                child: CheckboxListTile(
                                  value: isSelected,
                                  onChanged: (bool? value) {
                                    setDialogState(() {
                                      if (value == true) {
                                        if (!_selectedHealthConditions.contains(condition)) {
                                          _selectedHealthConditions.add(condition);
                                        }
                                      } else {
                                        _selectedHealthConditions.remove(condition);
                                      }
                                    });
                                  },
                                  title: Text(
                                    condition,
                                    style: TextStyle(
                                      fontFamily: 'OpenSans',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: isSelected 
                                          ? AppColors.successGreen
                                          : AppColors.blackText,
                                    ),
                                  ),
                                  activeColor: AppColors.successGreen,
                                  checkColor: AppColors.white,
                                  controlAffinity: ListTileControlAffinity.leading,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                    
                    // Action buttons
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: AppColors.grayText.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  fontFamily: 'OpenSans',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.grayText,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _healthConditionsController.text = _selectedHealthConditions.join(', ');
                                });
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.successGreen,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                                shadowColor: AppColors.successGreen.withOpacity(0.3),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.check,
                                    color: AppColors.white,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Done',
                                    style: TextStyle(
                                      fontFamily: 'Lato',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
  
  void _showAddFoodAllergyDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController dialogController = TextEditingController();
        return AlertDialog(
          title: Text(
            'Add Food Allergy',
            style: TextStyle(
              fontFamily: 'Lato',
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: dialogController,
            decoration: InputDecoration(
              hintText: 'Enter food allergy',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
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
                if (dialogController.text.isNotEmpty) {
                  // Add logic to append to food allergies
                  String currentText = _foodAllergiesController.text;
                  if (currentText.isNotEmpty) {
                    _foodAllergiesController.text = '$currentText, ${dialogController.text}';
                  } else {
                    _foodAllergiesController.text = dialogController.text;
                  }
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.successGreen,
              ),
              child: Text(
                'Add',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}