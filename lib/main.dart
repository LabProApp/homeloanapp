import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';
import 'network/service_locator.dart';
import 'theme/app_colors.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupServiceLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KeyBricks',
      theme: _buildTheme(),
      home: const SplashScreen(),
    );
  }

  ThemeData _buildTheme() {
    const String font = 'Poppins';

    return ThemeData(
      fontFamily: font,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.listingbackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.accent,
        error: AppColors.error,
        surface: AppColors.cardBg,
      ),

      // ── Typography ─────────────────────────────────────────────────────────
      // Scale: display 28-32, title 20-24, body 14-16, label 11-13
      textTheme: const TextTheme(
        // Headlines / display
        displayLarge:  TextStyle(fontSize: 32, fontWeight: FontWeight.w700, letterSpacing: -0.5, color: AppColors.textPrimary),
        displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.25, color: AppColors.textPrimary),
        displaySmall:  TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.textPrimary),

        // Section headings
        headlineLarge:  TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        headlineSmall:  TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),

        // Card / list titles
        titleLarge:  TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        titleMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
        titleSmall:  TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textSecondary),

        // Body copy
        bodyLarge:  TextStyle(fontSize: 15, fontWeight: FontWeight.w400, height: 1.5, color: AppColors.textPrimary),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, height: 1.5, color: AppColors.textSecondary),
        bodySmall:  TextStyle(fontSize: 13, fontWeight: FontWeight.w400, height: 1.4, color: AppColors.textMuted),

        // Captions / chips / badges
        labelLarge:  TextStyle(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.1),
        labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.1, color: AppColors.textMuted),
        labelSmall:  TextStyle(fontSize: 11, fontWeight: FontWeight.w400, letterSpacing: 0.4, color: AppColors.textMuted),
      ),

      // ── AppBar ─────────────────────────────────────────────────────────────
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        toolbarHeight: 48,
        titleTextStyle: TextStyle(
          fontFamily: font,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        iconTheme: IconThemeData(color: Colors.white, size: 24),
      ),

      // ── ElevatedButton — primary CTA ───────────────────────────────────────
      // Height: 52 px | font: 15 px bold | radius: 12 px | H-padding: 24 px
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.disabled,
          disabledForegroundColor: Colors.white60,
          elevation: 0,
          minimumSize: const Size.fromHeight(52),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: font,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),

      // ── OutlinedButton — secondary CTA ─────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          minimumSize: const Size.fromHeight(52),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: font,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),

      // ── TextButton — tertiary / inline links ───────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          minimumSize: const Size(64, 40),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(
            fontFamily: font,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ),

      // ── Input fields ───────────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.textBoxbackground,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        hintStyle: const TextStyle(
          fontFamily: font,
          fontSize: 14,
          color: AppColors.textMuted,
        ),
        labelStyle: const TextStyle(
          fontFamily: font,
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
        errorStyle: const TextStyle(
          fontFamily: font,
          fontSize: 12,
          color: AppColors.error,
        ),
      ),

      // ── Cards ──────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: AppColors.cardBg,
        elevation: 2,
        shadowColor: AppColors.shadowLight,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // ── Chips ──────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.white,
        selectedColor: AppColors.primary,
        disabledColor: AppColors.disabled.withOpacity(0.5),
        // unselected label
        labelStyle: const TextStyle(
          fontFamily: font,
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        // selected label — white text on primary background
        secondaryLabelStyle: const TextStyle(
          fontFamily: font,
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        side: const BorderSide(color: AppColors.border),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        showCheckmark: false,
      ),

      // ── BottomNavBar ───────────────────────────────────────────────────────
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedLabelStyle: TextStyle(fontFamily: font, fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontFamily: font, fontSize: 11),
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMuted,
        backgroundColor: AppColors.white,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),

      // ── Divider ────────────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),

      // ── SnackBar ───────────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        contentTextStyle: const TextStyle(fontFamily: font, fontSize: 14),
      ),
    );
  }
}
