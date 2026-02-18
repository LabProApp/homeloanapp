import 'package:flutter/material.dart';
import '../models/bank_model.dart';
import 'package:intl/intl.dart';
import '../screens/emi_calculator_screen.dart';
import '../screens/bank_applyLoan_dialog.dart';
import '../theme/app_colors.dart';

/// =======================
/// BANK DETAIL PAGE
/// =======================
class BankDetailPage extends StatelessWidget {
  final dynamic bank;

  const BankDetailPage({super.key, required this.bank});

  static const double sectionGap = 16;

  @override
  Widget build(BuildContext context) {
    final List<BankInterestRate> interestRates =
        bank.interestRates ?? [];

    return Scaffold(
      backgroundColor: const Color(0xffFFF7F0),

      /// FIXED BOTTOM BUTTON
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => LoanApplyDialog.show(context),
            icon: const Icon(
              Icons.flash_on_rounded,
              size: 18,
              color: Colors.white,
            ),
            label: const Text(
              "Apply Now",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),

      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                bank.bankName ?? 'Bank Details',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(offset: Offset(0, 1), blurRadius: 3),
                  ],
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.deepOrange, Colors.orange],
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.account_balance,
                      size: 80, color: Colors.white70),
                ),
              ),
            ),
          ),

          /// =======================
          /// CONTENT
          /// =======================
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [

                  /// QUICK STATS
                  _sectionWrapper(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                icon: Icons.percent,
                                title: 'Interest Rate',
                                value: '${bank.interestRate ?? '-'}%',
                                subtitle:
                                bank.interestType ?? 'Floating',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatCard(
                                icon: Icons.calendar_today,
                                title: 'Tenure',
                                value: '${bank.tenureYears ?? '-'}',
                                subtitle: 'Years',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                icon: Icons.currency_rupee,
                                title: 'Processing Fee',
                                value:
                                '₹${NumberFormat('#,##,###').format(bank.processingFee ?? 0)}',
                                subtitle: 'One-time',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatCard(
                                icon: Icons.credit_score,
                                title: 'Min Cibil Score',
                                value:
                                '${bank.minCibilScore ?? '-'}',
                                subtitle: 'Required',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: sectionGap),

                  /// INTEREST RATE TABLE
                  _SectionCard(
                    title: 'Interest Rate by Cibil Score',

                    children: [
                      if (interestRates.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('No data available'),
                        )
                      else
                        Table(
                          border: TableBorder.all(
                              color: Colors.orange.shade200),
                          children: [
                            const TableRow(
                              decoration: BoxDecoration(
                                  color: Colors.orange),
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Text('Cibil Score Range',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight:
                                          FontWeight.bold)),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Text('Rate',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight:
                                          FontWeight.bold)),
                                ),
                              ],
                            ),
                            ..._buildInterestRows(interestRates),
                          ],
                        ),
                    ],
                  ),

                  const SizedBox(height: sectionGap),

                  /// DOCUMENTS
                  _SectionCard(
                    title: 'Documents Required',
                    children: [
                      if (bank.requiredDocuments != null &&
                          bank.requiredDocuments!.isNotEmpty)
                        ...bank.requiredDocuments!
                            .split(',')
                            .map(
                              (doc) => _DetailRow(
                            icon: Icons.circle,
                            label: '',
                            value: doc.trim(),
                          ),
                        )
                      else
                        const _DetailRow(
                          icon: Icons.document_scanner,
                          label: '',
                          value: 'As per bank requirement',
                        ),
                    ],
                  ),

                  const SizedBox(height: sectionGap),

                  /// EMI CALCULATOR LINK
                  _SectionCard(
                    title: 'Tools',
                    children: [
                      ListTile(
                        leading:
                        const Icon(Icons.calculate, color: AppColors.listingbackground),
                        title: const Text("EMI Calculator"),
                        trailing:
                        const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                              const EmiCalculatorScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: sectionGap),

                  /// FEATURES
                  _SectionCard(
                    title: 'Features & Benefits',
                    children: [
                      _FeatureRow(
                          label: 'Prepayment Allowed',
                          isEnabled:
                          bank.prepaymentAllowed ?? false),
                      _FeatureRow(
                          label: 'Part Payment Allowed',
                          isEnabled:
                          bank.partPaymentAllowed ?? false),
                      _FeatureRow(
                          label: 'Balance Transfer',
                          isEnabled:
                          bank.balanceTransferAvailable ??
                              false),
                      _FeatureRow(
                          label: 'Insurance Bundled',
                          isEnabled:
                          bank.insuranceBundled ?? false),
                    ],
                  ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static List<TableRow> _buildInterestRows(
      List<BankInterestRate> rates) {
    rates.sort((a, b) =>
        (a.interestRate ?? double.infinity)
            .compareTo(b.interestRate ?? double.infinity));

    final best = rates.first.interestRate;

    return rates.map((rate) {
      final isBest = rate.interestRate == best;

      return TableRow(
        decoration: BoxDecoration(
          color:
          isBest ? Colors.orange.shade50 : Colors.transparent,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
                '${rate.minCibil ?? '-'} - ${rate.maxCibil ?? '-'}'),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text('${rate.interestRate ?? '-'} %'),
          ),
        ],
      );
    }).toList();
  }
}

/// =======================
/// COMMON UI
/// =======================

Widget _sectionWrapper({required Widget child}) {
  return Card(
    shape:
    RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: child,
    ),
  );
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;

  const _StatCard(
      {required this.icon,
        required this.title,
        required this.value,
        required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border:
        Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.orange),
          const SizedBox(height: 6),
          Text(title, textAlign: TextAlign.center),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.bold)),
          Text(subtitle,
              style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard(
      {required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.orange),
                const SizedBox(width: 8),
                Text(title,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow(
      {required this.icon,
        required this.label,
        required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 6, color: Colors.orange),
          const SizedBox(width: 10),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final String label;
  final bool isEnabled;

  const _FeatureRow(
      {required this.label, required this.isEnabled});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(isEnabled ? Icons.check_circle : Icons.cancel,
              color: isEnabled ? Colors.green : Colors.red),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          Text(isEnabled ? 'Yes' : 'No'),
        ],
      ),
    );
  }
}
