import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../models/property_model.dart';
import '../utility/ApiUrls.dart';

class PropertyApiService {

  /// 🔹 Fetch Properties (ALL or USER-SPECIFIC)
  Future<List<PropertyModel>> fetchProperties({String? userId}) async {
    try {
      final Uri uri;

      if (userId != null && userId.isNotEmpty) {
        /// ✅ user-specific properties
        uri = Uri.parse(
          "${ApiUrls.propertySearch}?userId=$userId",
        );
      } else {
        /// ✅ all properties
        uri = Uri.parse(ApiUrls.propertySearch);
      }

      developer.log("📤 FETCH PROPERTIES: $uri");

      final response = await http.get(uri);

      developer.log(
        "📥 FETCH PROPERTIES STATUS: ${response.statusCode}",
      );
      developer.log(
        "📥 FETCH PROPERTIES BODY: ${response.body}",
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data
            .map((e) => PropertyModel.fromJson(e))
            .toList();
      } else {
        throw Exception(
          "Failed to load properties (${response.statusCode})",
        );
      }
    } catch (e) {
      developer.log("❌ FETCH PROPERTIES ERROR: $e");
      rethrow;
    }
  }

  /// 🔹 Add Property
  static Future<bool> addProperty(PropertyModel property) async {
    final uri = Uri.parse(ApiUrls.post_property);

    developer.log("📤 ADD PROPERTY REQUEST");
    developer.log(jsonEncode(property.toJson()));

    final response = await http
        .post(
      uri,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(property.toJson()),
    )
        .timeout(const Duration(seconds: 20));

    developer.log("📥 ADD PROPERTY RESPONSE STATUS: ${response.statusCode}");
    developer.log("📥 ADD PROPERTY RESPONSE BODY: ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      throw Exception(
        "Add property failed (${response.statusCode}): ${response.body}",
      );
    }
  }
}
