import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:property/utility/ApiUrls.dart';

class UserApiService {

  /// 🔐 RESET PASSWORD
  static Future<void> resetPassword({
    required String value, // email or mobile
    required String password,
  }) async {
    final uri = Uri.parse(ApiUrls.resetPassword);

    final body = {
      value.contains('@') ? "email" : "mobile": value,
      "password": password,
    };

    developer.log("🔹 Reset Password API", name: "resetPassword");
    developer.log("🔹 URL: $uri", name: "resetPassword");
    developer.log("🔹 Body: ${jsonEncode(body)}", name: "resetPassword");

    final res = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    developer.log("🔹 Status: ${res.statusCode}", name: "resetPassword");
    developer.log("🔹 Response: ${res.body}", name: "resetPassword");

    if (res.statusCode != 200) {
      throw Exception(_extractApiError(res.body));
    }
  }

  /// 🔁 RESEND OTP
  static Future<void> resendOtp(String identifier) async {
    final uri = Uri.parse(ApiUrls.resendOtp).replace(
      queryParameters: {"identifier": identifier},
    );

    developer.log("🔹 Resend OTP API", name: "resendOtp");
    developer.log("🔹 URL: $uri", name: "resendOtp");

    final res = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
    );

    developer.log("🔹 Status Code: ${res.statusCode}", name: "resendOtp");
    developer.log("🔹 Response Body: ${res.body}", name: "resendOtp");

    if (res.statusCode != 200) {
      throw Exception(_extractApiError(res.body));
    }
  }

  /// ✅ VERIFY OTP
  static Future<void> verifyOtp({
    required String value,
    required String otp,
  }) async {
    final uri = Uri.parse(ApiUrls.verifyOtp).replace(
      queryParameters: {
        "identifier": value,
        "otp": otp,
      },
    );

    developer.log("🔹 Verify OTP API", name: "verifyOtp");
    developer.log("🔹 URL: $uri", name: "verifyOtp");

    final res = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
    );

    developer.log("🔹 Status: ${res.statusCode}", name: "verifyOtp");
    developer.log("🔹 Response: ${res.body}", name: "verifyOtp");

    if (res.statusCode != 200) {
      throw Exception(_extractApiError(res.body));
    }
  }
}
String _extractApiError(String responseBody) {
  try {
    final decoded = jsonDecode(responseBody);

    // 👇 your backend format
    if (decoded is Map && decoded.containsKey("error")) {
      return decoded["error"].toString();
    }

    // common fallbacks
    return decoded["message"] ??
        decoded["msg"] ??
        decoded.toString();
  } catch (_) {
    return responseBody.isNotEmpty
        ? responseBody
        : "Unexpected server error";
  }
}
