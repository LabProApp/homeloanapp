class AmortizationEntry {
  /// Month number in loan schedule
  final int monthNumber;

  /// Payment date (ISO-8601: yyyy-MM-dd)
  final DateTime paymentDate;

  /// Balance at the beginning of the month
  final double beginningBalance;

  /// Scheduled EMI payment
  final double scheduledPayment;

  /// Principal part of EMI
  final double principalComponent;

  /// Interest part of EMI
  final double interestComponent;

  /// Balance after payment
  final double endingBalance;

  const AmortizationEntry({
    this.monthNumber = 0,
    required this.paymentDate,
    this.beginningBalance = 0.0,
    this.scheduledPayment = 0.0,
    this.principalComponent = 0.0,
    this.interestComponent = 0.0,
    this.endingBalance = 0.0,
  });

  /// -------- FROM JSON --------
  factory AmortizationEntry.fromJson(Map<String, dynamic> json) {
    return AmortizationEntry(
      monthNumber: json['monthNumber'] ?? 0,
      paymentDate: DateTime.parse(json['paymentDate']),
      beginningBalance: (json['beginningBalance'] ?? 0).toDouble(),
      scheduledPayment: (json['scheduledPayment'] ?? 0).toDouble(),
      principalComponent: (json['principalComponent'] ?? 0).toDouble(),
      interestComponent: (json['interestComponent'] ?? 0).toDouble(),
      endingBalance: (json['endingBalance'] ?? 0).toDouble(),
    );
  }

  /// -------- TO JSON --------
  Map<String, dynamic> toJson() {
    return {
      "monthNumber": monthNumber,
      "paymentDate": paymentDate.toIso8601String().split('T').first,
      "beginningBalance": beginningBalance,
      "scheduledPayment": scheduledPayment,
      "principalComponent": principalComponent,
      "interestComponent": interestComponent,
      "endingBalance": endingBalance,
    };
  }
}
