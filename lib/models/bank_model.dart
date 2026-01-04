import 'dart:convert';

/// ================================
/// API Helpers
/// ================================

List<Bank> banksFromJson(String str) =>
    List<Bank>.from(
      json.decode(str).map((x) => Bank.fromJson(x)),
    );

String banksToJson(List<Bank> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

/// ================================
/// Bank Model (DOMAIN MODEL)
/// ================================

class Bank {
  final String? code;
  final String? createdTs;
  final String? lastUpdatedTs;
  final String? createdBy;
  final String? updatedBy;

  final int? id;
  final String? bankName;
  final String? contactName;
  final String? contactNumber;
  final String? email;
  final String? branchName;
  final String? bankLogoUrl;
  final String? locationAddress;
  final String? street;
  final String? city;
  final String? state;
  final String? postalCode;
  final String? country;
  final String? websiteUrl;

  final double? interestRate;
  final String? interestType;
  final double? processingFee;
  final int? tenureYears;
  final double? maxLoanAmount;
  final double? minLoanAmount;
  final double? minCibilScore;
  final double? minimumIncome;
  final String? employmentType;
  final int? minimumAge;
  final int? maximumAge;
  final String? nationalityRequirement;

  final bool? prepaymentAllowed;
  final bool? partPaymentAllowed;
  final bool? balanceTransferAvailable;
  final bool? insuranceBundled;

  final String? specialOffers;
  final String? requiredDocuments;
  final String? details;

  /// 🔥 Nested Interest Slabs
  final List<BankInterestRate> interestRates;

  final String? createdAt;
  final String? updatedAt;

  const Bank({
    this.code,
    this.createdTs,
    this.lastUpdatedTs,
    this.createdBy,
    this.updatedBy,
    this.id,
    this.bankName,
    this.bankLogoUrl,
    this.contactName,
    this.contactNumber,
    this.email,
    this.branchName,
    this.locationAddress,
    this.street,
    this.city,
    this.state,
    this.postalCode,
    this.country,
    this.websiteUrl,
    this.interestRate,
    this.interestType,
    this.processingFee,
    this.tenureYears,
    this.maxLoanAmount,
    this.minLoanAmount,
    this.minCibilScore,
    this.minimumIncome,
    this.employmentType,
    this.minimumAge,
    this.maximumAge,
    this.nationalityRequirement,
    this.prepaymentAllowed,
    this.partPaymentAllowed,
    this.balanceTransferAvailable,
    this.insuranceBundled,
    this.specialOffers,
    this.requiredDocuments,
    this.details,
    required this.interestRates,
    this.createdAt,
    this.updatedAt,
  });

  factory Bank.fromJson(Map<String, dynamic> json) {
    return Bank(
      code: json['code'],
      createdTs: json['createdTs'],
      lastUpdatedTs: json['lastUpdatedTs'],
      createdBy: json['createdBy'],
      updatedBy: json['updatedBy'],
      id: json['id'],
      bankName: json['bankName'],
      bankLogoUrl: json['bankLogoUrl'],
      contactName: json['contactName'],
      contactNumber: json['contactNumber'],
      email: json['email'],
      branchName: json['branchName'],
      locationAddress: json['locationAddress'],
      street: json['street'],
      city: json['city'],
      state: json['state'],
      postalCode: json['postalCode'],
      country: json['country'],
      websiteUrl: json['websiteUrl'],
      interestRate: _toDouble(json['interestRate']),
      interestType: json['interestType'],
      processingFee: _toDouble(json['processingFee']),
      tenureYears: json['tenureYears'],
      maxLoanAmount: _toDouble(json['maxLoanAmount']),
      minLoanAmount: _toDouble(json['minLoanAmount']),
      minCibilScore: _toDouble(json['minCibilScore']),
      minimumIncome: _toDouble(json['minimumIncome']),
      employmentType: json['employmentType'],
      minimumAge: json['minimumAge'],
      maximumAge: json['maximumAge'],
      nationalityRequirement: json['nationalityRequirement'],
      prepaymentAllowed: json['prepaymentAllowed'],
      partPaymentAllowed: json['partPaymentAllowed'],
      balanceTransferAvailable: json['balanceTransferAvailable'],
      insuranceBundled: json['insuranceBundled'],
      specialOffers: json['specialOffers'],
      requiredDocuments: json['requiredDocuments'],
      details: json['details'],
      interestRates: (json['interestRates'] as List<dynamic>? ?? [])
          .map((e) => BankInterestRate.fromJson(e))
          .toList(),
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
    'bankLogoUrl': bankLogoUrl,
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
    'interestRates': interestRates.map((e) => e.toJson()).toList(),
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };

  /// 🔎 Best interest across slabs
  double? bestInterestRate() {
    if (interestRates.isEmpty) return interestRate;
    return interestRates
        .map((e) => e.interestRate)
        .whereType<double>()
        .reduce((a, b) => a < b ? a : b);
  }
}

/// ================================
/// Interest Rate Model
/// ================================

class BankInterestRate {
  final String? code;
  final String? createdTs;
  final String? lastUpdatedTs;
  final String? createdBy;
  final String? updatedBy;

  final int? id;
  final double? minCibil;
  final double? maxCibil;
  final double? interestRate;
  final int? bankId;

  const BankInterestRate({
    this.code,
    this.createdTs,
    this.lastUpdatedTs,
    this.createdBy,
    this.updatedBy,
    this.id,
    this.minCibil,
    this.maxCibil,
    this.interestRate,
    this.bankId,
  });

  factory BankInterestRate.fromJson(Map<String, dynamic> json) {
    return BankInterestRate(
      code: json['code'],
      createdTs: json['createdTs'],
      lastUpdatedTs: json['lastUpdatedTs'],
      createdBy: json['createdBy'],
      updatedBy: json['updatedBy'],
      id: json['id'],
      minCibil: _toDouble(json['minCibil']),
      maxCibil: _toDouble(json['maxCibil']),
      interestRate: _toDouble(json['interestRate']),
      bankId: json['bankId'],
    );
  }

  Map<String, dynamic> toJson() => {
    'code': code,
    'createdTs': createdTs,
    'lastUpdatedTs': lastUpdatedTs,
    'createdBy': createdBy,
    'updatedBy': updatedBy,
    'id': id,
    'minCibil': minCibil,
    'maxCibil': maxCibil,
    'interestRate': interestRate,
    'bankId': bankId,
  };
}

/// ================================
/// Helpers
/// ================================

double? _toDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}
