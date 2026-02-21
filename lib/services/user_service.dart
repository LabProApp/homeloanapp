import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../utility/ApiUrls.dart';
import '../models/user_model.dart';
import '../models/DocumentModel.dart';
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
  static Future<String> uploadProfileImage(int userId, File image) async {
    final uri = Uri.parse("${ApiUrls.uploadDocuments}/USER/$userId");

    developer.log("📤 Upload Documents API", name: "UserApiService");
    developer.log("URL: $uri", name: "UserApiService");
    developer.log("FILE PATH: ${image.path}", name: "UserApiService");

    try {
      var request = http.MultipartRequest("POST", uri);

      // 🔑 IMPORTANT: field name must be "files" (plural)
      request.files.add(
        await http.MultipartFile.fromPath(
          "files",
          image.path,
        ),
      );

      // (Optional) captions support
      request.fields["captions"] = "profile-image";

      developer.log("REQUEST SENT", name: "UserApiService");

      var response = await request.send();

      developer.log("STATUS: ${response.statusCode}", name: "UserApiService");

      final responseBody = await response.stream.bytesToString();
      developer.log("RESPONSE: $responseBody", name: "UserApiService");

      if (response.statusCode != 200) {
        throw Exception("Image upload failed: $responseBody");
      }

      return responseBody; // JSON list of DocumentDto
    } on SocketException {
      developer.log("❌ No internet connection", name: "UserApiService");
      throw Exception("No internet connection");
    } on TimeoutException {
      developer.log("⏱ Upload timeout", name: "UserApiService");
      throw Exception("Upload timeout");
    } catch (e) {
      developer.log("🔥 Upload image error: $e", name: "UserApiService");
      rethrow;
    }
  }
  static Future<List<DocumentModel>> getDocuments({
    required String objectType,
    required int objectId,
  }) async {
    final uri = Uri.parse("${ApiUrls.uploadDocuments}/$objectType/$objectId");

    developer.log("📥 Get Documents API", name: "UserApiService");
    developer.log("URL: $uri", name: "UserApiService");

    http.Response res;

    try {
      res = await http
          .get(uri, headers: {"Content-Type": "application/json"})
          .timeout(const Duration(seconds: 15));
    } on SocketException {
      developer.log("❌ No internet", name: "UserApiService");
      throw Exception("No internet connection");
    } on TimeoutException {
      developer.log("⏱ Timeout", name: "UserApiService");
      throw Exception("Request timed out");
    }

    developer.log("STATUS: ${res.statusCode}", name: "UserApiService");
    developer.log("RESPONSE: ${res.body}", name: "UserApiService");

    if (res.statusCode != 200) {
      throw Exception("Failed to fetch documents");
    }

    final List decoded;

    try {
      decoded = jsonDecode(res.body) as List;
    } catch (_) {
      throw Exception("Invalid JSON received");
    }

    return decoded
        .map((e) => DocumentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }



  /// 👤 GET USER PROFILE (by email or mobile)
  static Future<UserModel> getProfile(String userId) async {
    final uri = Uri.parse(ApiUrls.userProfileById(userId));

    final res = await http.get(uri).timeout(const Duration(seconds: 15));

    if (res.statusCode != 200) {
      throw Exception("Failed to load profile");
    }

    final decoded = jsonDecode(res.body) as Map<String, dynamic>;

    return UserModel.fromJson(decoded);
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
  static Future<void> updateProfile({
    required int userId,
    required String name,
    required String address,
  }) async {
    final uri = Uri.parse(ApiUrls.updateUserProfile);

    developer.log("📤 Update Profile API", name: "UserApiService");
    developer.log("URL: $uri", name: "UserApiService");

    final body = {
      "id": userId,
      "name": name,
      "address": address,
    };

    developer.log("BODY: ${jsonEncode(body)}", name: "UserApiService");

    try {
      final res = await http.put(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      developer.log("STATUS: ${res.statusCode}", name: "UserApiService");
      developer.log("RESPONSE: ${res.body}", name: "UserApiService");

      if (res.statusCode != 200) {
        throw Exception("Failed to update profile: ${res.body}");
      }
    } on SocketException {
      developer.log("❌ No internet connection", name: "UserApiService");
      throw Exception("No internet connection");
    } on TimeoutException {
      developer.log("⏱ Request timeout", name: "UserApiService");
      throw Exception("Request timeout");
    } catch (e) {
      developer.log("🔥 Update profile error: $e", name: "UserApiService");
      rethrow;
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
