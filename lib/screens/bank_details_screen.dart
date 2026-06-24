import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/bank_model.dart';
import '../screens/bank_apply_loan_dialog.dart';
import '../theme/app_colors.dart';
import '../commons/common_widget.dart';
import 'package:url_launcher/url_launcher.dart';

void showBankDetailSheet(BuildContext context, Bank bank,
    {VoidCallback? onNavigateToEmi}) {
  showModalBottomSheet(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.95,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: BankDetailPage(
          bank: bank,
          scrollController: controller,
          onNavigateToEmi: onNavigateToEmi,
        ),
      ),
    ),
  );
}

class BankDetailPage extends StatelessWidget {
  final Bank bank;
  final ScrollController? scrollController;
  final VoidCallback? onNavigateToEmi;

  const BankDetailPage({
    super.key,
    required this.bank,
    this.scrollController,
    this.onNavigateToEmi,
  });

  static const double sectionGap = 16;
  static final _fmt = NumberFormat('#,##,###');
  static final _fmtCompact = NumberFormat.compact(locale: 'en_IN');

  @override
  Widget build(BuildContext context) {
    final List<BankInterestRate> interestRates = bank.interestRates;

    return Scaffold(
      backgroundColor: AppColors.listingbackground,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: AppButton(
            text: "Apply Now",
            onTap: () => LoanApplySheet.show(context),
          ),
        ),
      ),
      body: CustomScrollView(
        controller: scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── App Bar ──────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              titlePadding: const EdgeInsets.only(bottom: 16),
              title: Text(
                bank.bankName ?? 'Bank Details',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [Shadow(offset: Offset(0, 1), blurRadius: 3)],
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.warning],
                  ),
                ),
                child: Center(
                  child: _buildLogoOrIcon(),
                ),
              ),
            ),
          ),

          // ── Content ───────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [

                  // Quick Stats
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _StatCard(
                                  icon: Icons.percent,
                                  title: 'Interest Rate',
                                  value: '${bank.bestInterestRate()?.toStringAsFixed(2) ?? bank.interestRate ?? '-'}%',
                                  subtitle: bank.interestType ?? 'Floating',
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
                                  value: bank.processingFee != null
                                      ? '₹${_fmt.format(bank.processingFee)}'
                                      : '-',
                                  subtitle: 'One-time',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _StatCard(
                                  icon: Icons.credit_score,
                                  title: 'Min CIBIL Score',
                                  value: bank.minCibilScore != null
                                      ? '${bank.minCibilScore!.toInt()}+'
                                      : '-',
                                  subtitle: 'Required',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: sectionGap),

                  // About the Bank
                  if ((bank.details ?? '').isNotEmpty) ...[
                    _SectionCard(
                      icon: Icons.info_outline_rounded,
                      title: 'About',
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                          child: Text(
                            bank.details!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: sectionGap),
                  ],

                  // Loan Details
                  if (_hasLoanDetails()) ...[
                    _SectionCard(
                      icon: Icons.account_balance_wallet_outlined,
                      title: 'Loan Details',
                      children: [
                        if (bank.minLoanAmount != null)
                          _DetailRow(
                            icon: Icons.arrow_downward_rounded,
                            label: 'Min Loan Amount',
                            value: '₹${_fmtCompact.format(bank.minLoanAmount)}',
                          ),
                        if (bank.maxLoanAmount != null)
                          _DetailRow(
                            icon: Icons.arrow_upward_rounded,
                            label: 'Max Loan Amount',
                            value: '₹${_fmtCompact.format(bank.maxLoanAmount)}',
                          ),
                        if (bank.minimumIncome != null)
                          _DetailRow(
                            icon: Icons.currency_rupee,
                            label: 'Min Monthly Income',
                            value: '₹${_fmt.format(bank.minimumIncome)}',
                          ),
                        if ((bank.employmentType ?? '').isNotEmpty)
                          _DetailRow(
                            icon: Icons.work_outline_rounded,
                            label: 'Employment Type',
                            value: bank.employmentType!,
                          ),
                        if (bank.minimumAge != null || bank.maximumAge != null)
                          _DetailRow(
                            icon: Icons.person_outline_rounded,
                            label: 'Age Range',
                            value:
                                '${bank.minimumAge ?? '-'} – ${bank.maximumAge ?? '-'} years',
                          ),
                      ],
                    ),
                    const SizedBox(height: sectionGap),
                  ],

                  // Interest Rate Table
                  _SectionCard(
                    icon: Icons.bar_chart_rounded,
                    title: 'Interest Rate by CIBIL Score',
                    children: [
                      if (interestRates.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('No rate data available',
                              style: TextStyle(color: AppColors.textMuted)),
                        )
                      else
                        Table(
                          border: TableBorder.all(color: AppColors.border),
                          children: [
                            TableRow(
                              decoration: const BoxDecoration(color: AppColors.primary),
                              children: const [
                                Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Text('CIBIL Score Range',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600)),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Text('Rate',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600)),
                                ),
                              ],
                            ),
                            ..._buildInterestRows(interestRates),
                          ],
                        ),
                    ],
                  ),

                  const SizedBox(height: sectionGap),

                  // Features & Benefits
                  _SectionCard(
                    icon: Icons.verified_outlined,
                    title: 'Features & Benefits',
                    children: [
                      _FeatureRow(
                          label: 'Prepayment Allowed',
                          isEnabled: bank.prepaymentAllowed ?? false),
                      _FeatureRow(
                          label: 'Part Payment Allowed',
                          isEnabled: bank.partPaymentAllowed ?? false),
                      _FeatureRow(
                          label: 'Balance Transfer',
                          isEnabled: bank.balanceTransferAvailable ?? false),
                      _FeatureRow(
                          label: 'Insurance Bundled',
                          isEnabled: bank.insuranceBundled ?? false),
                    ],
                  ),

                  const SizedBox(height: sectionGap),

                  // Special Offers
                  if ((bank.specialOffers ?? '').isNotEmpty) ...[
                    _SectionCard(
                      icon: Icons.local_offer_outlined,
                      title: 'Special Offers',
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.star_rounded,
                                  color: AppColors.warning, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  bank.specialOffers!,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: sectionGap),
                  ],

                  // Documents Required
                  _SectionCard(
                    icon: Icons.folder_outlined,
                    title: 'Documents Required',
                    children: [
                      if (bank.requiredDocuments != null &&
                          bank.requiredDocuments!.isNotEmpty)
                        ...bank.requiredDocuments!
                            .split(',')
                            .map((doc) => _DetailRow(
                                  icon: Icons.circle,
                                  label: '',
                                  value: doc.trim(),
                                ))
                      else
                        const _DetailRow(
                          icon: Icons.document_scanner,
                          label: '',
                          value: 'As per bank requirement',
                        ),
                    ],
                  ),

                  // Contact
                  if (_hasContactInfo()) ...[
                    const SizedBox(height: sectionGap),
                    _SectionCard(
                      icon: Icons.contacts_outlined,
                      title: 'Contact & Branch',
                      children: [
                        if ((bank.contactName ?? '').isNotEmpty)
                          _DetailRow(
                              icon: Icons.person_outline_rounded,
                              label: 'Contact',
                              value: bank.contactName!),
                        if ((bank.contactNumber ?? '').isNotEmpty)
                          _TappableDetailRow(
                            icon: Icons.phone_outlined,
                            label: 'Phone',
                            value: bank.contactNumber!,
                            onTap: () =>
                                launchUrl(Uri.parse('tel:${bank.contactNumber}')),
                          ),
                        if ((bank.email ?? '').isNotEmpty)
                          _TappableDetailRow(
                            icon: Icons.email_outlined,
                            label: 'Email',
                            value: bank.email!,
                            onTap: () =>
                                launchUrl(Uri.parse('mailto:${bank.email}')),
                          ),
                        if ((bank.websiteUrl ?? '').isNotEmpty)
                          _TappableDetailRow(
                            icon: Icons.language_rounded,
                            label: 'Website',
                            value: bank.websiteUrl!,
                            onTap: () => launchUrl(
                              Uri.parse(bank.websiteUrl!),
                              mode: LaunchMode.externalApplication,
                            ),
                          ),
                        if ((bank.branchName ?? '').isNotEmpty)
                          _DetailRow(
                              icon: Icons.account_balance_outlined,
                              label: 'Branch',
                              value: bank.branchName!),
                        if ((bank.locationAddress ?? '').isNotEmpty)
                          _DetailRow(
                              icon: Icons.location_on_outlined,
                              label: 'Address',
                              value: bank.locationAddress!),
                      ],
                    ),
                  ],

                  const SizedBox(height: sectionGap),

                  // Tools
                  _SectionCard(
                    icon: Icons.calculate_outlined,
                    title: 'Tools',
                    children: [
                      ListTile(
                        leading:
                            const Icon(Icons.calculate, color: AppColors.primary),
                        title: const Text('EMI Calculator'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.of(context).pop();
                          onNavigateToEmi?.call();
                        },
                      ),
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

  bool _hasLoanDetails() =>
      bank.minLoanAmount != null ||
      bank.maxLoanAmount != null ||
      bank.minimumIncome != null ||
      (bank.employmentType ?? '').isNotEmpty ||
      bank.minimumAge != null ||
      bank.maximumAge != null;

  bool _hasContactInfo() =>
      (bank.contactName ?? '').isNotEmpty ||
      (bank.contactNumber ?? '').isNotEmpty ||
      (bank.email ?? '').isNotEmpty ||
      (bank.websiteUrl ?? '').isNotEmpty ||
      (bank.branchName ?? '').isNotEmpty ||
      (bank.locationAddress ?? '').isNotEmpty;

  Widget _buildLogoOrIcon() {
    final url = bank.bankLogoUrl;
    if (url != null && url.isNotEmpty) {
      return Container(
        width: 88,
        height: 88,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(10),
        child: Image.network(
          url,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.account_balance, size: 56, color: Colors.white70),
        ),
      );
    }
    return const Icon(Icons.account_balance, size: 80, color: Colors.white70);
  }

  static List<TableRow> _buildInterestRows(List<BankInterestRate> rates) {
    final sorted = List<BankInterestRate>.from(rates)
      ..sort((a, b) => (a.interestRate ?? double.infinity)
          .compareTo(b.interestRate ?? double.infinity));
    final best = sorted.first.interestRate;

    return sorted.map((rate) {
      final isBest = rate.interestRate == best;
      return TableRow(
        decoration: BoxDecoration(
            color: isBest ? AppColors.highlightBg : Colors.transparent),
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text('${rate.minCibil?.toInt() ?? '-'} – ${rate.maxCibil?.toInt() ?? '-'}'),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              '${rate.interestRate ?? '-'} %',
              style: isBest
                  ? const TextStyle(
                      fontWeight: FontWeight.bold, color: AppColors.primary)
                  : null,
            ),
          ),
        ],
      );
    }).toList();
  }
}

// ── Shared UI Components ─────────────────────────────────────────────────────

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
        color: AppColors.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.18)),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(height: 6),
          Text(title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary)),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          Text(subtitle,
              style:
                  const TextStyle(fontSize: 11, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final IconData? icon;

  const _SectionCard(
      {required this.title, required this.children, this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon ?? Icons.star_rounded, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(title,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
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
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 10),
          if (label.isNotEmpty) ...[
            SizedBox(
              width: 130,
              child: Text(label,
                  style: const TextStyle(
                      color: AppColors.textMuted, fontSize: 13)),
            ),
          ],
          Expanded(
              child: Text(value,
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textPrimary))),
        ],
      ),
    );
  }
}

class _TappableDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _TappableDetailRow(
      {required this.icon,
      required this.label,
      required this.value,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 10),
            SizedBox(
              width: 130,
              child: Text(label,
                  style: const TextStyle(
                      color: AppColors.textMuted, fontSize: 13)),
            ),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.primary,
                    decoration: TextDecoration.underline),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.open_in_new, size: 14, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final String label;
  final bool isEnabled;

  const _FeatureRow({required this.label, required this.isEnabled});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(
            isEnabled ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: isEnabled ? AppColors.success : AppColors.error,
          ),
          const SizedBox(width: 12),
          Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textPrimary))),
          Text(
            isEnabled ? 'Yes' : 'No',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isEnabled ? AppColors.success : AppColors.error),
          ),
        ],
      ),
    );
  }
}
