import 'package:flutter/material.dart';
import '../models/bank_model.dart';
import '../theme/app_colors.dart';
import 'package:intl/intl.dart';

class BankCompareDialog extends StatefulWidget {
  final List<Bank> banks;

  const BankCompareDialog({super.key, required this.banks});

  static void show(BuildContext context, List<Bank> banks) {
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => BankCompareDialog(banks: banks),
      ),
    );
  }

  @override
  State<BankCompareDialog> createState() => _BankCompareDialogState();
}

class _BankCompareDialogState extends State<BankCompareDialog> {
  late List<Bank> _banks;
  String _sortBy = 'interest';

  static final _fmt = NumberFormat('#,##,###');
  static final _fmtCompact = NumberFormat.compact(locale: 'en_IN');

  @override
  void initState() {
    super.initState();
    _banks = List.from(widget.banks);
    _sortBanks();
  }

  void _sortBanks() {
    setState(() {
      switch (_sortBy) {
        case 'interest':
          _banks.sort((a, b) => (a.bestInterestRate() ?? double.infinity)
              .compareTo(b.bestInterestRate() ?? double.infinity));
        case 'fee':
          _banks.sort((a, b) => (a.processingFee ?? double.infinity)
              .compareTo(b.processingFee ?? double.infinity));
        case 'tenure':
          _banks.sort(
              (a, b) => (b.tenureYears ?? 0).compareTo(a.tenureYears ?? 0));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bank Comparison'),
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          _sortChips(),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: _table(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sortChips() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          const Text('Sort:',
              style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500)),
          const SizedBox(width: 10),
          _chip('interest', 'Interest Rate'),
          const SizedBox(width: 8),
          _chip('fee', 'Processing Fee'),
          const SizedBox(width: 8),
          _chip('tenure', 'Tenure'),
        ],
      ),
    );
  }

  Widget _chip(String value, String label) {
    final selected = _sortBy == value;
    return GestureDetector(
      onTap: () {
        _sortBy = value;
        _sortBanks();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected ? AppColors.primary : Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _table() {
    final cibilRanges = <String>{};
    for (final bank in _banks) {
      for (final rate in bank.interestRates) {
        final range =
            '${rate.minCibil?.toInt() ?? 0}-${rate.maxCibil?.toInt() ?? 0}';
        cibilRanges.add(range);
      }
    }
    final sortedRanges = cibilRanges.toList()
      ..sort((a, b) {
        final minA = int.tryParse(a.split('-')[0]) ?? 0;
        final minB = int.tryParse(b.split('-')[0]) ?? 0;
        return minA.compareTo(minB);
      });

    return DataTable(
      columnSpacing: 28,
      headingRowColor:
          WidgetStateProperty.all(AppColors.primary.withOpacity(0.1)),
      columns: [
        const DataColumn(
            label: Text('Criteria',
                style: TextStyle(fontWeight: FontWeight.bold))),
        ..._banks.map(
          (bank) => DataColumn(
            label: Text(
              bank.bankName ?? '-',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
      rows: [
        _fixedRow(
          'Interest Rate',
          _banks.map((b) {
            final rate = b.bestInterestRate();
            return rate != null ? '${rate.toStringAsFixed(2)}%' : '--';
          }),
          highlightMin: true,
          lowerIsBetter: true,
        ),
        _fixedRow(
          'Tenure',
          _banks.map((b) =>
              b.tenureYears != null ? '${b.tenureYears} yrs' : '--'),
          highlightMin: true,
          lowerIsBetter: false,
        ),
        _fixedRow(
          'Processing Fee',
          _banks.map((b) => b.processingFee != null
              ? '₹${_fmt.format(b.processingFee)}'
              : '--'),
          highlightMin: true,
          lowerIsBetter: true,
        ),
        _fixedRow(
          'Min CIBIL Score',
          _banks.map((b) =>
              b.minCibilScore != null ? '${b.minCibilScore!.toInt()}+' : '--'),
          highlightMin: true,
          lowerIsBetter: true,
        ),
        _fixedRow(
          'Min Loan',
          _banks.map((b) => b.minLoanAmount != null
              ? '₹${_fmtCompact.format(b.minLoanAmount)}'
              : '--'),
        ),
        _fixedRow(
          'Max Loan',
          _banks.map((b) => b.maxLoanAmount != null
              ? '₹${_fmtCompact.format(b.maxLoanAmount)}'
              : '--'),
          highlightMin: true,
          lowerIsBetter: false,
        ),
        ...sortedRanges.map((range) => _cibilRow(range)),
      ],
    );
  }

  DataRow _fixedRow(
    String title,
    Iterable<String> values, {
    bool highlightMin = false,
    bool lowerIsBetter = true,
  }) {
    final list = values.toList();

    double? bestNum;
    if (highlightMin) {
      final nums = list
          .map((s) =>
              double.tryParse(s.replaceAll(RegExp(r'[₹%+a-zA-Z, ]'), '')))
          .whereType<double>()
          .toList();
      if (nums.isNotEmpty) {
        bestNum = lowerIsBetter
            ? nums.reduce((a, b) => a < b ? a : b)
            : nums.reduce((a, b) => a > b ? a : b);
      }
    }

    return DataRow(
      cells: [
        DataCell(Text(title,
            style: const TextStyle(fontWeight: FontWeight.w600))),
        ...list.map((v) {
          final num = double.tryParse(
              v.replaceAll(RegExp(r'[₹%+a-zA-Z, ]'), ''));
          final isBest =
              highlightMin && bestNum != null && num != null && num == bestNum;
          return DataCell(Text(
            v,
            style: TextStyle(
              fontWeight: isBest ? FontWeight.bold : FontWeight.normal,
              color: isBest ? AppColors.success : AppColors.textPrimary,
            ),
          ));
        }),
      ],
    );
  }

  DataRow _cibilRow(String range) {
    final parts = range.split('-');
    final min = double.tryParse(parts[0]) ?? 0;
    final max = double.tryParse(parts[1]) ?? 0;

    final rates = _banks.map((bank) {
      final rate = bank.interestRates.firstWhere(
        (r) => (r.minCibil ?? 0) <= max && (r.maxCibil ?? 0) >= min,
        orElse: () => const BankInterestRate(),
      );
      return rate.interestRate;
    }).toList();

    final minRate = rates.whereType<double>().fold<double>(
        double.infinity, (prev, e) => e < prev ? e : prev);

    return DataRow(
      cells: [
        DataCell(Text('CIBIL $range',
            style: const TextStyle(fontWeight: FontWeight.w600))),
        ...rates.map((rate) {
          final text = rate != null ? '${rate.toStringAsFixed(2)}%' : '--';
          final isBest = rate != null && rate == minRate;
          return DataCell(Text(
            text,
            style: TextStyle(
              fontWeight: isBest ? FontWeight.bold : FontWeight.normal,
              color: isBest ? AppColors.success : AppColors.textPrimary,
            ),
          ));
        }),
      ],
    );
  }
}
