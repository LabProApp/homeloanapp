class PropertyModel {
  final String id;
  final String title;
  final String subtitle;
  final String postedBy;
  final String rentOrSale;
  final String price;
  final String category;
  final String city;
  final String state;
  final String type;
  final String superArea;
  final List<String> images;
  final List<String> amenities;
  final bool verified;

  PropertyModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.postedBy,
    required this.rentOrSale,
    required this.price,
    required this.category,
    required this.city,
    required this.state,
    required this.type,
    required this.superArea,
    required this.images,
    required this.amenities,
    this.verified = false,
  });
  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    return PropertyModel(
      id: json['id'].toString(),
      title: json['projectName'] ?? '',
      subtitle: json['title'] ?? '',
      postedBy: json['postedBy'] ?? '',
      rentOrSale: json['rentOrSale'] ?? '',
      price: json['price'].toString() ?? '0',
      category: json['category'].toString() ?? '',
      city: json['city'].toString() ?? '',
      state: json['state'].toString() ?? '',
      type: json['type'].toString() ?? '',
      superArea: json['superArea'].toString() ?? '',
      images: _defaultImages,
      amenities: _defaultAmenities,
      verified: _defaultNewBooking,
    );
  }

  // 🔒 STATIC LIST (central place)
  static const List<String> _defaultImages = [
    "https://images.unsplash.com/photo-1568605114967-8130f3a36994",
    "https://images.unsplash.com/photo-1598928506311-c55ded91a20c",
    "https://images.unsplash.com/photo-1568605114967-8130f3a36994",
    "https://images.unsplash.com/photo-1598928506311-c55ded91a20c"
  ];
  static const List<String> _defaultAmenities = ["Parking","WiFi","Swimming Pool", "Gym","Lift","Security","Club House"];


  static const bool _defaultNewBooking =true;
}
