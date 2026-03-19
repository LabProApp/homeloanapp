import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utility/ApiUrls.dart';

/// Master model (State / City / Locality)
class MasterValue {
  final int id;
  final String value;

  MasterValue({
    required this.id,
    required this.value,
  });

  factory MasterValue.fromJson(Map<String, dynamic> json) {

    print("🔎 MasterValue.fromJson RAW: $json");

    final parsedId = json['id'] is int
        ? json['id']
        : int.tryParse(json['id'].toString()) ?? 0;

    final parsedValue = json['value']?.toString() ?? "";

    return MasterValue(
      id: parsedId,
      value: parsedValue,
    );
  }
}

class MasterService {

  /// STATE CACHE
  static List<MasterValue>? _stateCache;

  /// CITY CACHE (stateId -> cities)
  static final Map<int, List<MasterValue>> _cityCache = {};

  /// LOCALITY CACHE (cityId -> localities)
  static final Map<int, List<MasterValue>> _localityCache = {};

  /// ----------------------------------
  /// Fetch STATES
  /// ----------------------------------
  static Future<List<MasterValue>> getStates() async {

    print("📌 MasterService.getStates()");

    if (_stateCache != null) {
      print("⚡ STATES loaded from cache (${_stateCache!.length})");
      return _stateCache!;
    }

    final uri = Uri.parse(ApiUrls.state_list);

    print("🌐 Calling STATES API → $uri");

    final response = await http.get(uri);

    print("⬅️ Status: ${response.statusCode}");

    if (response.statusCode == 200) {

      final decoded = jsonDecode(response.body);

      final List<dynamic> data =
      decoded is List ? decoded : decoded["data"] ?? [];

      print("📊 States from API: ${data.length}");

      _stateCache = data
          .map((e) => MasterValue.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      print("✅ STATES cached");

      return _stateCache!;
    }

    throw Exception("Failed to load states");
  }

  /// ----------------------------------
  /// Fetch CITIES by STATE
  /// ----------------------------------
  static Future<List<MasterValue>> getCities(int stateId) async {

    print("📌 MasterService.getCities()");
    print("➡️ stateId: $stateId");

    /// CACHE CHECK
    if (_cityCache.containsKey(stateId)) {

      print("⚡ Returning CITIES from cache for stateId=$stateId");
      print("📊 Cached cities: ${_cityCache[stateId]!.length}");

      return _cityCache[stateId]!;
    }

    final url = "${ApiUrls.baseUrl}/master/$stateId/child?type=CITY";

    print("🌐 Calling Cities API → $url");

    final response = await http.get(Uri.parse(url));

    print("⬅️ Status: ${response.statusCode}");
    print("📦 RAW Response: ${response.body}");

    if (response.statusCode == 200) {

      final decoded = jsonDecode(response.body);

      final List<dynamic> data =
      decoded is List ? decoded : decoded["data"] ?? [];

      print("📊 Cities from API: ${data.length}");

      final cities = data
          .map((e) => MasterValue.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      /// SAVE CACHE
      _cityCache[stateId] = cities;

      print("✅ Cities cached for stateId=$stateId");

      return cities;
    }

    throw Exception("Failed to load cities");
  }

  /// ----------------------------------
  /// Fetch LOCALITIES by CITY
  /// ----------------------------------
  static Future<List<MasterValue>> getLocalities(int cityId) async {

    print("📌 MasterService.getLocalities()");
    print("➡️ cityId: $cityId");

    /// CACHE CHECK
    if (_localityCache.containsKey(cityId)) {

      print("⚡ Returning LOCALITIES from cache for cityId=$cityId");
      print("📊 Cached localities: ${_localityCache[cityId]!.length}");

      return _localityCache[cityId]!;
    }

    final url = "${ApiUrls.baseUrl}/master/$cityId/child?type=LOCALITY";

    print("🌐 Calling Localities API → $url");

    final response = await http.get(Uri.parse(url));

    print("⬅️ Status: ${response.statusCode}");
    print("📦 RAW Response: ${response.body}");

    if (response.statusCode == 200) {

      final decoded = jsonDecode(response.body);

      final List<dynamic> data =
      decoded is List ? decoded : decoded["data"] ?? [];

      print("📊 Localities from API: ${data.length}");

      final localities = data
          .map((e) => MasterValue.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      /// SAVE CACHE
      _localityCache[cityId] = localities;

      print("✅ Localities cached for cityId=$cityId");

      return localities;
    }

    throw Exception("Failed to load localities");
  }

  /// ----------------------------------
  /// Clear Cache
  /// ----------------------------------
  static void clearCache() {

    print("🧹 Clearing ALL master caches");

    print("States: ${_stateCache?.length ?? 0}");
    print("Cities: ${_cityCache.length}");
    print("Localities: ${_localityCache.length}");

    _stateCache = null;
    _cityCache.clear();
    _localityCache.clear();

    print("✅ Cache cleared");
  }
}