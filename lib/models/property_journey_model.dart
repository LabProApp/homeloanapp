import 'dart:convert';

enum JourneyStepStatus { pending, completed }

class JourneyStepState {
  JourneyStepStatus status;
  DateTime? completedAt;

  JourneyStepState({this.status = JourneyStepStatus.pending, this.completedAt});

  Map<String, dynamic> toJson() => {
        'status': status.name,
        'completedAt': completedAt?.toIso8601String(),
      };

  factory JourneyStepState.fromJson(Map<String, dynamic> j) => JourneyStepState(
        status: JourneyStepStatus.values.firstWhere(
          (s) => s.name == j['status'],
          orElse: () => JourneyStepStatus.pending,
        ),
        completedAt: j['completedAt'] != null
            ? DateTime.tryParse(j['completedAt'] as String)
            : null,
      );
}

class PropertyJourneyModel {
  final String id;
  final int propertyId;
  final int userId;
  final String propertyTitle;
  final String? propertyCity;
  final double? propertyPrice;
  final String? propertyType;
  final DateTime createdAt;
  DateTime updatedAt;
  final List<JourneyStepState> steps; // always 6 items

  PropertyJourneyModel({
    required this.id,
    required this.propertyId,
    required this.userId,
    required this.propertyTitle,
    this.propertyCity,
    this.propertyPrice,
    this.propertyType,
    required this.createdAt,
    required this.updatedAt,
    required this.steps,
  });

  int get completedCount =>
      steps.where((s) => s.status == JourneyStepStatus.completed).length;

  bool get isComplete => completedCount == steps.length;

  // The index of the first incomplete step (-1 if all done).
  int get activeStepIndex =>
      steps.indexWhere((s) => s.status == JourneyStepStatus.pending);

  static PropertyJourneyModel create({
    required int propertyId,
    required int userId,
    required String propertyTitle,
    String? propertyCity,
    double? propertyPrice,
    String? propertyType,
  }) {
    final now = DateTime.now();
    return PropertyJourneyModel(
      id: '${userId}_${propertyId}_${now.millisecondsSinceEpoch}',
      propertyId: propertyId,
      userId: userId,
      propertyTitle: propertyTitle,
      propertyCity: propertyCity,
      propertyPrice: propertyPrice,
      propertyType: propertyType,
      createdAt: now,
      updatedAt: now,
      steps: List.generate(6, (_) => JourneyStepState()),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'propertyId': propertyId,
        'userId': userId,
        'propertyTitle': propertyTitle,
        'propertyCity': propertyCity,
        'propertyPrice': propertyPrice,
        'propertyType': propertyType,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'steps': steps.map((s) => s.toJson()).toList(),
      };

  factory PropertyJourneyModel.fromJson(Map<String, dynamic> j) {
    final stepsRaw =
        (j['steps'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final steps = List.generate(
      6,
      (i) => i < stepsRaw.length
          ? JourneyStepState.fromJson(stepsRaw[i])
          : JourneyStepState(),
    );
    return PropertyJourneyModel(
      id: j['id'] as String,
      propertyId: j['propertyId'] as int,
      userId: j['userId'] as int,
      propertyTitle: j['propertyTitle'] as String,
      propertyCity: j['propertyCity'] as String?,
      propertyPrice: (j['propertyPrice'] as num?)?.toDouble(),
      propertyType: j['propertyType'] as String?,
      createdAt: DateTime.parse(j['createdAt'] as String),
      updatedAt: DateTime.parse(j['updatedAt'] as String),
      steps: steps,
    );
  }

  // ignore: unused_element
  static PropertyJourneyModel _decode(String raw) =>
      PropertyJourneyModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
}
