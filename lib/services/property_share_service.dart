import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/property_model.dart';

class PropertyShareService {
  static final _fmt = NumberFormat('#,##,###');

  // ── Deep link ────────────────────────────────────────────────────────────

  static String deepLink(PropertyModel p) =>
      'keybricks://property?id=${p.id ?? 0}';

  // ── Formatted price ──────────────────────────────────────────────────────

  static String _price(PropertyModel p) {
    final isRent = p.rentOrSale?.toUpperCase() == 'RENT';
    if (isRent) {
      final amt = p.monthlyRent ?? p.price;
      return amt != null ? '₹${_fmt.format(amt)}/month' : 'Contact for price';
    }
    return p.price != null ? '₹${_fmt.format(p.price)}' : 'Contact for price';
  }

  // ── Message builders ─────────────────────────────────────────────────────

  static String whatsAppText(PropertyModel p) {
    final buf = StringBuffer();
    buf.writeln('🏠 *${p.title ?? 'Property'}*');

    final loc = [p.location, p.city, p.state]
        .where((s) => s != null && s.isNotEmpty)
        .join(', ');
    if (loc.isNotEmpty) buf.writeln('📍 $loc');

    buf.writeln('💰 ${_price(p)}');

    final specs = <String>[];
    if (p.bedrooms != null) specs.add('🛏 ${p.bedrooms} Beds');
    if (p.bathrooms != null) specs.add('🛁 ${p.bathrooms} Bath');
    if (p.superArea != null) specs.add('📐 ${p.superArea!.toInt()} sqft');
    if (specs.isNotEmpty) buf.writeln(specs.join(' | '));

    final tags = <String?>[p.type, p.category, p.constructionStatus]
        .where((s) => s != null && s.isNotEmpty)
        .cast<String>();
    if (tags.isNotEmpty) buf.writeln('🏷 ${tags.join(' · ')}');

    if (p.verified == true) buf.writeln('✅ Verified Property');

    if (p.description != null && p.description!.isNotEmpty) {
      final desc = p.description!.length > 200
          ? '${p.description!.substring(0, 200)}…'
          : p.description!;
      buf.writeln('\n$desc');
    }

    buf.writeln('\n👉 Open in KeyBricks app:');
    buf.write(deepLink(p));
    return buf.toString();
  }

  /// Formal inquiry message a buyer sends to the property owner over WhatsApp.
  /// Includes property summary, deep-link, and the buyer's name / phone so
  /// the owner has a contact to call back on.
  static String inquiryWhatsAppText(
    PropertyModel p, {
    String? buyerName,
    String? buyerPhone,
    String? buyerEmail,
  }) {
    final isRent = p.rentOrSale?.toUpperCase() == 'RENT';
    final buf = StringBuffer();

    buf.writeln('Hello,');
    buf.writeln();
    buf.writeln(
        "I would like to inquire about the following ${isRent ? 'rental' : ''} property listed on KeyBricks:");
    buf.writeln();
    buf.writeln('🏠 *${p.title ?? 'Property'}*');

    final loc = [p.location, p.city, p.state]
        .where((s) => s != null && s.isNotEmpty)
        .join(', ');
    if (loc.isNotEmpty) buf.writeln('📍 $loc');
    buf.writeln('💰 ${_price(p)}');

    final specs = <String>[];
    if (p.bedrooms != null) specs.add('🛏 ${p.bedrooms} Beds');
    if (p.bathrooms != null) specs.add('🛁 ${p.bathrooms} Bath');
    if (p.superArea != null) specs.add('📐 ${p.superArea!.toInt()} sqft');
    if (specs.isNotEmpty) buf.writeln(specs.join(' | '));

    if (p.type != null && p.type!.isNotEmpty) {
      buf.writeln('🏷 ${p.type}');
    }

    buf.writeln();
    buf.writeln(
        'Could you please share more details or arrange a site visit at a convenient time?');

    final hasContact = (buyerName != null && buyerName.isNotEmpty) ||
        (buyerPhone != null && buyerPhone.isNotEmpty) ||
        (buyerEmail != null && buyerEmail.isNotEmpty);
    if (hasContact) {
      buf.writeln();
      buf.writeln('Regards,');
      if (buyerName != null && buyerName.isNotEmpty) buf.writeln(buyerName);
      if (buyerPhone != null && buyerPhone.isNotEmpty) {
        buf.writeln('📞 $buyerPhone');
      }
      if (buyerEmail != null && buyerEmail.isNotEmpty) {
        buf.writeln('✉ $buyerEmail');
      }
    }

    buf.writeln();
    buf.writeln('Property link: ${deepLink(p)}');
    return buf.toString();
  }

  static String emailSubject(PropertyModel p) =>
      '${p.title ?? 'Property Listing'} — ${_price(p)}';

  static String emailBody(PropertyModel p) {
    final buf = StringBuffer();
    buf.writeln('Hi,\n');
    buf.writeln('I\'d like to share this property listing with you:\n');
    buf.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    buf.writeln(p.title ?? 'Property');
    buf.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    final loc = [p.address, p.location, p.city, p.state]
        .where((s) => s != null && s.isNotEmpty)
        .join(', ');
    if (loc.isNotEmpty) buf.writeln('Location:   $loc');
    buf.writeln('Price:      ${_price(p)}');
    if (p.type != null) buf.writeln('Type:       ${p.type}');
    if (p.category != null) buf.writeln('Category:   ${p.category}');
    if (p.bedrooms != null) buf.writeln('Bedrooms:   ${p.bedrooms}');
    if (p.bathrooms != null) buf.writeln('Bathrooms:  ${p.bathrooms}');
    if (p.superArea != null) buf.writeln('Area:       ${p.superArea!.toInt()} sqft');
    if (p.constructionStatus != null) buf.writeln('Status:     ${p.constructionStatus}');
    if (p.furnishing != null) buf.writeln('Furnishing: ${p.furnishing}');
    if (p.facing != null) buf.writeln('Facing:     ${p.facing}');
    if (p.verified == true) buf.writeln('Verified:   ✓ Yes');
    if (p.reraApproved == true && p.reraNumber != null) {
      buf.writeln('RERA:       ${p.reraNumber}');
    }
    if (p.loanAvailable == true) buf.writeln('Loan:       Available');

    if (p.description != null && p.description!.isNotEmpty) {
      buf.writeln('\nDescription:\n${p.description}');
    }

    buf.writeln('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    buf.writeln('📱 Open in KeyBricks app:');
    buf.writeln(deepLink(p));
    buf.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    buf.writeln('Shared via KeyBricks');
    return buf.toString();
  }

  static String smsText(PropertyModel p) {
    final loc = [p.city, p.state]
        .where((s) => s != null && s.isNotEmpty)
        .join(', ');
    final locPart = loc.isNotEmpty ? ', $loc' : '';
    return '${p.title ?? 'Property'}$locPart — ${_price(p)}. View in KeyBricks: ${deepLink(p)}';
  }

  // ── Channel launchers ────────────────────────────────────────────────────

  static Future<void> shareViaWhatsApp(PropertyModel p) async {
    final encoded = Uri.encodeComponent(whatsAppText(p));
    final url = Uri.parse('https://wa.me/?text=$encoded');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  static Future<void> shareViaEmail(PropertyModel p) async {
    final subject = Uri.encodeComponent(emailSubject(p));
    final body = Uri.encodeComponent(emailBody(p));
    final url = Uri.parse('mailto:?subject=$subject&body=$body');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  static Future<void> shareViaSms(PropertyModel p) async {
    final body = Uri.encodeComponent(smsText(p));
    final url = Uri.parse('sms:?body=$body');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  static Future<void> copyLink(PropertyModel p) =>
      Clipboard.setData(ClipboardData(text: deepLink(p)));

  static Future<void> shareNative(PropertyModel p) => Share.share(
        '${p.title ?? 'Property'} — ${_price(p)}\n\n${deepLink(p)}',
        subject: emailSubject(p),
      );
}
