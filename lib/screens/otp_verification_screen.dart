import 'package:flutter/material.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:property/services/user_service.dart';
import 'package:property/theme/app_colors.dart';
import 'package:property/screens/reset_password_screen.dart';
class OtpVerificationScreen extends StatefulWidget {
  final String value;

  const OtpVerificationScreen({super.key, required this.value});

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
    listenForCode();
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resendOtp() async {
    setState(() => _resending = true);
    await UserApiService.resendOtp(widget.value);
    setState(() => _resending = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verify OTP")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text("OTP sent to ${widget.value}"),

            const SizedBox(height: 24),

            PinFieldAutoFill(
              codeLength: 6,
              currentCode: _otpCode,
              decoration: BoxLooseDecoration(
                gapSpace: 10,
                strokeColorBuilder: FixedColorBuilder(AppColors.primary),
              ),
              onCodeChanged: (code) {
                if (code != null) setState(() => _otpCode = code);
              },
            ),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _resending ? null : _resendOtp,
                child: Text(_resending ? "Resending..." : "Resend OTP"),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _loading ? null : _verifyOtp,
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Verify OTP"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
