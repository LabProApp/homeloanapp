import 'package:flutter/material.dart';
import 'package:sms_autofill/sms_autofill.dart';

import '../commons/common_widget.dart';
import '../screens/reset_password_screen.dart';
import '../services/user_service.dart';
import '../theme/app_colors.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String value;

  const OtpVerificationScreen({super.key, required this.value});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen>
    with CodeAutoFill {
  String _otpCode = '';
  bool _loading = false;
  bool _resending = false;

  @override
  void initState() {
    super.initState();
    listenForCode();
  }

  @override
  void dispose() {
    cancel();
    super.dispose();
  }

  @override
  void codeUpdated() {
    setState(() => _otpCode = code ?? '');
    if (_otpCode.length == 6) _verifyOtp();
  }

  Future<void> _verifyOtp() async {
    if (_otpCode.length != 6) return;
    setState(() => _loading = true);

    try {
      await UserApiService.verifyOtp(value: widget.value, otp: _otpCode);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(value: widget.value),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _showSnack(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resendOtp() async {
    setState(() => _resending = true);
    try {
      await UserApiService.resendOtp(widget.value);
      if (!mounted) return;
      _showSnack('OTP resent successfully', success: true);
    } catch (e) {
      if (!mounted) return;
      _showSnack(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  void _showSnack(String msg, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontFamily: 'Poppins', fontSize: 14)),
        backgroundColor: success ? AppColors.success : AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter the 6-digit code sent to',
              style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 4),
            Text(
              widget.value,
              style: textTheme.titleMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 32),

            PinFieldAutoFill(
              codeLength: 6,
              currentCode: _otpCode,
              decoration: BoxLooseDecoration(
                gapSpace: 10,
                radius: const Radius.circular(10),
                strokeColorBuilder: FixedColorBuilder(AppColors.primary),
                bgColorBuilder: FixedColorBuilder(AppColors.textBoxbackground),
              ),
              onCodeChanged: (code) {
                if (code != null) setState(() => _otpCode = code);
              },
            ),

            const SizedBox(height: 12),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _resending ? null : _resendOtp,
                child: Text(
                  _resending ? 'Resending…' : 'Resend OTP',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            AppButton(
              text: 'Verify OTP',
              isLoading: _loading,
              onTap: _loading ? null : _verifyOtp,
            ),
          ],
        ),
      ),
    );
  }
}
