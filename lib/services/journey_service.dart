import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/property_journey_model.dart';

class JourneyService {
  static const _key = 'property_journeys_v1';

  // ── Read ──────────────────────────────────────────────────────────────────

  static Future<List<PropertyJourneyModel>> loadAll(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    return raw
        .map(_tryDecode)
        .whereType<PropertyJourneyModel>()
        .where((j) => j.userId == userId)
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  static Future<PropertyJourneyModel?> findByPropertyId(
      int userId, int propertyId) async {
    final all = await loadAll(userId);
    try {
      return all.firstWhere((j) => j.propertyId == propertyId);
    } catch (_) {
      return null;
    }
  }

  // ── Write ─────────────────────────────────────────────────────────────────

  static Future<void> save(PropertyJourneyModel journey) async {
    final prefs = await SharedPreferences.getInstance();
    final all = _decodeAll(prefs.getStringList(_key) ?? []);

    final idx = all.indexWhere((j) => j.id == journey.id);
    if (idx >= 0) {
      all[idx] = journey;
    } else {
      all.insert(0, journey);
    }

    await prefs.setStringList(
        _key, all.map((j) => jsonEncode(j.toJson())).toList());
  }

  static Future<void> delete(String journeyId) async {
    final prefs = await SharedPreferences.getInstance();
    final all = _decodeAll(prefs.getStringList(_key) ?? []);
    all.removeWhere((j) => j.id == journeyId);
    await prefs.setStringList(
        _key, all.map((j) => jsonEncode(j.toJson())).toList());
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  static List<PropertyJourneyModel> _decodeAll(List<String> raw) =>
      raw.map(_tryDecode).whereType<PropertyJourneyModel>().toList();

  static PropertyJourneyModel? _tryDecode(String s) {
    try {
      return PropertyJourneyModel.fromJson(
          jsonDecode(s) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }
}
