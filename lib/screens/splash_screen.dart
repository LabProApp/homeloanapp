import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'package:property/theme/app_colors.dart';
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary, // Deep Orange
              AppColors.secondary, // Warm Amber
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Circle
              CircleAvatar(
                radius: 45,
                backgroundColor: Colors.white.withOpacity(0.95),
                child: const Icon(
                  Icons.home,
                  size: 42,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: 18),

              // App Name
              const Text(
                "AbodeOne",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),

              const SizedBox(height: 6),

              // Tagline
              const Text(
                "Find. Finance. Finalize.",
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.cardBg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
