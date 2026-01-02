import 'dart:convert';

Inquiry inquiryFromJson(String str) =>
    Inquiry.fromJson(json.decode(str));

String inquiryToJson(Inquiry data) =>
    json.encode(data.toJson());

class Inquiry {
  final int? id;

  /// Applicant Details
  final String applicantName;
  final String mobileNumber;
  final String? email;
  final int? age;
  final double? monthlyIncome;
  final String inquiryType;
  final String? comments;

  /// Loan Details
  final double? budget;
  final double? requiredLoanAmount;
  final int? loanTenureYears;
  final String? loanType;

  /// Property Details
  final String? propertyType;
  final String? propertyState;
  final String? propertyCity;
  final String? propertyLocality;
  final bool? propertyIdentified;

  /// Lead Source
  final String? leadSource;
  final String? campaignCode;

  /// Bank & Status
  final String? preferredBank;
  final String? inquiryStatus;
  final int? assignedAgentId;
  final String? assignedAgentName;

  /// Approval Details
  final String? approvedBank;
  final double? approvedLoanAmount;
  final double? approvedInterestRate;

  /// Dates
  final DateTime? expectedPurchaseDate;

  Inquiry({
    this.id,
    required this.applicantName,
    required this.mobileNumber,
    this.email,
    this.age,
    this.monthlyIncome,
    required this.inquiryType,
    this.comments,
    this.budget,
    this.requiredLoanAmount,
    this.loanTenureYears,
    this.loanType,
    this.propertyType,
    this.propertyState,
    this.propertyCity,
    this.propertyLocality,
    this.propertyIdentified,
    this.leadSource,
    this.campaignCode,
    this.preferredBank,
    this.inquiryStatus,
    this.assignedAgentId,
    this.assignedAgentName,
    this.approvedBank,
    this.approvedLoanAmount,
    this.approvedInterestRate,
    this.expectedPurchaseDate,
  });

  factory Inquiry.fromJson(Map<String, dynamic> json) {
    return Inquiry(
      id: json['id'],
      applicantName: json['applicantName'],
      mobileNumber: json['mobileNumber'],
      email: json['email'],
      age: json['age'],
      monthlyIncome: json['monthlyIncome']?.toDouble(),
      inquiryType: json['inquiryType'],
      comments: json['comments'],
      budget: json['budget']?.toDouble(),
      requiredLoanAmount: json['requiredLoanAmount']?.toDouble(),
      loanTenureYears: json['loanTenureYears'],
      loanType: json['loanType'],

      propertyType: json['propertyType'],
      propertyState: json['propertyState'],
      propertyCity: json['propertyCity'],
      propertyLocality: json['propertyLocality'],
      propertyIdentified: json['propertyIdentified'],
      leadSource: json['leadSource'],
      campaignCode: json['campaignCode'],
      preferredBank: json['preferredBank'],
      inquiryStatus: json['inquiryStatus'] ,
      assignedAgentId: json['assignedAgentId'],
      assignedAgentName: json['assignedAgentName'],
      approvedBank: json['approvedBank'],
      approvedLoanAmount: json['approvedLoanAmount']?.toDouble(),
      approvedInterestRate: json['approvedInterestRate']?.toDouble(),
      expectedPurchaseDate: json['expectedPurchaseDate'] != null
          ? DateTime.parse(json['expectedPurchaseDate'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "applicantName": applicantName,
      "mobileNumber": mobileNumber,
      "email": email,
      "age": age,
      "monthlyIncome": monthlyIncome,
      "inquiryType": inquiryType,
      "comments": comments,
      "budget": budget,
      "requiredLoanAmount": requiredLoanAmount,
      "loanTenureYears": loanTenureYears,
      "loanType": loanType,
      "propertyType": propertyType,
      "propertyState": propertyState,
      "propertyCity": propertyCity,
      "propertyLocality": propertyLocality,
      "propertyIdentified": propertyIdentified,
      "leadSource": leadSource,
      "campaignCode": campaignCode,
      "preferredBank": preferredBank,
      "inquiryStatus": inquiryStatus,
      "assignedAgentId": assignedAgentId,
      "assignedAgentName": assignedAgentName,
      "approvedBank": approvedBank,
      "approvedLoanAmount": approvedLoanAmount,
      "approvedInterestRate": approvedInterestRate,
      "expectedPurchaseDate":
      expectedPurchaseDate?.toIso8601String().split('T').first,
    };
  }
}
