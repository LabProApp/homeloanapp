import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/app_version_model.dart';
import '../utility/api_urls.dart';

/// Calls the public version-check endpoint on every app launch.
///
/// Uses a raw [http.get] (not [ApiClient]) because:
///   • The endpoint is public — no auth header needed.
///   • A short timeout (5 s) prevents the splash from hanging on bad networks.
///   • Any failure silently returns [AppVersionModel.noUpdate] so the app
///     always starts, even when the server is unreachable.
class AppVersionApiService {
  static Future<AppVersionModel> check({required int versionCode}) async {
    try {
      final platform = Platform.isAndroid ? 'ANDROID' : 'IOS';
      final uri = Uri.parse(ApiUrls.versionCheck).replace(queryParameters: {
        'platform': platform,
        'versionCode': versionCode.toString(),
      });
      developer.log('AppVersion check: $uri');

      final res = await http.get(uri).timeout(const Duration(seconds: 5));

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        if (decoded is Map<String, dynamic>) {
          return AppVersionModel.fromJson(decoded);
        }
      }
      developer.log('AppVersion check failed: ${res.statusCode}');
    } catch (e) {
      developer.log('AppVersion check error: $e');
    }
    // Any error → treat as no update so the app is never blocked.
    return AppVersionModel.noUpdate;
  }
}
