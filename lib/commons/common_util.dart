import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class AppUtils {
  static final _dateFmt = DateFormat('dd MMM yyyy');

  /// Format Post Date
  static String formatDate(String? postDate) {
    if (postDate == null || postDate.isEmpty) return "-";
    try {
      return _dateFmt.format(DateTime.parse(postDate));
    } catch (e) {
      return postDate;
    }
  }

  /// Call any phone number
  static Future<void> call(String phone) async {
    final Uri callUri = Uri(scheme: 'tel', path: phone);

    if (await canLaunchUrl(callUri)) {
      await launchUrl(callUri);
    } else {
      throw 'Could not launch call';
    }
  }

  /// Open WhatsApp with message
  static Future<void> whatsapp(String phone, String message) async {
    final Uri whatsappUri = Uri.parse(
      "https://wa.me/$phone?text=${Uri.encodeComponent(message)}",
    );

    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(
        whatsappUri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      throw 'WhatsApp not installed';
    }
  }
}