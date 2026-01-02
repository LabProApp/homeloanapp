import 'dart:convert';
import 'package:http/http.dart' as http;

class InquiryService {
  static const String _baseUrl =
      "https://your-api-domain.com/api/inquiries"; // 🔴 replace

  static Future<bool> submitInquiry({
    required String name,
    required String phone,
    required String service,
    required String message,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name,
          "phone": phone,
          "service": service,
          "message": message,
        }),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}
