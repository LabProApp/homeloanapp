import 'dart:convert';
import 'dart:developer' as developer;

import '../models/admin_stats_model.dart';
import '../models/plan_change_request_model.dart';
import '../models/user_model.dart';
import '../network/api_client.dart';
import '../utility/api_urls.dart';

/// Client for admin-only endpoints on the backend.
///
/// All methods require the caller to hold a JWT with ROLE_ADMIN — the
/// backend enforces this with {@code @PreAuthorize} and returns 403
/// otherwise.
class AdminApiService {
  // ── Stats ─────────────────────────────────────────────────────────────────

  static Future<AdminStatsModel> getStats() async {
    final res = await ApiClient.get(Uri.parse(ApiUrls.adminStats));
    if (res.statusCode != 200) {
      throw Exception('Failed to load admin stats (${res.statusCode})');
    }
    return AdminStatsModel.fromJson(
        jsonDecode(res.body) as Map<String, dynamic>);
  }

  // ── Users ─────────────────────────────────────────────────────────────────

  /// Returns one page of users matching the optional plan + free-text filter.
  /// {@code plan} accepts BASIC / DELUX / PREMIUM (or null for any).
  static Future<AdminUsersPage> listUsers({
    String? plan,
    String? search,
    int page = 0,
    int size = 50,
  }) async {
    final params = <String, String>{
      if (plan != null && plan.isNotEmpty) 'plan': plan,
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      'page': page.toString(),
      'size': size.toString(),
    };
    final uri =
        Uri.parse(ApiUrls.adminUsers).replace(queryParameters: params);
    developer.log('Admin list users: $uri');
    final res = await ApiClient.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Failed to load users (${res.statusCode})');
    }
    final decoded = jsonDecode(res.body) as Map<String, dynamic>;
    final raw = decoded['content'];
    final users = raw is List
        ? raw
            .whereType<Map<String, dynamic>>()
            .map(UserModel.fromJson)
            .toList()
        : <UserModel>[];
    return AdminUsersPage(
      users: users,
      page: decoded['page'] is int ? decoded['page'] as int : 0,
      size: decoded['size'] is int ? decoded['size'] as int : users.length,
      total: decoded['total'] is int ? decoded['total'] as int : users.length,
    );
  }

  /// Assigns a plan to a user. Wraps {@code POST /api/user/{id}/plan}.
  /// Pass null durationYears to accept the server default (1 year).
  static Future<UserModel> assignPlan({
    required int userId,
    required String plan,
    int? durationYears,
    String? reason,
  }) async {
    final body = <String, dynamic>{'plan': plan};
    if (durationYears != null) body['durationYears'] = durationYears;
    if (reason != null && reason.trim().isNotEmpty) body['reason'] = reason.trim();
    final res = await ApiClient.post(
      Uri.parse(ApiUrls.adminChangeUserPlan(userId)),
      body: jsonEncode(body),
    );
    if (res.statusCode != 200) {
      throw Exception(_errorMessage(res.body, 'Plan assignment failed'));
    }
    return UserModel.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  // ── Plan-change requests (admin queue) ────────────────────────────────────

  static Future<List<PlanChangeRequestModel>> listRequests({
    String status = 'PENDING',
  }) async {
    final uri = Uri.parse(ApiUrls.planRequests)
        .replace(queryParameters: {'status': status});
    final res = await ApiClient.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Failed to load plan requests (${res.statusCode})');
    }
    final decoded = jsonDecode(res.body);
    if (decoded is! List) return const [];
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(PlanChangeRequestModel.fromJson)
        .toList();
  }

  static Future<PlanChangeRequestModel> approveRequest(int id,
      {int? durationYears}) async {
    final uri = Uri.parse(ApiUrls.approvePlanRequest(id)).replace(
        queryParameters: durationYears == null
            ? null
            : {'durationYears': durationYears.toString()});
    final res = await ApiClient.post(uri);
    if (res.statusCode != 200) {
      throw Exception(_errorMessage(res.body, 'Approval failed'));
    }
    return PlanChangeRequestModel.fromJson(
        jsonDecode(res.body) as Map<String, dynamic>);
  }

  static Future<PlanChangeRequestModel> rejectRequest(int id,
      {required String reason}) async {
    final res = await ApiClient.post(
      Uri.parse(ApiUrls.rejectPlanRequest(id)),
      body: jsonEncode({'reason': reason}),
    );
    if (res.statusCode != 200) {
      throw Exception(_errorMessage(res.body, 'Rejection failed'));
    }
    return PlanChangeRequestModel.fromJson(
        jsonDecode(res.body) as Map<String, dynamic>);
  }

  // ── helpers ───────────────────────────────────────────────────────────────

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

/// Lightweight pagination wrapper for [AdminApiService.listUsers].
class AdminUsersPage {
  final List<UserModel> users;
  final int page;
  final int size;
  final int total;
  const AdminUsersPage({
    required this.users,
    required this.page,
    required this.size,
    required this.total,
  });
}
