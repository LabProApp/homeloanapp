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

  /// Open WhatsApp with message.
  ///
  /// On Android 11+ `canLaunchUrl` is unreliable for https URLs that resolve
  /// to another app, so we try the native `whatsapp://` scheme first, then
  /// fall back to `https://wa.me/...` (which the OS resolves to WhatsApp if
  /// installed, or the browser otherwise).
  static Future<void> whatsapp(String phone, String message) async {
    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      throw 'No phone number';
    }
    final encoded = Uri.encodeComponent(message);

    final native = Uri.parse('whatsapp://send?phone=$digits&text=$encoded');
    try {
      final ok = await launchUrl(native, mode: LaunchMode.externalApplication);
      if (ok) return;
    } catch (_) {}

    final web = Uri.parse('https://wa.me/$digits?text=$encoded');
    final ok = await launchUrl(web, mode: LaunchMode.externalApplication);
    if (!ok) throw 'Could not open WhatsApp';
  }
}