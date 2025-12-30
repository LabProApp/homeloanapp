

// To parse this JSON data, do
//
//     final fetchBanks = fetchBanksFromJson(jsonString);

import 'dart:convert';

List<FetchBanks> fetchBanksFromJson(String str) => List<FetchBanks>.from(json.decode(str).map((x) => FetchBanks.fromJson(x)));

String fetchBanksToJson(List<FetchBanks> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class FetchBanks {
  final String? code;
  final String? createdTs;
  final String? lastUpdatedTs;
  final String? createdBy;
  final String? updatedBy;
  final int id;
  final String bankName;
  final String contactName;
  final String contactNumber;
  final String email;
  final String branchName;
  final String locationAddress;
  final String street;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final String websiteUrl;

  final double interestRate;
  final String interestType;
  final dynamic processingFee;
  final dynamic tenureYears;
  final dynamic maxLoanAmount;
  final dynamic minLoanAmount;
  final dynamic minCibilScore;
  final dynamic minimumIncome;
  final String employmentType;
  final dynamic minimumAge;
  final dynamic maximumAge;
  final String nationalityRequirement;
  final bool prepaymentAllowed;
  final bool partPaymentAllowed;
  final bool balanceTransferAvailable;
  final bool insuranceBundled;
  final String specialOffers;
  final String requiredDocuments;
  final String details;
  final String? createdAt;
  final String? updatedAt;

  FetchBanks({
    required this.code,
    required this.createdTs,
    required this.lastUpdatedTs,
    required this.createdBy,
    required this.updatedBy,
    required this.id,
    required this.bankName,
    required this.contactName,
    required this.contactNumber,
    required this.email,
    required this.branchName,
    required this.locationAddress,
    required this.street,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    required this.websiteUrl,
    required this.interestRate,
    required this.interestType,
    required this.processingFee,
    required this.tenureYears,
    required this.maxLoanAmount,
    required this.minLoanAmount,
    required this.minCibilScore,
    required this.minimumIncome,
    required this.employmentType,
    required this.minimumAge,
    required this.maximumAge,
    required this.nationalityRequirement,
    required this.prepaymentAllowed,
    required this.partPaymentAllowed,
    required this.balanceTransferAvailable,
    required this.insuranceBundled,
    required this.specialOffers,
    required this.requiredDocuments,
    required this.details,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FetchBanks.fromJson(Map<String, dynamic> json) {
    return FetchBanks(
      code: json['code'],
      createdTs: json['createdTs'],
      lastUpdatedTs: json['lastUpdatedTs'],
      createdBy: json['createdBy'],
      updatedBy: json['updatedBy'],
      id: json['id'] ?? 0,
      bankName: json['bankName'] ?? '',
      contactName: json['contactName'] ?? '',
      contactNumber: json['contactNumber'] ?? '',
      email: json['email'] ?? '',
      branchName: json['branchName'] ?? '',
      locationAddress: json['locationAddress'] ?? '',
      street: json['street'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      postalCode: json['postalCode'] ?? '',
      country: json['country'] ?? '',
      websiteUrl: json['websiteUrl'] ?? '',

      interestRate: (json['interestRate'] as num?)?.toDouble() ?? 0.0,
      interestType: json['interestType'] ?? '',
      processingFee: json['processingFee'] ?? 0,
      tenureYears: json['tenureYears'] ?? 0,
      maxLoanAmount: json['maxLoanAmount'] ?? 0,
      minLoanAmount: json['minLoanAmount'] ?? 0,
      minCibilScore: json['minCibilScore'] ?? 0,
      minimumIncome: json['minimumIncome'] ?? 0,
      employmentType: json['employmentType'] ?? '',
      minimumAge: json['minimumAge'] ?? 0,
      maximumAge: json['maximumAge'] ?? 0,
      nationalityRequirement: json['nationalityRequirement'] ?? '',
      prepaymentAllowed: json['prepaymentAllowed'] ?? false,
      partPaymentAllowed: json['partPaymentAllowed'] ?? false,
      balanceTransferAvailable: json['balanceTransferAvailable'] ?? false,
      insuranceBundled: json['insuranceBundled'] ?? false,
      specialOffers: json['specialOffers'] ?? '',
      requiredDocuments: json['requiredDocuments'] ?? '',
      details: json['details'] ?? '',

      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'createdTs': createdTs,
        'lastUpdatedTs': lastUpdatedTs,
        'createdBy': createdBy,
        'updatedBy': updatedBy,
        'id': id,
        'bankName': bankName,
        'contactName': contactName,
        'contactNumber': contactNumber,
        'email': email,
        'branchName': branchName,
        'locationAddress': locationAddress,
        'street': street,
        'city': city,
        'state': state,
        'postalCode': postalCode,
        'country': country,
        'websiteUrl': websiteUrl,
        'interestRate': interestRate,
        'interestType': interestType,
        'processingFee': processingFee,
        'tenureYears': tenureYears,
        'maxLoanAmount': maxLoanAmount,
        'minLoanAmount': minLoanAmount,
        'minCibilScore': minCibilScore,
        'minimumIncome': minimumIncome,
        'employmentType': employmentType,
        'minimumAge': minimumAge,
        'maximumAge': maximumAge,
        'nationalityRequirement': nationalityRequirement,
        'prepaymentAllowed': prepaymentAllowed,
        'partPaymentAllowed': partPaymentAllowed,
        'balanceTransferAvailable': balanceTransferAvailable,
        'insuranceBundled': insuranceBundled,
        'specialOffers': specialOffers,
        'requiredDocuments': requiredDocuments,
        'details': details,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };
}
