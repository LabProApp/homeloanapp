import 'dart:convert';

class PropertyModel {
  final String? code;
  final DateTime? createdTs;
  final DateTime? lastUpdatedTs;
  final String? createdBy;
  final String? updatedBy;
  final int? id;
  final String? title;
  final String? address;
  final String? city;
  final String? propertyStatus;
  final String? planPackage;
  final String? state;
  final String? type;

  // ✅ Changed to double
  final double? price;
  final int? bedrooms;
  final int? bathrooms;
  final String? location;
  final double? carpetArea;
  final double? superArea;

  final String? amenities; // CSV string
  final String? postedBy;
  final String? constructionStatus;
  final String? currency;
  final DateTime? readyDate;
  final String? category;
  final String? projectName;
  final String? description;
  final int? postedByUser;

  final String contactNumber; // required, non-null

  final String? postDate;
  final String? rentOrSale;
  final bool? verified;
  final List<DocumentModel>? documentList;
  final List<int>? amenitiesAsList;

  PropertyModel({
    this.code,
    this.createdTs,
    this.lastUpdatedTs,
    this.createdBy,
    this.updatedBy,
    this.id,
    this.title,
    this.address,
    this.city,
    this.propertyStatus,
    this.planPackage,
    this.state,
    this.type,
    this.price,
    this.bedrooms,
    this.bathrooms,
    this.location,
    this.carpetArea,
    this.superArea,
    this.amenities,
    this.postedBy,
    this.constructionStatus,
    this.currency,
    this.readyDate,
    this.category,
    this.projectName,
    this.description,
    this.postedByUser,
    required this.contactNumber,
    this.postDate,
    this.rentOrSale,
    this.verified,
    this.documentList,
    this.amenitiesAsList,
  });

  factory PropertyModel.fromJson(Map<String, dynamic> json) => PropertyModel(
    code: json["code"] as String?,
    createdTs: json["createdTs"] != null
        ? DateTime.parse(json["createdTs"])
        : null,
    lastUpdatedTs: json["lastUpdatedTs"] != null
        ? DateTime.parse(json["lastUpdatedTs"])
        : null,
    createdBy: json["createdBy"] as String?,
    updatedBy: json["updatedBy"] as String?,
    id: json["id"] as int?,
    title: json["title"] as String?,
    address: json["address"] as String?,
    city: json["city"] as String?,
    propertyStatus: json["propertyStatus"]?.toString(),
    planPackage: json["planPackage"]?.toString(),
    state: json["state"] as String?,
    type: json["type"] as String?,

    // ✅ Parse price safely
    price: _toDouble(json["price"]),

    bedrooms: json["bedrooms"] as int?,
    bathrooms: json["bathrooms"] as int?,
    location: json["location"] as String?,

    // ✅ carpetArea and superArea as double
    carpetArea: _toDouble(json["carpetArea"]),
    superArea: _toDouble(json["superArea"]),

    amenities: json["amenities"] as String?,
    postedBy: json["postedBy"] as String?,
    constructionStatus: json["constructionStatus"] as String?,
    currency: json["currency"] as String?,
    readyDate: json["readyDate"] != null
        ? DateTime.parse(json["readyDate"])
        : null,
    category: json["category"] as String?,
    projectName: json["projectName"] as String?,
    description: json["description"] as String?,
    postedByUser: json["postedByUser"] as int?,

    contactNumber: (json["contactNumber"] as String?) ?? "",

    postDate:  (json["postDate"] as String?) ?? "",


    rentOrSale: json["rentOrSale"] as String?,
    verified: json["verified"] as bool?,
    documentList: json["documentList"] != null
        ? List<DocumentModel>.from(
      (json["documentList"] as List<dynamic>)
          .map((x) => DocumentModel.fromJson(x)),
    )
        : [],
    amenitiesAsList: json["amenitiesAsList"] != null
        ? List<int>.from(json["amenitiesAsList"])
        : [],
  );

  Map<String, dynamic> toJson() => {
    "code": code,
    "createdTs": createdTs?.toIso8601String(),
    "lastUpdatedTs": lastUpdatedTs?.toIso8601String(),
    "createdBy": createdBy,
    "updatedBy": updatedBy,
    "id": id,
    "title": title,
    "address": address,
    "city": city,
    "propertyStatus": propertyStatus,
    "planPackage": planPackage,
    "state": state,
    "type": type,
    "price": price,
    "bedrooms": bedrooms,
    "bathrooms": bathrooms,
    "location": location,
    "carpetArea": carpetArea,
    "superArea": superArea,
    "amenities": amenities,
    "postedBy": postedBy,
    "constructionStatus": constructionStatus,
    "currency": currency,
    "readyDate": readyDate?.toIso8601String(),
    "category": category,
    "projectName": projectName,
    "description": description,
    "postedByUser": postedByUser,
    "contactNumber": contactNumber,
    "postDate": postDate,
    "rentOrSale": rentOrSale,
    "verified": verified,
    "documentList":
    documentList?.map((document) => document.toJson()).toList(),
    "amenitiesAsList": amenitiesAsList,
  };

  /// ---------------- HELPERS ----------------
  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}

/// ---------------- DOCUMENT MODEL ----------------
class DocumentModel {
  final int? id;
  final String? docUrl;
  final String? s3key;
  final String? docType;
  final String? objectType;
  final int? objectId;
  final String? caption;
  final String? documentStatus;
  final String? rejectionReason;
  final String? comments;

  DocumentModel({
    this.id,
    this.docUrl,
    this.s3key,
    this.docType,
    this.objectType,
    this.objectId,
    this.caption,
    this.documentStatus,
    this.rejectionReason,
    this.comments,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) => DocumentModel(
    id: json["id"] as int?,
    docUrl: json["docUrl"] as String?,
    s3key: json["s3key"] as String?,
    docType: json["docType"] as String?,
    objectType: json["objectType"] as String?,
    objectId: json["objectId"] as int?,
    caption: json["caption"] as String?,
    documentStatus: json["documentStatus"] as String?,
    rejectionReason: json["rejectionReason"] as String?,
    comments: json["comments"] as String?,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "docUrl": docUrl,
    "s3key": s3key,
    "docType": docType,
    "objectType": objectType,
    "objectId": objectId,
    "caption": caption,
    "documentStatus": documentStatus,
    "rejectionReason": rejectionReason,
    "comments": comments,
  };
}

/// ---------------- PARSING ----------------
List<PropertyModel> propertyListFromJson(String str) =>
    List<PropertyModel>.from(
        json.decode(str).map((x) => PropertyModel.fromJson(x)));

String propertyListToJson(List<PropertyModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));
