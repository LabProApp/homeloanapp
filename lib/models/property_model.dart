import 'dart:convert';
import 'DocumentModel.dart';

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
  final String? state;
  final String? propertyStatus;
  final String? type;

  final double? price;
  final int? bedrooms;
  final int? bathrooms;
  final String? location;
  final double? carpetArea;
  final double? superArea;

  final String? amenities;
  final String? postedBy;
  final String contactNumber;
  final String? constructionStatus;
  final String? currency;
  final DateTime? readyDate;
  final String? category;
  final String? projectName;
  final String? description;
  final int? postedByUser;
  final String? postDate;
  final String? rentOrSale;
  final bool? verified;

  // 🆕 Extra fields from JSON
  final String? landmark;
  final double? latitude;
  final double? longitude;
  final int? floorNumber;
  final int? totalFloors;
  final String? parkingCount;
  final String? parkingType;
  final String? facing;
  final String? propertyAge;
  final String? ownershipType;

  final String? furnishing;

  final bool? negotiable;
  final bool? loanAvailable;
  final double? monthlyRent;
  final double? securityDeposit;
  final double? brokerage;
  final String? preferredTenants;
  final bool? petsAllowed;
  final bool? nonVegAllowed;
  final String? leaseDuration;
  final String? noticePeriod;
  final bool? maintenanceIncluded;
  final String? builderName;
  final bool? reraApproved;
  final String? reraNumber;
  final int? viewsCount;
  final int? shortListCount;

  final List<DocumentModel>? documentList;
  final List<int>? amenitiesAsList;
  final List<int>? amenitiesFromList;

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
    this.state,
    this.propertyStatus,
    this.type,
    this.price,
    this.bedrooms,
    this.bathrooms,
    this.location,
    this.carpetArea,
    this.superArea,
    this.amenities,
    this.postedBy,
    required this.contactNumber,
    this.constructionStatus,
    this.currency,
    this.readyDate,
    this.category,
    this.projectName,
    this.description,
    this.postedByUser,
    this.postDate,
    this.rentOrSale,
    this.verified,
    this.landmark,
    this.latitude,
    this.longitude,
    this.floorNumber,
    this.totalFloors,
    this.parkingCount,
    this.parkingType,
    this.facing,
    this.propertyAge,
    this.ownershipType,
    this.furnishing,
    this.negotiable,
    this.loanAvailable,
    this.monthlyRent,
    this.securityDeposit,
    this.brokerage,
    this.preferredTenants,
    this.petsAllowed,
    this.nonVegAllowed,
    this.leaseDuration,
    this.noticePeriod,
    this.maintenanceIncluded,
    this.builderName,
    this.reraApproved,
    this.reraNumber,
    this.viewsCount,
    this.shortListCount,
    this.documentList,
    this.amenitiesAsList,
    this.amenitiesFromList,
  });

  factory PropertyModel.fromJson(Map<String, dynamic> json) => PropertyModel(
    code: json["code"],
    createdTs: json["createdTs"] != null ? DateTime.parse(json["createdTs"]) : null,
    lastUpdatedTs: json["lastUpdatedTs"] != null ? DateTime.parse(json["lastUpdatedTs"]) : null,
    createdBy: json["createdBy"],
    updatedBy: json["updatedBy"],
    id: json["id"],
    title: json["title"],
    address: json["address"],
    city: json["city"],
    state: json["state"],
    propertyStatus: json["propertyStatus"],
    type: json["type"],
    price: _toDouble(json["price"]),
    bedrooms: json["bedrooms"],
    bathrooms: json["bathrooms"],
    location: json["location"],
    carpetArea: _toDouble(json["carpetArea"]),
    superArea: _toDouble(json["superArea"]),
    amenities: json["amenities"],
    postedBy: json["postedBy"],
    contactNumber: json["contactNumber"] ?? "",
    constructionStatus: json["constructionStatus"],
    currency: json["currency"],
    readyDate: json["readyDate"] != null ? DateTime.parse(json["readyDate"]) : null,
    category: json["category"],
    projectName: json["projectName"],
    description: json["description"],
    postedByUser: json["postedByUser"],
    postDate: json["postDate"],
    rentOrSale: json["rentOrSale"],
    verified: json["verified"],
    landmark: json["landmark"],
    latitude: _toDouble(json["latitude"]),
    longitude: _toDouble(json["longitude"]),
    floorNumber: json["floorNumber"],
    totalFloors: json["totalFloors"],
    parkingCount: json["parkingCount"],
    parkingType: json["parkingType"],
    facing: json["facing"],
    propertyAge: json["propertyAge"],
    ownershipType: json["ownershipType"],
    furnishing: json["furnishing"],
    negotiable: json["negotiable"],
    loanAvailable: json["loanAvailable"],
    monthlyRent: _toDouble(json["monthlyRent"]),
    securityDeposit: _toDouble(json["securityDeposit"]),
    brokerage: _toDouble(json["brokerage"]),
    preferredTenants: json["preferredTenants"],
    petsAllowed: json["petsAllowed"],
    nonVegAllowed: json["nonVegAllowed"],
    leaseDuration: json["leaseDuration"],
    noticePeriod: json["noticePeriod"],
    maintenanceIncluded: json["maintenanceIncluded"],
    builderName: json["builderName"],
    reraApproved: json["reraApproved"],
    reraNumber: json["reraNumber"],
    viewsCount: json["viewsCount"],
    shortListCount: json["shortListCount"],
    documentList: json["documentList"] != null
        ? List<DocumentModel>.from(
        json["documentList"].map((x) => DocumentModel.fromJson(x)))
        : [],
    amenitiesAsList: json["amenitiesAsList"] != null
        ? List<int>.from(json["amenitiesAsList"])
        : [],
    amenitiesFromList: json["amenitiesFromList"] != null
        ? List<int>.from(json["amenitiesFromList"])
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
    "state": state,
    "propertyStatus": propertyStatus,
    "type": type,
    "price": price,
    "bedrooms": bedrooms,
    "bathrooms": bathrooms,
    "location": location,
    "carpetArea": carpetArea,
    "superArea": superArea,
    "amenities": amenities,
    "postedBy": postedBy,
    "contactNumber": contactNumber,
    "constructionStatus": constructionStatus,
    "currency": currency,
    "readyDate": readyDate?.toIso8601String(),
    "category": category,
    "projectName": projectName,
    "description": description,
    "postedByUser": postedByUser,
    "postDate": postDate,
    "rentOrSale": rentOrSale,
    "verified": verified,
    "landmark": landmark,
    "latitude": latitude,
    "longitude": longitude,
    "floorNumber": floorNumber,
    "totalFloors": totalFloors,
    "parkingCount": parkingCount,
    "parkingType": parkingType,
    "facing": facing,
    "propertyAge": propertyAge,
    "ownershipType": ownershipType,
    "furnishing": furnishing,
    "negotiable": negotiable,
    "loanAvailable": loanAvailable,
    "monthlyRent": monthlyRent,
    "securityDeposit": securityDeposit,
    "brokerage": brokerage,
    "preferredTenants": preferredTenants,
    "petsAllowed": petsAllowed,
    "nonVegAllowed": nonVegAllowed,
    "leaseDuration": leaseDuration,
    "noticePeriod": noticePeriod,
    "maintenanceIncluded": maintenanceIncluded,
    "builderName": builderName,
    "reraApproved": reraApproved,
    "reraNumber": reraNumber,
    "viewsCount": viewsCount,
    "shortListCount": shortListCount,
    "documentList": documentList?.map((e) => e.toJson()).toList(),
    "amenitiesAsList": amenitiesAsList,
    "amenitiesFromList": amenitiesFromList,
  };

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}