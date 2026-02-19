import 'dart:convert';
class StateModel {
  final int id;
  final String code;
  final String value;

  StateModel({
    required this.id,
    required this.code,
    required this.value,
  });

  factory StateModel.fromJson(Map<String, dynamic> json) {
    return StateModel(
      id: json['id'],
      code: json['code'],
      value: json['value'],
    );
  }
}
