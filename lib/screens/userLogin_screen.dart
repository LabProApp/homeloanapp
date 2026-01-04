import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:property/screens/DashBoard.dart';
import 'package:property/theme/app_colors.dart';
import 'package:property/screens/user_forgot_password.dart';
import 'package:property/services/user_service.dart';
import 'package:property/screens/otp_verification_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  int selectedTab = 0; // 0 = Login, 1 = Signup
  bool _isPasswordVisible = false;

  final TextEditingController emailOrMobileController =
  TextEditingController();

  final Color primaryColor = AppColors.accent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          /// 🔹 Background Image
          Image.asset(
            'assets/images/splash_bg.jpg',
            fit: BoxFit.cover,
          ),

          /// 🔹 Blur + Overlay
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              color: Colors.black.withOpacity(0.35),
            ),
          ),

          /// 🔹 Foreground UI
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 50),

                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white.withOpacity(0.9),
                    child: const Icon(Icons.home,
                        size: 40, color: Colors.deepOrange),
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    "AbodeOne",
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    "Find. Finance. Finalize.",
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70),
                  ),

                  const SizedBox(height: 25),

                  /// Tabs
                  Container(
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.white.withOpacity(0.15),
                    ),
                    child: Row(
                      children: [
                        _tabButton("Log In", 0),
                        _tabButton("Sign Up", 1),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  _label("Email or Mobile"),
                  _textField(
                    controller: emailOrMobileController,
                    hint: "Enter email or mobile number",
                    icon: Icons.email_outlined,
                  ),

                  const SizedBox(height: 18),

                  if (selectedTab == 0) ...[
                    _label("Password"),
                    _passwordField(),
                    const SizedBox(height: 10),

                    Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                              const ForgotPasswordScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          "Forgot Password?",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 25),

                  /// 🔵 Primary Button
                  _gradientButton(
                    text: selectedTab == 0 ? "Sign In" : "Sign Up",
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary,
                        AppColors.secondary,
                      ],
                    ),
                    onTap:
                    selectedTab == 0 ? _handleLogin : _handleSignup,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= ACTIONS =================

  void _handleLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => DashboardScreen()),
    );
  }

  void _handleSignup() async {
    if (emailOrMobileController.text.isEmpty) {
      _showError("Please enter email or mobile number");
      return;
    }

    try {
      /// 🔥 No response expected — success = no exception
      await UserApiService
          .resendOtp(emailOrMobileController.text.trim());

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtpVerificationScreen(
            value: emailOrMobileController.text.trim(),
          ),
        ),
      );
    } catch (e) {
      _showError("Failed to send OTP. Please try again.");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // ================= Helper Widgets =================

  Widget _tabButton(String title, int index) {
    bool isSelected = selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTab = index),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary
                : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: isSelected
                  ? Colors.white
                  : Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.white70,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _textField({
    required String hint,
    required IconData icon,
    required TextEditingController controller,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        suffixIcon: Icon(icon, color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.white38),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.white),
        ),
      ),
    );
  }

  Widget _passwordField() {
    return TextField(
      obscureText: !_isPasswordVisible,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: "Enter your password",
        hintStyle: const TextStyle(color: Colors.white54),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible
                ? Icons.visibility
                : Icons.visibility_off,
            color: Colors.white70,
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.white38),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.white),
        ),
      ),
    );
  }

  Widget _gradientButton({
    required String text,
    required Gradient gradient,
    VoidCallback? onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(30),
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          onPressed: onTap,
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
