const List<String> _dayNames = [
  'Senin',
  'Selasa',
  'Rabu',
  'Kamis',
  'Jumat',
  'Sabtu',
  'Minggu'
];

const List<String> _monthNames = [
  'Januari',
  'Februari',
  'Maret',
  'April',
  'Mei',
  'Juni',
  'Juli',
  'Agustus',
  'September',
  'Oktober',
  'November',
  'Desember'
];

extension DateTimeExt on DateTime {
  String toFormattedDate() {
    String dayName = _dayNames[weekday - 1];
    String day = this.day.toString();
    String month = _monthNames[this.month - 1];
    String year = this.year.toString();

    return '$dayName, $day $month $year';
  }

  String toFormattedTime() {
    String hour = this.hour.toString().padLeft(2, '0');
    String minute = this.minute.toString().padLeft(2, '0');

    return '$hour:$minute WIB';
  }

  /// Convert to WITA timezone and format as time string
  String toWITATime() {
    // Convert current time to WITA (UTC+8)
    final witaTime = toUtc().add(const Duration(hours: 8));
    String hour = witaTime.hour.toString().padLeft(2, '0');
    String minute = witaTime.minute.toString().padLeft(2, '0');
    
    return '$hour:$minute WITA';
  }
}

extension StringTimeExt on String {
  /// Convert time string (HH:mm or HH:mm:ss) to WITA timezone format
  String toWITAFormat() {
    try {
      // Parse the time string
      final parts = split(':');
      if (parts.length >= 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        
        // Create DateTime object for today with the parsed time
        final now = DateTime.now();
        final timeDateTime = DateTime(now.year, now.month, now.day, hour, minute);
        
        // Convert to WITA (assuming the original time is in UTC or server timezone)
        // If the server already sends WITA time, we can just format it
        String formattedHour = hour.toString().padLeft(2, '0');
        String formattedMinute = minute.toString().padLeft(2, '0');
        
        return '$formattedHour:$formattedMinute WITA';
      }
      return '$this WITA'; // Fallback
    } catch (e) {
      return '$this WITA'; // Fallback if parsing fails
    }
  }
}
