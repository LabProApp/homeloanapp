import 'package:flutter/material.dart';
import 'package:property/models/bank_model.dart';
import 'package:property/theme/app_colors.dart';

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
              (a, b) =>
              (a.interestRate ?? double.infinity)
                  .compareTo(b.interestRate ?? double.infinity),
        );
      } else if (_sortBy == 'fee') {
        _banks.sort(
              (a, b) =>
              (a.processingFee ?? double.infinity)
                  .compareTo(b.processingFee ?? double.infinity),
        );
      } else if (_sortBy == 'amount') {
        _banks.sort(
              (a, b) =>
              (b.maxLoanAmount ?? 0)
                  .compareTo(a.maxLoanAmount ?? 0),
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
              DropdownMenuItem(
                value: 'amount',
                child: Text("Max Loan Amount"),
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

  /// 📊 Comparison Table
  Widget _table() {
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
          rows: [
            _row(
              "Interest Rate",
              _banks.map(
                    (b) => b.interestRate != null
                    ? "${b.interestRate}%"
                    : "--",
              ),
            ),
            _row(
              "Processing Fee",
              _banks.map(
                    (b) => b.processingFee != null
                    ? "₹${b.processingFee}"
                    : "--",
              ),
            ),
            _row(
              "Max Loan Amount",
              _banks.map(
                    (b) => b.maxLoanAmount != null
                    ? "₹${b.maxLoanAmount}"
                    : "--",
              ),
            ),
            _row(
              "Tenure",
              _banks.map(
                    (b) => b.tenureYears != null
                    ? "${b.tenureYears} yrs"
                    : "--",
              ),
            ),
            _row(
              "Min CIBIL",
              _banks.map(
                    (b) => b.minCibilScore?.toString() ?? "--",
              ),
            ),
          ],
        ),
      ),
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
