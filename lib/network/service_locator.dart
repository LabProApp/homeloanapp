import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:property/services/emi_service.dart';

final GetIt sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  /// 🌐 HTTP CLIENT (Singleton)
  sl.registerLazySingleton<http.Client>(() => http.Client());




  /// 💰 EMI CALCULATOR SERVICE
  sl.registerLazySingleton<LoanApiService>(
        () => LoanApiService(client: sl()),
  );
}
