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
  late Animation<double> _zoomOutAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Zoom OUT: start large → normal size
    _zoomOutAnim = Tween<double>(begin: 1.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();

    Future.delayed(const Duration(seconds: 2), () {
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
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              color: Colors.black.withOpacity(0.1),
            ),
          ),

          /// Foreground Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                /// LOGO ZOOM OUT
                ScaleTransition(
                  scale: _zoomOutAnim,
                  child: const CircleAvatar(
                    radius: 50,
                    backgroundImage:
                    AssetImage('assets/images/ic_launcher.png'),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "KeyBricks",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  "Find. Finance. Finalize.",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                    letterSpacing: 0.5,
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