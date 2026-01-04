import 'package:flutter/material.dart';
import 'package:property/models/bank_model.dart';
import 'package:property/screens/bankDetails_screen.dart';
import 'package:property/screens/bank_applyLoan_dialog.dart';
import 'package:property/theme/app_colors.dart';

class BankCard extends StatelessWidget {
  final Bank bank;

  /// ✅ Compare support
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
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BankDetailPage(bank: bank),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🏦 LOGO + NAME + COMPARE
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
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  /// ✅ Compare Checkbox
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
                          style: TextStyle(fontSize: 10),
                        ),
                      ],
                    )
                  else
                    Icon(
                      Icons.chevron_right,
                      size: 28,
                      color: Colors.grey.shade600,
                    ),
                ],
              ),

              const SizedBox(height: 14),

              /// 📊 INFO ROW
              Row(
                children: [
                  _info(
                    "Starting Interest",
                    "${bank.interestRate ?? '-'}%",
                  ),
                  const SizedBox(width: 12),
                  _info(
                    "Max Tenure",
                    "${bank.tenureYears ?? '-'} yrs",
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// ⚡ APPLY NOW BUTTON
              SizedBox(
                width: double.infinity,
                height: 50,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => LoanApplyDialog.show(context),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withOpacity(0.85),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.flash_on_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Apply Now",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🖼️ BANK LOGO WITH PLACEHOLDER
  Widget _bankLogo() {
    final logoUrl = bank.bankLogoUrl;

    return Container(
      width: 48,
      height: 48,
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
      Icons.account_balance,
      size: 28,
      color: Colors.grey.shade500,
    );
  }

  Widget _info(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
