import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../services/leads_service.dart';
import '../commons/common_util.dart';
import '../commons/common_widget.dart';

/// Shows all users who have expressed interest in a specific property.
/// Navigate to this from the property detail screen.
class PropertyLeadsScreen extends StatefulWidget {
  final int propertyId;
  final String propertyTitle;

  const PropertyLeadsScreen({
    super.key,
    required this.propertyId,
    required this.propertyTitle,
  });

  @override
  State<PropertyLeadsScreen> createState() => _PropertyLeadsScreenState();
}

class _PropertyLeadsScreenState extends State<PropertyLeadsScreen> {
  List<dynamic> _leads = [];
  bool _loading = true;

  static final _dateFmt = DateFormat('dd MMM yyyy');

  static const _statusColors = <String, Color>{
    'NEW':            AppColors.info,
    'CONTACTED':      AppColors.warning,
    'INTERESTED':     Color(0xFF2E7D32),
    'NOT_INTERESTED': AppColors.error,
    'CONVERTED':      AppColors.success,
    'CLOSED':         AppColors.textMuted,
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await LeadApiService.fetchPropertyLeads(widget.propertyId);
      setState(() => _leads = data);
    } catch (e) {
      debugPrint('PropertyLeadsScreen error: $e');
    }
    setState(() => _loading = false);
  }

  String _fmt(String? d) {
    if (d == null || d.isEmpty) return '-';
    try {
      return _dateFmt.format(DateTime.parse(d));
    } catch (_) {
      return d;
    }
  }

  String _initials(String? name) {
    if (name == null || name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.listingbackground,
      appBar: GradientAppBar(
        titleWidget: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Interested Buyers'),
            Text(
              widget.propertyTitle,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.white70),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            tooltip: 'Refresh',
            onPressed: _load,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _leads.isEmpty
              ? _emptyState()
              : RefreshIndicator(
                  onRefresh: _load,
                  child: Column(
                    children: [
                      _buildSummaryBar(),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                          itemCount: _leads.length,
                          itemBuilder: (_, i) =>
                              _InterestedBuyerCard(
                                lead: _leads[i],
                                dateFmt: _fmt,
                                initials: _initials,
                                statusColors: _statusColors,
                                onFollowUp: () => _followUpSheet(_leads[i]),
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  // ── Summary bar ────────────────────────────────────────────────────────────
  Widget _buildSummaryBar() {
    int count(String s) =>
        _leads.where((l) => (l['status'] ?? '') == s).length;
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          _SummaryChip(label: 'Total',      count: _leads.length,     color: AppColors.primary),
          const SizedBox(width: 8),
          _SummaryChip(label: 'Interested', count: count('INTERESTED'),color: const Color(0xFF2E7D32)),
          const SizedBox(width: 8),
          _SummaryChip(label: 'Converted',  count: count('CONVERTED'), color: AppColors.success),
          const SizedBox(width: 8),
          _SummaryChip(label: 'New',        count: count('NEW'),       color: AppColors.info),
        ],
      ),
    );
  }

  // ── Follow-up sheet ────────────────────────────────────────────────────────
  void _followUpSheet(Map lead) {
    DateTime? selectedDate;
    final remarkCtrl = TextEditingController();
    bool saving = false;
    final displayFmt = DateFormat('dd MMM yyyy, hh:mm a');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
              left: 20, right: 20, top: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.alarm_add_outlined,
                        color: AppColors.warning, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Schedule Follow-Up',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w700)),
                        Text(lead['clientName'] ?? '',
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.textMuted),
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              GestureDetector(
                onTap: () async {
                  final now = DateTime.now();
                  final date = await showDatePicker(
                    context: ctx,
                    initialDate: now.add(const Duration(days: 1)),
                    firstDate: now,
                    lastDate: now.add(const Duration(days: 365)),
                  );
                  if (date == null) return;
                  final time = await showTimePicker(
                      context: ctx, initialTime: TimeOfDay.now());
                  if (time == null) return;
                  setSheet(() {
                    selectedDate = DateTime(
                        date.year, date.month, date.day, time.hour, time.minute);
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: selectedDate != null
                            ? AppColors.warning
                            : AppColors.border),
                    borderRadius: BorderRadius.circular(12),
                    color: selectedDate != null
                        ? AppColors.warning.withOpacity(0.06)
                        : AppColors.white,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_month_outlined,
                          color: selectedDate != null
                              ? AppColors.warning
                              : AppColors.textMuted,
                          size: 20),
                      const SizedBox(width: 10),
                      Text(
                        selectedDate != null
                            ? displayFmt.format(selectedDate!)
                            : 'Tap to pick date & time',
                        style: TextStyle(
                          fontSize: 14,
                          color: selectedDate != null
                              ? AppColors.textPrimary
                              : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: remarkCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Note (optional)',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.alarm_on_outlined, size: 18),
                  label: const Text('Confirm Follow-Up'),
                  onPressed: (saving || selectedDate == null)
                      ? null
                      : () async {
                          setSheet(() => saving = true);
                          try {
                            final updated = await LeadApiService.scheduleFollowUp(
                              leadId: lead['id'] as int,
                              followUpDate: selectedDate!,
                              remark: remarkCtrl.text.trim(),
                            );
                            final idx = _leads
                                .indexWhere((l) => l['id'] == lead['id']);
                            if (idx >= 0) {
                              setState(() => _leads[idx] = updated);
                            }
                            if (ctx.mounted) Navigator.pop(ctx);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Follow-up scheduled'),
                                  backgroundColor: AppColors.success,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                              );
                            }
                          } catch (e) {
                            setSheet(() => saving = false);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.warning,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    disabledBackgroundColor: AppColors.border,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyState() => Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.visibility_outlined,
                    size: 36, color: AppColors.primary),
              ),
              const SizedBox(height: 16),
              const Text('No interest yet',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              const Text('Users who enquire about this property will appear here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
            ],
          ),
        ),
      );
}

// ── Interested buyer card ─────────────────────────────────────────────────────

class _InterestedBuyerCard extends StatelessWidget {
  final Map lead;
  final String Function(String?) dateFmt;
  final String Function(String?) initials;
  final Map<String, Color> statusColors;
  final VoidCallback onFollowUp;

  const _InterestedBuyerCard({
    required this.lead,
    required this.dateFmt,
    required this.initials,
    required this.statusColors,
    required this.onFollowUp,
  });

  @override
  Widget build(BuildContext context) {
    final phone     = lead['mobile'] as String?;
    final status    = (lead['status'] ?? 'NEW') as String;
    final followUp  = dateFmt(lead['nextFollowUpDate'] as String?);
    final hasFollowUp = followUp != '-';
    final budget    = lead['budget'] ?? lead['preferredBudget'];
    final message   = (lead['message'] ?? '') as String;
    final color     = statusColors[status] ?? AppColors.textMuted;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(color: AppColors.shadowLight, blurRadius: 5, offset: Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: avatar + name + status + follow-up button
            Row(
              children: [
                // Avatar
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      initials(lead['clientName'] as String?),
                      style: const TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lead['clientName'] ?? 'Unknown',
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (phone != null && phone.isNotEmpty)
                        Text(phone,
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.textMuted)),
                    ],
                  ),
                ),
                // Status chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color.withOpacity(0.3)),
                  ),
                  child: Text(
                    status.replaceAll('_', ' '),
                    style: TextStyle(
                        color: color, fontSize: 10, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Row 2: inquiry date, budget, lead source
            Wrap(
              spacing: 12,
              runSpacing: 4,
              children: [
                _chip(Icons.calendar_today_outlined,
                    dateFmt(lead['inquiryDate'] as String?)),
                if (budget != null)
                  _chip(Icons.account_balance_wallet_outlined,
                      '₹${NumberFormat('#,##,###').format(budget)}'),
                if (lead['leadSource'] != null)
                  _chip(Icons.source_outlined, lead['leadSource'] as String),
                if (lead['profession'] != null)
                  _chip(Icons.work_outline, lead['profession'] as String),
              ],
            ),

            if (message.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.chat_bubble_outline,
                      size: 13, color: AppColors.textMuted),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      message,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 10),
            const Divider(height: 1, thickness: 1, color: AppColors.border),
            const SizedBox(height: 10),

            // Action row: Call | WhatsApp | Follow Up
            Row(
              children: [
                // Call
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.call_outlined, size: 15),
                    label: const Text('Call'),
                    style: _outBtn(),
                    onPressed: phone != null ? () => AppUtils.call(phone) : null,
                  ),
                ),
                const SizedBox(width: 6),
                // WhatsApp
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.chat_outlined, size: 15),
                    label: const Text('WhatsApp'),
                    style: _outBtn(color: const Color(0xFF25D366)),
                    onPressed: phone != null
                        ? () => AppUtils.whatsapp(
                            phone,
                            'Hi ${lead['clientName'] ?? ''}, following up on your property inquiry.')
                        : null,
                  ),
                ),
                const SizedBox(width: 6),
                // Follow Up compact button
                InkWell(
                  onTap: onFollowUp,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: 34,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: (hasFollowUp ? AppColors.warning : AppColors.primary)
                          .withOpacity(0.10),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: (hasFollowUp ? AppColors.warning : AppColors.primary)
                              .withOpacity(0.35)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          hasFollowUp
                              ? Icons.alarm_on_outlined
                              : Icons.alarm_add_outlined,
                          size: 14,
                          color: hasFollowUp ? AppColors.warning : AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          hasFollowUp ? followUp : 'Follow Up',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: hasFollowUp
                                ? AppColors.warning
                                : AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget _chip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppColors.textMuted),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }

  static ButtonStyle _outBtn({Color? color}) => OutlinedButton.styleFrom(
        foregroundColor: color ?? AppColors.primary,
        side: BorderSide(color: (color ?? AppColors.primary).withOpacity(0.4)),
        minimumSize: const Size(0, 34),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle:
            const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      );
}

// ── Summary chip ──────────────────────────────────────────────────────────────

class _SummaryChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _SummaryChip(
      {required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
                text: '$count ',
                style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.w800)),
            TextSpan(
                text: label,
                style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
