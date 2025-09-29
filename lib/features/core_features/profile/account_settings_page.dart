import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class AccountSettingsPage extends StatelessWidget {
  const AccountSettingsPage({super.key});

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
                  // Simple refresh delay since this is a StatelessWidget
                  await Future.delayed(const Duration(milliseconds: 500));
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
    showDialog(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        title: const Text(
          'Change Password',
          style: TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.bold,
            color: AppColors.blackText,
          ),
        ),
        content: const Text(
          'Password change functionality will be implemented soon. This feature will allow you to securely update your account password.',
          style: TextStyle(
            fontFamily: 'Lato',
            color: AppColors.grayText,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'OK',
              style: TextStyle(color: AppColors.successGreen),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
              // TODO: Implement actual account deletion logic
            },
            child: Text(
              'Delete',
              style: TextStyle(color: AppColors.primaryAccent),
            ),
          ),
        ],
      ),
    );
  }
}