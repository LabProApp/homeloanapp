import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/app_config.dart';
import '../models/app_version_model.dart';
import '../network/api_client.dart';
import '../services/app_version_service.dart';
import '../services/feature_flags.dart';
import '../services/secure_token_service.dart';
import '../services/user_service.dart';
import '../theme/app_colors.dart';
import 'dashboard_screen.dart';
import 'user_login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // ── 1. Hydrate cached feature flags ─────────────────────────────────────
    await FeatureFlags.load();

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    final token  = await SecureTokenService.getToken();

    final hasValidSession =
        userId != null && userId != 0 && token != null && token.isNotEmpty;

    // ── 2. Session check ────────────────────────────────────────────────────
    if (hasValidSession) {
      ApiClient.setToken(token);
      try {
        final user = await UserApiService.getProfile(userId!);
        await FeatureFlags.save(user);
      } catch (_) {
        // Network unavailable — cached flags remain in use.
      }
    } else {
      ApiClient.setToken(null);
      await SecureTokenService.clearToken();
      await prefs.clear();
      await FeatureFlags.save(null);
    }

    // ── 3. Version check ────────────────────────────────────────────────────
    final info        = await PackageInfo.fromPlatform();
    final versionCode = int.tryParse(info.buildNumber) ?? 1;

    final versionStatus = await AppVersionApiService.check(versionCode: versionCode);

    // Persist for the drawer update badge (doesn't require re-checking).
    await prefs.setBool('updateAvailable', versionStatus.updateAvailable);
    await prefs.setString('latestVersionName', versionStatus.latestVersionName ?? '');
    await prefs.setString(
        'updateStoreUrl',
        versionStatus.storeUrl ?? _fallbackStoreUrl());

    // ── 4. Remove native splash now that all async work is done ─────────────
    FlutterNativeSplash.remove();

    if (!mounted) return;

    // ── 5. Handle forced update (blocks navigation) ──────────────────────────
    if (versionStatus.forceUpdate) {
      await _showUpdateDialog(versionStatus, forced: true);
      // After the dialog the user is redirected to the store.
      // Do NOT navigate into the app — keep showing the dialog until the user
      // has updated (i.e. the app is restarted with a higher versionCode).
      return;
    }

    // ── 6. Handle optional update (dismissible) ──────────────────────────────
    if (versionStatus.updateAvailable) {
      final wantsUpdate = await _showUpdateDialog(versionStatus, forced: false);
      if (wantsUpdate == true) {
        await _openStore(versionStatus.storeUrl);
        // After launching the store let the user navigate into the app normally
        // so they can switch back without being blocked.
      }
    }

    // ── 7. Navigate ──────────────────────────────────────────────────────────
    if (!mounted) return;
    _navigate(hasValidSession, userId);
  }

  // ── Navigation ─────────────────────────────────────────────────────────────

  void _navigate(bool hasValidSession, int? userId) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => hasValidSession
            ? DashboardScreen(userId: userId!)
            : const LoginScreen(),
        transitionsBuilder: (_, animation, __, child) {
          final curved = CurvedAnimation(
              parent: animation, curve: Curves.easeOutCubic);
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.06),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  // ── Update dialog ──────────────────────────────────────────────────────────

  /// Shows either a mandatory (non-dismissible) or optional update dialog.
  ///
  /// Returns `true` if the user tapped "Update Now", `false`/`null` otherwise.
  Future<bool?> _showUpdateDialog(
      AppVersionModel version, {required bool forced}) {
    final newVersion = version.latestVersionName != null
        ? 'v${version.latestVersionName}'
        : 'a new version';

    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // always prevent tap-outside dismiss
      builder: (_) => PopScope(
        // Hardware back button: allowed only for optional updates.
        canPop: !forced,
        child: AlertDialog(
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (forced ? AppColors.error : AppColors.primary)
                      .withOpacity(0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  forced
                      ? Icons.system_update_rounded
                      : Icons.new_releases_rounded,
                  color: forced ? AppColors.error : AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                forced ? 'Update Required' : 'Update Available',
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                forced
                    ? 'This version of KeyBricks is no longer supported. '
                        'Please update to $newVersion to continue.'
                    : 'KeyBricks $newVersion is available with improvements '
                        'and bug fixes.',
              ),
              if (version.releaseNotes != null &&
                  version.releaseNotes!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.inputFill,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    version.releaseNotes!,
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.4),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            if (!forced)
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Not Now',
                    style: TextStyle(color: AppColors.textMuted)),
              ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    forced ? AppColors.error : AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Update Now',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  // ── Store launch ───────────────────────────────────────────────────────────

  Future<void> _openStore(String? serverUrl) async {
    final url = serverUrl?.isNotEmpty == true ? serverUrl! : _fallbackStoreUrl();
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {
      // If the store URL can't be launched show a snackbar, but don't crash.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                'Could not open the store. Please search for "KeyBricks" manually.'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  static String _fallbackStoreUrl() =>
      Platform.isAndroid ? AppConfig.playStoreUrl : AppConfig.appStoreUrl;

  // ── Scaffold ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: DecoratedBox(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/splash_bg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SizedBox.expand(),
      ),
    );
  }
}
