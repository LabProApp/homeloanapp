import 'dart:ui';
import 'dart:async';
import 'dart:io';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dashBoard.dart';
import 'otp_verification_screen.dart';
import 'user_forgot_password.dart';
import '../services/user_service.dart';
import '../theme/app_colors.dart';
import '../commons/common_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  int selectedTab = 0;
  bool _isPasswordVisible = false;
  bool _loading = false;
  bool _checkingLogin = true;

  final TextEditingController emailOrMobileController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkIfLoggedIn();
  }

  /// 🔐 AUTO LOGIN CHECK
  Future<void> _checkIfLoggedIn() async {
    dev.log("Checking login from SharedPreferences...",
        name: "LoginScreen");

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt("userId"); // ✅ FIXED KEY

    dev.log("Stored userId = $userId", name: "LoginScreen");

    if (userId != null && userId != 0) {
      dev.log("User already logged in → Navigating to Dashboard",
          name: "LoginScreen");

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => DashboardScreen(userId: userId),
        ),
      );
    } else {
      dev.log("No user logged in → Showing Login Screen",
          name: "LoginScreen");

      if (mounted) {
        setState(() => _checkingLogin = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingLogin) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/splash_bg.jpg', fit: BoxFit.cover),

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

                  const Hero(
                    tag: "appLogo",
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage:
                      AssetImage('assets/images/ic_launcher.png'),
                    ),
                  ),

                  const SizedBox(height: 15),
                  const Text(
                    "KeyBricks",
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "Find. Finance. Finalize.",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),

                  const SizedBox(height: 30),

                  /// TABS
                  Container(
                    height: 55,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
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
                          style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 30),

                  AppButton(
                    text: selectedTab == 0 ? "Sign In" : "Sign Up",
                    isLoading: _loading,
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
    if (emailOrMobileController.text.isEmpty ||
        passwordController.text.isEmpty) {
      _showError("Please enter credentials");
      return;
    }

    setState(() => _loading = true);

    try {
      dev.log("Attempting login...", name: "LoginScreen");

      final LoginResponse response = await UserApiService.login(
        emailOrMobileController.text.trim(),
        passwordController.text.trim(),
      );

      final user = response.user;

      dev.log("Login success. UserId=${user.id}", name: "LoginScreen");

      if (user.id == null || user.id == 0) {
        _showError("Login failed. User ID missing.");
        return;
      }

      final prefs = await SharedPreferences.getInstance();

      dev.log("Saving user data...", name: "LoginScreen");

      await prefs.setInt("userId", user.id!);
      await prefs.setString("userName", user.name ?? "");
      await prefs.setString("userEmail", user.email ?? "");
      await prefs.setString("userMobile", user.mobile ?? "");
      await prefs.setString("userRole", user.userRole ?? "");
      await prefs.setBool("isVerified", user.isVerified ?? false);

      if (response.token != null) {
        await prefs.setString("token", response.token!);
      }

      dev.log("User saved in SharedPreferences", name: "LoginScreen");

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => DashboardScreen(userId: user.id!),
        ),
      );
    } on SocketException catch (e, s) {
      _logError("No internet connection", e, s);
      _showError("No internet connection");
    } on TimeoutException catch (e, s) {
      _logError("Request timeout", e, s);
      _showError("Request timed out. Try again.");
    } on FormatException catch (e, s) {
      _logError("Invalid response format", e, s);
      _showError("Invalid server response");
    } catch (e, s) {
      _logError("Unknown login error", e, s);
      _showError("Invalid login credentials");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signup() async {
    if (emailOrMobileController.text.isEmpty) {
      _showError("Enter email or mobile");
      return;
    }

    setState(() => _loading = true);

    try {
      dev.log("Sending OTP...", name: "LoginScreen");

      await UserApiService.resendOtp(
          emailOrMobileController.text.trim());

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtpVerificationScreen(
            value: emailOrMobileController.text.trim(),
          ),
        ),
      );
    } catch (e, s) {
      _logError("OTP send failed", e, s);
      _showError("Failed to send OTP");
    } finally {
      setState(() => _loading = false);
    }
  }

  // ================= HELPERS =================

  void _logError(String message, Object error, StackTrace stackTrace) {
    if (kDebugMode) {
      dev.log(message,
          name: 'LoginScreen', error: error, stackTrace: stackTrace);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: Colors.red, content: Text(msg)),
    );
  }

  Widget _tabButton(String title, int index) {
    final isSelected = selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTab = index),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
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
    child: Text(text,
        style: const TextStyle(
            color: Colors.white70, fontWeight: FontWeight.w500)),
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
            _isPasswordVisible
                ? Icons.visibility
                : Icons.visibility_off,
            color: Colors.white70,
          ),
          onPressed: () =>
              setState(() => _isPasswordVisible = !_isPasswordVisible),
        ),
        enabledBorder: _border(),
        focusedBorder: _border(focus: true),
      ),
    );
  }

  OutlineInputBorder _border({bool focus = false}) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide:
    BorderSide(color: focus ? Colors.white : Colors.white38),
  );
}