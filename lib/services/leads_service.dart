import 'dart:convert';

import '../models/client_lead_model.dart';
import '../network/api_client.dart';
import '../utility/api_urls.dart';

class LeadApiService {
  static Future<List<dynamic>> fetchBrokerLeads({
    required int brokerId,
    List<String>? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final query = <String, dynamic>{'brokerId': brokerId.toString()};

    if (status != null && status.isNotEmpty) {
      query['status'] = status; // repeatable list param
    }
    if (startDate != null) query['startDate'] = startDate.toIso8601String();
    if (endDate != null) query['endDate'] = endDate.toIso8601String();

    final uri = Uri.parse(ApiUrls.searchLeads).replace(queryParameters: query);
    final response = await ApiClient.get(uri);

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      if (decoded is List) return decoded;
      return [];
    }
    throw Exception('Failed to load leads (${response.statusCode})');
  }

  static Future<List<dynamic>> fetchPropertyLeads(int propertyId) async {
    final uri = Uri.parse(ApiUrls.propertyLeadsSummary(propertyId));
    final response = await ApiClient.get(uri);

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      if (decoded is List) return decoded;
      return [];
    }
    throw Exception('Failed to load property leads (${response.statusCode})');
  }

  static Future<bool> createLead(ClientLeadModel lead) async {
    final response = await ApiClient.post(
      Uri.parse(ApiUrls.postBrokerLeads),
      body: jsonEncode(lead.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) return true;
    throw Exception('Failed to create lead (${response.statusCode}): ${response.body}');
  }

  static Future<bool> updateLead({
    required String leadId,
    required Map<String, dynamic> payload,
  }) async {
    final uri = Uri.parse(
      ApiUrls.updateBrokerLeads.replaceFirst('{leadId}', leadId),
    );
    final response = await ApiClient.put(uri, body: jsonEncode(payload));

    if (response.statusCode == 200 || response.statusCode == 204) return true;
    throw Exception('Failed to update lead (${response.statusCode})');
  }

  static Future<Map<String, dynamic>> updateLeadStatus({
    required int leadId,
    required String status,
    String? remark,
  }) async {
    final uri = Uri.parse(
      ApiUrls.updateLeadStatus.replaceFirst('{leadId}', leadId.toString()),
    );
    final body = <String, dynamic>{'status': status};
    if (remark != null && remark.isNotEmpty) body['remark'] = remark;

    final response = await ApiClient.put(uri, body: jsonEncode(body));
    if (response.statusCode == 200) return json.decode(response.body);
    throw Exception('Failed to update status (${response.statusCode})');
  }

  static Future<List<dynamic>> fetchUserRequirements(int userId) async {
    final uri = Uri.parse(ApiUrls.searchLeads).replace(queryParameters: {
      'userId': userId.toString(),
      'leadType': 'PROPERTY_INQUIRY',
    });
    final response = await ApiClient.get(uri);
    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      if (decoded is List) return decoded;
      return [];
    }
    throw Exception('Failed to load requirements (${response.statusCode})');
  }

  static Future<void> deleteLead(int leadId) async {
    final uri = Uri.parse(
      ApiUrls.updateBrokerLeads.replaceFirst('{leadId}', leadId.toString()),
    );
    final response = await ApiClient.delete(uri);
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete lead (${response.statusCode})');
    }
  }

  static Future<Map<String, dynamic>> scheduleFollowUp({
    required int leadId,
    required DateTime followUpDate,
    String? remark,
  }) async {
    final uri = Uri.parse(
      ApiUrls.scheduleLeadFollowUp.replaceFirst('{leadId}', leadId.toString()),
    );
    final body = <String, dynamic>{
      'followUpDate': followUpDate.toIso8601String(),
    };
    if (remark != null && remark.isNotEmpty) body['remark'] = remark;

    final response = await ApiClient.put(uri, body: jsonEncode(body));
    if (response.statusCode == 200) return json.decode(response.body);
    throw Exception('Failed to schedule follow-up (${response.statusCode})');
  }
}
