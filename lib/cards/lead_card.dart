import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../commons/common_util.dart';
import '../theme/app_colors.dart';

class LeadCard extends StatelessWidget {
  final Map lead;
  final VoidCallback onEdit;
  final VoidCallback onFollowUp;

  const LeadCard({
    super.key,
    required this.lead,
    required this.onEdit,
    required this.onFollowUp,
  });

  static final _dateFmt = DateFormat('dd MMM yyyy');
  static final _fmt     = NumberFormat('#,##,###');

  String _fmt(String? d) {
    if (d == null || d.isEmpty) return '-';
    try {
      return _dateFmt.format(DateTime.parse(d));
    } catch (_) {
      return d;
    }
  }

  String get _initials {
    final name = (lead['clientName'] ?? '') as String;
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (parts[0].isNotEmpty) return parts[0][0].toUpperCase();
    return '?';
  }

  // Human-readable label for leadType enum value
  String _leadTypeLabel(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    switch (raw) {
      case 'PROPERTY_INQUIRY':    return 'Property';
      case 'HOME_LOAN':           return 'Home Loan';
      case 'LAP':                 return 'LAP';
      case 'BALANCE_TRANSFER':    return 'Balance Transfer';
      case 'LOAN_TRANSFER':       return 'Loan Transfer';
      case 'PROPERTY_REGISTRATION': return 'Registration';
      case 'RENT_AGREEMENT':      return 'Rent';
      case 'DOCUMENT_SERVICES':   return 'Documents';
      case 'BUY_HOME':            return 'Buy Home';
      case 'SELL_HOME':           return 'Sell Home';
      case 'HOME_RENTAL':         return 'Home Rental';
      case 'COMMERCIAL':          return 'Commercial';
      default:                    return raw.replaceAll('_', ' ');
    }
  }

  Color _leadTypeColor(String? raw) {
    switch (raw) {
      case 'PROPERTY_INQUIRY':    return AppColors.primary;
      case 'HOME_LOAN':           return AppColors.info;
      case 'LAP':                 return const Color(0xFF7B61FF);
      case 'BALANCE_TRANSFER':    return AppColors.warning;
      case 'LOAN_TRANSFER':       return const Color(0xFFFF6B35);
      case 'PROPERTY_REGISTRATION':
      case 'RENT_AGREEMENT':
      case 'DOCUMENT_SERVICES':   return AppColors.textMuted;
      case 'BUY_HOME':            return const Color(0xFF2E7D32);
      case 'SELL_HOME':           return const Color(0xFFFF6B35);
      case 'HOME_RENTAL':         return const Color(0xFF00838F);
      case 'COMMERCIAL':          return const Color(0xFF4527A0);
      default:                    return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final status   = (lead['status']   ?? '') as String;
    final leadType = lead['leadType']  as String?;
    final phone    = lead['mobile']    as String?;
    final followUp = _fmt(lead['nextFollowUpDate'] as String?);
    final hasFollowUp = followUp != '-';
    final message = (lead['message'] ?? '') as String;
    final remark  = (lead['remark']  ?? '') as String;

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

          // ── Header ─────────────────────────────────────────────────────────
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
                        Text(phone,
                            style: tt.bodySmall?.copyWith(color: AppColors.textMuted)),
                    ],
                  ),
                ),
                // Lead type badge
                if (leadType != null && leadType.isNotEmpty) ...[
                  _TypeBadge(_leadTypeLabel(leadType), _leadTypeColor(leadType)),
                  const SizedBox(width: 6),
                ],
                // Status badge
                _StatusBadge(status),
                const SizedBox(width: 4),
                // Edit button
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

          // ── Property info ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow(Icons.home_outlined, lead['propertyTitle'] ?? '-', bold: true),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: _InfoRow(Icons.location_on_outlined,
                          [lead['propertyCity'], lead['propertyLocality']]
                              .whereType<String>()
                              .where((s) => s.isNotEmpty)
                              .join(', ')
                              .takeIf((s) => s.isNotEmpty) ?? '-'),
                    ),
                    if (lead['propertyPrice'] != null)
                      _InfoRow(Icons.currency_rupee_outlined,
                          _fmt.format(lead['propertyPrice'])),
                  ],
                ),
                if ((lead['budget'] ?? lead['preferredBudget']) != null) ...[
                  const SizedBox(height: 4),
                  _InfoRow(Icons.account_balance_wallet_outlined,
                    'Budget ₹${_fmt.format(lead['budget'] ?? lead['preferredBudget'])}'),
                ],
                if (message.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  _InfoRow(Icons.chat_bubble_outline, message,
                      maxLines: 2, color: AppColors.textSecondary),
                ],
              ],
            ),
          ),

          const Divider(height: 1, thickness: 1, color: AppColors.border),

          // ── Timeline ───────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: _InfoRow(Icons.calendar_today_outlined,
                      'Inquiry: ${_fmt(lead['inquiryDate'] as String?)}'),
                ),
                if (hasFollowUp)
                  _FollowUpBadge(followUp),
              ],
            ),
          ),

          if (remark.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: _InfoRow(Icons.notes_outlined, remark,
                  maxLines: 2, color: AppColors.textMuted),
            ),

          // ── Action buttons ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Row(
              children: [
                // Call
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.call_outlined, size: 15),
                    label: const Text('Call'),
                    style: _btnStyle(),
                    onPressed: phone != null ? () => AppUtils.call(phone) : null,
                  ),
                ),
                const SizedBox(width: 6),
                // WhatsApp
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.chat_outlined, size: 15),
                    label: const Text('WhatsApp'),
                    style: _btnStyle(color: const Color(0xFF25D366)),
                    onPressed: phone != null
                        ? () => AppUtils.whatsapp(phone,
                            'Hi ${lead['clientName'] ?? ''}, following up on your inquiry.')
                        : null,
                  ),
                ),
                const SizedBox(width: 6),
                // Follow Up — 99acres-style compact button
                _FollowUpButton(onPressed: onFollowUp, hasFollowUp: hasFollowUp),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static ButtonStyle _btnStyle({Color? color}) => OutlinedButton.styleFrom(
        foregroundColor: color ?? AppColors.primary,
        side: BorderSide(color: (color ?? AppColors.primary).withOpacity(0.4)),
        minimumSize: const Size(0, 34),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      );
}

// ── Follow Up compact button ──────────────────────────────────────────────────

class _FollowUpButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool hasFollowUp;

  const _FollowUpButton({required this.onPressed, required this.hasFollowUp});

  @override
  Widget build(BuildContext context) {
    final color = hasFollowUp ? AppColors.warning : AppColors.primary;
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasFollowUp ? Icons.alarm_on_outlined : Icons.alarm_add_outlined,
              size: 14,
              color: color,
            ),
            const SizedBox(width: 4),
            Text(
              'Follow Up',
              style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w700, color: color),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Follow-up scheduled badge ─────────────────────────────────────────────────

class _FollowUpBadge extends StatelessWidget {
  final String date;
  const _FollowUpBadge(this.date);

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Text(date,
              style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.warning,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ── Status badge ──────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge(this.status);

  Color get _color {
    switch (status) {
      case 'NEW':           return AppColors.info;
      case 'CONTACTED':     return AppColors.warning;
      case 'VISIT_PLANNED': return const Color(0xFF7B61FF);
      case 'VISIT_DONE':    return const Color(0xFF2E7D32);
      case 'NEGOTIATING':   return const Color(0xFFFF6B35);
      case 'CLOSED_WON':    return AppColors.success;
      case 'CLOSED_LOST':   return AppColors.error;
      case 'DROPPED':       return AppColors.textMuted;
      default:              return AppColors.textMuted;
    }
  }

  String get _label => status.isEmpty ? '-' : status.replaceAll('_', ' ');

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
        _label,
        style: TextStyle(color: _color, fontSize: 10, fontWeight: FontWeight.w700),
      ),
    );
  }
}

// ── Lead type badge ───────────────────────────────────────────────────────────

class _TypeBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _TypeBadge(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w700),
      ),
    );
  }
}

// ── Info row ──────────────────────────────────────────────────────────────────

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

extension _StringExt on String {
  String? takeIf(bool Function(String) pred) => pred(this) ? this : null;
}
