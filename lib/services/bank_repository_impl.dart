import 'package:property/network/bases.dart';
import 'package:property/network/error_handling_api.dart';
import 'package:property/models/bank_model.dart';
import 'package:property/services/bank_repository.dart';

class BankRepositoryImpl extends BankRepository {
final ApiService api;

  BankRepositoryImpl({required this.api});

  @override
 Future<OnComplete<List<FetchBanks>>> fetchBanks() async {
    try {
      ApiResponse response = await apiRequest(
      
        request: api.getdataaa(
          url: "/banks"),
      );

      if (response.success == true) {
        final List<FetchBanks> banks =
    (response.result as List)
        .map((e) => FetchBanks.fromJson(e))
        .toList();

        return OnComplete.success(banks);
      } else {
        return OnComplete.error(response.message ?? "Service Not Available");
      }
    } catch (e) {
      return OnComplete.error(e.toString());
    }
  }

  // Implementation will go here
}