import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/dashboard_screen.dart';
import '../theme/app_colors.dart';
import 'user_login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Master controller for the whole intro sequence (1 000 ms)
  late final AnimationController _introCtrl;

  // Logo: scale-in with spring bounce
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;

  // Glow ring that pulses behind the logo
  late final Animation<double> _glowScale;
  late final Animation<double> _glowFade;

  // Brand text slides up & fades in
  late final Animation<double> _titleFade;
  late final Animation<Offset> _titleSlide;

  // Tagline trails behind the title
  late final Animation<double> _taglineFade;
  late final Animation<Offset> _taglineSlide;

  // Progress indicator appears last
  late final Animation<double> _progressFade;

  @override
  void initState() {
    super.initState();
    _introCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // Logo: 0 ms → 600 ms, easeOutBack (bounces slightly past 1.0)
    _logoScale = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(
        parent: _introCtrl,
        curve: const Interval(0.0, 0.33, curve: Curves.easeOutBack),
      ),
    );
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _introCtrl,
        curve: const Interval(0.0, 0.22, curve: Curves.easeIn),
      ),
    );

    // Glow: 0 ms → 700 ms, expands and fades out (like a ripple)
    _glowScale = Tween<double>(begin: 1.0, end: 1.7).animate(
      CurvedAnimation(
        parent: _introCtrl,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );
    _glowFade = Tween<double>(begin: 0.5, end: 0.0).animate(
      CurvedAnimation(
        parent: _introCtrl,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    // Title: 400 ms → 900 ms
    _titleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _introCtrl,
        curve: const Interval(0.22, 0.5, curve: Curves.easeOut),
      ),
    );
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.35),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _introCtrl,
        curve: const Interval(0.22, 0.5, curve: Curves.easeOut),
      ),
    );

    // Tagline: 550 ms → 1 050 ms
    _taglineFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _introCtrl,
        curve: const Interval(0.3, 0.58, curve: Curves.easeOut),
      ),
    );
    _taglineSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _introCtrl,
        curve: const Interval(0.3, 0.58, curve: Curves.easeOut),
      ),
    );

    // Progress indicator: 900 ms → 1 200 ms
    _progressFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _introCtrl,
        curve: const Interval(0.5, 0.67, curve: Curves.easeIn),
      ),
    );

    _introCtrl.forward();
    _navigateNext();
  }

  Future<void> _navigateNext() async {
    // Wait for animation + a brief moment to let the progress bar show
    await Future.delayed(const Duration(milliseconds: 1500));

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 700),
        pageBuilder: (_, __, ___) =>
            userId == null ? const LoginScreen() : DashboardScreen(userId: userId),
        transitionsBuilder: (_, animation, __, child) {
          // Fade + subtle upward slide — feels like the content "arrives"
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
  void dispose() {
    _introCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background photo
          Image.asset('assets/images/splash_bg.jpg', fit: BoxFit.cover),

          // Dark tint overlay (gradient replaces GPU-heavy blur)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x55000000), Color(0x88000000)],
              ),
            ),
          ),

          // Centre content
          Center(
            child: AnimatedBuilder(
              animation: _introCtrl,
              builder: (_, __) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Logo with glow ripple ───────────────────────────────
                    SizedBox(
                      width: 140,
                      height: 140,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Glow ring — FadeTransition avoids offscreen compositing
                          FadeTransition(
                            opacity: _glowFade,
                            child: Transform.scale(
                              scale: _glowScale.value,
                              child: Container(
                                width: 110,
                                height: 110,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primary.withOpacity(0.35),
                                ),
                              ),
                            ),
                          ),
                          // Logo
                          FadeTransition(
                            opacity: _logoFade,
                            child: Transform.scale(
                              scale: _logoScale.value,
                              child: Container(
                                width: 110,
                                height: 110,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.4),
                                      blurRadius: 24,
                                      spreadRadius: 4,
                                    ),
                                  ],
                                ),
                                child: const CircleAvatar(
                                  radius: 55,
                                  backgroundImage:
                                      AssetImage('assets/images/ic_launcher.png'),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── Brand name ─────────────────────────────────────────
                    FadeTransition(
                      opacity: _titleFade,
                      child: SlideTransition(
                        position: _titleSlide,
                        child: const Text(
                          'KeyBricks',
                          style: TextStyle(

                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),

                    // ── Tagline ────────────────────────────────────────────
                    FadeTransition(
                      opacity: _taglineFade,
                      child: SlideTransition(
                        position: _taglineSlide,
                        child: const Text(
                          'Find. Finance. Finalize.',
                          style: TextStyle(

                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: Colors.white70,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 56),

                    // ── Progress indicator ─────────────────────────────────
                    FadeTransition(
                      opacity: _progressFade,
                      child: SizedBox(
                        width: 140,
                        child: LinearProgressIndicator(
                          backgroundColor: Colors.white24,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                          minHeight: 3,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
