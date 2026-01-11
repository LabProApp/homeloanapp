import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/legal_service_model.dart';
import '../models/inquiry_request.dart';
import '../utility/ApiUrls.dart';
import 'dart:developer' as developer;
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

    try {
      developer.log('🔹 Submitting Inquiry to: $uri', name: 'InquiryService');
      developer.log('🔹 Request Body: ${jsonEncode(request.toJson())}', name: 'InquiryService');

      final response = await http
          .post(
        uri,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(request.toJson()),
      )
          .timeout(const Duration(seconds: 15));

      developer.log('🔹 Response Status: ${response.statusCode}', name: 'InquiryService');
      developer.log('🔹 Response Body: ${response.body}', name: 'InquiryService');

      if (response.statusCode == 200 || response.statusCode == 201) {
        developer.log('✅ Inquiry submitted successfully', name: 'InquiryService');
        return true;
      } else {
        developer.log(
          '❌ Inquiry failed (${response.statusCode}): ${response.body}',
          name: 'InquiryService',
        );
        throw Exception(
          "Inquiry failed (${response.statusCode}): ${response.body}",
        );
      }
    } catch (e, stackTrace) {
      developer.log('⚠️ Exception submitting inquiry: $e', name: 'InquiryService', stackTrace: stackTrace);
      rethrow;
    }
  }
}
