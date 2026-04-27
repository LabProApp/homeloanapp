import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import '../commons/common_widget.dart';
import '../screens/otp_verification_screen.dart';
import '../services/user_service.dart';
import '../theme/app_colors.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ctrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String? _validateIdentifier(String? value) {
    final v = value?.trim() ?? '';
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

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      await UserApiService.resendOtp(_ctrl.text.trim());
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtpVerificationScreen(value: _ctrl.text.trim()),
        ),
      );
    } on SocketException {
      _showError('No internet connection. Please check your network.');
    } on TimeoutException {
      _showError('Connection timed out. Please try again.');
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      _showError(msg.isNotEmpty
          ? msg
          : 'Could not send verification code. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(msg, style: const TextStyle(fontSize: 14)),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
        flexibleSpace: const DecoratedBox(
          decoration: BoxDecoration(gradient: AppColors.primaryGradient),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Icon header
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.10),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock_reset_rounded,
                      size: 40, color: AppColors.primary),
                ),
              ),

              const SizedBox(height: 28),

              Text(
                'Reset your password',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter the email or mobile number linked to your account. '
                'We\'ll send you a verification code to proceed.',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),

              const SizedBox(height: 28),

              TextFormField(
                controller: _ctrl,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _loading ? null : _sendOtp(),
                style: const TextStyle(
                    fontSize: 14, color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Email or Mobile',
                  hintText: 'e.g. you@email.com or 9876543210',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
                validator: _validateIdentifier,
              ),

              const SizedBox(height: 28),

              AppButton(
                text: 'Send Verification Code',
                isLoading: _loading,
                onTap: _loading ? null : _sendOtp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
