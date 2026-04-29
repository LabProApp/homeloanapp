import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme/app_colors.dart';
import '../models/calc_loan_request.dart';
import '../models/calc_loan_response.dart';
import '../services/emi_service.dart';
import '../commons/common_widget.dart';

class EmiCalculatorScreen extends StatefulWidget {
  final double? initialAmount;
  final ScrollController? scrollController;

  const EmiCalculatorScreen({super.key, this.initialAmount, this.scrollController});

  @override
  State<EmiCalculatorScreen> createState() => _EmiCalculatorScreenState();
}

class _EmiCalculatorScreenState extends State<EmiCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();

  final principalCtrl = TextEditingController();
  final interestCtrl  = TextEditingController();
  final tenureCtrl    = TextEditingController();

  bool loading = false;
  CalcLoanResponse? response;

  double _calcPrincipal = 0;
  double _calcRate      = 0;
  int    _calcTenure    = 0;

  static final _fmt = NumberFormat('#,##,###');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _resetForm();
      if (widget.initialAmount != null) {
        principalCtrl.text = widget.initialAmount!.toInt().toString();
      }
    });
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    principalCtrl.clear();
    interestCtrl.clear();
    tenureCtrl.clear();
    setState(() { response = null; loading = false; });
  }

  @override
  void dispose() {
    principalCtrl.dispose();
    interestCtrl.dispose();
    tenureCtrl.dispose();
    super.dispose();
  }

  Future<void> _calculateEmi() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => loading = true);
    try {
      _calcPrincipal = double.parse(principalCtrl.text);
      _calcRate      = double.parse(interestCtrl.text);
      _calcTenure    = int.parse(tenureCtrl.text);

      final request = CalcLoanRequest(
        principal: _calcPrincipal,
        annualInterestRate: _calcRate,
        tenureYears: _calcTenure,
        includeSchedule: false,
      );
      final res = await LoanApiService.calculateLoan(request);
      setState(() => response = res);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Calculation failed')),
        );
      }
    } finally {
      setState(() => loading = false);
    }
  }

  // ── Amortization: balance remaining at end of each year ────────────────────
  List<FlSpot> _balanceSpots() {
    final r   = _calcRate / 12 / 100;
    final emi = response!.monthlyPayment;
    return List.generate(_calcTenure + 1, (y) {
      final n       = y * 12;
      final factor  = pow(1 + r, n).toDouble();
      final balance = r == 0
          ? (_calcPrincipal - emi * n).clamp(0.0, double.infinity)
          : (_calcPrincipal * factor - emi * (factor - 1) / r)
              .clamp(0.0, double.infinity);
      return FlSpot(y.toDouble(), balance);
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isSheet = widget.scrollController != null;

    final content = SingleChildScrollView(
      controller: widget.scrollController,
      padding: EdgeInsets.fromLTRB(16, isSheet ? 0 : 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isSheet) ...[
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ],
          Text('EMI Calculator',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          _formCard(),
          const SizedBox(height: 20),
          if (response != null) ...[
            _resultCard(),
            const SizedBox(height: 16),
            _pieSection(),
            const SizedBox(height: 16),
            _lineSection(),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );

    if (isSheet) {
      return Container(
        color: AppColors.listingbackground,
        child: content,
      );
    }

    return Scaffold(
      backgroundColor: AppColors.listingbackground,
      body: content,
    );
  }

  // ── Form card ─────────────────────────────────────────────────────────────
  Widget _formCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Form(
          key: _formKey,
          child: Column(children: [
            _field('Loan Amount (₹)', principalCtrl),
            _field('Interest Rate (%)', interestCtrl),
            _field('Tenure (Years)', tenureCtrl),
            const SizedBox(height: 14),
            AppButton(text: 'Calculate EMI', isLoading: loading, onTap: _calculateEmi),
          ]),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          filled: true,
          fillColor: AppColors.textBoxbackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // ── Result card ───────────────────────────────────────────────────────────
  Widget _resultCard() {
    final r = response!;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(children: [
              const Text('Monthly EMI',
                  style: TextStyle(color: AppColors.white70, fontSize: 13)),
              const SizedBox(height: 4),
              Text('₹ ${_fmt.format(r.monthlyPayment.toInt())}',
                  style: const TextStyle(
                      color: AppColors.white, fontSize: 26, fontWeight: FontWeight.w700)),
            ]),
          ),
          const SizedBox(height: 16),
          _row('Principal Amount', '₹ ${_fmt.format(_calcPrincipal.toInt())}'),
          _row('Total Interest',   '₹ ${_fmt.format(r.totalInterest.toInt())}'),
          const Divider(height: 16),
          _row('Total Payment',    '₹ ${_fmt.format(r.totalPayment.toInt())}', bold: true),
        ]),
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: bold ? FontWeight.w600 : FontWeight.normal)),
          Text(value, style: TextStyle(
              fontSize: 13,
              color: AppColors.textPrimary,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500)),
        ],
      ),
    );
  }

  // ── Pie chart — principal vs interest ─────────────────────────────────────
  Widget _pieSection() {
    final principal = _calcPrincipal;
    final interest  = response!.totalInterest;
    final total     = principal + interest;
    final pPct = total > 0 ? (principal / total * 100).toStringAsFixed(1) : '0';
    final iPct = total > 0 ? (interest  / total * 100).toStringAsFixed(1) : '0';

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Payment Breakdown',
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 3,
                  centerSpaceRadius: 36,
                  sections: [
                    PieChartSectionData(
                      color: AppColors.primary,
                      value: principal,
                      title: '$pPct%',
                      radius: 72,
                      titleStyle: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.white),
                    ),
                    PieChartSectionData(
                      color: AppColors.error,
                      value: interest,
                      title: '$iPct%',
                      radius: 72,
                      titleStyle: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.white),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _Legend(
                    color: AppColors.primary,
                    label: 'Principal  ₹${_fmt.format(_calcPrincipal.toInt())}'),
                const SizedBox(width: 20),
                _Legend(
                    color: AppColors.error,
                    label: 'Interest  ₹${_fmt.format(response!.totalInterest.toInt())}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Line chart — outstanding balance per year ──────────────────────────────
  Widget _lineSection() {
    final spots      = _balanceSpots();
    final maxBalance = _calcPrincipal;
    final interval   = (maxBalance / 4).ceilToDouble();
    final xInterval  = (_calcTenure / 4).ceilToDouble().clamp(1.0, double.infinity);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Outstanding Balance',
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 2),
            const Text('Balance remaining at end of each year',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: interval > 0 ? interval : 1,
                    getDrawingHorizontalLine: (_) =>
                        FlLine(color: AppColors.border, strokeWidth: 1),
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        interval: xInterval,
                        getTitlesWidget: (v, _) => Text(
                          'Yr ${v.toInt()}',
                          style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                        ),
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 48,
                        interval: interval > 0 ? interval : 1,
                        getTitlesWidget: (v, _) => Text(
                          '${(v / 100000).toStringAsFixed(0)}L',
                          style: const TextStyle(fontSize: 9, color: AppColors.textMuted),
                        ),
                      ),
                    ),
                    topTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: const Border(
                      bottom: BorderSide(color: AppColors.border),
                      left:   BorderSide(color: AppColors.border),
                    ),
                  ),
                  minX: 0,
                  maxX: _calcTenure.toDouble(),
                  minY: 0,
                  maxY: maxBalance,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: AppColors.primary,
                      barWidth: 2.5,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.primary.withOpacity(0.08),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Legend dot + label ─────────────────────────────────────────────────────────

class _Legend extends StatelessWidget {
  final Color color;
  final String label;

  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12, height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }
}
