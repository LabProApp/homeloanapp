import 'dart:ui';
import 'package:flutter/material.dart';
import 'Dashboard.dart';
import 'otp_verification_screen.dart';
import 'user_forgot_password.dart';
import '../services/user_service.dart';
import '../theme/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  int selectedTab = 0; // 0 = Login, 1 = Signup
  bool _isPasswordVisible = false;
  bool _loading = false;

  final TextEditingController emailOrMobileController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background
          Image.asset('assets/images/splash_bg.jpg', fit: BoxFit.cover),

          // Blur overlay
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(color: Colors.black.withOpacity(0.35)),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 50),
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.home, size: 40, color: Colors.deepOrange),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    "ProFinDo",
                    style: TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "Find. Finance. Finalize.",
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  const SizedBox(height: 30),

                  // Tabs
                  Container(
                    height: 55,
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
                    hint: "Enter email or mobile",
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
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ForgotPasswordScreen(),
                          ),
                        ),
                        child: const Text(
                          "Forgot Password?",
                          style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 30),

                  // Button
                  _gradientButton(
                    text: selectedTab == 0 ? "Sign In" : "Sign Up",
                    onTap: _loading
                        ? null
                        : (selectedTab == 0 ? _login : _signup),
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

  Future<void> _login() async {
    if (emailOrMobileController.text.isEmpty || passwordController.text.isEmpty) {
      _showError("Please enter credentials");
      return;
    }

    setState(() => _loading = true);

    try {
      // ✅ UserApiService returns LoginResponse directly
      final LoginResponse response = await UserApiService.login(
        emailOrMobileController.text.trim(),
        passwordController.text.trim(),
      );

      if (response.userId.isEmpty) {
        _showError("User ID not found in response");
        return;
      }

      // Navigate to Dashboard with userId
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => DashboardScreen(userId: response.userId)),
      );
    } catch (e) {
      _showError("Invalid login credentials");
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _signup() async {
    if (emailOrMobileController.text.isEmpty) {
      _showError("Enter email or mobile");
      return;
    }

    setState(() => _loading = true);

    try {
      await UserApiService.resendOtp(emailOrMobileController.text.trim());

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtpVerificationScreen(
            value: emailOrMobileController.text.trim(),
          ),
        ),
      );
    } catch (e) {
      _showError("Failed to send OTP");
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: Colors.red, content: Text(msg)),
    );
  }

  // ================= UI HELPERS =================

  Widget _tabButton(String title, int index) {
    final isSelected = selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTab = index),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            title,
            style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Align(
    alignment: Alignment.centerLeft,
    child: Text(
      text,
      style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w500),
    ),
  );

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
        enabledBorder: _border(),
        focusedBorder: _border(focus: true),
      ),
    );
  }

  Widget _passwordField() {
    return TextField(
      controller: passwordController,
      obscureText: !_isPasswordVisible,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: "Enter password",
        hintStyle: const TextStyle(color: Colors.white54),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.white70,
          ),
          onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
        ),
        enabledBorder: _border(),
        focusedBorder: _border(focus: true),
      ),
    );
  }

  OutlineInputBorder _border({bool focus = false}) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: BorderSide(color: focus ? Colors.white : Colors.white38),
  );

  Widget _gradientButton({required String text, VoidCallback? onTap}) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
          ),
          borderRadius: BorderRadius.circular(30),
        ),
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
          ),
          child: _loading
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}
