import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/api_client.dart';
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
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    ApiClient.setToken(prefs.getString('token'));

    // Dismiss native splash now that auth state is known
    FlutterNativeSplash.remove();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) =>
            userId == null ? const LoginScreen() : DashboardScreen(userId: userId),
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
