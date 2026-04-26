import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import '../services/emi_service.dart';

final GetIt sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  sl.registerLazySingleton<http.Client>(() => http.Client());
  sl.registerLazySingleton<LoanApiService>(() => LoanApiService(client: sl()));
}
