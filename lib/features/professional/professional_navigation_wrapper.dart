import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'consultations/consultation_dashboard_page.dart';
import 'consultations/upcoming_schedules_page.dart';
import 'consultations/patient_notes_page.dart';
import 'profile/update_profile_page.dart';
import 'profile/manage_availability_page.dart';

class ProfessionalNavigationWrapper extends StatefulWidget {
  const ProfessionalNavigationWrapper({super.key});

  @override
  State<ProfessionalNavigationWrapper> createState() => _ProfessionalNavigationWrapperState();
}

class _ProfessionalNavigationWrapperState extends State<ProfessionalNavigationWrapper> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const ConsultationDashboardPage(),    // Dashboard
    const UpcomingSchedulesPage(),        // Schedules
    const PatientNotesPage(),            // Patient Notes
    const UpdateProfilePage(),           // Profile
    const ManageAvailabilityPage(),      // Availability
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: ProfessionalBottomNavigation(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class ProfessionalBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const ProfessionalBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _buildNavItem(
                  index: 0,
                  icon: Icons.dashboard_outlined,
                  activeIcon: Icons.dashboard,
                  label: 'Dashboard',
                ),
              ),
              Expanded(
                child: _buildNavItem(
                  index: 1,
                  icon: Icons.schedule_outlined,
                  activeIcon: Icons.schedule,
                  label: 'Schedules',
                ),
              ),
              Expanded(
                child: _buildNavItem(
                  index: 2,
                  icon: Icons.note_alt_outlined,
                  activeIcon: Icons.note_alt,
                  label: 'Notes',
                ),
              ),
              Expanded(
                child: _buildNavItem(
                  index: 3,
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: 'Profile',
                ),
              ),
              Expanded(
                child: _buildNavItem(
                  index: 4,
                  icon: Icons.calendar_today_outlined,
                  activeIcon: Icons.calendar_today,
                  label: 'Hours',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final bool isActive = currentIndex == index;
    
    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isActive ? AppColors.successGreen.withOpacity(0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isActive ? activeIcon : icon,
                color: isActive ? AppColors.successGreen : AppColors.grayText,
                size: 22,
              ),
            ),
            const SizedBox(height: 2),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'OpenSans',
                  fontSize: 9,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  color: isActive ? AppColors.successGreen : AppColors.grayText,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}