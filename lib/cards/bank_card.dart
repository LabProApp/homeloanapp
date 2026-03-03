import 'package:flutter/material.dart';
import '../models/bank_model.dart';
import '../screens/bankDetails_screen.dart';
import '../screens/bank_applyLoan_dialog.dart';
import '../theme/app_colors.dart';
import '../commons/common_widget.dart'; // For AppButton

class BankCard extends StatelessWidget {
  final Bank bank;

  /// Compare support
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: AppColors.primary.withOpacity(0.08),
      elevation: 0.8,
      shadowColor: Colors.black.withOpacity(0.08),
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: Colors.grey.shade200,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          showBankDetailSheet(context, bank);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// HEADER ROW
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _bankLogo(),
                  const SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      bank.bankName ?? "Bank",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  if (showCompareCheckbox)
                    Column(
                      children: [
                        Checkbox(
                          value: isCompared,
                          activeColor: AppColors.primary,
                          onChanged: (v) =>
                              onCompareChanged?.call(v ?? false),
                        ),
                        const Text(
                          "Compare",
                          style: TextStyle(fontSize: 11),
                        ),
                      ],
                    )
                  else
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 26,
                      color: Colors.grey.shade500,
                    ),
                ],
              ),

              const SizedBox(height: 14),

              /// INFO ROW
              Row(
                children: [
                  _info("Interest Rate", "${bank.interestRate ?? '-'}%"),
                  const SizedBox(width: 12),
                  _info("Tenure", "${bank.tenureYears ?? '-'} yrs"),
                ],
              ),

              const SizedBox(height: 14),

              Divider(color: AppColors.primary),

              const SizedBox(height: 12),

              /// APPLY BUTTON using AppButton
              AppButton(
                text: "Apply Now",
                onTap: () => LoanApplySheet.show(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// BANK LOGO
  Widget _bankLogo() {
    final logoUrl = bank.bankLogoUrl;

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade100,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: logoUrl != null && logoUrl.isNotEmpty
            ? Image.network(
          logoUrl,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => _logoPlaceholder(),
        )
            : _logoPlaceholder(),
      ),
    );
  }

  Widget _logoPlaceholder() {
    return Icon(
      Icons.account_balance_rounded,
      size: 26,
      color: Colors.grey.shade500,
    );
  }

  Widget _info(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
