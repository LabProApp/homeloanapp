class UserModel {
  final String name;
  final String email;
  final String mobile;
  final String plan;
  final String planStatus;
  final String nextBilling;
  final String imageUrl;

  UserModel({
    required this.name,
    required this.email,
    required this.mobile,
    required this.plan,
    required this.planStatus,
    required this.nextBilling,
    required this.imageUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json["name"] ?? "",
      email: json["email"] ?? "",
      mobile: json["mobile"] ?? "",
      plan: json["plan"] ?? "Free",
      planStatus: json["plan_status"] ?? "Active",
      nextBilling: json["next_billing"] ?? "",
      imageUrl: json["profile_image"] ??
          "https://i.pravatar.cc/300",
    );
  }
}
