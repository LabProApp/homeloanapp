import 'dart:convert';
import '../models/amortization_entry.dart';

class CalcLoanResponse {
  /// Monthly EMI amount
  final double monthlyPayment;

  /// Total payment over loan tenure
  final double totalPayment;

  /// Total interest paid
  final double totalInterest;

  /// Total loan duration in months
  final int totalMonths;

  /// Affordable EMI based on FOIR
  final double affordableEmi;

  /// Eligible loan amount
  final double eligibleLoan;

  /// Optional amortization schedule
  final List<AmortizationEntry>? amortizationSchedule;

  const CalcLoanResponse({
    this.monthlyPayment = 0.0,
    this.totalPayment = 0.0,
    this.totalInterest = 0.0,
    this.totalMonths = 0,
    this.affordableEmi = 0.0,
    this.eligibleLoan = 0.0,
    this.amortizationSchedule,
  });

  /// -------- FROM JSON --------
  factory CalcLoanResponse.fromJson(Map<String, dynamic> json) {
    return CalcLoanResponse(
      monthlyPayment: (json['monthlyPayment'] ?? 0).toDouble(),
      totalPayment: (json['totalPayment'] ?? 0).toDouble(),
      totalInterest: (json['totalInterest'] ?? 0).toDouble(),
      totalMonths: json['totalMonths'] ?? 0,
      affordableEmi: (json['affordableEmi'] ?? 0).toDouble(),
      eligibleLoan: (json['eligibleLoan'] ?? 0).toDouble(),
      amortizationSchedule: json['amortizationSchedule'] != null
          ? (json['amortizationSchedule'] as List)
          .map((e) => AmortizationEntry.fromJson(e))
          .toList()
          : null,
    );
  }

  /// -------- TO JSON --------
  Map<String, dynamic> toJson() {
    return {
      "monthlyPayment": monthlyPayment,
      "totalPayment": totalPayment,
      "totalInterest": totalInterest,
      "totalMonths": totalMonths,
      "affordableEmi": affordableEmi,
      "eligibleLoan": eligibleLoan,
      "amortizationSchedule":
      amortizationSchedule?.map((e) => e.toJson()).toList(),
    };
  }
}
