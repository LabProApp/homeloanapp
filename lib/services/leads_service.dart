import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utility/ApiUrls.dart';
import '../models/ClientLead_model.dart';

class LeadApiService {

  /// ================= FETCH LEADS =================
  static Future<List<dynamic>> fetchBrokerLeads({
    required int brokerId,
    List<String>? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final query = <String, String>{};

    if (status != null && status.isNotEmpty) {
      query["status"] = status.join(",");
    }

    if (startDate != null) {
      query["startDate"] = startDate.toIso8601String();
    }

    if (endDate != null) {
      query["endDate"] = endDate.toIso8601String();
    }

    final uri = Uri.parse(
      ApiUrls.getBrokerLeads.replaceFirst("{brokerId}", brokerId.toString()),
    ).replace(queryParameters: query);

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Failed to load leads");
    }
  }

  /// ================= CREATE LEAD =================
  static Future<bool> createLead(ClientLeadModel lead) async {
    final uri = Uri.parse(ApiUrls.postBrokerLeads);

    final response = await http.post(
      uri,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(lead.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      throw Exception(
        "Failed to create lead (${response.statusCode}) : ${response.body}",
      );
    }
  }

  /// ================= UPDATE LEAD =================
  static Future<bool> updateLead({
    required String leadId,
    required Map<String, dynamic> payload,
  }) async {
    final uri = Uri.parse(
      ApiUrls.updateBrokerLeads.replaceFirst("{leadId}", leadId),
    );

    final response = await http.put(
      uri,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      return true;
    } else {
      throw Exception("Failed to update lead (${response.statusCode})");
    }
  }
}