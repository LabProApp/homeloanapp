import 'dart:convert';
import 'dart:developer' as developer;

import '../models/plan_change_request_model.dart';
import '../network/api_client.dart';
import '../utility/api_urls.dart';

/// Client for the user-side plan-change request API.
///
/// See backend {@code com.api.plan.PlanChangeRequestController}.
class PlanRequestApiService {
  /// Submit a new upgrade request. Server rejects with 400 if the user
  /// already has a PENDING request.
  static Future<PlanChangeRequestModel> submit({
    required String plan,
    String? notes,
  }) async {
    final uri = Uri.parse(ApiUrls.planRequests);
    developer.log('Submit plan request: $uri plan=$plan');

    final res = await ApiClient.post(
      uri,
      body: jsonEncode({
        'requestedPlan': plan,
        if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
      }),
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      return PlanChangeRequestModel.fromJson(
          jsonDecode(res.body) as Map<String, dynamic>);
    }
    throw Exception(_errorMessage(res.body, 'Could not submit plan request'));
  }

  /// Returns the current user's full request history, newest first.
  static Future<List<PlanChangeRequestModel>> getMyRequests() async {
    final uri = Uri.parse(ApiUrls.myPlanRequests);
    developer.log('Fetch my plan requests: $uri');

    final res = await ApiClient.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Failed to load plan requests (${res.statusCode})');
    }
    final decoded = jsonDecode(res.body);
    if (decoded is! List) return [];
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(PlanChangeRequestModel.fromJson)
        .toList();
  }

  /// Cancel a PENDING request the current user submitted.
  static Future<PlanChangeRequestModel> cancel(int requestId) async {
    final uri = Uri.parse(ApiUrls.cancelPlanRequest(requestId));
    final res = await ApiClient.post(uri);
    if (res.statusCode != 200) {
      throw Exception(_errorMessage(res.body, 'Could not cancel request'));
    }
    return PlanChangeRequestModel.fromJson(
        jsonDecode(res.body) as Map<String, dynamic>);
  }

  static String _errorMessage(String body, String fallback) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map && decoded['error'] is String) {
        return decoded['error'] as String;
      }
    } catch (_) {}
    return fallback;
  }
}
