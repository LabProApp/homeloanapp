import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../commons/common_widget.dart';
import '../network/api_client.dart';
import '../services/secure_token_service.dart';
import '../services/user_service.dart';
import '../theme/app_colors.dart';
import 'dashboard_screen.dart';
import 'otp_verification_screen.dart';
import 'user_forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  int _tab = 0;
  bool _passwordVisible = false;
  bool _loading = false;
  bool _checkingLogin = true;
  String _selectedRole = 'CLIENT';

  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();

  late final AnimationController _entranceCtrl;
  late final Animation<double> _logoFade;
  late final Animation<Offset> _logoSlide;
  late final Animation<double> _titleFade;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _tabFade;
  late final Animation<Offset> _tabSlide;
  late final Animation<double> _fieldsFade;
  late final Animation<Offset> _fieldsSlide;
  late final Animation<double> _btnFade;
  late final Animation<Offset> _btnSlide;

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _logoFade    = _fade(0.00, 0.30);
    _logoSlide   = _slide(0.00, 0.30);
    _titleFade   = _fade(0.15, 0.45);
    _titleSlide  = _slide(0.15, 0.45);
    _tabFade     = _fade(0.28, 0.58);
    _tabSlide    = _slide(0.28, 0.58);
    _fieldsFade  = _fade(0.42, 0.72);
    _fieldsSlide = _slide(0.42, 0.72);
    _btnFade     = _fade(0.56, 0.86);
    _btnSlide    = _slide(0.56, 0.86);
    _checkIfLoggedIn();
  }

  Animation<double> _fade(double start, double end) =>
      Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _entranceCtrl,
        curve: Interval(start, end, curve: Curves.easeOut),
      ));

  Animation<Offset> _slide(double start, double end) =>
      Tween<Offset>(begin: const Offset(0, 0.28), end: Offset.zero)
          .animate(CurvedAnimation(
        parent: _entranceCtrl,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      ));

  Future<void> _checkIfLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    if (userId != null && userId != 0) {
      ApiClient.setToken(await SecureTokenService.getToken());
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => DashboardScreen(userId: userId)),
      );
    } else {
      if (mounted) {
        setState(() => _checkingLogin = false);
        _entranceCtrl.forward();
      }
    }
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_checkingLogin) {
      return Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('assets/images/splash_bg.jpg', fit: BoxFit.cover),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xCC0F172A),
                      Color(0xB31E293B),
                      Color(0xCCB45309),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/splash_bg.jpg', fit: BoxFit.cover),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xCC0F172A), // navy at top
                    Color(0xA31E293B), // slate middle
                    Color(0xCCB45309), // brand-amber tint at bottom
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: AnimatedBuilder(
                animation: _entranceCtrl,
                builder: (_, __) => Column(
                  children: [
                    const SizedBox(height: 52),

                    // Logo
                    _animated(
                      fade: _logoFade,
                      slide: _logoSlide,
                      child: Hero(
                        tag: 'appLogo',
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.45),
                                blurRadius: 28,
                                spreadRadius: 6,
                              ),
                            ],
                          ),
                          child: const CircleAvatar(
                            radius: 50,
                            backgroundImage:
                                AssetImage('assets/images/ic_launcher.png'),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Brand
                    _animated(
                      fade: _titleFade,
                      slide: _titleSlide,
                      child: const Column(
                        children: [
                          Text(
                            'KeyBricks',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 1.0,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Find. Finance. Finalize.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Tabs
                    _animated(
                      fade: _tabFade,
                      slide: _tabSlide,
                      child: _buildTabs(),
                    ),

                    const SizedBox(height: 24),

                    // Fields
                    _animated(
                      fade: _fieldsFade,
                      slide: _fieldsSlide,
                      child: _buildFields(),
                    ),

                    const SizedBox(height: 28),

                    // Button
                    _animated(
                      fade: _btnFade,
                      slide: _btnSlide,
                      child: AppButton(
                        text: _tab == 0 ? 'Sign In' : 'Create Account',
                        isLoading: _loading,
                        onTap: _loading
                            ? null
                            : (_tab == 0 ? _login : _signup),
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Sub-widgets ────────────────────────────────────────────────────────────

  Widget _animated({
    required Animation<double> fade,
    required Animation<Offset> slide,
    required Widget child,
  }) =>
      FadeTransition(
        opacity: fade,
        child: SlideTransition(position: slide, child: child),
      );

  Widget _buildTabs() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withOpacity(0.15),
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: Row(children: [
        _tabBtn('Log In', 0),
        _tabBtn('Sign Up', 1),
      ]),
    );
  }

  Widget _tabBtn(String label, int index) {
    final selected = _tab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _tab = index;
            _emailCtrl.clear();
            _passwordCtrl.clear();
            _nameCtrl.clear();
            _selectedRole = 'CLIENT';
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.center,
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: selected
                ? [
                    BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2))
                  ]
                : [],
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : Colors.white70,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_tab == 1) ...[
          _fieldLabel('Full Name'),
          const SizedBox(height: 6),
          _glassField(
            controller: _nameCtrl,
            hint: 'Enter your full name',
            icon: Icons.badge_outlined,
            keyboardType: TextInputType.name,
          ),
          const SizedBox(height: 16),
        ],

        _fieldLabel('Email or Mobile'),
        const SizedBox(height: 6),
        _glassField(
          controller: _emailCtrl,
          hint: 'Enter email or mobile',
          icon: Icons.person_outline_rounded,
          keyboardType: TextInputType.emailAddress,
        ),

        const SizedBox(height: 16),
        _fieldLabel('Password'),
        const SizedBox(height: 6),
        _glassField(
          controller: _passwordCtrl,
          hint: _tab == 0 ? 'Enter password' : 'Create a password',
          icon: _passwordVisible
              ? Icons.visibility_rounded
              : Icons.visibility_off_rounded,
          obscure: !_passwordVisible,
          keyboardType: TextInputType.visiblePassword,
          onIconTap: () =>
              setState(() => _passwordVisible = !_passwordVisible),
        ),

        if (_tab == 0) ...[
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const ForgotPasswordScreen()),
              ),
              child: const Text(
                'Forgot Password?',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ] else ...[
          const SizedBox(height: 16),
          _fieldLabel('I am a'),
          const SizedBox(height: 8),
          _roleSelector(),
        ],
      ],
    );
  }

  Widget _roleSelector() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withOpacity(0.15),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(children: [
        _roleBtn('CLIENT', 'Client'),
        _roleBtn('AGENT', 'Agent'),
      ]),
    );
  }

  Widget _roleBtn(String role, String label) {
    final selected = _selectedRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedRole = role),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.center,
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: selected
                ? [BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2))]
                : [],
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : Colors.white70,
            ),
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Colors.white70,
        ),
      );

  Widget _glassField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
    VoidCallback? onIconTap,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 14, color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
        filled: true,
        fillColor: Colors.white.withOpacity(0.10),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        suffixIcon: GestureDetector(
          onTap: onIconTap,
          child: Icon(icon, color: Colors.white60, size: 20),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white, width: 1.5),
        ),
      ),
    );
  }

  // ── Validation helpers ────────────────────────────────────────────────────

  String? _validateIdentifier(String value) {
    final v = value.trim();
    if (v.isEmpty) return 'Please enter your email or mobile number';
    if (v.contains('@')) {
      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
      if (!emailRegex.hasMatch(v)) return 'Please enter a valid email address';
    } else {
      final digits = v.replaceAll(RegExp(r'\D'), '');
      if (digits.length != 10 &&
          !(digits.length == 12 && digits.startsWith('91'))) {
        return 'Please enter a valid 10-digit mobile number';
      }
    }
    return null;
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> _login() async {
    final identifierError = _validateIdentifier(_emailCtrl.text);
    if (identifierError != null) {
      _showError(identifierError);
      return;
    }
    if (_passwordCtrl.text.trim().isEmpty) {
      _showError('Please enter your password');
      return;
    }
    if (_passwordCtrl.text.length < 6) {
      _showError('Password must be at least 6 characters');
      return;
    }

    setState(() => _loading = true);

    try {
      final response = await UserApiService.login(
        _emailCtrl.text.trim(),
        _passwordCtrl.text.trim(),
      );
      final user = response.user;
      if (user.id == null || user.id == 0) {
        _showError('Login failed. Please try again.');
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('userId', user.id!);
      await prefs.setString('userName', user.name ?? '');
      await prefs.setString('userEmail', user.email ?? '');
      await prefs.setString('userMobile', user.mobile ?? '');
      await prefs.setString('userRole', user.userRole ?? '');
      await prefs.setBool('isVerified', user.isVerified ?? false);
      if (response.token != null) {
        await SecureTokenService.saveToken(response.token!);
        ApiClient.setToken(response.token);
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (_, __, ___) => DashboardScreen(userId: user.id!),
          transitionsBuilder: (_, animation, __, child) {
            final curved = CurvedAnimation(
                parent: animation, curve: Curves.easeOutCubic);
            return FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.05, 0),
                  end: Offset.zero,
                ).animate(curved),
                child: child,
              ),
            );
          },
        ),
      );
    } on SocketException {
      _showError('No internet connection. Please check your network.');
    } on TimeoutException {
      _showError('Connection timed out. Please try again.');
    } on FormatException {
      _showError('Unexpected server response. Please try again later.');
    } catch (e, s) {
      if (kDebugMode) {
        dev.log('Login error', name: 'LoginScreen', error: e, stackTrace: s);
      }
      final msg = e.toString().replaceFirst('Exception: ', '');
      _showError(msg.isNotEmpty ? msg : 'Incorrect email or password.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signup() async {
    if (_nameCtrl.text.trim().isEmpty) {
      _showError('Please enter your full name');
      return;
    }
    final identifierError = _validateIdentifier(_emailCtrl.text);
    if (identifierError != null) {
      _showError(identifierError);
      return;
    }
    final pwd = _passwordCtrl.text.trim();
    if (pwd.length < 8) {
      _showError('Password must be at least 8 characters');
      return;
    }
    if (!pwd.contains(RegExp(r'[A-Za-z]'))) {
      _showError('Password must contain at least one letter');
      return;
    }
    if (!pwd.contains(RegExp(r'[0-9]'))) {
      _showError('Password must contain at least one number');
      return;
    }

    setState(() => _loading = true);

    try {
      await UserApiService.signup(
        name: _nameCtrl.text.trim(),
        identifier: _emailCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
        role: _selectedRole,
      );
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtpVerificationScreen(
            value: _emailCtrl.text.trim(),
            isSignup: true,
          ),
        ),
      );
    } on SocketException {
      _showError('No internet connection. Please check your network.');
    } on TimeoutException {
      _showError('Connection timed out. Please try again.');
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      _showError(msg.isNotEmpty ? msg : 'Failed to create account. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: AppColors.error,
          content: Text(msg, style: const TextStyle(fontSize: 14)),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
  }
}
