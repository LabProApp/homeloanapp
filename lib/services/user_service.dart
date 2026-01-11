import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../utility/ApiUrls.dart';
import 'dart:async';
import 'dart:io';
/// ================= USER API SERVICE =================
class UserApiService {
  /// 🔐 LOGIN
  static Future<LoginResponse> login(String identifier, String password) async {
    final uri = Uri.parse(ApiUrls.userlogin);

    final body = {
      identifier.contains('@') ? "email" : "mobile": identifier,
      "password": password,
    };

    developer.log("🔐 Login API", name: "UserApiService");
    developer.log("URL: $uri", name: "UserApiService");
    developer.log("BODY: ${jsonEncode(body)}", name: "UserApiService");

    http.Response res;

    try {
      res = await http
          .post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      )
          .timeout(const Duration(seconds: 15));
    } on TimeoutException {
      throw Exception("Login request timed out");
    } on SocketException {
      throw Exception("No internet connection");
    }

    developer.log("STATUS: ${res.statusCode}", name: "UserApiService");
    developer.log("RESPONSE: ${res.body}", name: "UserApiService");

    if (res.statusCode != 200) {
      throw Exception(_extractApiError(res.body));
    }

    final Map<String, dynamic> decoded;

    try {
      decoded = jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      throw Exception("Invalid JSON received from server");
    }

    // 🔴 Validate response structure
    if (decoded["id"] == null) {
      throw Exception("User ID missing in response");
    }

    // ✅ Build LoginResponse safely
    return LoginResponse(
      userId: decoded["id"].toString(),
      token: decoded["token"]?.toString(), // future-proof
    );
  }


  /// 🔐 RESET PASSWORD
  static Future<void> resetPassword({
    required String value,
    required String password,
  }) async {
    final uri = Uri.parse(ApiUrls.resetPassword);

    final body = {
      value.contains('@') ? "email" : "mobile": value,
      "password": password,
    };

    final res = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (res.statusCode != 200) {
      throw Exception(_extractApiError(res.body));
    }
  }

  /// 🔁 RESEND OTP
  static Future<void> resendOtp(String identifier) async {
    final uri = Uri.parse(ApiUrls.resendOtp).replace(
      queryParameters: {"identifier": identifier},
    );

    final res = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
    );

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

    final res = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
    );

    if (res.statusCode != 200) {
      throw Exception(_extractApiError(res.body));
    }
  }
}

/// ================= LOGIN RESPONSE MODEL =================
class LoginResponse {
  final String userId;
  final String? token;

  LoginResponse({required this.userId, this.token});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      userId: json["userId"]?.toString() ??
          json["id"]?.toString() ??
          json["user_id"]?.toString() ??
          "",
      token: json["token"]?.toString(),
    );
  }
}

/// ================= ERROR HANDLER =================
String _extractApiError(String responseBody) {
  try {
    final decoded = jsonDecode(responseBody);

    if (decoded is Map && decoded.containsKey("error")) {
      return decoded["error"].toString();
    }

    return decoded["message"]?.toString() ??
        decoded["msg"]?.toString() ??
        decoded.toString();
  } catch (_) {
    return responseBody.isNotEmpty ? responseBody : "Unexpected server error";
  }
}
