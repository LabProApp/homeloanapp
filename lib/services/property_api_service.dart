import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../models/property_model.dart';
import '../utility/ApiUrls.dart';

class PropertyApiService {

  /// 🔹 Fetch Properties (ALL or USER-SPECIFIC)
  Future<List<PropertyModel>> fetchProperties({
    String? userId,
    String? title,
    String? address,
    String? city,
    String? type,
    String? category,
    String? postedBy,
    String? constructionStatus,
    String? currency,
    String? location,
    double? minPrice,
    double? maxPrice,
    int? minBedrooms,
    int? maxBedrooms,
    int? minBathrooms,
    int? maxBathrooms,
    double? minArea,
    double? maxArea,
    String? amenity,
    String? rentOrSale,
    String? postDate,
    String? postedByUser,
  }) async {
    try {
      final Map<String, String> queryParams = {};

      void addParam(String key, dynamic value) {
        if (value != null && value.toString().isNotEmpty) {
          queryParams[key] = value.toString();
        }
      }

      addParam("userId", userId);
      addParam("title", title);
      addParam("address", address);
      addParam("city", city);
      addParam("type", type);
      addParam("category", category);
      addParam("postedBy", postedBy);
      addParam("constructionStatus", constructionStatus);
      addParam("currency", currency);
      addParam("location", location);
      addParam("minPrice", minPrice);
      addParam("maxPrice", maxPrice);
      addParam("minBedrooms", minBedrooms);
      addParam("maxBedrooms", maxBedrooms);
      addParam("minBathrooms", minBathrooms);
      addParam("maxBathrooms", maxBathrooms);
      addParam("minArea", minArea);
      addParam("maxArea", maxArea);
      addParam("amenity", amenity);
      addParam("rentOrSale", rentOrSale);
      addParam("postDate", postDate);
      addParam("postedByUser", postedByUser);

      final uri = Uri.parse(ApiUrls.propertySearch)
          .replace(queryParameters: queryParams.isEmpty ? null : queryParams);

      developer.log("📤 FETCH PROPERTIES: $uri");

      final response = await http.get(uri);

      developer.log("📥 FETCH PROPERTIES STATUS: ${response.statusCode}");
      developer.log("📥 FETCH PROPERTIES BODY: ${response.body}");

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((e) => PropertyModel.fromJson(e)).toList();
      } else {
        throw Exception("Failed to load properties (${response.statusCode})");
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

    final response = await http.post(
      uri,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(property.toJson()),
    ).timeout(const Duration(seconds: 20));

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

  /// 🔹 Update Property
  static Future<bool> updateProperty(PropertyModel property) async {
    if (property.id == null) {
      throw Exception("Property ID is required for update");
    }

    final uri = Uri.parse("${ApiUrls.update_property}/${property.id}");

    developer.log("📤 UPDATE PROPERTY REQUEST");
    developer.log(jsonEncode(property.toJson()));

    final response = await http.put(
      uri,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(property.toJson()),
    ).timeout(const Duration(seconds: 20));

    developer.log("📥 UPDATE PROPERTY STATUS: ${response.statusCode}");
    developer.log("📥 UPDATE PROPERTY BODY: ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 204) {
      return true;
    } else {
      throw Exception(
        "Update property failed (${response.statusCode}): ${response.body}",
      );
    }
  }
}
