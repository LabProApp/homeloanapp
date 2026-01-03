import 'dart:convert';

List<FetchBanks> fetchBanksFromJson(String str) =>
    List<FetchBanks>.from(json.decode(str).map((x) => FetchBanks.fromJson(x)));

String fetchBanksToJson(List<FetchBanks> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

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
  final String bankLogoUrl;
  final double interestRate;
  final String interestType;
  final num? processingFee;
  final num? tenureYears;
  final num? maxLoanAmount;
  final num? minLoanAmount;
  final num? minCibilScore;
  final num? minimumIncome;
  final String employmentType;
  final num? minimumAge;
  final num? maximumAge;
  final String nationalityRequirement;
  final bool prepaymentAllowed;
  final bool partPaymentAllowed;
  final bool balanceTransferAvailable;
  final bool insuranceBundled;
  final String specialOffers;
  final String requiredDocuments;
  final String details;
  final BankDocuments? documents;
  final String? createdAt;
  final String? updatedAt;

  FetchBanks({
    this.code,
    this.createdTs,
    this.lastUpdatedTs,
    this.createdBy,
    this.updatedBy,
    required this.id,
    required this.bankName,
    required this.bankLogoUrl,
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
    this.processingFee,
    this.tenureYears,
    this.maxLoanAmount,
    this.minLoanAmount,
    this.minCibilScore,
    this.minimumIncome,
    required this.employmentType,
    this.minimumAge,
    this.maximumAge,
    required this.nationalityRequirement,
    required this.prepaymentAllowed,
    required this.partPaymentAllowed,
    required this.balanceTransferAvailable,
    required this.insuranceBundled,
    required this.specialOffers,
    required this.requiredDocuments,
    required this.details,
    this.documents,
    this.createdAt,
    this.updatedAt,
  });

  factory FetchBanks.fromJson(Map<String, dynamic> json) => FetchBanks(
    code: json['code'] as String?,
    createdTs: json['createdTs'] as String?,
    lastUpdatedTs: json['lastUpdatedTs'] as String?,
    createdBy: json['createdBy'] as String?,
    updatedBy: json['updatedBy'] as String?,
    id: json['id'] ?? 0,
    bankName: json['bankName'] ?? '',
    contactName: json['contactName'] ?? '',
    bankLogoUrl: json['bankLogoUrl'] ?? '',
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
    processingFee: json['processingFee'] as num? ?? 0,
    tenureYears: json['tenureYears'] as num? ?? 0,
    maxLoanAmount: json['maxLoanAmount'] as num? ?? 0,
    minLoanAmount: json['minLoanAmount'] as num? ?? 0,
    minCibilScore: json['minCibilScore'] as num? ?? 0,
    minimumIncome: json['minimumIncome'] as num? ?? 0,
    employmentType: json['employmentType'] ?? '',
    minimumAge: json['minimumAge'] as num? ?? 0,
    maximumAge: json['maximumAge'] as num? ?? 0,
    nationalityRequirement: json['nationalityRequirement'] ?? '',
    prepaymentAllowed: json['prepaymentAllowed'] ?? false,
    partPaymentAllowed: json['partPaymentAllowed'] ?? false,
    balanceTransferAvailable: json['balanceTransferAvailable'] ?? false,
    insuranceBundled: json['insuranceBundled'] ?? false,
    specialOffers: json['specialOffers'] ?? '',
    requiredDocuments: json['requiredDocuments'] ?? '',
    details: json['details'] ?? '',
    documents: json['documents'] != null
        ? BankDocuments.fromJson(json['documents'])
        : null, // <-- NEW
    createdAt: json['createdAt'] as String?,
    updatedAt: json['updatedAt'] as String?,
  );

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

/// =======================
/// DOCUMENTS MODEL
/// =======================
class BankDocuments {
  final String identityProof;
  final String addressProof;
  final String incomeProof;
  final String propertyProof;
  final String other;

  BankDocuments({
    required this.identityProof,
    required this.addressProof,
    required this.incomeProof,
    required this.propertyProof,
    required this.other,
  });

  factory BankDocuments.fromJson(Map<String, dynamic> json) => BankDocuments(
    identityProof: json['identityProof'] ?? 'PAN / Aadhaar / Passport',
    addressProof: json['addressProof'] ?? 'Utility Bill / Passport / Aadhaar',
    incomeProof: json['incomeProof'] ?? 'Salary Slip / ITR / Bank Statement',
    propertyProof: json['propertyProof'] ?? 'Sale Deed / Agreement',
    other: json['other'] ?? 'As per bank requirement',
  );

  Map<String, dynamic> toJson() => {
    'identityProof': identityProof,
    'addressProof': addressProof,
    'incomeProof': incomeProof,
    'propertyProof': propertyProof,
    'other': other,
  };

  factory BankDocuments.empty() => BankDocuments(
    identityProof: '',
    addressProof: '',
    incomeProof: '',
    propertyProof: '',
    other: '',
  );
}
