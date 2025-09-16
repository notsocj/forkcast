import 'package:flutter/material.dart';
import 'dart:async';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants.dart';
import 'create_new_password_page.dart';

class OTPCodePage extends StatefulWidget {
  final String email;
  const OTPCodePage({super.key, required this.email});

  @override
  State<OTPCodePage> createState() => _OTPCodePageState();
}

class _OTPCodePageState extends State<OTPCodePage> {
  bool _canSubmitOTP() {
    return otpDigits.every((d) => d.isNotEmpty);
  }
  final int otpLength = 4;
  List<String> otpDigits = List.filled(4, '');
  int currentIndex = 0;
  int resendSeconds = 59;
  late final TextEditingController _hiddenController;
  late final FocusNode _hiddenFocusNode;
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _hiddenController = TextEditingController();
    _hiddenFocusNode = FocusNode();
    _startResendTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_hiddenFocusNode);
    });
  }

  void _startResendTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendSeconds > 0) {
        setState(() {
          resendSeconds--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _hiddenController.dispose();
    _hiddenFocusNode.dispose();
    super.dispose();
  }

  void _onKeyTap(String value) {
    if (value == '<') {
      // Backspace
      for (int i = otpLength - 1; i >= 0; i--) {
        if (otpDigits[i].isNotEmpty) {
          setState(() {
            otpDigits[i] = '';
            currentIndex = i;
          });
          break;
        }
      }
    } else if (currentIndex < otpLength && value != '*') {
      setState(() {
        otpDigits[currentIndex] = value;
        if (currentIndex < otpLength - 1) currentIndex++;
      });
    }
  }

  void _onResendCode() {
    if (resendSeconds == 0) {
      setState(() {
        resendSeconds = 59;
      });
      _startResendTimer();
      // TODO: Implement resend OTP logic
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP code resent'),
          backgroundColor: AppColors.successGreen,
        ),
      );
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      resizeToAvoidBottomInset: true,
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // Title with lock emoji
                Row(
                  children: [
                    Text(
                      "Enter OTP Code",
                      style: const TextStyle(
                        fontFamily: AppConstants.headingFont,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: AppColors.blackText,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text("🔒", style: TextStyle(fontSize: 24)),
                  ],
                ),
                const SizedBox(height: 16),
                // Description
                Text(
                  "We've sent a 4-digit OTP code to your email address. Please enter it below to verify and continue with password reset.",
                  style: const TextStyle(
                    fontFamily: AppConstants.primaryFont,
                    fontSize: 14,
                    color: AppColors.grayText,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                // OTP Input Boxes
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(otpLength, (i) {
                    bool isActive = currentIndex == i;
                    return Container(
                      width: 48,
                      height: 56,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isActive ? AppColors.successGreen : AppColors.grayText,
                          width: isActive ? 2 : 1,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        otpDigits[i],
                        style: const TextStyle(
                          fontFamily: AppConstants.headingFont,
                          fontSize: 24,
                          color: AppColors.blackText,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),
                // Resend timer and code
                Center(
                  child: Column(
                    children: [
                      Text(
                        "You can resend the code in  ${resendSeconds}  seconds",
                        style: const TextStyle(
                          fontFamily: AppConstants.primaryFont,
                          fontSize: 14,
                          color: AppColors.grayText,
                        ),
                      ),
                      GestureDetector(
                        onTap: _onResendCode,
                        child: Text(
                          "Resend code",
                          style: TextStyle(
                            fontFamily: AppConstants.primaryFont,
                            fontSize: 14,
                            color: resendSeconds == 0 ? AppColors.successGreen : AppColors.grayText,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Numeric Keypad
                _buildKeypad(),
                const SizedBox(height: 16),
                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _canSubmitOTP()
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CreateNewPasswordPage(),
                              ),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _canSubmitOTP()
                          ? AppColors.successGreen
                          : AppColors.grayText,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      "Submit",
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

  Widget _buildKeypad() {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['*', '0', '<'],
    ];
    return Column(
      children: keys.map((row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: row.map((key) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: GestureDetector(
                onTap: () => _onKeyTap(key),
                child: Container(
                  width: 64,
                  height: 48,
                  decoration: BoxDecoration(
                    color: key == '<' ? AppColors.lightGray : AppColors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.grayText, width: 0.5),
                  ),
                  alignment: Alignment.center,
                  child: key == '<'
                      ? const Icon(Icons.backspace_outlined, color: AppColors.grayText)
                      : Text(
                          key,
                          style: const TextStyle(
                            fontFamily: AppConstants.headingFont,
                            fontSize: 22,
                            color: AppColors.blackText,
                          ),
                        ),
                ),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}
