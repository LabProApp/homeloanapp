import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../commons/common_widget.dart';
import '../utility/money_input_formatter.dart';

class LoanEligibilityScreen extends StatefulWidget {
  const LoanEligibilityScreen({super.key});

  @override
  State<LoanEligibilityScreen> createState() => _LoanEligibilityScreenState();
}

class _LoanEligibilityScreenState extends State<LoanEligibilityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _salaryCtrl     = TextEditingController();
  final _existingEmiCtrl = TextEditingController();
  final _loanAmountCtrl = TextEditingController();
  final _tenureCtrl     = TextEditingController();

  static final _fmt = NumberFormat('#,##,###');

  double _foirPercent = 50; // 40–60% slider
  _EligibilityResult? _result;

  @override
  void dispose() {
    _salaryCtrl.dispose();
    _existingEmiCtrl.dispose();
    _loanAmountCtrl.dispose();
    _tenureCtrl.dispose();
    super.dispose();
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final salary      = MoneyInputFormatter.parse(_salaryCtrl.text) ?? 0;
    final existingEmi = MoneyInputFormatter.parse(_existingEmiCtrl.text) ?? 0;
    final required    = MoneyInputFormatter.parse(_loanAmountCtrl.text) ?? 0;
    final tenureYears = int.tryParse(_tenureCtrl.text.trim()) ?? 20;

    // Available EMI based on FOIR
    final availableEmi = (salary * _foirPercent / 100) - existingEmi;

    // Max eligible loan at common bank rates
    final scenarios = [7.0, 8.5, 9.5, 10.5].map((rate) {
      final maxLoan = _maxLoan(availableEmi, rate, tenureYears * 12);
      final emiForRequired = required > 0
          ? _calcEmi(required, rate, tenureYears * 12)
          : 0.0;
      return _RateScenario(
        rate: rate,
        maxEligibleLoan: maxLoan,
        emiIfRequired: emiForRequired,
      );
    }).toList();

    setState(() {
      _result = _EligibilityResult(
        monthlySalary: salary,
        existingEmi: existingEmi,
        foirPercent: _foirPercent,
        availableEmi: availableEmi,
        tenureYears: tenureYears,
        requiredLoan: required,
        scenarios: scenarios,
      );
    });
  }

  // EMI = P * r * (1+r)^n / [(1+r)^n - 1]
  double _calcEmi(double principal, double annualRate, int months) {
    if (principal <= 0 || months <= 0) return 0;
    final r = annualRate / 12 / 100;
    final pow = math.pow(1 + r, months);
    return principal * r * pow / (pow - 1);
  }

  // Max loan = EMI * [(1+r)^n - 1] / [r * (1+r)^n]
  double _maxLoan(double emi, double annualRate, int months) {
    if (emi <= 0 || months <= 0) return 0;
    final r = annualRate / 12 / 100;
    final pow = math.pow(1 + r, months);
    return emi * (pow - 1) / (r * pow);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.listingbackground,
      appBar: GradientAppBar(
        title: 'Loan Eligibility Check',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoCard(),
            const SizedBox(height: 16),
            _formCard(),
            const SizedBox(height: 16),
            _foirSlider(),
            const SizedBox(height: 20),
            AppButton(text: 'Check Eligibility', onTap: _calculate),
            if (_result != null) ...[
              const SizedBox(height: 24),
              _resultSection(_result!),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _infoCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.primary, size: 20),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Banks typically allow 40–60% of net salary for all EMI obligations (FOIR). Adjust the slider to match your bank\'s policy.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _formCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your Financial Details',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 16),
            _field(
              ctrl: _salaryCtrl,
              label: 'Gross Monthly Salary (₹)',
              hint: 'e.g. 80,000',
              required: true,
              isMoney: true,
            ),
            const SizedBox(height: 12),
            _field(
              ctrl: _existingEmiCtrl,
              label: 'Existing Monthly EMIs (₹)',
              hint: '0 if none',
              required: false,
              isMoney: true,
            ),
            const SizedBox(height: 12),
            _field(
              ctrl: _loanAmountCtrl,
              label: 'Required Loan Amount (₹)',
              hint: 'e.g. 50,00,000',
              required: false,
              isMoney: true,
            ),
            const SizedBox(height: 12),
            _field(
              ctrl: _tenureCtrl,
              label: 'Loan Tenure (years)',
              hint: 'e.g. 20',
              required: true,
              isInt: true,
              max: 30,
            ),
          ],
        ),
      ),
    );
  }

  Widget _foirSlider() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('FOIR (Eligible EMI %)',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_foirPercent.toInt()}%',
                  style: const TextStyle(
                      color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 14),
                ),
              ),
            ],
          ),
          Slider(
            value: _foirPercent,
            min: 40,
            max: 60,
            divisions: 20,
            activeColor: AppColors.primary,
            onChanged: (v) => setState(() => _foirPercent = v),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('40% (Conservative)', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
              Text('60% (Aggressive)', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _resultSection(_EligibilityResult r) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Eligibility Results',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        const SizedBox(height: 12),

        // Summary card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Available Monthly EMI',
                  style: TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 4),
              Text(
                r.availableEmi > 0
                    ? '₹ ${_fmt.format(r.availableEmi.toInt())}'
                    : 'Not Eligible',
                style: const TextStyle(
                    color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _summaryChip('Salary', '₹ ${_fmt.format(r.monthlySalary.toInt())}'),
                  const SizedBox(width: 8),
                  _summaryChip('Existing EMI', '₹ ${_fmt.format(r.existingEmi.toInt())}'),
                  const SizedBox(width: 8),
                  _summaryChip('FOIR', '${r.foirPercent.toInt()}%'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        if (r.availableEmi <= 0) ...[
          _warningBanner(
            'Not Eligible',
            'Your existing EMIs exceed the allowed FOIR limit. Consider reducing existing obligations before applying.',
          ),
        ] else ...[
          const Text('Eligible Loan at Different Interest Rates',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          ...r.scenarios.map((s) => _scenarioCard(s, r)),
          const SizedBox(height: 8),
          if (r.requiredLoan > 0) _requiredLoanSummary(r),
        ],
      ],
    );
  }

  Widget _scenarioCard(_RateScenario s, _EligibilityResult r) {
    final eligible = s.maxEligibleLoan > 0;
    final meetsRequired = r.requiredLoan > 0 && s.maxEligibleLoan >= r.requiredLoan;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: meetsRequired
              ? const Color(0xFF2E7D32)
              : r.requiredLoan > 0
                  ? AppColors.error.withOpacity(0.3)
                  : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '${s.rate}%',
                style: const TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 13),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eligible ? '₹ ${_fmt.format(s.maxEligibleLoan.toInt())}' : 'Not Eligible',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: eligible ? AppColors.textPrimary : AppColors.error,
                  ),
                ),
                const SizedBox(height: 2),
                Text('Max eligible loan at ${s.rate}% p.a.',
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
          if (r.requiredLoan > 0)
            Icon(
              meetsRequired ? Icons.check_circle_rounded : Icons.cancel_rounded,
              color: meetsRequired ? const Color(0xFF2E7D32) : AppColors.error,
              size: 22,
            ),
        ],
      ),
    );
  }

  Widget _requiredLoanSummary(_EligibilityResult r) {
    final eligibleAt = r.scenarios.where((s) => s.maxEligibleLoan >= r.requiredLoan).toList();
    final isEligible = eligibleAt.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isEligible
            ? const Color(0xFFE8F5E9)
            : const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isEligible ? const Color(0xFF2E7D32) : AppColors.error,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isEligible ? Icons.verified_rounded : Icons.warning_amber_rounded,
            color: isEligible ? const Color(0xFF2E7D32) : AppColors.error,
            size: 24,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEligible
                      ? 'Eligible for ₹ ${_fmt.format(r.requiredLoan.toInt())}'
                      : 'Not eligible for ₹ ${_fmt.format(r.requiredLoan.toInt())}',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: isEligible ? const Color(0xFF2E7D32) : AppColors.error,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isEligible
                      ? 'You qualify at rates: ${eligibleAt.map((s) => "${s.rate}%").join(", ")}'
                      : 'Increase tenure, reduce existing EMIs, or apply for a smaller amount',
                  style: TextStyle(
                      fontSize: 11,
                      color: isEligible ? const Color(0xFF388E3C) : AppColors.error),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _warningBanner(String title, String message) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, color: AppColors.error, fontSize: 13)),
                const SizedBox(height: 2),
                Text(message,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryChip(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 10)),
          Text(value,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _field({
    required TextEditingController ctrl,
    required String label,
    required String hint,
    required bool required,
    bool isInt = false,
    bool isMoney = false,
    int? max,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: TextInputType.number,
      inputFormatters: isMoney ? [MoneyInputFormatter()] : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: const Icon(Icons.currency_rupee, size: 18),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        isDense: true,
      ),
      validator: (v) {
        if (required && (v == null || v.trim().isEmpty)) return 'Required';
        if (v != null && v.isNotEmpty) {
          final n = isMoney ? MoneyInputFormatter.parse(v) : double.tryParse(v);
          if (n == null || n < 0) return 'Enter a valid amount';
          if (max != null && n > max) return 'Max $max years';
        }
        return null;
      },
    );
  }
}

// ── Data classes ─────────────────────────────────────────────────────────────

class _EligibilityResult {
  final double monthlySalary;
  final double existingEmi;
  final double foirPercent;
  final double availableEmi;
  final int tenureYears;
  final double requiredLoan;
  final List<_RateScenario> scenarios;

  const _EligibilityResult({
    required this.monthlySalary,
    required this.existingEmi,
    required this.foirPercent,
    required this.availableEmi,
    required this.tenureYears,
    required this.requiredLoan,
    required this.scenarios,
  });
}

class _RateScenario {
  final double rate;
  final double maxEligibleLoan;
  final double emiIfRequired;

  const _RateScenario({
    required this.rate,
    required this.maxEligibleLoan,
    required this.emiIfRequired,
  });
}

