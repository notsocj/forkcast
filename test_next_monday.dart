// Test script to verify _getNextMonday() calculation
// Run: dart test_next_monday.dart

void main() {
  print('Testing _getNextMonday() calculation for all days of week:\n');
  
  // Test cases: [Year, Month, Day, Expected Next Monday]
  final testCases = [
    // October 2025 test cases
    [2025, 10, 13, '2025-10-13'], // Monday → Monday (today)
    [2025, 10, 14, '2025-10-20'], // Tuesday → Next Monday
    [2025, 10, 15, '2025-10-20'], // Wednesday → Next Monday
    [2025, 10, 16, '2025-10-20'], // Thursday → Next Monday
    [2025, 10, 17, '2025-10-20'], // Friday → Next Monday
    [2025, 10, 18, '2025-10-20'], // Saturday → Next Monday
    [2025, 10, 19, '2025-10-20'], // Sunday → Next Monday
    
    // Edge case: October 12, 2025 (Saturday - your reported issue)
    [2025, 10, 12, '2025-10-13'], // Saturday → Monday Oct 13
    
    // Additional test cases for different months
    [2025, 11, 3, '2025-11-03'],  // Monday Nov 3
    [2025, 11, 9, '2025-11-10'],  // Sunday Nov 9 → Monday Nov 10
    [2025, 12, 25, '2025-12-29'], // Thursday Dec 25 → Monday Dec 29
    
    // Year boundary test
    [2025, 12, 28, '2025-12-29'], // Sunday Dec 28 → Monday Dec 29
    [2025, 12, 29, '2025-12-29'], // Monday Dec 29 → Monday Dec 29
    [2025, 12, 30, '2026-01-05'], // Tuesday Dec 30 → Monday Jan 5, 2026
  ];
  
  int passed = 0;
  int failed = 0;
  
  for (final testCase in testCases) {
    final testDate = DateTime(testCase[0] as int, testCase[1] as int, testCase[2] as int);
    final expected = testCase[3] as String;
    final result = getNextMonday(testDate);
    
    final resultStr = '${result.year}-${result.month.toString().padLeft(2, '0')}-${result.day.toString().padLeft(2, '0')}';
    final dayName = _getDayName(testDate.weekday);
    
    if (resultStr == expected) {
      print('✅ PASS: ${testCase[0]}-${(testCase[1] as int).toString().padLeft(2, '0')}-${(testCase[2] as int).toString().padLeft(2, '0')} ($dayName) → $resultStr');
      passed++;
    } else {
      print('❌ FAIL: ${testCase[0]}-${(testCase[1] as int).toString().padLeft(2, '0')}-${(testCase[2] as int).toString().padLeft(2, '0')} ($dayName) → Expected: $expected, Got: $resultStr');
      failed++;
    }
  }
  
  print('\n${'=' * 60}');
  print('Test Results: $passed passed, $failed failed');
  print('${'=' * 60}');
  
  if (failed == 0) {
    print('🎉 All tests passed! The _getNextMonday() function works correctly.');
  } else {
    print('⚠️  Some tests failed. Please review the calculation logic.');
  }
}

// Fixed implementation of _getNextMonday()
DateTime getNextMonday(DateTime now) {
  final currentWeekday = now.weekday; // Monday = 1, Tuesday = 2, ..., Sunday = 7
  
  // Calculate days until next Monday
  int daysToAdd;
  if (currentWeekday == DateTime.monday) {
    daysToAdd = 0; // Today is Monday
  } else {
    daysToAdd = (DateTime.monday - currentWeekday + 7) % 7;
  }
  
  final nextMonday = now.add(Duration(days: daysToAdd));
  return DateTime(nextMonday.year, nextMonday.month, nextMonday.day);
}

String _getDayName(int weekday) {
  switch (weekday) {
    case DateTime.monday:
      return 'Monday';
    case DateTime.tuesday:
      return 'Tuesday';
    case DateTime.wednesday:
      return 'Wednesday';
    case DateTime.thursday:
      return 'Thursday';
    case DateTime.friday:
      return 'Friday';
    case DateTime.saturday:
      return 'Saturday';
    case DateTime.sunday:
      return 'Sunday';
    default:
      return 'Unknown';
  }
}
