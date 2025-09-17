import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants.dart';

class NameEntryPage extends StatefulWidget {
  const NameEntryPage({super.key});

  @override
  State<NameEntryPage> createState() => _NameEntryPageState();
}

class _NameEntryPageState extends State<NameEntryPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _canContinue = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_updateContinueButton);
  }

  @override
  void dispose() {
    _nameController.removeListener(_updateContinueButton);
    _nameController.dispose();
    super.dispose();
  }

  void _updateContinueButton() {
    setState(() {
      _canContinue = _nameController.text.trim().isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.blackText,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.darkGray,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            "1/8",
            style: TextStyle(
              fontFamily: AppConstants.primaryFont,
              fontSize: 14,
              color: AppColors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                // Title
                Text(
                  "What's your name?",
                  style: const TextStyle(
                    fontFamily: AppConstants.headingFont,
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                    color: AppColors.blackText,
                  ),
                ),
                const SizedBox(height: 80),
                // Name Input Field with Purple Border
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.purpleAccent,
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.grayText.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextFormField(
                      controller: _nameController,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: AppConstants.primaryFont,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.blackText,
                      ),
                      decoration: InputDecoration(
                        hintText: "Enter your full name",
                        hintStyle: TextStyle(
                          fontFamily: AppConstants.primaryFont,
                          fontSize: 18,
                          color: AppColors.grayText.withOpacity(0.7),
                          fontWeight: FontWeight.w500,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 20,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your name';
                        }
                        if (value.trim().length < 2) {
                          return 'Name must be at least 2 characters long';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                const Spacer(),
                // Continue Button
                SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _canContinue ? _handleContinue : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _canContinue 
                            ? AppColors.successGreen 
                            : AppColors.grayText.withOpacity(0.3),
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Continue",
                        style: TextStyle(
                          fontFamily: AppConstants.primaryFont,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleContinue() {
    if (_formKey.currentState!.validate()) {
      // TODO: Save name to user profile and navigate to next setup page
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Name saved: ${_nameController.text.trim()}'),
          backgroundColor: AppColors.successGreen,
        ),
      );
      // TODO: Navigate to gender selection page
      // Navigator.push(context, MaterialPageRoute(builder: (context) => GenderSelectionPage()));
    }
  }
}