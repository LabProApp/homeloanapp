import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:property/models/bank_model.dart';
import 'package:property/utility/ApiUrls.dart';

class BankApiService {



  Future<List<FetchBanks>> fetchBanks() async {
    final response = await http.get(
      Uri.parse(ApiUrls.getBanks_list),
      headers: {
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => FetchBanks.fromJson(e)).toList();
    } else {
      throw Exception(
        "Failed to load banks (${response.statusCode})",
      );
    }
  }
}
