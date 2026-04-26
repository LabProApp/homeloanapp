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
    final query = <String, String>{};

    if (status != null && status.isNotEmpty) query['status'] = status.join(',');
    if (startDate != null) query['startDate'] = startDate.toIso8601String();
    if (endDate != null) query['endDate'] = endDate.toIso8601String();

    final uri = Uri.parse(
      ApiUrls.getBrokerLeads.replaceFirst('{brokerId}', brokerId.toString()),
    ).replace(queryParameters: query);

    final response = await ApiClient.get(uri);

    if (response.statusCode == 200) return json.decode(response.body);
    throw Exception('Failed to load leads (${response.statusCode})');
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
}
