import 'package:flutter/material.dart';

class AppColors {
  // ===== Brand / Primary =====
  static const Color primary = Color(0xFFD97706);
  static const Color primaryDark = Color(0xFFB45309);
  static const Color secondary = Colors.orangeAccent;
  static const Color accent = Color(0xFF059669);

  // ===== Premium accents (cool counterpart to the warm brand) =====
  static const Color navy = Color(0xFF0F172A);       // deep slate-navy
  static const Color slate = Color(0xFF1E293B);      // softer slate
  static const Color indigo = Color(0xFF334155);     // muted indigo for chips/labels
  static const Color goldAccent = Color(0xFFEAB308); // premium gold highlight

  // ===== Backgrounds =====
  // Listings get a mild orange tint to keep the warm brand feel without
  // the heavy cream of the original palette. Scaffold/background stay cool
  // for screens that aren't photo-heavy (forms, calculators, profile).
  static const Color listingbackground = Color(0xFFFFF4E6); // mild peach
  static const Color scaffoldBg = Color(0xFFF1F5F9);
  static const Color cardBg = Colors.white;
  static const Color background = Color(0xFFFFF4E6);
  static const Color white = Colors.white;
  static const Color surfaceSubtle = Color(0xFFF8FAFC);
  static const Color surfaceElevated = Color(0xFFFFFFFF);
  static const Color textBoxbackground = Color(0xFFFFFFFF);
  static const Color highlightBg = Color(0xFFFFF8F0);
  static const Color glass = Color(0x26FFFFFF);       // frosted card on imagery
  static const Color glassBorder = Color(0x4DFFFFFF); // border on glass cards

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

  // ===== Premium gradients for backdrops (darker, more contrast for text) =====
  static const LinearGradient premiumGradient = LinearGradient(
    colors: [navy, slate],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Darker top-to-bottom overlay used on top of backdrop photos for legibility.
  static const LinearGradient backdropScrim = LinearGradient(
    colors: [Color(0x99000000), Color(0x33000000), Color(0xCC000000)],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ===== Image header gradient (SliverAppBar photo overlays) =====
  static const LinearGradient headerImageGradient = LinearGradient(
    colors: [imageGradientTop, Colors.transparent, imageGradientBottom],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
