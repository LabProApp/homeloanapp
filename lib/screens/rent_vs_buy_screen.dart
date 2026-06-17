import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../commons/common_widget.dart';
import '../utility/money_input_formatter.dart';

class RentVsBuyScreen extends StatefulWidget {
  final double? initialPropertyPrice;
  const RentVsBuyScreen({super.key, this.initialPropertyPrice});

  @override
  State<RentVsBuyScreen> createState() => _RentVsBuyScreenState();
}

class _RentVsBuyScreenState extends State<RentVsBuyScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  static final _fmt = NumberFormat('#,##,###');

  // Inputs
  final _propPriceCtrl    = TextEditingController();
  final _downPaymentCtrl  = TextEditingController();
  final _monthlyRentCtrl  = TextEditingController();
  final _currentSavingsCtrl = TextEditingController();

  double _loanRate        = 8.5;
  double _tenureYears     = 20;
  double _rentGrowthRate  = 5.0;
  double _propAppreciation = 7.0;
  double _investReturnRate = 10.0;

  _RentVsBuyResult? _result;

  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    if (widget.initialPropertyPrice != null) {
      _propPriceCtrl.text   = MoneyInputFormatter.format(widget.initialPropertyPrice!);
      _downPaymentCtrl.text = MoneyInputFormatter.format(widget.initialPropertyPrice! * 0.2);
    }
  }

  @override
  void dispose() {
    _tab.dispose();
    _propPriceCtrl.dispose();
    _downPaymentCtrl.dispose();
    _monthlyRentCtrl.dispose();
    _currentSavingsCtrl.dispose();
    super.dispose();
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final propPrice   = MoneyInputFormatter.parse(_propPriceCtrl.text) ?? 0;
    final downPayment = MoneyInputFormatter.parse(_downPaymentCtrl.text) ?? 0;
    final monthlyRent = MoneyInputFormatter.parse(_monthlyRentCtrl.text) ?? 0;
    final initSavings = MoneyInputFormatter.parse(_currentSavingsCtrl.text) ?? 0;

    if (propPrice <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter a valid property price')));
      return;
    }
    if (downPayment >= propPrice) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Down payment must be less than property price')));
      return;
    }
    if (monthlyRent <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter a valid monthly rent')));
      return;
    }

    final loanAmount    = propPrice - downPayment;
    final n             = (_tenureYears * 12).toInt();
    final r             = _loanRate / 100 / 12;

    // Monthly EMI
    final emi = loanAmount * r * math.pow(1 + r, n) / (math.pow(1 + r, n) - 1);

    // ── BUY scenario over tenure ──────────────────────────────────────────────
    final totalEmiPaid  = emi * n;
    final totalInterest = totalEmiPaid - loanAmount;
    // Stamp duty + registration (avg 7%)
    final registrationCost = propPrice * 0.07;
    // Annual maintenance (avg 1% of property value)
    final totalMaintenance = propPrice * 0.01 * _tenureYears;
    final totalBuyCost = downPayment + totalEmiPaid + registrationCost + totalMaintenance;

    // Property value at end of tenure
    final futurePropertyValue = propPrice * math.pow(1 + _propAppreciation / 100, _tenureYears);
    // Net wealth from buying (property value - total costs + savings on not renting)
    final buyNetWealth = futurePropertyValue - loanAmount;

    // ── RENT scenario over tenure ─────────────────────────────────────────────
    double totalRentPaid = 0;
    double currentRent   = monthlyRent;
    for (int year = 0; year < _tenureYears.toInt(); year++) {
      totalRentPaid += currentRent * 12;
      currentRent  *= (1 + _rentGrowthRate / 100);
    }

    // Monthly savings invested (EMI - rent difference, if positive, invested)
    final monthlySavingsDiff = emi - monthlyRent;
    // Down payment invested instead
    final dpFutureValue = (downPayment + initSavings) *
        math.pow(1 + _investReturnRate / 100, _tenureYears);
    // If EMI > rent, renter invests the difference monthly
    double investedDiff = 0;
    if (monthlySavingsDiff > 0) {
      final rm = _investReturnRate / 100 / 12;
      investedDiff = monthlySavingsDiff *
          (math.pow(1 + rm, n) - 1) / rm;
    }
    final rentTotalWealth = dpFutureValue + investedDiff;
    final rentNetCost     = totalRentPaid;

    final buyIsWinner = buyNetWealth >= rentTotalWealth;

    setState(() {
      _result = _RentVsBuyResult(
        propPrice: propPrice,
        downPayment: downPayment,
        loanAmount: loanAmount,
        emi: emi,
        totalEmiPaid: totalEmiPaid,
        totalInterest: totalInterest,
        registrationCost: registrationCost,
        totalMaintenance: totalMaintenance,
        totalBuyCost: totalBuyCost,
        futurePropertyValue: futurePropertyValue,
        buyNetWealth: buyNetWealth,
        monthlyRent: monthlyRent,
        totalRentPaid: totalRentPaid,
        rentTotalWealth: rentTotalWealth,
        monthlySavingsDiff: monthlySavingsDiff,
        initSavings: initSavings,
        tenureYears: _tenureYears.toInt(),
        buyIsWinner: buyIsWinner,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.listingbackground,
      appBar: GradientAppBar(title: 'Rent vs Buy Calculator'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _infoCard(),
          const SizedBox(height: 16),
          _inputsCard(),
          const SizedBox(height: 16),
          _assumptionsCard(),
          const SizedBox(height: 16),
          AppButton(text: 'Compare Now', onTap: _calculate),
          if (_result != null) ...[
            const SizedBox(height: 24),
            _verdictCard(_result!),
            const SizedBox(height: 16),
            _wealthChartCard(_result!),
            const SizedBox(height: 16),
            _comparisonTable(_result!),
            const SizedBox(height: 16),
            _wealthProjectionCard(_result!),
            const SizedBox(height: 16),
            _disclaimerCard(),
          ],
          const SizedBox(height: 32),
        ]),
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
      child: Row(children: [
        Icon(Icons.balance_outlined, color: AppColors.primary, size: 20),
        const SizedBox(width: 10),
        const Expanded(child: Text(
          'Compare the true financial impact of renting vs buying over the long term.',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        )),
      ]),
    );
  }

  Widget _inputsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Form(
        key: _formKey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Property & Rent Details',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 16),
          _numField(_propPriceCtrl,    'Property Price (₹)', 'e.g. 8000000'),
          const SizedBox(height: 12),
          _numField(_downPaymentCtrl,  'Down Payment (₹)', 'e.g. 1600000'),
          const SizedBox(height: 12),
          _numField(_monthlyRentCtrl,  'Current Monthly Rent (₹)', 'e.g. 25000'),
          const SizedBox(height: 12),
          _numField(_currentSavingsCtrl, 'Current Savings / Investments (₹)', 'Optional', required: false),
          const SizedBox(height: 12),
          _sliderRow('Loan Tenure', '${_tenureYears.toInt()} yrs', _tenureYears, 5, 30, 1,
              (v) => setState(() => _tenureYears = v)),
        ]),
      ),
    );
  }

  Widget _assumptionsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Expanded(child: Text('Rate Assumptions',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('Editable', style: TextStyle(fontSize: 10, color: AppColors.primary)),
          ),
        ]),
        const SizedBox(height: 14),
        _sliderRow('Home Loan Rate', '${_loanRate.toStringAsFixed(1)}%', _loanRate, 6.0, 14.0, 0.25,
            (v) => setState(() => _loanRate = v)),
        const SizedBox(height: 12),
        _sliderRow('Rent Inflation', '${_rentGrowthRate.toStringAsFixed(1)}%/yr', _rentGrowthRate, 2.0, 12.0, 0.5,
            (v) => setState(() => _rentGrowthRate = v)),
        const SizedBox(height: 12),
        _sliderRow('Property Appreciation', '${_propAppreciation.toStringAsFixed(1)}%/yr', _propAppreciation, 2.0, 15.0, 0.5,
            (v) => setState(() => _propAppreciation = v)),
        const SizedBox(height: 12),
        _sliderRow('Investment Return (Renter)', '${_investReturnRate.toStringAsFixed(1)}%/yr', _investReturnRate, 6.0, 18.0, 0.5,
            (v) => setState(() => _investReturnRate = v)),
      ]),
    );
  }

  Widget _numField(TextEditingController ctrl, String label, String hint, {bool required = true}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: TextInputType.number,
      inputFormatters: [MoneyInputFormatter()],
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: const Icon(Icons.currency_rupee, size: 18),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        isDense: true,
      ),
      validator: required
          ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null
          : null,
    );
  }

  Widget _sliderRow(String label, String value, double current, double min, double max, double divisions,
      ValueChanged<double> onChanged) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(value,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
        ),
      ]),
      SliderTheme(
        data: SliderTheme.of(context).copyWith(
          activeTrackColor: AppColors.primary,
          thumbColor: AppColors.primary,
          inactiveTrackColor: AppColors.border,
          overlayColor: AppColors.primary.withOpacity(0.1),
          trackHeight: 3,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
        ),
        child: Slider(
          value: current, min: min, max: max,
          divisions: ((max - min) / divisions).toInt(),
          onChanged: onChanged,
        ),
      ),
    ]);
  }

  Widget _verdictCard(_RentVsBuyResult r) {
    final winner = r.buyIsWinner ? 'Buying' : 'Renting';
    final diff   = (r.buyNetWealth - r.rentTotalWealth).abs();
    final color  = r.buyIsWinner ? const Color(0xFF1565C0) : const Color(0xFF2E7D32);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.75)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(r.buyIsWinner ? Icons.home : Icons.apartment, color: Colors.white, size: 28),
          const SizedBox(width: 10),
          Text('$winner Wins!',
              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
        ]),
        const SizedBox(height: 8),
        Text(
          r.buyIsWinner
              ? 'Over ${r.tenureYears} years, buying builds ₹${_fmt.format(diff.toInt())} more wealth than renting.'
              : 'Over ${r.tenureYears} years, renting + investing builds ₹${_fmt.format(diff.toInt())} more wealth than buying.',
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        const SizedBox(height: 12),
        Row(children: [
          _verdictStat('Buy Wealth', '₹ ${_fmt.format(r.buyNetWealth.toInt())}'),
          const SizedBox(width: 24),
          _verdictStat('Rent Wealth', '₹ ${_fmt.format(r.rentTotalWealth.toInt())}'),
        ]),
      ]),
    );
  }

  Widget _verdictStat(String label, String value) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
      Text(value, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
    ]);
  }

  Widget _comparisonTable(_RentVsBuyResult r) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Cost Breakdown',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
        const SizedBox(height: 14),

        // Header
        Row(children: [
          const Expanded(flex: 3, child: SizedBox()),
          Expanded(flex: 2, child: Center(child: Text('BUY',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF1565C0))))),
          Expanded(flex: 2, child: Center(child: Text('RENT',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF2E7D32))))),
        ]),
        const Divider(height: 16),

        _tableRow('Monthly Outflow',
            '₹ ${_fmt.format(r.emi.toInt())}',
            '₹ ${_fmt.format(r.monthlyRent.toInt())}'),
        _tableRow('Total Paid (${r.tenureYears}y)',
            '₹ ${_fmt.format(r.totalBuyCost.toInt())}',
            '₹ ${_fmt.format(r.totalRentPaid.toInt())}'),
        _tableRow('Interest Paid',
            '₹ ${_fmt.format(r.totalInterest.toInt())}', '—'),
        _tableRow('Stamp + Reg (~7%)',
            '₹ ${_fmt.format(r.registrationCost.toInt())}', '—'),
        _tableRow('Maintenance (1%/yr)',
            '₹ ${_fmt.format(r.totalMaintenance.toInt())}', '—'),
        const Divider(height: 16),
        _tableRow('Property Value (${r.tenureYears}y)',
            '₹ ${_fmt.format(r.futurePropertyValue.toInt())}', '—',
            highlight: true),
        _tableRow('Net Wealth',
            '₹ ${_fmt.format(r.buyNetWealth.toInt())}',
            '₹ ${_fmt.format(r.rentTotalWealth.toInt())}',
            highlight: true),
      ]),
    );
  }

  Widget _tableRow(String label, String buyVal, String rentVal, {bool highlight = false}) {
    final style = TextStyle(
      fontSize: highlight ? 13 : 12,
      fontWeight: highlight ? FontWeight.w700 : FontWeight.normal,
      color: highlight ? AppColors.textPrimary : AppColors.textSecondary,
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        Expanded(flex: 3, child: Text(label, style: style)),
        Expanded(flex: 2, child: Center(child: Text(buyVal,
            style: style.copyWith(color: const Color(0xFF1565C0))))),
        Expanded(flex: 2, child: Center(child: Text(rentVal,
            style: style.copyWith(color: const Color(0xFF2E7D32))))),
      ]),
    );
  }

  Widget _wealthProjectionCard(_RentVsBuyResult r) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Key Insights', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
        const SizedBox(height: 12),
        _insightRow(Icons.home_outlined, const Color(0xFF1565C0),
            'Monthly EMI',
            '₹ ${_fmt.format(r.emi.toInt())} for ${r.tenureYears} years'),
        _insightRow(Icons.trending_up_outlined, const Color(0xFF2E7D32),
            'Property Value after ${r.tenureYears}y',
            '₹ ${_fmt.format(r.futurePropertyValue.toInt())}'),
        if (r.monthlySavingsDiff > 0)
          _insightRow(Icons.savings_outlined, const Color(0xFF6A1B9A),
              'Renter invests extra monthly',
              '₹ ${_fmt.format(r.monthlySavingsDiff.toInt())} (EMI - rent)'),
        _insightRow(Icons.percent_outlined, const Color(0xFFE65100),
            'Break-even assumption',
            'Property appreciation @ ${_propAppreciation.toStringAsFixed(1)}% vs investments @ ${_investReturnRate.toStringAsFixed(1)}%'),
      ]),
    );
  }

  Widget _insightRow(IconData icon, Color color, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ])),
      ]),
    );
  }

  String _shortFmt(double v) {
    if (v >= 1e7) return '₹${(v / 1e7).toStringAsFixed(1)}Cr';
    if (v >= 1e5) return '₹${(v / 1e5).toStringAsFixed(0)}L';
    return '₹${_fmt.format(v.toInt())}';
  }

  Widget _wealthChartCard(_RentVsBuyResult r) {
    final n       = r.tenureYears * 12;
    final rMonth  = _loanRate / 100 / 12;
    final rm      = _investReturnRate / 100 / 12;
    final pow1rn  = math.pow(1 + rMonth, n);

    final List<FlSpot> buySpots  = [];
    final List<FlSpot> rentSpots = [];

    for (int y = 0; y <= r.tenureYears; y++) {
      // Buy equity: appreciation of property minus outstanding loan balance
      final propValue = r.propPrice * math.pow(1 + _propAppreciation / 100, y);
      double loanBalance = 0;
      if (y > 0 && y < r.tenureYears) {
        final monthsPaid = y * 12;
        final pow1rm = math.pow(1 + rMonth, monthsPaid);
        loanBalance = r.loanAmount * (pow1rn - pow1rm) / (pow1rn - 1);
      }
      buySpots.add(FlSpot(y.toDouble(), propValue - loanBalance));

      // Rent wealth: invested down payment + compounding monthly-diff investments
      final investedDP = (r.downPayment + r.initSavings) *
          math.pow(1 + _investReturnRate / 100, y);
      double investedDiff = 0;
      if (r.monthlySavingsDiff > 0 && y > 0) {
        investedDiff = r.monthlySavingsDiff *
            (math.pow(1 + rm, y * 12) - 1) / rm;
      }
      rentSpots.add(FlSpot(y.toDouble(), investedDP + investedDiff));
    }

    final allVals  = [...buySpots.map((s) => s.y), ...rentSpots.map((s) => s.y)];
    final maxVal   = allVals.reduce(math.max) * 1.15;
    final interval = maxVal / 4;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Wealth Growth Over Time',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
        const SizedBox(height: 2),
        Text('Year-by-year equity vs invest-and-rent wealth',
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        const SizedBox(height: 12),
        Row(children: [
          _wealthLegend(const Color(0xFF1565C0), 'Buy Equity'),
          const SizedBox(width: 20),
          _wealthLegend(const Color(0xFF2E7D32), 'Rent + Invest'),
        ]),
        const SizedBox(height: 16),
        SizedBox(
          height: 220,
          child: LineChart(LineChartData(
            minX: 0,
            maxX: r.tenureYears.toDouble(),
            minY: 0,
            maxY: maxVal,
            clipData: const FlClipData.all(),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: interval,
              getDrawingHorizontalLine: (_) => FlLine(
                color: Colors.grey.withOpacity(0.15),
                strokeWidth: 1,
              ),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border(
                bottom: BorderSide(color: Colors.grey.withOpacity(0.3)),
                left: BorderSide(color: Colors.grey.withOpacity(0.3)),
              ),
            ),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 24,
                  interval: (r.tenureYears / 5).ceilToDouble(),
                  getTitlesWidget: (v, _) => Text(
                    'Yr ${v.toInt()}',
                    style: const TextStyle(fontSize: 9, color: AppColors.textSecondary),
                  ),
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 52,
                  interval: interval,
                  getTitlesWidget: (v, _) => Text(
                    _shortFmt(v),
                    style: const TextStyle(fontSize: 9, color: AppColors.textSecondary),
                  ),
                ),
              ),
            ),
            lineTouchData: LineTouchData(
              handleBuiltInTouches: true,
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (_) => Colors.black87,
                getTooltipItems: (spots) => spots.map((s) {
                  final label = s.barIndex == 0 ? 'Buy' : 'Rent';
                  return LineTooltipItem(
                    '$label Yr ${s.x.toInt()}\n${_shortFmt(s.y)}',
                    const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600),
                  );
                }).toList(),
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: buySpots,
                isCurved: true,
                color: const Color(0xFF1565C0),
                barWidth: 2.5,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF1565C0).withOpacity(0.18),
                      const Color(0xFF1565C0).withOpacity(0.0),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              LineChartBarData(
                spots: rentSpots,
                isCurved: true,
                color: const Color(0xFF2E7D32),
                barWidth: 2.5,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF2E7D32).withOpacity(0.18),
                      const Color(0xFF2E7D32).withOpacity(0.0),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
          )),
        ),
      ]),
    );
  }

  Widget _wealthLegend(Color color, String label) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 20,
        height: 3,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      const SizedBox(width: 6),
      Text(label,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
    ]);
  }

  Widget _disclaimerCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFFCC02).withOpacity(0.6)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.info_outline, color: Color(0xFFE65100), size: 16),
        const SizedBox(width: 8),
        const Expanded(child: Text(
          'This is a simplified model for illustrative purposes. Actual returns depend on location, '
          'market conditions, tax benefits (Section 24, 80C), opportunity cost, and personal circumstances. '
          'Consult a financial advisor before deciding.',
          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
        )),
      ]),
    );
  }
}

class _RentVsBuyResult {
  final double propPrice, downPayment, loanAmount;
  final double emi, totalEmiPaid, totalInterest;
  final double registrationCost, totalMaintenance, totalBuyCost;
  final double futurePropertyValue, buyNetWealth;
  final double monthlyRent, totalRentPaid, rentTotalWealth;
  final double monthlySavingsDiff;
  final double initSavings;
  final int tenureYears;
  final bool buyIsWinner;

  const _RentVsBuyResult({
    required this.propPrice, required this.downPayment, required this.loanAmount,
    required this.emi, required this.totalEmiPaid, required this.totalInterest,
    required this.registrationCost, required this.totalMaintenance, required this.totalBuyCost,
    required this.futurePropertyValue, required this.buyNetWealth,
    required this.monthlyRent, required this.totalRentPaid, required this.rentTotalWealth,
    required this.monthlySavingsDiff, required this.initSavings,
    required this.tenureYears, required this.buyIsWinner,
  });
}
