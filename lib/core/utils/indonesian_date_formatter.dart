import 'package:intl/intl.dart';

class IndonesianDateFormatter {
  static const List<String> _dayNames = [
    'Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'
  ];
  
  static const List<String> _monthNames = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  /// Format date with Indonesian day name
  static String formatDateWithDayName(DateTime date) {
    final dayName = _dayNames[date.weekday % 7];
    final day = date.day;
    final monthName = _monthNames[date.month - 1];
    final year = date.year;
    
    return '$dayName, $day $monthName $year';
  }

  /// Format date with Indonesian day name (short format)
  static String formatDateWithDayNameShort(DateTime date) {
    final dayName = _dayNames[date.weekday % 7];
    final day = date.day;
    final month = date.month;
    final year = date.year;
    
    return '$dayName, $day/$month/$year';
  }

  /// Get Indonesian day name
  static String getDayName(DateTime date) {
    return _dayNames[date.weekday % 7];
  }

  /// Get Indonesian month name
  static String getMonthName(DateTime date) {
    return _monthNames[date.month - 1];
  }

  /// Format time in Indonesian format (HH:mm)
  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  /// Format date in Indonesian format (dd/MM/yyyy)
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }
}

