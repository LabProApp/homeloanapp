import 'dart:convert';
import 'dart:developer' as developer;

import '../models/inquiry_request.dart';
import '../models/legal_service_model.dart';
import '../network/api_client.dart';
import '../utility/api_urls.dart';

class LegalServiceApi {
  static Future<LegalServiceResponse> fetchProviders({
    int page = 0,
    int size = 20,
  }) async {
    final response = await ApiClient.get(Uri.parse(ApiUrls.getlegalVendors_list));

    if (response.statusCode == 200) {
      return legalServiceResponseFromJson(response.body);
    }
    throw Exception('Failed to load legal services (${response.statusCode})');
  }

  static Future<bool> submitInquiry(Inquiry request) async {
    developer.log('Submitting inquiry to ${ApiUrls.legalInquiry}', name: 'LegalServiceApi');

    final response = await ApiClient.post(
      Uri.parse(ApiUrls.legalInquiry),
      body: jsonEncode(request.toJson()),
    );

    developer.log('Inquiry response: ${response.statusCode}', name: 'LegalServiceApi');

    if (response.statusCode == 200 || response.statusCode == 201) return true;
    throw Exception('Inquiry failed (${response.statusCode}): ${response.body}');
  }
}
