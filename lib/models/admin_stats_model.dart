/// Wire model for `com.api.admin.AdminStatsDto`. Counts only — no PII.
class AdminStatsModel {
  final int totalUsers;
  final int totalProperties;
  final int propertiesForSale;
  final int propertiesForRent;
  final int pendingPlanRequests;
  final int activeSubscriptions;
  final Map<String, int> usersByPlan;

  const AdminStatsModel({
    this.totalUsers = 0,
    this.totalProperties = 0,
    this.propertiesForSale = 0,
    this.propertiesForRent = 0,
    this.pendingPlanRequests = 0,
    this.activeSubscriptions = 0,
    this.usersByPlan = const {},
  });

  factory AdminStatsModel.fromJson(Map<String, dynamic> json) {
    int n(dynamic v) => v is num ? v.toInt() : 0;
    final byPlan = <String, int>{};
    final raw = json['usersByPlan'];
    if (raw is Map) {
      raw.forEach((k, v) {
        if (k is String) byPlan[k] = v is num ? v.toInt() : 0;
      });
    }
    return AdminStatsModel(
      totalUsers: n(json['totalUsers']),
      totalProperties: n(json['totalProperties']),
      propertiesForSale: n(json['propertiesForSale']),
      propertiesForRent: n(json['propertiesForRent']),
      pendingPlanRequests: n(json['pendingPlanRequests']),
      activeSubscriptions: n(json['activeSubscriptions']),
      usersByPlan: byPlan,
    );
  }
}
