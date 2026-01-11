import 'package:flutter/material.dart';
import '../models/bank_model.dart';
import '../theme/app_colors.dart';
import 'package:intl/intl.dart';
class BankCompareDialog extends StatefulWidget {
  final List<Bank> banks;

  const BankCompareDialog({
    super.key,
    required this.banks,
  });

  static void show(BuildContext context, List<Bank> banks) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => BankCompareDialog(banks: banks),
    );
  }

  @override
  State<BankCompareDialog> createState() => _BankCompareDialogState();
}

class _BankCompareDialogState extends State<BankCompareDialog> {
  late List<Bank> _banks;
  String _sortBy = 'interest';

  @override
  void initState() {
    super.initState();
    _banks = List.from(widget.banks);
    _sortBanks();
  }

  void _sortBanks() {
    setState(() {
      if (_sortBy == 'interest') {
        _banks.sort(
              (a, b) => (a.interestRate ?? double.infinity)
              .compareTo(b.interestRate ?? double.infinity),
        );
      } else if (_sortBy == 'fee') {
        _banks.sort(
              (a, b) => (a.processingFee ?? double.infinity)
              .compareTo(b.processingFee ?? double.infinity),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Dialog(
      insetPadding: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SizedBox(
        width: width * 0.95,
        height: height * 0.8,
        child: Column(
          children: [
            _header(context),
            _sortBar(),
            const Divider(height: 1),
            Expanded(child: _table()),
          ],
        ),
      ),
    );
  }

  /// 🔝 Header
  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              "Bank Comparison",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  /// 🔽 Sorting
  Widget _sortBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Text("Sort by: "),
          const SizedBox(width: 12),
          DropdownButton<String>(
            value: _sortBy,
            items: const [
              DropdownMenuItem(
                value: 'interest',
                child: Text("Interest Rate"),
              ),
              DropdownMenuItem(
                value: 'fee',
                child: Text("Processing Fee"),
              ),
            ],
            onChanged: (value) {
              if (value == null) return;
              _sortBy = value;
              _sortBanks();
            },
          ),
        ],
      ),
    );
  }

  /// 📊 Comparison Table with Processing Fee + CIBIL-wise interest rates
  Widget _table() {
    // Collect all unique CIBIL ranges
    final cibilRanges = <String>{};
    for (final bank in _banks) {
      for (final rate in bank.interestRates) {
        final range =
            "${rate.minCibil?.toInt() ?? 0}-${rate.maxCibil?.toInt() ?? 0}";
        cibilRanges.add(range);
      }
    }

    final sortedRanges = cibilRanges.toList()
      ..sort((a, b) {
        final minA = int.parse(a.split('-')[0]);
        final minB = int.parse(b.split('-')[0]);
        return minA.compareTo(minB);
      });

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          columnSpacing: 28,
          headingRowColor: MaterialStateProperty.all(
            AppColors.primary.withOpacity(0.1),
          ),
          columns: [
            const DataColumn(
              label: Text(
                "Criteria",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ..._banks.map(
                  (bank) => DataColumn(
                label: Text(
                  bank.bankName ?? "-",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
          // First row = Processing Fee
          rows: [
            _row(
              "Processing Fee",
              _banks.map((b) =>
              b.processingFee != null ? "₹${NumberFormat('#,##,###.##').format(b.processingFee)}" : "--"),
            ),
            // Next rows = CIBIL-wise interest rates
            ...sortedRanges.map((range) => _cibilRow(range)).toList(),
          ],
        ),
      ),
    );
  }

  /// Generate a row for a CIBIL range with highlighting
  DataRow _cibilRow(String range) {
    final parts = range.split('-');
    final min = double.tryParse(parts[0]) ?? 0;
    final max = double.tryParse(parts[1]) ?? 0;

    // Collect rates for all banks for this range
    final rates = _banks.map((bank) {
      final rate = bank.interestRates.firstWhere(
            (r) => (r.minCibil ?? 0) <= max && (r.maxCibil ?? 0) >= min,
        orElse: () => BankInterestRate(interestRate: null),
      );
      return rate.interestRate;
    }).toList();

    // Find the minimum rate to highlight
    final minRate = rates.whereType<double>().fold<double>(
        double.infinity, (prev, e) => e < prev ? e : prev);

    return DataRow(
      cells: [
        DataCell(
          Text(
            range,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        ...rates.map((rate) {
          final text = rate != null ? "${rate.toStringAsFixed(2)}%" : "--";
          final isBest = rate != null && rate == minRate;
          return DataCell(
            Text(
              text,
              style: TextStyle(
                fontWeight: isBest ? FontWeight.bold : FontWeight.normal,
                color: isBest ? Colors.green : AppColors.textPrimary,
              ),
            ),
          );
        }),
      ],
    );
  }

  DataRow _row(String title, Iterable<String> values) {
    return DataRow(
      cells: [
        DataCell(
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        ...values.map((v) => DataCell(Text(v))),
      ],
    );
  }
}
