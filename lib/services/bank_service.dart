import 'dart:convert';

import '../models/bank_model.dart';
import '../network/api_client.dart';
import '../utility/api_urls.dart';

class BankApiService {
  Future<List<Bank>> fetchBanks() async {
    final response = await ApiClient.get(Uri.parse(ApiUrls.getBanks_list));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Bank.fromJson(e)).toList();
    }
    throw Exception('Failed to load banks (${response.statusCode})');
  }
}
