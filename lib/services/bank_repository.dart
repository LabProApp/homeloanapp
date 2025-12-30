import 'package:property/network/error_handling_api.dart';
import 'package:property/models/bank_model.dart';

abstract class BankRepository {
Future<OnComplete<List<FetchBanks>>> fetchBanks();
}
