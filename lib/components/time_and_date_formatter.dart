import 'package:intl/intl.dart';

String formatTime(String timeString) {
  // Parse the time string into a DateTime object
  final timeParts = timeString.split(':');
  final hour = int.parse(timeParts[0]);
  final minute = int.parse(timeParts[1]);

  // Create a DateTime object (using a default date since we only care about time)
  final dateTime = DateTime(0, 1, 1, hour, minute);

  // Format it to a readable string (e.g., "8 AM" or "5 PM")
  return DateFormat.jm().format(dateTime); // "j" for hour (1-12), "a" for AM/PM
}

String formatDate(String date) {
  final DateFormat inputFormat = DateFormat('MM/dd/yyyy');
  DateTime parsedDate;
  try {
    parsedDate = inputFormat.parse(date);
  } catch (e) {
    return 'Invalid Date';
  }

  final DateFormat outputFormat = DateFormat('MMMM d, yyyy');
  return outputFormat.format(parsedDate); // Format to "Month Day, Year"
}
