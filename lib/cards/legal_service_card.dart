import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/legal_service_model.dart';
import '../commons/common_widget.dart'; // Import AppButton

class LegalServiceCard extends StatelessWidget {
  final LegalService service;
  final VoidCallback onCall;
  final VoidCallback onWhatsApp;

  const LegalServiceCard({
    super.key,
    required this.service,
    required this.onCall,
    required this.onWhatsApp,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.primary.withOpacity(0.08),
      elevation: 0.8,
      shadowColor: Colors.black.withOpacity(0.08),
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// HEADER
            Row(
              children: [
                _Avatar(letter: service.legalName),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.legalName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "${service.city}, ${service.state}",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            /// SERVICES CHIPS
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: service.services
                  .map(
                    (s) => Chip(
                  label: Text(
                    s,
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: Colors.grey.shade100,
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              )
                  .toList(),
            ),

            const SizedBox(height: 12),
            Divider(height: 1, color: Colors.grey.shade300),
            const SizedBox(height: 14),

            /// ACTIONS (using AppButton)
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: "Call",

                    onTap: onCall,

                    height: 44,

                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    text: "WhatsApp",

                    onTap: onWhatsApp,

                    height: 44,

                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------------- AVATAR ----------------

class _Avatar extends StatelessWidget {
  final String letter;

  const _Avatar({required this.letter});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Center(
        child: Text(
          letter[0].toUpperCase(),
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
