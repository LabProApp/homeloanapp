import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../commons/common_util.dart';
import '../theme/app_colors.dart';

class LeadCard extends StatelessWidget {
  final Map lead;
  final VoidCallback onEdit;

  const LeadCard({super.key, required this.lead, required this.onEdit});

  static final _dateFmt = DateFormat('dd MMM yyyy');

  String _fmt(String? d) {
    if (d == null || d.isEmpty) return '-';
    try { return _dateFmt.format(DateTime.parse(d)); } catch (_) { return d; }
  }

  String get _initials {
    final name = (lead['clientName'] ?? '') as String;
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (parts[0].isNotEmpty) return parts[0][0].toUpperCase();
    return '?';
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final status = (lead['status'] ?? '') as String;
    final phone = lead['mobile'] as String?;
    final followUp = _fmt(lead['nextFollowUpDate'] as String?);
    final hasFollowUp = followUp != '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(color: AppColors.shadowLight, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Header ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 8, 10),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(_initials, style: const TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    )),
                  ),
                ),
                const SizedBox(width: 10),
                // Name + contact
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lead['clientName'] ?? 'Client',
                        style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (phone != null && phone.isNotEmpty)
                        Text(phone, style: tt.bodySmall?.copyWith(color: AppColors.textMuted)),
                    ],
                  ),
                ),
                // Status + edit
                _StatusBadge(status),
                const SizedBox(width: 4),
                InkWell(
                  onTap: onEdit,
                  borderRadius: BorderRadius.circular(8),
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, thickness: 1, color: AppColors.border),

          // ── Property info ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow(Icons.home_outlined, lead['propertyTitle'] ?? '-', bold: true),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(child: _InfoRow(Icons.location_on_outlined, lead['propertyCity'] ?? '-')),
                    if (lead['propertyPrice'] != null)
                      _InfoRow(Icons.currency_rupee_outlined,
                          NumberFormat('#,##,###').format(lead['propertyPrice'])),
                  ],
                ),
                if (lead['preferredPropertyType'] != null) ...[
                  const SizedBox(height: 4),
                  Row(children: [
                    Expanded(child: _InfoRow(Icons.tune_outlined, lead['preferredPropertyType'])),
                    if (lead['preferredBudget'] != null)
                      _InfoRow(Icons.account_balance_wallet_outlined,
                          'Budget ₹${NumberFormat('#,##,###').format(lead['preferredBudget'])}'),
                  ]),
                ],
              ],
            ),
          ),

          const Divider(height: 1, thickness: 1, color: AppColors.border),

          // ── Timeline & source ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: _InfoRow(Icons.calendar_today_outlined,
                      'Inquiry: ${_fmt(lead['inquiryDate'] as String?)}'),
                ),
                if (hasFollowUp)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.alarm_outlined, size: 12, color: AppColors.warning),
                        const SizedBox(width: 4),
                        Text(followUp, style: const TextStyle(
                          fontSize: 11, color: AppColors.warning, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          if (lead['remark'] != null && (lead['remark'] as String).isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: _InfoRow(Icons.notes_outlined, lead['remark'] as String,
                  maxLines: 2, color: AppColors.textMuted),
            ),
          ],

          // ── Action buttons ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.call_outlined, size: 16),
                    label: const Text('Call'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 36),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: phone != null ? () => AppUtils.call(phone) : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.chat_outlined, size: 16),
                    label: const Text('WhatsApp'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 36),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: phone != null
                        ? () => AppUtils.whatsapp(phone, 'Hi, following up on your inquiry.')
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge(this.status);

  Color get _color {
    switch (status) {
      case 'NEW': return AppColors.info;
      case 'CONTACTED': return AppColors.warning;
      case 'CLOSED': return AppColors.success;
      case 'DROPPED': return AppColors.error;
      default: return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withOpacity(0.3)),
      ),
      child: Text(
        status.isEmpty ? '-' : status,
        style: TextStyle(color: _color, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool bold;
  final int maxLines;
  final Color? color;

  const _InfoRow(this.icon, this.text,
      {this.bold = false, this.maxLines = 1, this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color ?? AppColors.textMuted),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            text,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: color ?? AppColors.textSecondary,
              fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}
