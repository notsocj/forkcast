import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants.dart';
import '../../core/widgets/progress_pill.dart';
import '../../providers/profile_setup_provider.dart';
import 'height_input_page.dart';

class BirthdayEntryPage extends StatefulWidget {
  const BirthdayEntryPage({super.key});

  @override
  State<BirthdayEntryPage> createState() => _BirthdayEntryPageState();
}

class _BirthdayEntryPageState extends State<BirthdayEntryPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Date selection state
  int _selectedMonth = DateTime.now().month;
  int _selectedDay = DateTime.now().day;
  int _selectedYear = DateTime.now().year;
  
  bool _canContinue = true; // Default to true since we have default values

  // Generate lists for pickers
  final List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  
  List<int> get _days {
    int daysInMonth = DateTime(_selectedYear, _selectedMonth + 1, 0).day;
    return List.generate(daysInMonth, (index) => index + 1);
  }
  
  List<int> get _years {
    int currentYear = DateTime.now().year;
    return List.generate(100, (index) => currentYear - index);
  }

  @override
  void initState() {
    super.initState();
    _validateDate();
  }

  void _validateDate() {
    setState(() {
      // Ensure the selected day is valid for the selected month/year
      int daysInMonth = DateTime(_selectedYear, _selectedMonth, 0).day;
      if (_selectedDay > daysInMonth) {
        _selectedDay = daysInMonth;
      }
      _canContinue = true; // Always valid since we have constraints
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
            const ProgressPill(current: 3, total: 8, width: 200),
            const SizedBox(width: 12),
            const Text(
              '3/8',
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                // Top spacing and title
                const SizedBox(height: 40),
                Text(
                  "When's your birthday?",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: AppConstants.headingFont,
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                    color: AppColors.blackText,
                  ),
                ),
                const SizedBox(height: 40),
                
                // Date picker section
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Column headers
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Month',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: AppConstants.primaryFont,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.grayText,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'Day',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: AppConstants.primaryFont,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.grayText,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'Year',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: AppConstants.primaryFont,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.grayText,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        
                                // Date pickers (larger)
                                SizedBox(
                                  height: 300,
                                  child: Row(
                                    children: [
                                      // Month picker
                                      Expanded(
                                        child: _buildDatePicker(
                                          items: List.generate(_months.length, (index) => (index + 1).toString().padLeft(2, '0')),
                                          height: 300,
                                          itemExtent: 56,
                                          selectedIndex: _selectedMonth - 1,
                                          onSelectedItemChanged: (index) {
                                            setState(() {
                                              _selectedMonth = index + 1;
                                              _validateDate();
                                            });
                                          },
                                        ),
                                      ),
                                      // Day picker
                                      Expanded(
                                        child: _buildDatePicker(
                                          items: _days.map((day) => '$day'.padLeft(2, '0')).toList(),
                                          height: 300,
                                          itemExtent: 56,
                                          selectedIndex: _selectedDay - 1,
                                          onSelectedItemChanged: (index) {
                                            setState(() {
                                              _selectedDay = index + 1;
                                              _validateDate();
                                            });
                                          },
                                        ),
                                      ),
                                      // Year picker
                                      Expanded(
                                        child: _buildDatePicker(
                                          items: _years.map((year) => year.toString()).toList(),
                                          height: 300,
                                          itemExtent: 56,
                                          selectedIndex: _years.indexOf(_selectedYear),
                                          onSelectedItemChanged: (index) {
                                            setState(() {
                                              _selectedYear = _years[index];
                                              _validateDate();
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                      ],
                    ),
                  ),
                ),
                
                // Continue Button pinned to bottom
                SizedBox(
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
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker({
    required List<String> items,
    required int selectedIndex,
    required Function(int) onSelectedItemChanged,
    double height = 200,
    double itemExtent = 40,
  }) {
    return SizedBox(
      height: height,
      child: ListWheelScrollView.useDelegate(
        controller: FixedExtentScrollController(initialItem: selectedIndex),
        itemExtent: itemExtent,
        perspective: 0.005,
        diameterRatio: 1.2,
        physics: const FixedExtentScrollPhysics(),
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: items.length,
          builder: (context, index) {
            bool isSelected = index == selectedIndex;
            return Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected 
                    ? AppColors.successGreen.withOpacity(0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                items[index],
                style: TextStyle(
                  fontFamily: AppConstants.primaryFont,
                  fontSize: isSelected ? 22 : 18,
                  fontWeight: FontWeight.w600,
                  color: isSelected 
                      ? AppColors.successGreen 
                      : AppColors.blackText,
                ),
              ),
            );
          },
        ),
        onSelectedItemChanged: onSelectedItemChanged,
      ),
    );
  }

  void _handleContinue() {
    // Save birthday to profile setup provider
    final profileProvider = Provider.of<ProfileSetupProvider>(context, listen: false);
    final selectedDate = DateTime(_selectedYear, _selectedMonth, _selectedDay);
    profileProvider.setBirthdate(selectedDate);

    // Navigate to height input page
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HeightInputPage()),
    );
  }
}