import 'package:flutter/material.dart';

class AppColors {
  // ===== Brand / Primary =====
  static const Color primary = Color(0xFFD97706);
  static const Color secondary = Colors.orangeAccent;
  static const Color accent = Color(0xFF059669);

  // ===== Backgrounds =====
  static const Color listingbackground = Color(0xFFFFF3E0);
  static const Color scaffoldBg = Color(0xFFFBE9E7);
  static const Color cardBg = Colors.white;
  static const Color background = Color(0xFFFFF3E0);
  static const Color white = Colors.white;
  static const Color surfaceSubtle = Color(0xFFF8FAFC);
  static const Color textBoxbackground = Color(0xFFFFFFFF);
  static const Color highlightBg = Color(0xFFFFF8F0);

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

  // ===== Image overlays (icon circles, photo badges) =====
  static const Color imageOverlay = Color(0x73000000);     // ~45% black
  static const Color imageCaptionText = Color(0xB3FFFFFF);

  // ===== Image gradient overlays (for SliverAppBar / card photo gradients) =====
  static const Color imageGradientTop = Color(0x66000000);     // 40%
  static const Color imageGradientBottom = Color(0xB3000000);  // 70%
  static const Color imageGradientCardBottom = Color(0xE8000000); // 91% for card full overlay

  // ===== Box shadows (named so we avoid raw Color(0x0A000000) everywhere) =====
  static const Color shadowExtraLight = Color(0x0A000000); // 3.9%
  static const Color shadowLight = Color(0x0C000000);      // 4.7%
  static const Color shadowMedium = Color(0x14000000);     // 7.8%
  static const Color shadowDark = Color(0x1F000000);       // 12%

  // ===== Semi-transparent white (login screens, glass effects) =====
  static const Color white70 = Color(0xB3FFFFFF);
  static const Color white60 = Color(0x99FFFFFF);
  static const Color white54 = Color(0x8AFFFFFF);
  static const Color white38 = Color(0x61FFFFFF);
  static const Color white24 = Color(0x3DFFFFFF);
  static const Color white15 = Color(0x26FFFFFF);
  static const Color white10 = Color(0x1AFFFFFF);

  // ===== Shared gradient (AppBars, headers, hero banners) =====
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ===== Image header gradient (SliverAppBar photo overlays) =====
  static const LinearGradient headerImageGradient = LinearGradient(
    colors: [imageGradientTop, Colors.transparent, imageGradientBottom],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
