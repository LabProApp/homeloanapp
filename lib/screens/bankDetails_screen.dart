import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_colors.dart';
import '../models/bank_model.dart';
import 'package:intl/intl.dart';
/// =======================
/// BANK DETAIL PAGE
/// =======================
class BankDetailPage extends StatelessWidget {
  final dynamic bank;

  const BankDetailPage({super.key, required this.bank});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(), // ✅ Bouncy scroll
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.primary,
            centerTitle: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                bank.bankName ?? 'Bank Details',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 3,
                      color: AppColors.textPrimary,
                    ),
                  ],

                ),
              ),
              centerTitle: true,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.secondary,
                      AppColors.primary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.account_balance,
                    size: 80,
                    color: Colors.white70,
                  ),
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

                  /// =======================
                  /// QUICK STATS
                  /// =======================
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _StatCard(
                                  icon: Icons.percent,
                                  title: 'Starting Interest Rate',
                                  value: '${bank.interestRate}%',
                                  subtitle: bank.interestType ?? 'Floating',
                                  color: AppColors.secondary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _StatCard(
                                  icon: Icons.calendar_today,
                                  title: 'Max Tenure',
                                  value: '${bank.tenureYears}',
                                  subtitle: 'Years',
                                  color: AppColors.primary,
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
                                  value: '₹${NumberFormat('#,##,###.##').format(bank.processingFee)}',
                                  subtitle: 'One-time',
                                  color: AppColors.secondary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _StatCard(
                                  icon: Icons.credit_score,
                                  title: 'Min CIBIL',
                                  value: '${bank.minCibilScore}',
                                  subtitle: 'Required',
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// =======================
                  /// CIBIL INTEREST RATE CARD  ✅ NEW
                  /// =======================
                  _SectionCard(
                    title: 'Interest Rate by CIBIL Score',
                    icon: Icons.credit_score,
                    children: [
                      if (bank.interestRates.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'Interest rate details not available',
                            style: TextStyle(color: AppColors.textMuted),
                          ),
                        )
                      else
                        Table(
                          border: TableBorder.all(
                            color: AppColors.textMuted.withOpacity(0.2),
                            width: 1,
                          ),
                          columnWidths: const {
                            0: FlexColumnWidth(2),
                            1: FlexColumnWidth(1),
                          },
                          children: [
                            // Header row
                            const TableRow(
                              decoration: BoxDecoration(color: AppColors.primary),
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'CIBIL Score Range',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Interest Rate',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // Data rows
                            ..._buildInterestRows(bank.interestRates),
                          ],
                        ),
                    ],
                  ),


                  const SizedBox(height: 16),

                  /// =======================
                  /// DOCUMENTS REQUIRED
                  /// =======================
                  _SectionCard(
                    title: 'Documents Required',
                    icon: Icons.folder,
                    children: [
                      if (bank.requiredDocuments != null && bank.requiredDocuments!.isNotEmpty)
                        ...bank.requiredDocuments!
                            .split(',')
                            .map(
                              (doc) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.circle, size: 2, color: AppColors.textMuted),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    doc.trim(),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                            .toList()
                      else
                        _DetailRow(
                          icon: Icons.document_scanner,
                          label: 'Required Documents',
                          value: 'As per bank requirement',
                        ),
                    ],
                  ),




                  const SizedBox(height: 16),

                  /// =======================
                  /// CONTACT INFO
                  /// =======================
                  _SectionCard(
                    title: 'Contact Information',
                    icon: Icons.contact_phone,
                    children: [
                      _DetailRow(
                        icon: Icons.person,
                        label: 'Contact Person',
                        value: bank.contactName ?? 'N/A',
                      ),
                      _DetailRow(
                        icon: Icons.phone,
                        label: 'Phone',
                        value: bank.contactNumber ?? 'N/A',
                        trailing: bank.contactNumber != null
                            ? IconButton(
                          icon: const Icon(Icons.call),
                          color: AppColors.primary,
                          onPressed: () =>
                              _launchPhone(bank.contactNumber),
                        )
                            : null,
                      ),
                      _DetailRow(
                        icon: Icons.email,
                        label: 'Email',
                        value: bank.email ?? 'N/A',
                        trailing: bank.email != null
                            ? IconButton(
                          icon: const Icon(Icons.email),
                          color: AppColors.primary,
                          onPressed: () => _launchEmail(bank.email),
                        )
                            : null,
                      ),
                      _DetailRow(
                        icon: Icons.language,
                        label: 'Website',
                        value: bank.websiteUrl ?? 'N/A',
                        trailing: bank.websiteUrl != null
                            ? IconButton(
                          icon: const Icon(Icons.open_in_browser),
                          color: AppColors.primary,
                          onPressed: () =>
                              _launchWebsite(bank.websiteUrl),
                        )
                            : null,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  /// =======================
                  /// LOAN DETAILS
                  /// =======================
                  _SectionCard(
                    title: 'Loan Details',
                    icon: Icons.account_balance_wallet,
                    children: [
                      _DetailRow(
                        icon: Icons.arrow_upward,
                        label: 'Max Loan Amount',
                        value: '₹${_formatAmount(bank.maxLoanAmount)}',
                      ),
                      _DetailRow(
                        icon: Icons.arrow_downward,
                        label: 'Min Loan Amount',
                        value: '₹${_formatAmount(bank.minLoanAmount)}',
                      ),
                      _DetailRow(
                        icon: Icons.work,
                        label: 'Employment Type',
                        value: bank.employmentType ?? 'N/A',
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  /// =======================
                  /// FEATURES
                  /// =======================
                  _SectionCard(
                    title: 'Features & Benefits',
                    icon: Icons.star,
                    children: [
                      _FeatureRow(
                        label: 'Prepayment Allowed',
                        isEnabled: bank.prepaymentAllowed ?? false,
                      ),
                      _FeatureRow(
                        label: 'Part Payment Allowed',
                        isEnabled: bank.partPaymentAllowed ?? false,
                      ),
                      _FeatureRow(
                        label: 'Balance Transfer',
                        isEnabled:
                        bank.balanceTransferAvailable ?? false,
                      ),
                      _FeatureRow(
                        label: 'Insurance Bundled',
                        isEnabled: bank.insuranceBundled ?? false,
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// =======================
  /// HELPERS
  /// =======================
  static String _formatAmount(double? amount) {
    if (amount == null) return 'N/A';
    if (amount >= 10000000) {
      return '${(amount / 10000000).toStringAsFixed(2)} Cr';
    } else if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(2)} L';
    }
    return amount.toStringAsFixed(0);
  }

  static void _launchPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  static void _launchEmail(String email) async {
    final uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  static void _launchWebsite(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

/// =======================
/// STAT CARD
/// =======================
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

/// =======================
/// SECTION CARD
/// =======================
class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
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
/// =======================
/// DETAIL ROW
/// =======================
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Widget? trailing;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textMuted),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// =======================
/// FEATURE ROW
/// =======================
class _FeatureRow extends StatelessWidget {
  final String label;
  final bool isEnabled;

  const _FeatureRow({
    required this.label,
    required this.isEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(
            isEnabled ? Icons.check_circle : Icons.cancel,
            color: isEnabled ? AppColors.success : AppColors.error,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            isEnabled ? 'Yes' : 'No',
            style: TextStyle(
              color: isEnabled ? AppColors.success : AppColors.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
List<TableRow> _buildInterestRows(List<BankInterestRate> rates) {
  if (rates.isEmpty) return [];

  // Sort by lowest interest
  rates.sort((a, b) => (a.interestRate ?? double.infinity)
      .compareTo(b.interestRate ?? double.infinity));

  // Highlight the best (lowest) interest
  final bestRate = rates.first.interestRate ?? 0;

  return rates.map((rate) {
    final isBest = (rate.interestRate ?? 0) == bestRate;

    return TableRow(
      decoration: BoxDecoration(
        color: isBest ? AppColors.secondary.withOpacity(0.15) : Colors.transparent,
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            '${rate.minCibil?.toInt() ?? '-'} - ${rate.maxCibil?.toInt() ?? '-'}',
            style: TextStyle(
              fontWeight: isBest ? FontWeight.bold : FontWeight.normal,
              color: isBest ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            '${rate.interestRate?.toStringAsFixed(2) ?? '-'} %',
            style: TextStyle(
              fontWeight: isBest ? FontWeight.bold : FontWeight.normal,
              color: isBest ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }).toList();
}
