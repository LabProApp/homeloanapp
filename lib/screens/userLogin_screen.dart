import 'package:flutter/material.dart';
import 'package:property/screens/DashBoard.dart';
import 'package:property/theme/app_colors.dart';
import 'properyListing_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  int selectedTab = 0;
  bool _isPasswordVisible = false;

  final Color primaryColor = Colors.deepOrangeAccent; // Deep blue

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ),

              const SizedBox(height: 30),

              CircleAvatar(
                radius: 40,
                backgroundColor: primaryColor.withOpacity(0.12),
                child: Icon(Icons.home, size: 40, color: Colors.deepOrange),
              ),

              const SizedBox(height: 15),

              const Text(
                "AbodeOne",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 5),

              const Text(
                "Find. Finance. Finalize.",
                style: TextStyle(fontSize: 16, color: Colors.deepOrangeAccent),
              ),

              const SizedBox(height: 25),

              // Tabs
              Container(
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.grey.shade200,
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
                hint: "Enter email or mobile number",
                icon: Icons.email_outlined,
              ),

              const SizedBox(height: 18),

              _label("Password"),
              _passwordField(),

              const SizedBox(height: 10),

              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "Forgot Password?",
                  style: TextStyle(
                    fontSize: 14,
                    color: primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // 🔵 Primary Button
              _gradientButton(
                text: "Sign In",
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                  AppColors.primary, // Indigo
                   AppColors.secondary, // Blue
                  ],
                ),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DashboardScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 22),

              Row(
                children: [
                  Expanded(child: Divider(color: AppColors.border)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      "or continue with",
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                  ),
                  Expanded(child: Divider(color:AppColors.border)),
                ],
              ),

              const SizedBox(height: 20),

              // Google Button
              _gradientButton(
                text: "Continue with Google",
                icon: Icons.g_mobiledata,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.error,
                    AppColors.primary,
                  ],
                ),
              ),

              const SizedBox(height: 15),

              // Phone Button
              _gradientButton(
                text: "Continue with Phone",
                icon: Icons.phone_android,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary,
                    AppColors.secondary,
                  ],
                ),
              ),

              const SizedBox(height: 35),
            ],
          ),
        ),
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
            color: isSelected ? primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: isSelected ? AppColors.white: AppColors.textPrimary,
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
        style: TextStyle(
          fontSize: 14,
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _textField({required String hint, required IconData icon}) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        suffixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  Widget _passwordField() {
    return TextField(
      obscureText: !_isPasswordVisible,
      decoration: InputDecoration(
        hintText: "Enter your password",
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  // 🔹 Rounded Gradient Button
  Widget _gradientButton({
    required String text,
    IconData? icon,
    required Gradient gradient,
    VoidCallback? onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(30), // ✅ ROUND
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: Colors.white),
                const SizedBox(width: 8),
              ],
              Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
