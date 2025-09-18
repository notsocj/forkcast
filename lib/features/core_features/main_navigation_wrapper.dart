import 'package:flutter/material.dart';
import '../../core/widgets/main_bottom_navigation.dart';
import 'dashboard/user_dashboard_page.dart';
import 'profile/user_profile_page.dart';

class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({super.key});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const UserDashboardPage(),      // Home
    const UserProfilePage(),        // Profile
    const PlaceholderPage(title: 'Price Monitoring'),    // Price Monitoring
    const PlaceholderPage(title: 'Meal Plan'),           // Meal Plan
    const PlaceholderPage(title: 'Q&A Forum'),          // Q&A Forum
    const PlaceholderPage(title: 'Teleconsultation'),    // Teleconsultation
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: MainBottomNavigation(
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

// Placeholder widget for unimplemented pages
class PlaceholderPage extends StatelessWidget {
  final String title;
  
  const PlaceholderPage({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.grey[100],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '$title\nComing Soon',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}