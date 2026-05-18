/// Wire model for `com.api.plan.PlanChangeRequestDto` on the backend.
class PlanChangeRequestModel {
  final int? id;
  final int? userId;
  final String requestedPlan; // BASIC / DELUX / PREMIUM
  final String status;        // PENDING / APPROVED / REJECTED / CANCELLED
  final String? notes;
  final DateTime? requestedAt;
  final DateTime? reviewedAt;
  final int? reviewedBy;
  final String? rejectionReason;

  PlanChangeRequestModel({
    this.id,
    this.userId,
    required this.requestedPlan,
    required this.status,
    this.notes,
    this.requestedAt,
    this.reviewedAt,
    this.reviewedBy,
    this.rejectionReason,
  });

  factory PlanChangeRequestModel.fromJson(Map<String, dynamic> json) {
    DateTime? parse(dynamic v) =>
        v is String && v.isNotEmpty ? DateTime.tryParse(v) : null;
    return PlanChangeRequestModel(
      id: json['id'] is int ? json['id'] as int : null,
      userId: json['userId'] is int ? json['userId'] as int : null,
      requestedPlan: json['requestedPlan']?.toString() ?? '',
      status: json['status']?.toString() ?? 'PENDING',
      notes: json['notes']?.toString(),
      requestedAt: parse(json['requestedAt']),
      reviewedAt: parse(json['reviewedAt']),
      reviewedBy: json['reviewedBy'] is int ? json['reviewedBy'] as int : null,
      rejectionReason: json['rejectionReason']?.toString(),
    );
  }

  /// Body for `POST /api/plan-requests`. The server stamps everything else.
  Map<String, dynamic> toSubmitJson() => {
        'requestedPlan': requestedPlan,
        if (notes != null && notes!.isNotEmpty) 'notes': notes,
      };

  bool get isPending => status == 'PENDING';
  bool get isApproved => status == 'APPROVED';
  bool get isRejected => status == 'REJECTED';
  bool get isCancelled => status == 'CANCELLED';
}
