import 'package:intl/intl.dart';

// Suppose widget.property.postDate is a String or DateTime
String getFormattedDate(String? dateStr) {
  if (dateStr == null || dateStr.isEmpty) return "-";

  try {
    // Try parsing the string to DateTime
    final date = DateTime.parse(dateStr);
    // Format as: 03 Jan 2026
    return DateFormat("dd MMM yyyy").format(date);
  } catch (e) {
    return dateStr; // fallback if parsing fails
  }
}
