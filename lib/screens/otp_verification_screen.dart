import 'package:flutter/material.dart';
import 'package:sms_autofill/sms_autofill.dart';
import '../services/user_service.dart';
import '../theme/app_colors.dart';
import '../screens/reset_password_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String value; // email or mobile

  const OtpVerificationScreen({
    super.key,
    required this.value,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen>
    with CodeAutoFill {
  String _otpCode = "";
  bool _loading = false;
  bool _resending = false;

  @override
  void initState() {
    super.initState();
    listenForCode(); // 📲 Auto read OTP
  }

  @override
  void dispose() {
    cancel();
    super.dispose();
  }

  @override
  void codeUpdated() {
    setState(() {
      _otpCode = code ?? "";
    });

    // ✅ Auto-submit when OTP length is complete
    if (_otpCode.length == 6) {
      _verifyOtp();
    }
  }

  Future<void> _verifyOtp() async {
    if (_otpCode.length != 6) return;

    setState(() => _loading = true);

    try {
      await UserApiService.verifyOtp(
        value: widget.value,
        otp: _otpCode,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(
            value: widget.value,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      final message = e.toString().replaceFirst("Exception: ", "");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resendOtp() async {
    setState(() => _resending = true);

    try {
      await UserApiService.resendOtp(widget.value);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("OTP resent successfully")),
      );
    } catch (e) {
      if (!mounted) return;

      final message = e.toString().replaceFirst("Exception: ", "");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Verify OTP"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "OTP sent to ${widget.value}",
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 24),

            /// 🔢 OTP INPUT
            PinFieldAutoFill(
              codeLength: 6,
              currentCode: _otpCode,
              decoration: BoxLooseDecoration(
                gapSpace: 10,
                radius: const Radius.circular(8),
                strokeColorBuilder:
                FixedColorBuilder(AppColors.primary),
              ),
              onCodeChanged: (code) {
                if (code != null) {
                  setState(() => _otpCode = code);
                }
              },
            ),

            const SizedBox(height: 12),

            /// 🔁 RESEND OTP
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _resending ? null : _resendOtp,
                child: Text(
                  _resending ? "Resending..." : "Resend OTP",
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),

            const SizedBox(height: 24),

            /// ✅ VERIFY BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _loading ? null : _verifyOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _loading
                    ? const CircularProgressIndicator(
                  color: Colors.white,
                )
                    : const Text(
                  "Verify OTP",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
