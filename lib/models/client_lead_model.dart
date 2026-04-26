class ClientLeadModel {
  final int? id;

  // Relations
  final int? brokerId;
  final int? userId;
  final int? propertyId;

  // Client Info
  final String? clientName;
  final String? mobile;
  final String? email;

  // Property Snapshot
  final String? propertyTitle;
  final String? propertyCity;
  final double? propertyPrice;

  // Client Preference
  final String? preferredPropertyType;
  final double? preferredBudget;

  // Dates
  final String? inquiryDate;
  final String? contactedDate;
  final String? nextFollowUpDate;

  // Status
  final bool? contacted;
  final String? status;

  // Notes
  final String? remark;

  // Lead Source
  final String? leadSource;

  ClientLeadModel({
    this.id,
    this.brokerId,
    this.userId,
    this.propertyId,
    this.clientName,
    this.mobile,
    this.email,
    this.propertyTitle,
    this.propertyCity,
    this.propertyPrice,
    this.preferredPropertyType,
    this.preferredBudget,
    this.inquiryDate,
    this.contactedDate,
    this.nextFollowUpDate,
    this.contacted,
    this.status,
    this.remark,
    this.leadSource,
  });

  // 🔁 JSON → MODEL
  factory ClientLeadModel.fromJson(Map<String, dynamic> json) {
    return ClientLeadModel(
      id: json['id'],
      brokerId: json['brokerId'],
      userId: json['userId'],
      propertyId: json['propertyId'],
      clientName: json['clientName'],
      mobile: json['mobile'],
      email: json['email'],
      propertyTitle: json['propertyTitle'],
      propertyCity: json['propertyCity'],
      propertyPrice: json['propertyPrice'] != null
          ? (json['propertyPrice'] as num).toDouble()
          : null,
      preferredPropertyType: json['preferredPropertyType'],
      preferredBudget: json['preferredBudget'] != null
          ? (json['preferredBudget'] as num).toDouble()
          : null,
      inquiryDate: json['inquiryDate'],
      contactedDate: json['contactedDate'],
      nextFollowUpDate: json['nextFollowUpDate'],
      contacted: json['contacted'],
      status: json['status'],
      remark: json['remark'],
      leadSource: json['leadSource'],
    );
  }

  // 🔁 MODEL → JSON
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "brokerId": brokerId,
      "userId": userId,
      "propertyId": propertyId,
      "clientName": clientName,
      "mobile": mobile,
      "email": email,
      "propertyTitle": propertyTitle,
      "propertyCity": propertyCity,
      "propertyPrice": propertyPrice,
      "preferredPropertyType": preferredPropertyType,
      "preferredBudget": preferredBudget,
      "inquiryDate": inquiryDate,
      "contactedDate": contactedDate,
      "nextFollowUpDate": nextFollowUpDate,
      "contacted": contacted,
      "status": status,
      "remark": remark,
      "leadSource": leadSource,
    };
  }
}