class UserModel {
  final int id;
  final String name;
  final String email;
  final String mobile;
  final String address;
  final bool isVerified;
  final String userStatus;   // ACTIVE / INACTIVE etc
  final String userRole;     // CUSTOMER / ADMIN / AGENT / OWNER
  final String userPackage;  // Free / Premium / Gold

  final String imageUrl;     // profile image (if API gives it)

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
  });

  /// ✅ From API JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
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
