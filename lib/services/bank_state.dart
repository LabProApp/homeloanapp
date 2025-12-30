import 'package:equatable/equatable.dart';
import 'package:property/models/bank_model.dart';

abstract class BankState extends Equatable{
  @override
  List<Object?> get props => [];
}

class BankInitialState extends BankState {}
class BankLoadingState extends BankState {}
class BankLoadedState extends BankState {
 final List<FetchBanks> banks;   
  BankLoadedState({required this.banks});
  @override
  List<Object?> get props => [banks];
}
class BankErrorState extends BankState {
  final String message;     
  BankErrorState({required this.message});
  @override
  List<Object?> get props => [message];
}