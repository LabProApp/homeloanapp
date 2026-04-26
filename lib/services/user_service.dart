import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/document_model.dart';
import '../models/user_model.dart';
import '../network/api_client.dart';
import '../utility/api_urls.dart';

class UserApiService {
  static Future<LoginResponse> login(String identifier, String password) async {
    final uri = Uri.parse(ApiUrls.userlogin);

    final body = {
      identifier.contains('@') ? 'email' : 'mobile': identifier,
      'password': password,
    };

    developer.log('Login: $uri', name: 'UserApiService');

    final res = await ApiClient.post(uri, body: jsonEncode(body));

    developer.log('Status: ${res.statusCode}', name: 'UserApiService');

    if (res.statusCode != 200) throw Exception(_extractError(res.body));

    final Map<String, dynamic> decoded;
    try {
      decoded = jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      throw Exception('Invalid JSON received from server');
    }

    if (decoded['id'] == null) throw Exception('User ID missing in response');

    return LoginResponse(
      user: UserModel.fromJson(decoded),
      token: decoded['token']?.toString(),
    );
  }

  static Future<String> uploadProfileImage(int userId, File image) async {
    final uri = Uri.parse('${ApiUrls.uploadDocuments}/USER/$userId');

    developer.log('Upload profile image: $uri', name: 'UserApiService');

    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('files', image.path))
      ..fields['captions'] = 'profile-image';

    final streamed = await ApiClient.sendMultipart(request);
    final response = await http.Response.fromStream(streamed);

    developer.log('Upload status: ${response.statusCode}', name: 'UserApiService');

    if (response.statusCode != 200) {
      throw Exception('Image upload failed: ${response.body}');
    }

    return response.body;
  }

  static Future<List<DocumentModel>> getDocuments({
    required String objectType,
    required int objectId,
  }) async {
    final uri = Uri.parse('${ApiUrls.uploadDocuments}/$objectType/$objectId');

    developer.log('Get documents: $uri', name: 'UserApiService');

    final res = await ApiClient.get(uri);

    if (res.statusCode != 200) throw Exception('Failed to fetch documents');

    final List decoded = jsonDecode(res.body) as List;
    return decoded
        .map((e) => DocumentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<UserModel> getProfile(int userId) async {
    final uri = Uri.parse(ApiUrls.userProfileById(userId.toString()));
    final res = await ApiClient.get(uri);

    if (res.statusCode != 200) throw Exception('Failed to load profile');

    return UserModel.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  static Future<void> resetPassword({
    required String value,
    required String password,
  }) async {
    final body = {
      value.contains('@') ? 'email' : 'mobile': value,
      'password': password,
    };

    final res = await ApiClient.post(
      Uri.parse(ApiUrls.resetPassword),
      body: jsonEncode(body),
    );

    if (res.statusCode != 200) throw Exception(_extractError(res.body));
  }

  static Future<void> resendOtp(String identifier) async {
    final uri = Uri.parse(ApiUrls.resendOtp)
        .replace(queryParameters: {'identifier': identifier});

    final res = await ApiClient.post(uri);

    if (res.statusCode != 200) throw Exception(_extractError(res.body));
  }

  static Future<void> updateProfile({
    required int userId,
    required String name,
    required String address,
  }) async {
    final uri = Uri.parse(ApiUrls.updateUserProfile);
    final body = {'id': userId, 'name': name, 'address': address};

    developer.log('Update profile: $uri', name: 'UserApiService');

    final res = await ApiClient.put(uri, body: jsonEncode(body));

    if (res.statusCode != 200) {
      throw Exception('Failed to update profile: ${res.body}');
    }
  }

  static Future<void> verifyOtp({
    required String value,
    required String otp,
  }) async {
    final uri = Uri.parse(ApiUrls.verifyOtp).replace(
      queryParameters: {'identifier': value, 'otp': otp},
    );

    final res = await ApiClient.post(uri);

    if (res.statusCode != 200) throw Exception(_extractError(res.body));
  }

  static String _extractError(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map) {
        return decoded['error']?.toString() ??
            decoded['message']?.toString() ??
            decoded['msg']?.toString() ??
            decoded.toString();
      }
    } catch (_) {}
    return body.isNotEmpty ? body : 'Unexpected server error';
  }
}

class LoginResponse {
  final UserModel user;
  final String? token;

  const LoginResponse({required this.user, this.token});
}
