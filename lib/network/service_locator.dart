import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:property/network/bases.dart';
import 'package:property/services/bank_repository_impl.dart';
import 'package:property/services/bank_repository.dart';
import 'package:property/services/bank_cubit.dart';

final s1=GetIt.instance;
Future<void> init()async{
  s1.registerLazySingleton(()=>http.Client());
  s1.registerLazySingleton<ApiService>(()=> ApiService(client: s1()));
  s1.registerLazySingleton<BankRepository>(
    () => BankRepositoryImpl(api: s1()),
  );

  /// Cubits (FACTORY — very important)
  s1.registerFactory<BankCubit>(
    () => BankCubit(bankRepository: s1()),
  );


}
 