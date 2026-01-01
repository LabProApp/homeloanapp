import 'dart:convert';

class CalcLoanRequest {
  /// Loan principal amount
  final double principal;

  /// Annual interest rate in percentage (e.g. 7.5)
  final double annualInterestRate;

  /// Loan tenure in years
  final int tenureYears;

  /// Optional: include amortization schedule
  final bool includeSchedule;

  /// Monthly income of applicant
  final double monthlyIncome;

  /// Existing EMI obligations
  final double existingEmi;

  /// FOIR percentage (default usually 50%)
  final double foirPercent;

  /// Calculated affordable EMI
  final double affordableEmi;

  /// Calculated eligible loan amount
  final double eligibleLoanAmount;

  const CalcLoanRequest({
    required this.principal,
    required this.annualInterestRate,
    required this.tenureYears,
    this.includeSchedule = false,
    this.monthlyIncome = 0.0,
    this.existingEmi = 0.0,
    this.foirPercent = 0.0,
    this.affordableEmi = 0.0,
    this.eligibleLoanAmount = 0.0,
  });

  /// -------- FROM JSON --------
  factory CalcLoanRequest.fromJson(Map<String, dynamic> json) {
    return CalcLoanRequest(
      principal: (json['principal'] ?? 0).toDouble(),
      annualInterestRate: (json['annualInterestRate'] ?? 0).toDouble(),
      tenureYears: json['tenureYears'] ?? 0,
      includeSchedule: json['includeSchedule'] ?? false,
      monthlyIncome: (json['monthlyIncome'] ?? 0).toDouble(),
      existingEmi: (json['existingEmi'] ?? 0).toDouble(),
      foirPercent: (json['foirPercent'] ?? 0).toDouble(),
      affordableEmi: (json['affordableEmi'] ?? 0).toDouble(),
      eligibleLoanAmount: (json['eligibleLoanAmount'] ?? 0).toDouble(),
    );
  }

  /// -------- TO JSON (API REQUEST) --------
  Map<String, dynamic> toJson() {
    return {
      "principal": principal,
      "annualInterestRate": annualInterestRate,
      "tenureYears": tenureYears,
      "includeSchedule": includeSchedule,
      "monthlyIncome": monthlyIncome,
      "existingEmi": existingEmi,
      "foirPercent": foirPercent,
      "affordableEmi": affordableEmi,
      "eligibleLoanAmount": eligibleLoanAmount,
    };
  }

  /// -------- COPY WITH --------
  CalcLoanRequest copyWith({
    double? principal,
    double? annualInterestRate,
    int? tenureYears,
    bool? includeSchedule,
    double? monthlyIncome,
    double? existingEmi,
    double? foirPercent,
    double? affordableEmi,
    double? eligibleLoanAmount,
  }) {
    return CalcLoanRequest(
      principal: principal ?? this.principal,
      annualInterestRate:
      annualInterestRate ?? this.annualInterestRate,
      tenureYears: tenureYears ?? this.tenureYears,
      includeSchedule: includeSchedule ?? this.includeSchedule,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      existingEmi: existingEmi ?? this.existingEmi,
      foirPercent: foirPercent ?? this.foirPercent,
      affordableEmi: affordableEmi ?? this.affordableEmi,
      eligibleLoanAmount:
      eligibleLoanAmount ?? this.eligibleLoanAmount,
    );
  }
}
