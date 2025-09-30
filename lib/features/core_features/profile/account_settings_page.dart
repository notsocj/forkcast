import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/auth_service.dart';
import '../../auth/sign_in_page.dart';

class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Minimal Gradient Header with Back Button (clipped to avoid overflow)
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(18),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                decoration: BoxDecoration(
                  color: AppColors.successGreen,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                    // Use Expanded so title cannot push outside the header
                    const Expanded(
                      child: Text(
                        'Account Settings',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          fontFamily: 'Lato',
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  setState(() {
                    _isLoading = true;
                  });
                  await Future.delayed(const Duration(milliseconds: 500));
                  setState(() {
                    _isLoading = false;
                  });
                },
                color: AppColors.successGreen,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildModernSettingsTile(
                        icon: Icons.lock_outline,
                        title: 'Change Password',
                        onTap: () {
                          _showChangePasswordDialog(context);
                        },
                      ),
                      _buildModernDivider(),
                      _buildModernSettingsTile(
                        icon: Icons.delete_outline,
                        title: 'Delete Account',
                        textColor: AppColors.primaryAccent,
                        iconColor: AppColors.primaryAccent,
                        onTap: () {
                          _showDeleteAccountDialog(context);
                        },
                      ),
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


  Widget _buildModernSettingsTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.primaryBackground,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryAccent.withOpacity(0.07),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.successGreen).withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconColor ?? AppColors.successGreen,
                size: 22,
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor ?? AppColors.blackText,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.grayText,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      height: 1.2,
      color: AppColors.lightGray.withOpacity(0.25),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool obscureCurrentPassword = true;
    bool obscureNewPassword = true;
    bool obscureConfirmPassword = true;
    bool isChangingPassword = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Container(
            padding: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.lightGray.withOpacity(0.3),
                  width: 1,
                ),
              ),
            ),
            child: const Text(
              'Change Password',
              style: TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.bold,
                color: AppColors.blackText,
                fontSize: 20,
              ),
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Current Password Field
                _buildPasswordField(
                  controller: currentPasswordController,
                  label: 'Current Password',
                  obscureText: obscureCurrentPassword,
                  onToggleVisibility: () {
                    setState(() {
                      obscureCurrentPassword = !obscureCurrentPassword;
                    });
                  },
                ),
                const SizedBox(height: 16),
                // New Password Field
                _buildPasswordField(
                  controller: newPasswordController,
                  label: 'New Password',
                  obscureText: obscureNewPassword,
                  onToggleVisibility: () {
                    setState(() {
                      obscureNewPassword = !obscureNewPassword;
                    });
                  },
                ),
                const SizedBox(height: 16),
                // Confirm Password Field
                _buildPasswordField(
                  controller: confirmPasswordController,
                  label: 'Confirm New Password',
                  obscureText: obscureConfirmPassword,
                  onToggleVisibility: () {
                    setState(() {
                      obscureConfirmPassword = !obscureConfirmPassword;
                    });
                  },
                ),
                const SizedBox(height: 8),
                // Password Requirements
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.successGreen.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Password Requirements:',
                        style: TextStyle(
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w600,
                          color: AppColors.blackText,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '• At least 6 characters long\n• Contains letters and numbers\n• Avoid using personal information',
                        style: TextStyle(
                          fontFamily: 'Lato',
                          color: AppColors.grayText,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isChangingPassword ? null : () {
                Navigator.of(ctx).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: isChangingPassword ? AppColors.grayText : AppColors.grayText,
                  fontFamily: 'Lato',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: isChangingPassword ? null : () async {
                // Validation
                if (currentPasswordController.text.isEmpty ||
                    newPasswordController.text.isEmpty ||
                    confirmPasswordController.text.isEmpty) {
                  _showErrorSnackBar(context, 'Please fill in all fields');
                  return;
                }

                if (newPasswordController.text != confirmPasswordController.text) {
                  _showErrorSnackBar(context, 'New passwords do not match');
                  return;
                }

                if (newPasswordController.text.length < 6) {
                  _showErrorSnackBar(context, 'New password must be at least 6 characters long');
                  return;
                }

                setState(() {
                  isChangingPassword = true;
                });

                try {
                  await _authService.changePassword(
                    currentPassword: currentPasswordController.text,
                    newPassword: newPasswordController.text,
                  );

                  if (mounted) {
                    Navigator.of(ctx).pop();
                    _showSuccessSnackBar(context, 'Password changed successfully!');
                  }
                } catch (e) {
                  setState(() {
                    isChangingPassword = false;
                  });
                  if (mounted) {
                    _showErrorSnackBar(context, e.toString().replaceFirst('Exception: ', ''));
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.successGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: isChangingPassword
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Change Password',
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          fontFamily: 'Lato',
          color: AppColors.grayText,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.lightGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.successGreen),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
            color: AppColors.grayText,
          ),
          onPressed: onToggleVisibility,
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    final passwordController = TextEditingController();
    bool obscurePassword = true;
    bool isDeletingAccount = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Container(
            padding: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.primaryAccent.withOpacity(0.3),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_outlined,
                  color: AppColors.primaryAccent,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Delete Account',
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.bold,
                    color: AppColors.blackText,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Warning Message
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryAccent.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.primaryAccent.withOpacity(0.2),
                    ),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '⚠️ This action cannot be undone!',
                        style: TextStyle(
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w600,
                          color: AppColors.blackText,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Deleting your account will permanently remove:\n\n• Your profile and personal information\n• All saved meal plans and preferences\n• Consultation history and notes\n• Forum posts and saved content\n• All app data associated with your account',
                        style: TextStyle(
                          fontFamily: 'Lato',
                          color: AppColors.grayText,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Password Confirmation
                const Text(
                  'Please enter your password to confirm account deletion:',
                  style: TextStyle(
                    fontFamily: 'Lato',
                    color: AppColors.blackText,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Current Password',
                    labelStyle: const TextStyle(
                      fontFamily: 'Lato',
                      color: AppColors.grayText,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.lightGray),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.primaryAccent),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.grayText,
                      ),
                      onPressed: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isDeletingAccount ? null : () {
                Navigator.of(ctx).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: isDeletingAccount ? AppColors.grayText : AppColors.grayText,
                  fontFamily: 'Lato',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: isDeletingAccount ? null : () async {
                if (passwordController.text.isEmpty) {
                  _showErrorSnackBar(context, 'Please enter your password');
                  return;
                }

                setState(() {
                  isDeletingAccount = true;
                });

                try {
                  await _authService.deleteAccount(passwordController.text);
                  
                  if (mounted) {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const SignInPage()),
                      (route) => false,
                    );
                    
                    _showSuccessSnackBar(context, 'Account deleted successfully');
                  }
                } catch (e) {
                  setState(() {
                    isDeletingAccount = false;
                  });
                  if (mounted) {
                    _showErrorSnackBar(context, e.toString().replaceFirst('Exception: ', ''));
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: isDeletingAccount
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Delete Account',
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.successGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primaryAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}