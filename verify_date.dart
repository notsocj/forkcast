void main() {
  final date = DateTime(2025, 10, 12);
  print('October 12, 2025 is weekday: ${date.weekday}');
  print('Where 1=Monday, 2=Tuesday, 3=Wednesday, 4=Thursday, 5=Friday, 6=Saturday, 7=Sunday');
  print('');
  print('So October 12, 2025 is: ${_getDayName(date.weekday)}');
  
  // Calculate next Monday from Oct 12
  int currentWeekday = date.weekday;
  int daysToAdd;
  
  if (currentWeekday == DateTime.monday) {
    daysToAdd = 0;
  } else {
    daysToAdd = (DateTime.monday - currentWeekday + 7) % 7;
  }
  
  final nextMonday = date.add(Duration(days: daysToAdd));
  print('Next Monday from Oct 12, 2025: ${nextMonday.year}-${nextMonday.month.toString().padLeft(2, '0')}-${nextMonday.day.toString().padLeft(2, '0')}');
}

String _getDayName(int weekday) {
  switch (weekday) {
    case DateTime.monday: return 'MONDAY';
    case DateTime.tuesday: return 'TUESDAY';
    case DateTime.wednesday: return 'WEDNESDAY';
    case DateTime.thursday: return 'THURSDAY';
    case DateTime.friday: return 'FRIDAY';
    case DateTime.saturday: return 'SATURDAY';
    case DateTime.sunday: return 'SUNDAY';
    default: return 'UNKNOWN';
  }
}
