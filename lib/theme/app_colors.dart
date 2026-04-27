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
  static const Color background = Color(0xFFFFF3E0); // Light slate
  static const Color white = Colors.white;

  // ===== Text =====
  static const Color textPrimary = Color(0xFF0F172A); // Dark slate (headings)
  static const Color textSecondary = Color(0xFF475569); // Body text
  static const Color textMuted = Color(0xFF64748B); // Labels / hints

  // ===== Borders & Dividers =====
  static const Color border = Color(0xFFE2E8F0);

  // ===== Status Colors =====
  static const Color success = Color(0xFF16A34A); // Loan approved / success
  static const Color error = Color(0xFFDC2626);   // Errors
  static const Color warning = Color(0xFFD97706); // Pending / alerts
  static const Color info = Color(0xFF2563EB);    // Informational

  // ===== Special UI =====
  static const Color disabled = Color(0xFFCBD5E1);
  static const Color overlay = Color(0x80000000);

  // ===== Image overlays =====
  static const Color imageOverlay = Color(0x73000000);   // 45% black — used on photo overlays
  static const Color imageCaptionText = Color(0xB3FFFFFF); // 70% white — secondary caption text on images
}
