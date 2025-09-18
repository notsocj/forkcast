import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants.dart';
import '../../core/widgets/progress_pill.dart';
import '../../providers/profile_setup_provider.dart';
import 'gender_selection_page.dart';

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
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ProgressPill(current: 1, total: 8, width: 200),
            const SizedBox(width: 12),
            const Text(
              '1/8',
              style: TextStyle(
                fontFamily: AppConstants.primaryFont,
                fontSize: 14,
                color: AppColors.blackText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),
                    // Title (centered)
                    Center(
                      child: Text(
                        "What's your name?",
                        style: const TextStyle(
                          fontFamily: AppConstants.headingFont,
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                          color: AppColors.blackText,
                        ),
                      ),
                    ),
                    const SizedBox(height: 60),
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
                // Centered modern name input card
                Center(
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 520),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.successGreen.withOpacity(0.18), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.successGreen.withOpacity(0.08),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppColors.successGreen.withOpacity(0.12),
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.successGreen.withOpacity(0.22)),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.person,
                              color: AppColors.successGreen,
                              size: 28,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: TextFormField(
                            controller: _nameController,
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                              fontFamily: AppConstants.primaryFont,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: AppColors.blackText,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Enter your full name',
                              hintStyle: TextStyle(
                                color: AppColors.grayText,
                                fontFamily: AppConstants.primaryFont,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(vertical: 10),
                              suffixIcon: _nameController.text.isNotEmpty
                                  ? IconButton(
                                      icon: Icon(Icons.clear, color: AppColors.grayText),
                                      onPressed: () {
                                        _nameController.clear();
                                      },
                                    )
                                  : null,
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
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleContinue() {
    if (_formKey.currentState!.validate()) {
      // Save name to profile setup provider
      final profileProvider = Provider.of<ProfileSetupProvider>(context, listen: false);
      profileProvider.setFullName(_nameController.text.trim());

      // Navigate to gender selection page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const GenderSelectionPage()),
      );
    }
  }
}