class ClientLeadModel {
  final int? id;

  // Relations
  final int? brokerId;
  final int? userId;
  final int? propertyId;
  final int? propertyOwnerId;
  final int? assignedAgentId;

  // Client Info
  final String? clientName;
  final String? mobile;
  final String? email;
  final int? age;
  final double? monthlyIncome;
  final String? profession;

  // Lead Classification
  final String? leadType;
  final String? leadSource;
  final String? campaignCode;

  // Property Snapshot
  final String? propertyTitle;
  final String? propertyCity;
  final String? propertyState;
  final String? propertyLocality;
  final String? propertyType;
  final double? propertyPrice;
  final bool? propertyIdentified;

  // Client Preference / Financial
  final String? preferredPropertyType;
  final double? preferredBudget;
  final double? budget;
  final double? minBudget;
  final double? maxBudget;
  final double? requiredLoanAmount;
  final int? loanTenureYears;
  final String? loanType;
  final String? preferredBank;

  // Communication
  final String? message;
  final String? remark;

  // Dates
  final String? inquiryDate;
  final String? contactedDate;
  final String? nextFollowUpDate;
  final String? expectedPurchaseDate;

  // Status
  final bool? contacted;
  final String? status;

  // Structured preference data (e.g. "Looking To: Buy | Beds: 3 | Baths: 2")
  final String? specifications;

  // Enriched display fields (read-only from API)
  final String? ownerName;
  final String? ownerMobile;
  final String? ownerEmail;
  final String? brokerName;
  final String? assignedAgentName;

  ClientLeadModel({
    this.id,
    this.brokerId,
    this.userId,
    this.propertyId,
    this.propertyOwnerId,
    this.assignedAgentId,
    this.clientName,
    this.mobile,
    this.email,
    this.age,
    this.monthlyIncome,
    this.profession,
    this.leadType,
    this.leadSource,
    this.campaignCode,
    this.propertyTitle,
    this.propertyCity,
    this.propertyState,
    this.propertyLocality,
    this.propertyType,
    this.propertyPrice,
    this.propertyIdentified,
    this.preferredPropertyType,
    this.preferredBudget,
    this.budget,
    this.minBudget,
    this.maxBudget,
    this.requiredLoanAmount,
    this.loanTenureYears,
    this.loanType,
    this.preferredBank,
    this.message,
    this.remark,
    this.inquiryDate,
    this.contactedDate,
    this.nextFollowUpDate,
    this.expectedPurchaseDate,
    this.contacted,
    this.status,
    this.specifications,
    this.ownerName,
    this.ownerMobile,
    this.ownerEmail,
    this.brokerName,
    this.assignedAgentName,
  });

  factory ClientLeadModel.fromJson(Map<String, dynamic> json) {
    return ClientLeadModel(
      id: json['id'],
      brokerId: json['brokerId'],
      userId: json['userId'],
      propertyId: json['propertyId'],
      propertyOwnerId: json['propertyOwnerId'],
      assignedAgentId: json['assignedAgentId'],
      clientName: json['clientName'],
      mobile: json['mobile'],
      email: json['email'],
      age: json['age'],
      monthlyIncome: json['monthlyIncome'] != null ? (json['monthlyIncome'] as num).toDouble() : null,
      profession: json['profession'],
      leadType: json['leadType'],
      leadSource: json['leadSource'],
      campaignCode: json['campaignCode'],
      propertyTitle: json['propertyTitle'],
      propertyCity: json['propertyCity'],
      propertyState: json['propertyState'],
      propertyLocality: json['propertyLocality'],
      propertyType: json['propertyType'],
      propertyPrice: json['propertyPrice'] != null ? (json['propertyPrice'] as num).toDouble() : null,
      propertyIdentified: json['propertyIdentified'],
      preferredPropertyType: json['preferredPropertyType'],
      preferredBudget: json['preferredBudget'] != null ? (json['preferredBudget'] as num).toDouble() : null,
      budget: json['budget'] != null ? (json['budget'] as num).toDouble() : null,
      minBudget: json['minBudget'] != null ? (json['minBudget'] as num).toDouble() : null,
      maxBudget: json['maxBudget'] != null ? (json['maxBudget'] as num).toDouble() : null,
      requiredLoanAmount: json['requiredLoanAmount'] != null ? (json['requiredLoanAmount'] as num).toDouble() : null,
      loanTenureYears: json['loanTenureYears'],
      loanType: json['loanType'],
      preferredBank: json['preferredBank'],
      message: json['message'],
      remark: json['remark'],
      inquiryDate: json['inquiryDate'],
      contactedDate: json['contactedDate'],
      nextFollowUpDate: json['nextFollowUpDate'],
      expectedPurchaseDate: json['expectedPurchaseDate'],
      contacted: json['contacted'],
      status: json['status'],
      specifications: json['specifications'],
      ownerName: json['ownerName'],
      ownerMobile: json['ownerMobile'],
      ownerEmail: json['ownerEmail'],
      brokerName: json['brokerName'],
      assignedAgentName: json['assignedAgentName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (brokerId != null) 'brokerId': brokerId,
      if (userId != null) 'userId': userId,
      if (propertyId != null) 'propertyId': propertyId,
      if (propertyOwnerId != null) 'propertyOwnerId': propertyOwnerId,
      if (assignedAgentId != null) 'assignedAgentId': assignedAgentId,
      'clientName': clientName,
      'mobile': mobile,
      if (email != null) 'email': email,
      if (age != null) 'age': age,
      if (monthlyIncome != null) 'monthlyIncome': monthlyIncome,
      if (profession != null) 'profession': profession,
      if (leadType != null) 'leadType': leadType,
      if (leadSource != null) 'leadSource': leadSource,
      if (campaignCode != null) 'campaignCode': campaignCode,
      if (propertyTitle != null) 'propertyTitle': propertyTitle,
      if (propertyCity != null) 'propertyCity': propertyCity,
      if (propertyState != null) 'propertyState': propertyState,
      if (propertyLocality != null) 'propertyLocality': propertyLocality,
      if (propertyType != null) 'propertyType': propertyType,
      if (propertyPrice != null) 'propertyPrice': propertyPrice,
      if (propertyIdentified != null) 'propertyIdentified': propertyIdentified,
      if (preferredPropertyType != null) 'preferredPropertyType': preferredPropertyType,
      if (preferredBudget != null) 'preferredBudget': preferredBudget,
      if (budget != null) 'budget': budget,
      if (requiredLoanAmount != null) 'requiredLoanAmount': requiredLoanAmount,
      if (loanTenureYears != null) 'loanTenureYears': loanTenureYears,
      if (loanType != null) 'loanType': loanType,
      if (preferredBank != null) 'preferredBank': preferredBank,
      if (message != null) 'message': message,
      if (remark != null) 'remark': remark,
      if (status != null) 'status': status,
      if (nextFollowUpDate != null) 'nextFollowUpDate': nextFollowUpDate,
      if (expectedPurchaseDate != null) 'expectedPurchaseDate': expectedPurchaseDate,
      if (specifications != null) 'specifications': specifications,
    };
  }
}
