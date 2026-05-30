import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/bank_model.dart';
import '../screens/bank_details_screen.dart';
import '../screens/bank_apply_loan_dialog.dart';
import '../theme/app_colors.dart';

class BankCard extends StatelessWidget {
  final Bank bank;
  final bool isSelected;
  final ValueChanged<bool>? onSelectionChanged;
  final VoidCallback? onNavigateToEmi;

  const BankCard({
    super.key,
    required this.bank,
    this.isSelected = false,
    this.onSelectionChanged,
    this.onNavigateToEmi,
  });

  static final _fmt = NumberFormat('#,##,###');
  static final _fmtCompact = NumberFormat.compact(locale: 'en_IN');

  @override
  Widget build(BuildContext context) {
    final best = bank.bestInterestRate();
    final loanRange = _loanRange();

    return Card(
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.10),
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: isSelected
            ? const BorderSide(color: AppColors.primary, width: 2)
            : const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => showBankDetailSheet(context, bank,
            onNavigateToEmi: onNavigateToEmi),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Logo + Name + Checkbox ──────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _logo(),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bank.bankName ?? 'Bank',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if ((bank.interestType ?? '').isNotEmpty)
                          Text(
                            bank.interestType!,
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.textMuted),
                          ),
                      ],
                    ),
                  ),
                  if (onSelectionChanged != null)
                    Checkbox(
                      value: isSelected,
                      onChanged: (v) => onSelectionChanged?.call(v ?? false),
                      activeColor: AppColors.primary,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    )
                  else
                    const Icon(Icons.chevron_right_rounded,
                        color: AppColors.textMuted),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Key stats row ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: SizedBox(
                height: 64,
                child: Row(
                  children: [
                    _stat('${best?.toStringAsFixed(2) ?? '-'}%', 'Interest',
                        highlight: true),
                    _vDivider(),
                    _stat('${bank.tenureYears ?? '-'} yrs', 'Tenure'),
                    if (loanRange != null) ...[
                      _vDivider(),
                      _stat(loanRange, 'Loan Range'),
                    ],
                  ],
                ),
              ),
            ),

            // ── Processing fee + CIBIL tags ─────────────────────────
            if (bank.processingFee != null || bank.minCibilScore != null) ...[
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Wrap(
                  spacing: 14,
                  runSpacing: 4,
                  children: [
                    if (bank.processingFee != null)
                      _tag(Icons.receipt_long_outlined,
                          '₹${_fmt.format(bank.processingFee)} fee'),
                    if (bank.minCibilScore != null)
                      _tag(Icons.credit_score_outlined,
                          'CIBIL ${bank.minCibilScore!.toInt()}+'),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            // ── Translucent action strip ────────────────────────────
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary.withOpacity(0.03),
                    AppColors.primary.withOpacity(0.08),
                  ],
                ),
                border: Border(
                  top: BorderSide(
                      color: AppColors.primary.withOpacity(0.12)),
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => showBankDetailSheet(context, bank,
                          onNavigateToEmi: onNavigateToEmi),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: AppColors.primary),
                        foregroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('View Details',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => LoanApplySheet.show(context),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('Apply Now',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _loanRange() {
    final min = bank.minLoanAmount;
    final max = bank.maxLoanAmount;
    if (min == null && max == null) return null;
    if (min != null && max != null) {
      return '${_fmtCompact.format(min)}–${_fmtCompact.format(max)}';
    }
    if (max != null) return 'up to ${_fmtCompact.format(max)}';
    return '${_fmtCompact.format(min!)}+';
  }

  Widget _logo() {
    final url = bank.bankLogoUrl;
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: AppColors.surfaceSubtle,
        border: Border.all(color: AppColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: url != null && url.isNotEmpty
            ? Image.network(url,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => _logoFallback())
            : _logoFallback(),
      ),
    );
  }

  Widget _logoFallback() => const Icon(Icons.account_balance_rounded,
      color: AppColors.textMuted, size: 28);

  Widget _stat(String value, String label, {bool highlight = false}) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: highlight ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 3),
          Text(label,
              style:
                  const TextStyle(fontSize: 12, color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _vDivider() => Container(
        width: 1,
        height: 40,
        color: AppColors.border,
        margin: const EdgeInsets.symmetric(horizontal: 6),
      );

  Widget _tag(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textMuted),
        const SizedBox(width: 5),
        Text(text,
            style:
                const TextStyle(fontSize: 12, color: AppColors.textMuted)),
      ],
    );
  }
}
