import 'dart:async';
import 'dart:developer' as developer;
import 'dart:ui';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/app_initializer.dart';
import 'screens/property_detail_screen.dart';
import 'screens/rent_property_detail_screen.dart';
import 'screens/user_login_screen.dart';
import 'network/api_client.dart';
import 'network/service_locator.dart';
import 'services/feature_flags.dart';
import 'services/property_api_service.dart';
import 'services/secure_token_service.dart';
import 'services/user_service.dart';
import 'theme/app_colors.dart';

/// Global navigator key so the deep-link handler can push routes from outside
/// the widget tree (e.g. from a background stream callback).
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Suppress all Flutter debugPrint noise — only dev.log API calls remain visible.
  debugPrint = (_, {wrapWidth}) {};

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    developer.log(
      'Flutter error: ${details.exception}',
      name: 'GlobalError',
      error: details.exception,
      stackTrace: details.stack,
    );
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    developer.log(
      'Unhandled error: $error',
      name: 'GlobalError',
      error: error,
      stackTrace: stack,
    );
    return true;
  };

  setupServiceLocator();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSub;
  DateTime? _backgroundedAt;

  static const _sessionTimeout = Duration(minutes: 30);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initDeepLinks();
    ApiClient.onUnauthorized = _handleUnauthorized;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _backgroundedAt = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      final bg = _backgroundedAt;
      _backgroundedAt = null;
      if (bg != null && DateTime.now().difference(bg) >= _sessionTimeout) {
        _handleUnauthorized();
      } else {
        _refreshFeatureFlagsIfLoggedIn();
      }
    }
  }

  /// Re-fetches the user profile on resume so a plan change done outside
  /// the app (admin upgrade, subscription expiry) reflects within seconds
  /// instead of waiting for the next login.
  Future<void> _refreshFeatureFlagsIfLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');
      if (userId == null || userId == 0) return;
      final user = await UserApiService.getProfile(userId);
      await FeatureFlags.save(user);
    } catch (_) {
      // Network hiccups shouldn't break the resume path — keep the cached flags.
    }
  }

  Future<void> _handleUnauthorized() async {
    ApiClient.setToken(null);
    await SecureTokenService.clearToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await FeatureFlags.save(null);
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _initDeepLinks() {
    _appLinks = AppLinks();

    // Handle links when the app is already running (foreground / background).
    _linkSub = _appLinks.uriLinkStream.listen(
      _handleDeepLink,
      onError: (_) {}, // silently ignore stream errors
    );

    // Handle the initial link that cold-started the app.
    _appLinks.getInitialLink().then((uri) {
      if (uri != null) _handleDeepLink(uri);
    });
  }

  Future<void> _handleDeepLink(Uri uri) async {
    if (uri.scheme != 'keybricks') return;

    final idStr = uri.queryParameters['id'];
    final id = idStr != null ? int.tryParse(idStr) : null;
    if (id == null) return;

    try {
      final property = await PropertyApiService.fetchById(id);
      if (property == null) return;

      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId') ?? 0;

      final nav = navigatorKey.currentState;
      if (nav == null) return;

      final isRent = property.rentOrSale?.toUpperCase() == 'RENT';
      nav.push(
        MaterialPageRoute(
          builder: (_) => isRent
              ? RentalPropertyDetailScreen(property: property, userId: userId)
              : PropertyDetailScreen(property: property, userId: userId),
        ),
      );
    } catch (_) {
      // Silently fail — property may not exist or network may be unavailable.
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _linkSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'KeyBricks',
      theme: _buildTheme(),
      home: const AppInitializer(),
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
      textTheme: const TextTheme(
        displayLarge:  TextStyle(fontSize: 32, fontWeight: FontWeight.w700, letterSpacing: -0.5, color: AppColors.textPrimary),
        displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.25, color: AppColors.textPrimary),
        displaySmall:  TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        headlineLarge:  TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        headlineSmall:  TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        titleLarge:  TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        titleMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
        titleSmall:  TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
        bodyLarge:  TextStyle(fontSize: 15, fontWeight: FontWeight.w400, height: 1.5, color: AppColors.textPrimary),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, height: 1.5, color: AppColors.textSecondary),
        bodySmall:  TextStyle(fontSize: 13, fontWeight: FontWeight.w400, height: 1.4, color: AppColors.textMuted),
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
        toolbarHeight: 56,
        titleTextStyle: TextStyle(
          fontFamily: font,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        iconTheme: IconThemeData(color: Colors.white, size: 24),
      ),

      // ── ElevatedButton ─────────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.disabled,
          disabledForegroundColor: Colors.white60,
          elevation: 2,
          shadowColor: AppColors.primary.withOpacity(0.30),
          minimumSize: const Size.fromHeight(52),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontFamily: font, fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.2),
        ),
      ),

      // ── OutlinedButton ─────────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          elevation: 0,
          minimumSize: const Size.fromHeight(52),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontFamily: font, fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.2),
        ),
      ),

      // ── TextButton ─────────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          minimumSize: const Size(64, 40),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontFamily: font, fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.1),
        ),
      ),

      // ── Input fields ───────────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.error)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.error, width: 1.5)),
        hintStyle: const TextStyle(fontFamily: font, fontSize: 14, color: AppColors.textMuted),
        labelStyle: const TextStyle(fontFamily: font, fontSize: 14, color: AppColors.textSecondary),
        floatingLabelStyle: const TextStyle(fontFamily: font, fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w500),
        errorStyle: const TextStyle(fontFamily: font, fontSize: 12, color: AppColors.error),
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
        labelStyle: const TextStyle(fontFamily: font, fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
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
      dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 1, space: 1),

      // ── SnackBar ───────────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentTextStyle: const TextStyle(fontFamily: font, fontSize: 14),
        elevation: 4,
      ),

      // ── Dialog ─────────────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.modalBg,
        surfaceTintColor: Colors.transparent,
        elevation: 6,
        shadowColor: AppColors.shadowDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: const TextStyle(
          fontFamily: font, fontSize: 17, fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        contentTextStyle: const TextStyle(
          fontFamily: font, fontSize: 14, height: 1.5,
          color: AppColors.textSecondary,
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      ),

      // ── BottomSheet ─────────────────────────────────────────────────────────
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.modalBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        showDragHandle: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),

      // ── ListTile ─────────────────────────────────────────────────────────────
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        iconColor: AppColors.textSecondary,
        textColor: AppColors.textPrimary,
        minLeadingWidth: 24,
      ),

      // ── PopupMenu ────────────────────────────────────────────────────────────
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.modalBg,
        surfaceTintColor: Colors.transparent,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(
          fontFamily: font, fontSize: 14, color: AppColors.textPrimary,
        ),
      ),

      // ── Slider ───────────────────────────────────────────────────────────────
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: AppColors.primary.withOpacity(0.18),
        thumbColor: AppColors.primary,
        overlayColor: AppColors.primary.withOpacity(0.12),
        valueIndicatorColor: AppColors.primary,
        valueIndicatorTextStyle: const TextStyle(
          fontFamily: font, fontSize: 12, color: Colors.white,
        ),
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
      ),

      // ── FloatingActionButton ─────────────────────────────────────────────────
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),
    );
  }
}
