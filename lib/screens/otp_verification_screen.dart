import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sms_autofill/sms_autofill.dart';

import '../commons/common_widget.dart';
import '../screens/reset_password_screen.dart';
import '../services/user_service.dart';
import '../theme/app_colors.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String value;
  final bool isSignup;

  const OtpVerificationScreen({
    super.key,
    required this.value,
    this.isSignup = false,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen>
    with CodeAutoFill {
  String _otpCode = '';
  bool _loading = false;
  bool _resending = false;
  int _countdown = 60;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    listenForCode();
    _startCountdown();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    cancel();
    super.dispose();
  }

  @override
  void codeUpdated() {
    if (!mounted) return;
    setState(() => _otpCode = code ?? '');
    if (_otpCode.length == 6) _verifyOtp();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    setState(() => _countdown = 60);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        if (_countdown > 0) {
          _countdown--;
        } else {
          t.cancel();
        }
      });
    });
  }

  Future<void> _verifyOtp() async {
    if (_otpCode.length != 6) {
      _showSnack('Please enter the complete 6-digit code');
      return;
    }
    setState(() => _loading = true);

    try {
      await UserApiService.verifyOtp(value: widget.value, otp: _otpCode);
      if (!mounted) return;
      if (widget.isSignup) {
        // Account activated — go back to login and show success
        Navigator.of(context).popUntil((route) => route.isFirst);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Account created! Please log in.'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ResetPasswordScreen(value: widget.value),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceFirst('Exception: ', '');
      _showSnack(
        msg.isNotEmpty ? msg : 'Invalid or expired code. Please try again.',
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resendOtp() async {
    if (_countdown > 0) return;
    setState(() => _resending = true);
    try {
      await UserApiService.resendOtp(widget.value);
      if (!mounted) return;
      _startCountdown();
      _showSnack('Verification code resent successfully', success: true);
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceFirst('Exception: ', '');
      _showSnack(
          msg.isNotEmpty ? msg : 'Failed to resend code. Please try again.');
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  void _showSnack(String msg, {bool success = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(msg, style: const TextStyle(fontSize: 14)),
          backgroundColor: success ? AppColors.success : AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final canResend = _countdown == 0 && !_resending;

    return Scaffold(
      appBar: GradientAppBar(
        title: 'Verify Code',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Icon header
            Center(
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.mark_email_read_outlined,
                    size: 36, color: AppColors.primary),
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Enter the 6-digit code sent to',
              style: textTheme.bodyMedium
                  ?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 4),
            Text(
              widget.value,
              style: textTheme.titleMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 32),

            PinFieldAutoFill(
              codeLength: 6,
              currentCode: _otpCode,
              decoration: BoxLooseDecoration(
                gapSpace: 10,
                radius: const Radius.circular(12),
                strokeColorBuilder:
                    FixedColorBuilder(AppColors.primary),
                bgColorBuilder:
                    FixedColorBuilder(AppColors.textBoxbackground),
              ),
              onCodeChanged: (code) {
                if (code != null) setState(() => _otpCode = code);
              },
            ),

            const SizedBox(height: 16),

            // Resend row
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (_countdown > 0)
                  Text(
                    'Resend in ${_countdown}s',
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.textMuted),
                  )
                else
                  TextButton(
                    onPressed: canResend ? _resendOtp : null,
                    child: Text(
                      _resending ? 'Resending…' : 'Resend Code',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 24),

            AppButton(
              text: 'Verify Code',
              isLoading: _loading,
              onTap: _loading ? null : _verifyOtp,
            ),

            const SizedBox(height: 20),

            Center(
              child: Text(
                "Didn't receive the code? Check your spam folder.",
                textAlign: TextAlign.center,
                style: textTheme.bodySmall
                    ?.copyWith(color: AppColors.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
