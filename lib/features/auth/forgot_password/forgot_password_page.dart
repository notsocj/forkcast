import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants.dart';
import 'otp_code_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
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
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.blackText,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // Title with key emoji
                Row(
                  children: [
                    Text(
                      "Forgot Password?",
                      style: const TextStyle(
                        fontFamily: AppConstants.headingFont,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: AppColors.blackText,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "🔑",
                      style: TextStyle(fontSize: 24),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Description
                Text(
                  "Please enter your registered email address below. We'll send you a One-Time Password (OTP) to reset your password securely.",
                  style: const TextStyle(
                    fontFamily: AppConstants.primaryFont,
                    fontSize: 14,
                    color: AppColors.grayText,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),
                // Registered Email Address Label
                Text(
                  "Registered Email Address",
                  style: const TextStyle(
                    fontFamily: AppConstants.primaryFont,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.blackText,
                  ),
                ),
                const SizedBox(height: 8),
                // Email Input Field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: "juanlunamigueldelcruz@gmail.com",
                    hintStyle: const TextStyle(
                      color: AppColors.grayText,
                      fontFamily: AppConstants.primaryFont,
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(
                      Icons.email_outlined,
                      color: AppColors.grayText,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.grayText),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.grayText),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.primaryAccent),
                    ),
                    filled: true,
                    fillColor: AppColors.lightGray,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email address';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const Spacer(),
                // Send OTP Code Button at bottom
                SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _handleSendOTP,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.successGreen,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text(
                        "Send OTP Code",
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

  void _handleSendOTP() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('OTP code sent to ${_emailController.text}'),
          backgroundColor: AppColors.successGreen,
        ),
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OTPCodePage(email: _emailController.text),
        ),
      );
    }
  }
}