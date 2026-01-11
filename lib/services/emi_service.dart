import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/calcLoanRequest.dart';
import '../models/calcLoanResponse.dart';
import '../utility/ApiUrls.dart';
class LoanApiService {

  final http.Client client;
  LoanApiService({required this.client});
  static Future<CalcLoanResponse> calculateLoan(CalcLoanRequest request) async {
    final response = await http.post(
      Uri.parse(ApiUrls.emiCalculator),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return CalcLoanResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to calculate loan");
    }
  }
}
