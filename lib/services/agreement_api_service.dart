import 'dart:convert';
import 'dart:developer' as dev;

import '../network/api_client.dart';
import '../utility/api_urls.dart';

class AgreementApiService {
  static const _tag = 'AgreementApiService';

  /// Fetches the default terms/clauses for a [type] ('rent' or 'sale') agreement.
  /// Returns null if the API is unreachable or returns an unexpected response —
  /// callers should fall back to their local default terms in that case.
  static Future<String?> fetchTemplate(String type) async {
    try {
      final url = type == 'rent'
          ? ApiUrls.rentAgreementTemplate
          : ApiUrls.saleAgreementTemplate;
      final response = await ApiClient.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic>) {
          return (data['defaultTerms'] ?? data['terms']) as String?;
        }
      } else {
        dev.log('fetchTemplate $type: ${response.statusCode}', name: _tag);
      }
    } catch (e) {
      dev.log('fetchTemplate $type error: $e', name: _tag);
    }
    return null;
  }

  /// Submits a generated agreement to the backend for storage/logging.
  /// Fire-and-forget — failures are logged but not surfaced to the user.
  static Future<void> submitGenerated({
    required String agreementType,
    int? propertyId,
    int? tenantId,
    int? ownerId,
    required Map<String, dynamic> attributes,
  }) async {
    try {
      final body = <String, dynamic>{
        'agreementType': agreementType,
        if (propertyId != null) 'propertyId': propertyId,
        if (tenantId != null) 'tenantId': tenantId,
        if (ownerId != null) 'ownerId': ownerId,
        'attributes': attributes,
      };
      await ApiClient.post(
        Uri.parse(ApiUrls.agreementsGenerate),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
    } catch (e) {
      dev.log('submitGenerated error: $e', name: _tag);
    }
  }
}
