class UserModel {
  final int id;
  final String name;
  final String email;
  final String mobile;
  final String address;
  final bool isVerified;
  final String userStatus;   // ACTIVE / INACTIVE etc
  final String userRole;     // CUSTOMER / ADMIN / AGENT / OWNER
  final String userPackage;  // BASIC / DELUX / PREMIUM (legacy: REGULAR / ELITE)

  final String imageUrl;     // profile image (if API gives it)

  /// Annual price (INR) of the active plan. 0 for BASIC. Read-only — set by
  /// the server.
  final double planPriceYearly;

  /// Feature-flag map keyed by the canonical feature key (e.g. `buy_sell`,
  /// `bank_loans`). Use [hasFeature] to query.
  final Map<String, bool> featureFlags;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.mobile,
    required this.address,
    required this.isVerified,
    required this.userStatus,
    required this.userRole,
    required this.userPackage,
    required this.imageUrl,
    this.planPriceYearly = 0.0,
    this.featureFlags = const {},
  });

  /// Convenience accessor. Defaults to false when the flag isn't in the map.
  bool hasFeature(String key) => featureFlags[key] == true;

  /// ✅ From API JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    final flagsRaw = json['featureFlags'];
    final Map<String, bool> flags = {};
    if (flagsRaw is Map) {
      flagsRaw.forEach((k, v) {
        if (k is String) flags[k] = v == true;
      });
    }
    final priceRaw = json['planPriceYearly'];
    final double price = priceRaw is num ? priceRaw.toDouble() : 0.0;

    return UserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      mobile: json['mobile'] ?? '',
      address: json['address'] ?? '',

      isVerified: json['isVerified'] ?? false,
      userStatus: json['userStatus']?.toString() ?? '',
      userRole: json['userRole']?.toString() ?? '',
      userPackage: json['userPackage']?.toString() ?? '',

      imageUrl: json['imageUrl'] ?? '',
      planPriceYearly: price,
      featureFlags: flags,
    );
  }

  /// ✅ For update profile API
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "email": email,
      "mobile": mobile,
      "address": address,
      "isVerified": isVerified,
      "userStatus": userStatus,
      "userRole": userRole,
      "userPackage": userPackage,
    };
  }
}
