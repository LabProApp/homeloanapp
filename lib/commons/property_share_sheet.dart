import 'package:flutter/material.dart';

import '../models/property_model.dart';
import '../services/property_share_service.dart';
import '../theme/app_colors.dart';

/// Bottom sheet with per-channel share options for a property.
/// Usage:
///   showModalBottomSheet(context: context,
///     builder: (_) => PropertyShareSheet(property: p));
class PropertyShareSheet extends StatelessWidget {
  final PropertyModel property;

  const PropertyShareSheet({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Share Property',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            if ((property.title ?? '').isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                property.title!,
                style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _ShareOption(
                  icon: Icons.chat,
                  color: AppColors.whatsAppGreen,
                  label: 'WhatsApp',
                  onTap: () {
                    Navigator.pop(context);
                    PropertyShareService.shareViaWhatsApp(property);
                  },
                ),
                _ShareOption(
                  icon: Icons.email_outlined,
                  color: const Color(0xFF4285F4),
                  label: 'Email',
                  onTap: () {
                    Navigator.pop(context);
                    PropertyShareService.shareViaEmail(property);
                  },
                ),
                _ShareOption(
                  icon: Icons.sms_outlined,
                  color: const Color(0xFF34A853),
                  label: 'SMS',
                  onTap: () {
                    Navigator.pop(context);
                    PropertyShareService.shareViaSms(property);
                  },
                ),
                _ShareOption(
                  icon: Icons.copy,
                  color: AppColors.textSecondary,
                  label: 'Copy Link',
                  onTap: () async {
                    Navigator.pop(context);
                    await PropertyShareService.copyLink(property);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Link copied to clipboard')),
                      );
                    }
                  },
                ),
                _ShareOption(
                  icon: Icons.more_horiz,
                  color: AppColors.textMuted,
                  label: 'More',
                  onTap: () {
                    Navigator.pop(context);
                    PropertyShareService.shareNative(property);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ShareOption extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _ShareOption({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
