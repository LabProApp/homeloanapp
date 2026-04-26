import 'dart:convert';
import 'dart:developer' as developer;

import '../models/property_model.dart';
import '../network/api_client.dart';
import '../utility/api_urls.dart';

class PropertyApiService {
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
    int? postedByUserId,
  }) async {
    final params = <String, String>{};

    void add(String key, dynamic value) {
      if (value != null && value.toString().isNotEmpty) {
        params[key] = value.toString();
      }
    }

    add('userId', userId);
    add('title', title);
    add('address', address);
    add('city', city);
    add('type', type);
    add('category', category);
    add('postedBy', postedBy);
    add('constructionStatus', constructionStatus);
    add('currency', currency);
    add('location', location);
    add('minPrice', minPrice);
    add('maxPrice', maxPrice);
    add('minBedrooms', minBedrooms);
    add('maxBedrooms', maxBedrooms);
    add('minBathrooms', minBathrooms);
    add('maxBathrooms', maxBathrooms);
    add('minArea', minArea);
    add('maxArea', maxArea);
    add('amenity', amenity);
    add('rentOrSale', rentOrSale);
    add('postDate', postDate);
    add('postedByUser', postedByUserId);

    final uri = Uri.parse(ApiUrls.propertySearch)
        .replace(queryParameters: params.isEmpty ? null : params);

    developer.log('Fetch properties: $uri');

    final response = await ApiClient.get(uri);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => PropertyModel.fromJson(e)).toList();
    }
    throw Exception('Failed to load properties (${response.statusCode})');
  }

  static Future<int> addProperty(PropertyModel property) async {
    final uri = Uri.parse(ApiUrls.post_property);

    developer.log('Add property: $uri');

    final response = await ApiClient.post(
      uri,
      body: jsonEncode(property.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        if (decoded.containsKey('id')) return decoded['id'] as int;
        if (decoded.containsKey('propertyId')) return decoded['propertyId'] as int;
        if (decoded['data'] is Map && decoded['data'].containsKey('id')) {
          return decoded['data']['id'] as int;
        }
      }
      throw Exception('Property ID not found in response');
    }
    throw Exception('Add property failed (${response.statusCode}): ${response.body}');
  }

  static Future<bool> updateProperty(PropertyModel property) async {
    if (property.id == null) throw Exception('Property ID required for update');

    final uri = Uri.parse('${ApiUrls.update_property}/${property.id}');

    developer.log('Update property: $uri');

    final response = await ApiClient.put(
      uri,
      body: jsonEncode(property.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 204) return true;
    throw Exception('Update property failed (${response.statusCode}): ${response.body}');
  }

  Future<List<PropertyModel>> fetchFavouriteProperties(int userId) async {
    final uri = Uri.parse('${ApiUrls.baseUrl}/user/$userId/favourites');

    developer.log('Fetch favourites: $uri');

    final response = await ApiClient.get(uri);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => PropertyModel.fromJson(e)).toList();
    }
    throw Exception('Failed to load favourites (${response.statusCode})');
  }

  static Future<bool> toggleFavourite({
    required int userId,
    required int propertyId,
  }) async {
    final url = ApiUrls.post_MarkFavProperty
        .replaceFirst('{userId}', userId.toString())
        .replaceFirst('{propertyId}', propertyId.toString());

    developer.log('Toggle favourite: $url');

    final response = await ApiClient.post(Uri.parse(url));

    if (response.statusCode == 200 || response.statusCode == 204) return true;
    throw Exception('Toggle favourite failed: ${response.body}');
  }
}
