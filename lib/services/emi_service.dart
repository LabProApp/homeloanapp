import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/calc_loan_request.dart';
import '../models/calc_loan_response.dart';
import '../network/api_client.dart';
import '../utility/api_urls.dart';

class LoanApiService {
  final http.Client client;
  LoanApiService({required this.client});

  static Future<CalcLoanResponse> calculateLoan(CalcLoanRequest request) async {
    final response = await ApiClient.post(
      Uri.parse(ApiUrls.emiCalculator),
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return CalcLoanResponse.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to calculate loan (${response.statusCode})');
  }
}
