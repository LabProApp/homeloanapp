import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/api_client.dart';
import '../services/feature_flags.dart';
import '../services/secure_token_service.dart';
import '../services/user_service.dart';
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
    // Hydrate the feature-flag cache so dashboard reads on first frame
    // don't have to await disk.
    await FeatureFlags.load();
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    final token = await SecureTokenService.getToken();

    final hasValidSession =
        userId != null && userId != 0 && token != null && token.isNotEmpty;

    if (hasValidSession) {
      ApiClient.setToken(token);
      // Fetch the latest plan/feature data on every startup so a plan change
      // done outside the app (admin upgrade, subscription expiry) is reflected
      // immediately without waiting for the next login.
      try {
        final user = await UserApiService.getProfile(userId!);
        await FeatureFlags.save(user);
      } catch (_) {
        // Network unavailable — the flags loaded from disk above remain in use.
      }
    } else {
      // Clear any partial/stale state so the user lands on a clean login.
      ApiClient.setToken(null);
      await SecureTokenService.clearToken();
      await prefs.clear();
      await FeatureFlags.save(null);
    }

    // Dismiss native splash now that auth state is known
    FlutterNativeSplash.remove();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => hasValidSession
            ? DashboardScreen(userId: userId)
            : const LoginScreen(),
        transitionsBuilder: (_, animation, __, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
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

  @override
  Widget build(BuildContext context) {
    // Native splash is on top during _init(); this matches the background
    // so there is no flash if removal and navigation overlap.
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
