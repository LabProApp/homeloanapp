import 'dart:ui';
import 'package:flutter/material.dart';
import 'userLogin_screen.dart';
import '../theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _zoomAnim;
  late Animation<double> _rotateAnim;
  late Animation<double> _glowAnim;
  late Animation<double> _fadeTextAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    /// Zoom IN → Zoom OUT
    _zoomAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.2, end: 1.5)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.5, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_controller);

    /// Slight rotation
    _rotateAnim = Tween<double>(begin: -0.2, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    /// Glow ring expand
    _glowAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    /// Text fade in (starts later)
    _fadeTextAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.55, 1.0, curve: Curves.easeIn),
    );

    _controller.forward();

    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          /// Background Image
          Image.asset(
            'assets/images/splash_bg.jpg',
            fit: BoxFit.cover,
          ),

          /// Blur Effect
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Container(
              color: Colors.black.withOpacity(0.2),
            ),
          ),

          /// Foreground Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                /// LOGO + EFFECTS
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        /// Ripple glow
                        Container(
                          width: 180 * _glowAnim.value,
                          height: 180 * _glowAnim.value,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                            AppColors.primary.withOpacity(0.18),
                          ),
                        ),

                        /// Rotating + zooming logo
                        Transform.rotate(
                          angle: _rotateAnim.value,
                          child: Transform.scale(
                            scale: _zoomAnim.value,
                            child: const CircleAvatar(
                              radius: 55,
                              backgroundImage: AssetImage(
                                  'assets/images/ic_launcher.png'),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 30),

                /// APP NAME (fade in)
                FadeTransition(
                  opacity: _fadeTextAnim,
                  child: const Text(
                    "KeyBricks",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.4,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                /// TAGLINE (fade in)
                FadeTransition(
                  opacity: _fadeTextAnim,
                  child: const Text(
                    "Find. Finance. Finalize.",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}