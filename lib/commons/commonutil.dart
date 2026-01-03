import 'package:intl/intl.dart';

String formatPostDate(String? postDate) {
  if (postDate == null || postDate.isEmpty) return "-";

  try {
    final dt = DateTime.parse(postDate); // parse string to DateTime
    return DateFormat('dd MMM yyyy').format(dt); // format
  } catch (e) {
    return postDate; // fallback: return original string if parsing fails
  }
}
