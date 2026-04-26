import 'dart:convert';

import '../network/api_client.dart';
import '../utility/api_urls.dart';

class MasterValue {
  final int id;
  final String value;

  MasterValue({required this.id, required this.value});

  factory MasterValue.fromJson(Map<String, dynamic> json) {
    final parsedId = json['id'] is int
        ? json['id']
        : int.tryParse(json['id'].toString()) ?? 0;

    return MasterValue(
      id: parsedId,
      value: json['value']?.toString() ?? '',
    );
  }
}

class MasterService {
  static List<MasterValue>? _stateCache;
  static final Map<int, List<MasterValue>> _cityCache = {};
  static final Map<int, List<MasterValue>> _localityCache = {};

  static Future<List<MasterValue>> getStates() async {
    if (_stateCache != null) return _stateCache!;

    final response = await ApiClient.get(Uri.parse(ApiUrls.state_list));

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final List<dynamic> data = decoded is List ? decoded : decoded['data'] ?? [];
      _stateCache = data
          .map((e) => MasterValue.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      return _stateCache!;
    }
    throw Exception('Failed to load states');
  }

  static Future<List<MasterValue>> getCities(int stateId) async {
    if (_cityCache.containsKey(stateId)) return _cityCache[stateId]!;

    final uri = Uri.parse('${ApiUrls.baseUrl}/master/$stateId/child?type=CITY');
    final response = await ApiClient.get(uri);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final List<dynamic> data = decoded is List ? decoded : decoded['data'] ?? [];
      _cityCache[stateId] =
          data.map((e) => MasterValue.fromJson(Map<String, dynamic>.from(e))).toList();
      return _cityCache[stateId]!;
    }
    throw Exception('Failed to load cities');
  }

  static Future<List<MasterValue>> getLocalities(int cityId) async {
    if (_localityCache.containsKey(cityId)) return _localityCache[cityId]!;

    final uri = Uri.parse('${ApiUrls.baseUrl}/master/$cityId/child?type=LOCALITY');
    final response = await ApiClient.get(uri);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final List<dynamic> data = decoded is List ? decoded : decoded['data'] ?? [];
      _localityCache[cityId] =
          data.map((e) => MasterValue.fromJson(Map<String, dynamic>.from(e))).toList();
      return _localityCache[cityId]!;
    }
    throw Exception('Failed to load localities');
  }

  static void clearCache() {
    _stateCache = null;
    _cityCache.clear();
    _localityCache.clear();
  }
}
