import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:property/models/legal_service_model.dart';
import 'package:property/models/inquiry_request.dart';
import 'package:property/utility/ApiUrls.dart';

class LegalServiceApi {

  /// 🔹 Fetch Legal Service Providers
  static Future<LegalServiceResponse> fetchProviders({
    int page = 0,
    int size = 20,
  }) async {
    final uri = Uri.parse(ApiUrls.getlegalVendors_list);

    final response = await http
        .get(uri)
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      return legalServiceResponseFromJson(response.body);
    } else {
      throw Exception(
        "Failed to load legal services: ${response.body}",
      );
    }
  }

  /// 🔹 Submit Inquiry
  static Future<bool> submitInquiry(Inquiry request) async {
    final uri = Uri.parse(ApiUrls.legalInquiry);

    final response = await http
        .post(
      uri,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(request.toJson()),
    )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      throw Exception(
        "Inquiry failed (${response.statusCode}): ${response.body}",
      );
    }
  }
}
