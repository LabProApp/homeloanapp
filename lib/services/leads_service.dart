import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utility/ApiUrls.dart';

class LeadApiService {
  static Future<List<dynamic>> fetchBrokerLeads({
    required String brokerId,
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
      ApiUrls.getBrokerLeads.replaceFirst("{brokerId}", brokerId),
    ).replace(queryParameters: query);

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Failed to load leads");
    }
  }
}