import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:property/theme/app_colors.dart';
import 'package:property/screens/cibilrow_bank.dart';

class CibilInterestCard extends StatelessWidget {
  final double baseRate;

  const CibilInterestCard({required this.baseRate});

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
                    color: AppColors.accent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.credit_score,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Interest Rate by CIBIL Score',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          CibilRow(
            range: '750 – 900',
            rate: '${baseRate.toStringAsFixed(2)}%',
            tag: 'Best',
            color: AppColors.success,
          ),
          CibilRow(
            range: '700 – 749',
            rate: '${(baseRate + 0.30).toStringAsFixed(2)}%',
            tag: 'Good',
            color: AppColors.secondary,
          ),
          CibilRow(
            range: '650 – 699',
            rate: '${(baseRate + 0.75).toStringAsFixed(2)}%',
            tag: 'Average',
            color: AppColors.warning,
          ),
          CibilRow(
            range: '< 650',
            rate: '${(baseRate + 1.50).toStringAsFixed(2)}%',
            tag: 'High Risk',
            color: AppColors.error,
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              'Interest rates are indicative and may vary based on profile & documents.',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
