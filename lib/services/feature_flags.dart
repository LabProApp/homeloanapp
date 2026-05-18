import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';

/// Single source of truth for feature flags on the client.
///
/// Flags are populated from the server (login + profile fetch), persisted
/// to [SharedPreferences] under [_prefsKey], and queried via [isEnabled].
/// Default-on for safety: an unknown key returns `true` so a stale or
/// missing payload never locks a user out of a feature they should see.
class FeatureFlags {
  static const String _prefsKey = 'featureFlags';
  static const String _planKey = 'planName';
  static const String _planPriceKey = 'planPriceYearly';
  static const String _planPropertyLimitKey = 'planPropertyLimit';

  // Canonical keys — must match com.api.plan.PlanFeatureKeys on the server.
  static const String buySell = 'buy_sell';
  static const String rentPg = 'rent_pg';
  static const String bankLoans = 'bank_loans';
  static const String documentation = 'documentation';
  static const String emiCalculator = 'emi_calculator';
  static const String postProperty = 'post_property';
  static const String postRequirement = 'post_requirement';
  static const String journey = 'journey';

  static Map<String, bool> _cache = const {};

  /// Persist the flags returned by login / profile fetch. Pass `null`
  /// to clear (e.g. on logout).
  static Future<void> save(UserModel? user) async {
    final prefs = await SharedPreferences.getInstance();
    if (user == null) {
      _cache = const {};
      await prefs.remove(_prefsKey);
      await prefs.remove(_planKey);
      await prefs.remove(_planPriceKey);
      await prefs.remove(_planPropertyLimitKey);
      return;
    }
    _cache = Map<String, bool>.from(user.featureFlags);
    await prefs.setString(_prefsKey, jsonEncode(user.featureFlags));
    await prefs.setString(_planKey, user.userPackage);
    await prefs.setDouble(_planPriceKey, user.planPriceYearly);
    await prefs.setInt(_planPropertyLimitKey, user.planPropertyLimit);
  }

  /// Hydrate the in-memory cache from prefs (call on app start so the
  /// first frame doesn't have to await disk).
  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null || raw.isEmpty) {
      _cache = const {};
      return;
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        _cache = {
          for (final e in decoded.entries)
            if (e.key is String) e.key as String: e.value == true,
        };
      }
    } catch (_) {
      _cache = const {};
    }
  }

  /// Returns whether [key] is enabled for the current user. Defaults to
  /// `true` for unknown keys so a stale/missing payload never hides a
  /// feature the user should still see.
  static bool isEnabled(String key) => _cache[key] ?? true;

  /// Read-only snapshot — useful for debug screens.
  static Map<String, bool> get snapshot => Map.unmodifiable(_cache);

  /// Active plan name (BASIC / DELUX / PREMIUM). Empty until loaded.
  static Future<String> planName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_planKey) ?? '';
  }

  static Future<double> planPriceYearly() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_planPriceKey) ?? 0.0;
  }

  /// Max number of property listings the current plan permits. 0 means
  /// posting is blocked for this plan (BASIC). Read straight from prefs
  /// each call so callers always see the latest server-pushed value.
  static Future<int> planPropertyLimit() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_planPropertyLimitKey) ?? 0;
  }
}
