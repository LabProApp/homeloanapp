import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// =======================
/// APP COLORS (Orange + Brown)
/// =======================
class AppColors {
  static const primary = Color(0xFFB45309);      // Dark Brown
  static const secondary = Color(0xFFF59E0B);    // Orange
  static const lightBrown = Color(0xFFFDE68A);   // Light Brown / Cream
  static const success = Color(0xFF15803D);      // Green
  static const danger = Color(0xFFDC2626);       // Red
  static const background = Color(0xFFFFFBF5);   // Off white
  static const card = Colors.white;
  static const textDark = Color(0xFF3F2E1C);
  static const textMuted = Color(0xFF7C6A55);
}

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
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 3,
                      color: Colors.black26,
                    ),
                  ],
                ),
              ),
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

                  /// QUICK STATS
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
                                  value: '₹${_formatAmount(bank.processingFee)}',
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

                  /// CONTACT INFO
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
                          onPressed: () => _launchPhone(bank.contactNumber),
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
                          onPressed: () => _launchWebsite(bank.websiteUrl),
                        )
                            : null,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  /// LOAN DETAILS
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

                  /// FEATURES
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
                        isEnabled: bank.balanceTransferAvailable ?? false,
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.lightBrown,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
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
                Text(label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    )),
                Text(value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textDark,
                    )),
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
            color: isEnabled ? AppColors.success : AppColors.danger,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textDark,
              ),
            ),
          ),
          Text(
            isEnabled ? 'Yes' : 'No',
            style: TextStyle(
              color: isEnabled ? AppColors.success : AppColors.danger,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
