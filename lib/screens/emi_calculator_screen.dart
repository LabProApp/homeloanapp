import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme/app_colors.dart';
import '../models/calc_loan_request.dart';
import '../models/calc_loan_response.dart';
import '../services/emi_service.dart';
import '../commons/common_widget.dart';
import '../utility/money_input_formatter.dart';

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

  double _calcPrincipal   = 0;
  double _calcRate        = 0;
  int    _calcTenure      = 0;
  int    _touchedPieIndex = -1;

  static final _fmt = NumberFormat('#,##,###');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _resetForm();
      if (widget.initialAmount != null) {
        principalCtrl.text = MoneyInputFormatter.format(widget.initialAmount!);
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
      _calcPrincipal = MoneyInputFormatter.parse(principalCtrl.text) ?? 0;
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
            const SizedBox(height: 16),
            _barSection(),
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
            _field('Loan Amount (₹)', principalCtrl, isMoney: true, validator: (v) {
              if (v == null || v.isEmpty) return 'Required';
              final n = MoneyInputFormatter.parse(v) ?? 0;
              if (n < 10000) return 'Minimum ₹10,000';
              return null;
            }),
            _field('Interest Rate (%)', interestCtrl, validator: (v) {
              if (v == null || v.isEmpty) return 'Required';
              final n = double.tryParse(v) ?? -1;
              if (n < 1 || n > 30) return 'Rate must be 1–30%';
              return null;
            }),
            _field('Tenure (Years)', tenureCtrl, validator: (v) {
              if (v == null || v.isEmpty) return 'Required';
              final n = int.tryParse(v) ?? -1;
              if (n < 1 || n > 40) return 'Tenure must be 1–40 years';
              return null;
            }),
            const SizedBox(height: 14),
            AppButton(text: 'Calculate EMI', isLoading: loading, onTap: _calculateEmi),
          ]),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl,
      {bool isMoney = false, String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        inputFormatters: isMoney ? [MoneyInputFormatter()] : null,
        validator: validator ?? (v) => (v == null || v.isEmpty) ? 'Required' : null,
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

    String centerLabel;
    Color  centerColor;
    if (_touchedPieIndex == 0) {
      centerLabel = '₹ ${_fmt.format(principal.toInt())}';
      centerColor = AppColors.primary;
    } else if (_touchedPieIndex == 1) {
      centerLabel = '₹ ${_fmt.format(interest.toInt())}';
      centerColor = AppColors.error;
    } else {
      centerLabel = '${(total / 100000).toStringAsFixed(1)}L\nTotal';
      centerColor = AppColors.textSecondary;
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Payment Breakdown',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            const Text('Tap a segment to see amount',
                style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
            const SizedBox(height: 14),
            SizedBox(
              height: 200,
              child: Stack(alignment: Alignment.center, children: [
                PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, resp) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              resp == null || resp.touchedSection == null) {
                            _touchedPieIndex = -1;
                            return;
                          }
                          _touchedPieIndex = resp.touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                    sectionsSpace: 3,
                    centerSpaceRadius: 52,
                    sections: [
                      PieChartSectionData(
                        color: AppColors.primary,
                        value: principal,
                        title: '$pPct%',
                        radius: _touchedPieIndex == 0 ? 80 : 68,
                        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.white),
                      ),
                      PieChartSectionData(
                        color: AppColors.error,
                        value: interest,
                        title: '$iPct%',
                        radius: _touchedPieIndex == 1 ? 80 : 68,
                        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.white),
                      ),
                    ],
                  ),
                ),
                // Center label
                Column(mainAxisSize: MainAxisSize.min, children: centerLabel.split('\n').map((line) =>
                  Text(line, textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: centerColor))
                ).toList()),
              ]),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _Legend(color: AppColors.primary,
                    label: 'Principal  ₹ ${_fmt.format(_calcPrincipal.toInt())}'),
                const SizedBox(width: 20),
                _Legend(color: AppColors.error,
                    label: 'Interest  ₹ ${_fmt.format(response!.totalInterest.toInt())}'),
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
                  lineTouchData: LineTouchData(
                    handleBuiltInTouches: true,
                    touchTooltipData: LineTouchTooltipData(
                      tooltipBgColor: Colors.black87,
                      getTooltipItems: (spots) => spots.map((s) => LineTooltipItem(
                        'Year ${s.x.toInt()}\n₹ ${_fmt.format(s.y.toInt())}',
                        const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                      )).toList(),
                    ),
                  ),
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
                        gradient: LinearGradient(
                          begin: Alignment.topCenter, end: Alignment.bottomCenter,
                          colors: [AppColors.primary.withOpacity(0.20), AppColors.primary.withOpacity(0.02)],
                        ),
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

  // ── Annual breakdown bar chart ────────────────────────────────────────────
  Widget _barSection() {
    final r   = _calcRate / 12 / 100;
    final emi = response!.monthlyPayment;
    double balance = _calcPrincipal;
    double maxTotal = 0;
    final groups = <BarChartGroupData>[];

    for (int yr = 1; yr <= _calcTenure; yr++) {
      double yPrin = 0, yInt = 0;
      for (int m = 0; m < 12 && balance > 0; m++) {
        final iAmt = balance * r;
        final pAmt = (emi - iAmt).clamp(0.0, balance);
        yInt  += iAmt;
        yPrin += pAmt;
        balance -= pAmt;
      }
      final total = yPrin + yInt;
      if (total > maxTotal) maxTotal = total;
      final bw = _calcTenure > 20 ? 7.0 : 12.0;
      groups.add(BarChartGroupData(
        x: yr,
        barRods: [
          BarChartRodData(
            toY: total,
            width: bw,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
            rodStackItems: [
              BarChartRodStackItem(0,     yPrin,         AppColors.primary),
              BarChartRodStackItem(yPrin, yPrin + yInt,  AppColors.error.withOpacity(0.75)),
            ],
          ),
        ],
      ));
    }

    final bw = _calcTenure > 20 ? 7.0 : 12.0;
    final chartW = max(280.0, _calcTenure * (bw + 9));

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Annual EMI Breakdown',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 2),
            const Text('Principal vs Interest paid each year — tap a bar for details',
                style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
            const SizedBox(height: 12),
            Row(children: [
              _Legend(color: AppColors.primary,                  label: 'Principal'),
              const SizedBox(width: 16),
              _Legend(color: AppColors.error.withOpacity(0.75),  label: 'Interest'),
            ]),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: chartW,
                  child: BarChart(
                    BarChartData(
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          tooltipBgColor: Colors.black87,
                          getTooltipItem: (group, _, rod, __) {
                            // find principal portion from rodStackItems
                            final pAmt = rod.rodStackItems.isNotEmpty
                                ? rod.rodStackItems[0].toY
                                : 0.0;
                            final iAmt = rod.toY - pAmt;
                            return BarTooltipItem(
                              'Year ${group.x}\nPrincipal ₹ ${_fmt.format(pAmt.toInt())}\nInterest  ₹ ${_fmt.format(iAmt.toInt())}',
                              const TextStyle(color: Colors.white, fontSize: 10),
                            );
                          },
                        ),
                      ),
                      alignment: BarChartAlignment.spaceAround,
                      maxY: maxTotal * 1.15,
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 24,
                            getTitlesWidget: (v, _) {
                              final yr = v.toInt();
                              if (_calcTenure <= 10 || yr % 5 == 0 || yr == 1) {
                                return Text('$yr',
                                    style: const TextStyle(fontSize: 9, color: AppColors.textMuted));
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 44,
                            getTitlesWidget: (v, _) => Text(
                              '${(v / 100000).toStringAsFixed(0)}L',
                              style: const TextStyle(fontSize: 9, color: AppColors.textMuted),
                            ),
                          ),
                        ),
                        topTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: FlGridData(
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (_) =>
                            FlLine(color: AppColors.border.withOpacity(0.5), strokeWidth: 1),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: const Border(
                          bottom: BorderSide(color: AppColors.border),
                          left:   BorderSide(color: AppColors.border),
                        ),
                      ),
                      barGroups: groups,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
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
