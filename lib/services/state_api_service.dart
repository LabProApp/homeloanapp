import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utility/ApiUrls.dart'; // Make sure this points to your ApiUrls class

// Model for State (Cities are just strings)
class MasterValue {
  final int id;

  final String value;


  MasterValue({
    required this.id,
    required this.value,

  });

  factory MasterValue.fromJson(Map<String, dynamic> json) {
    print('Parsing MasterValue from JSON: $json'); // Logging
    return MasterValue(
      id: json['id'],

      value: json['value'],

    );
  }
}

class MasterService {
  // In-memory cache
  static List<MasterValue>? _stateCache;
  static final Map<int, List<String>> _cityCache = {}; // cities are strings

  /// Fetch states (cached)
  static Future<List<MasterValue>> getStates() async {
    if (_stateCache != null) {
      print('Returning cached states'); // Logging
      return _stateCache!;
    }

    final Uri uri = Uri.parse(ApiUrls.state_list);
    print('Fetching states from API: $uri'); // Logging
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      print('States API response: $data'); // Logging
      _stateCache = data.map((e) => MasterValue.fromJson(e)).toList();
      print('States cached successfully'); // Logging
      return _stateCache!;
    } else {
      print('Failed to load states: ${response.statusCode}'); // Logging
      throw Exception('Failed to load states');
    }
  }

  /// Fetch cities for a state ID (cached)
  static Future<List<String>> getCities(int stateId) async {
    if (_cityCache.containsKey(stateId)) {
      print('Returning cached cities for stateId=$stateId'); // Logging
      return _cityCache[stateId]!;
    }

    // Correct way to get city URL
    final String cityApiUrl = ApiUrls.city_list(stateId); // Assuming this returns the full URL
    final Uri uri = Uri.parse(cityApiUrl);

    print('Fetching cities from API: $uri'); // Logging
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      print('Cities API response for stateId=$stateId: $data'); // Logging
      final cities = data.map((e) => e.toString()).toList();
      _cityCache[stateId] = cities;
      print('Cities cached successfully for stateId=$stateId'); // Logging
      return cities;
    } else {
      print('Failed to load cities for stateId=$stateId: ${response.statusCode}'); // Logging
      throw Exception('Failed to load cities for state $stateId');
    }
  }

  /// Clear caches
  static void clearCache() {
    print('Clearing state and city caches'); // Logging
    _stateCache = null;
    _cityCache.clear();
  }
}
