  bool isOneDayBeforeOrEarlier(String? dateStr) {
    if (dateStr == null) return false;

    try {
      // Parse the given date string
      final DateTime givenDate = DateTime.parse(dateStr);

      // Get the current date (ignoring time by setting it to midnight)
      final DateTime today = DateTime.now();
      final DateTime currentDate = DateTime(today.year, today.month, today.day);

      // Check if the given date is on or after the current date
      return givenDate.isAfter(currentDate.subtract(Duration(days: 1))) ||
          givenDate.isAtSameMomentAs(currentDate);
    } catch (e) {
      // Return false if there's an error in parsing the date
      return false;
    }
  }