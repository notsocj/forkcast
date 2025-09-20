import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers for form fields
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _birthdateController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _householdSizeController = TextEditingController();
  final _healthConditionsController = TextEditingController();
  final _foodAllergiesController = TextEditingController();
  
  String _selectedGender = 'Male';
  String _selectedBudget = '₱1000-2000';
  
  @override
  void initState() {
    super.initState();
    // Initialize with current user data
    _loadUserData();
  }
  
  void _loadUserData() {
    // TODO: Load user data from Firebase
    _fullNameController.text = 'Juan Dela Cruz';
    _emailController.text = 'juandelacruz@example.com';
    _phoneController.text = '+63 9311234567';
    _birthdateController.text = '11-26-2001';
    _weightController.text = '65 kg';
    _heightController.text = '168 cm';
    _householdSizeController.text = '5 people';
    _healthConditionsController.text = 'Hypertension';
    _foodAllergiesController.text = '';
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
    _healthConditionsController.dispose();
    _foodAllergiesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Header with Back Button
            _buildHeader(),
            // Form Content
            Expanded(
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
                      
                      // Email
                      _buildTextField(
                        controller: _emailController,
                        label: 'Email',
                        keyboardType: TextInputType.emailAddress,
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
                      
                      // Weekly Budget Dropdown
                      _buildDropdownField(
                        label: 'Weekly Budget',
                        value: _selectedBudget,
                        items: ['₱500-1000', '₱1000-2000', '₱2000-3000', '₱3000+'],
                        onChanged: (value) {
                          setState(() {
                            _selectedBudget = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Household Size
                      _buildTextField(
                        controller: _householdSizeController,
                        label: 'Household Size',
                      ),
                      const SizedBox(height: 16),
                      
                      // Health Conditions with Add New button
                      _buildExpandableField(
                        controller: _healthConditionsController,
                        label: 'Health Condition',
                        addButtonText: 'Add New',
                        onAddPressed: () {
                          _showAddHealthConditionDialog();
                        },
                      ),
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
              child: const Icon(
                Icons.person,
                size: 50,
                color: Colors.white,
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
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: DateTime(2001, 11, 26),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              setState(() {
                _birthdateController.text = 
                    '${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}-${picked.year}';
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
  
  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
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
        child: Text(
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
  
  void _saveProfile() {
    // TODO: Implement save profile logic with Firebase
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
    Navigator.of(context).pop();
  }
  
  void _showAddHealthConditionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController dialogController = TextEditingController();
        return AlertDialog(
          title: Text(
            'Add Health Condition',
            style: TextStyle(
              fontFamily: 'Lato',
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: dialogController,
            decoration: InputDecoration(
              hintText: 'Enter health condition',
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
                  // Add logic to append to health conditions
                  String currentText = _healthConditionsController.text;
                  if (currentText.isNotEmpty) {
                    _healthConditionsController.text = '$currentText, ${dialogController.text}';
                  } else {
                    _healthConditionsController.text = dialogController.text;
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