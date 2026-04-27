import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/bank_model.dart';
import '../screens/bank_details_screen.dart';
import '../screens/bank_apply_loan_dialog.dart';
import '../theme/app_colors.dart';

class BankCard extends StatelessWidget {
  final Bank bank;
  final bool showCompareCheckbox;
  final bool isCompared;
  final ValueChanged<bool>? onCompareChanged;

  const BankCard({
    super.key,
    required this.bank,
    this.showCompareCheckbox = false,
    this.isCompared = false,
    this.onCompareChanged,
  });

  static final _fmt = NumberFormat('#,##,###');
  static final _fmtCompact = NumberFormat.compact(locale: 'en_IN');

  @override
  Widget build(BuildContext context) {
    final best = bank.bestInterestRate();
    final loanRange = _loanRange();

    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.08),
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isCompared
            ? const BorderSide(color: AppColors.primary, width: 2)
            : BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: showCompareCheckbox ? null : () => showBankDetailSheet(context, bank),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Logo + Name + Compare toggle ─────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _logo(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bank.bankName ?? 'Bank',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if ((bank.interestType ?? '').isNotEmpty)
                          Text(
                            bank.interestType!,
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.textMuted),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (showCompareCheckbox)
                    _compareChip()
                  else
                    const Icon(Icons.chevron_right_rounded,
                        color: AppColors.textMuted),
                ],
              ),

              const SizedBox(height: 14),

              // ── Key stats row ─────────────────────────────────────
              SizedBox(
                height: 52,
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

              // ── Processing fee + CIBIL tags ───────────────────────
              if (bank.processingFee != null || bank.minCibilScore != null) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 12,
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
              ],

              const SizedBox(height: 14),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // ── Action buttons ────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => showBankDetailSheet(context, bank),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        side: const BorderSide(color: AppColors.primary),
                        foregroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
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
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('Apply Now',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ),
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

  Widget _compareChip() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onCompareChanged?.call(!isCompared),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isCompared
              ? AppColors.primary.withOpacity(0.12)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isCompared ? AppColors.primary : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isCompared ? Icons.check_rounded : Icons.compare_arrows_rounded,
              size: 14,
              color: isCompared ? AppColors.primary : AppColors.textMuted,
            ),
            const SizedBox(width: 4),
            Text(
              isCompared ? 'Added' : 'Compare',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isCompared ? AppColors.primary : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _logo() {
    final url = bank.bankLogoUrl;
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: url != null && url.isNotEmpty
            ? Image.network(url,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => _logoFallback())
            : _logoFallback(),
      ),
    );
  }

  Widget _logoFallback() => Icon(Icons.account_balance_rounded,
      color: Colors.grey.shade400, size: 24);

  Widget _stat(String value, String label, {bool highlight = false}) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: highlight ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(label,
              style:
                  const TextStyle(fontSize: 11, color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _vDivider() => Container(
        width: 1,
        height: 36,
        color: Colors.grey.shade200,
        margin: const EdgeInsets.symmetric(horizontal: 4),
      );

  Widget _tag(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.textMuted),
        const SizedBox(width: 4),
        Text(text,
            style:
                const TextStyle(fontSize: 11, color: AppColors.textMuted)),
      ],
    );
  }
}
