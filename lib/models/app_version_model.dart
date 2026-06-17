/// Response from GET /api/version/check
class AppVersionModel {
  final bool updateAvailable;
  final bool forceUpdate;
  final String? latestVersionName;
  final String? storeUrl;
  final String? releaseNotes;

  const AppVersionModel({
    required this.updateAvailable,
    required this.forceUpdate,
    this.latestVersionName,
    this.storeUrl,
    this.releaseNotes,
  });

  factory AppVersionModel.fromJson(Map<String, dynamic> json) {
    return AppVersionModel(
      updateAvailable:   json['updateAvailable']   as bool? ?? false,
      forceUpdate:       json['forceUpdate']       as bool? ?? false,
      latestVersionName: json['latestVersionName'] as String?,
      storeUrl:          json['storeUrl']          as String?,
      releaseNotes:      json['releaseNotes']      as String?,
    );
  }

  /// No update is available — used as the safe fallback on network errors.
  static const AppVersionModel noUpdate = AppVersionModel(
    updateAvailable: false,
    forceUpdate: false,
  );
}
