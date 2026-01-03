import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:property/utility/ApiUrls.dart';

class UserApiService {

  static Future<void> resetPassword(String value,String password) async {
    final res = await http.post(
      Uri.parse(ApiUrls.resetPassword),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"value": value}),
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to send OTP");
    }
  }
  static Future<void> resendOtp(String value) async {
    final res = await http.post(
      Uri.parse(ApiUrls.resendOtp),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"value": value}),
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to resend OTP");
    }
  }

  static Future<void> verifyOtp({
    required String value,
    required String otp,
  }) async {
    final res = await http.post(
      Uri.parse(ApiUrls.verifyOtp),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "value": value,
        "otp": otp,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception("Invalid OTP");
    }
  }
}
