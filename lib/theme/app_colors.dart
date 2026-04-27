import 'package:flutter/material.dart';

class AppColors {
  // ===== Brand / Primary =====
  static const Color primary = Color(0xFFD97706);
  static const Color secondary = Colors.orangeAccent;
  static const Color textBoxbackground = Color(0xFFFFFFFF);
  static const Color accent = Color(0xFF059669);
  static const Color listingbackground = Color(0xFFFFF3E0);

  // ===== Backgrounds =====
  static const Color scaffoldBg = Color(0xFFFBE9E7);
  static const Color cardBg = Colors.white;
  static const Color background = Color(0xFFFFF3E0);
  static const Color white = Colors.white;
  static const Color surfaceSubtle = Color(0xFFF8FAFC); // light read-only / logo bg

  // ===== Text =====
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textMuted = Color(0xFF64748B);

  // ===== Borders & Dividers =====
  static const Color border = Color(0xFFE2E8F0);

  // ===== Status Colors =====
  static const Color success = Color(0xFF16A34A);
  static const Color error = Color(0xFFDC2626);
  static const Color warning = Color(0xFFD97706);
  static const Color info = Color(0xFF2563EB);

  // ===== Third-party / Social =====
  static const Color whatsAppGreen = Color(0xFF25D366);

  // ===== Special UI =====
  static const Color disabled = Color(0xFFCBD5E1);
  static const Color overlay = Color(0x80000000);

  // ===== Image overlays =====
  static const Color imageOverlay = Color(0x73000000);
  static const Color imageCaptionText = Color(0xB3FFFFFF);

  // ===== Shared gradient (AppBars, headers, hero banners) =====
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
