import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../services/leads_service.dart';
import '../cards/lead_card.dart';
import '../commons/common_widget.dart';

class BrokerLeadsScreen extends StatefulWidget {
  final int brokerId;

  const BrokerLeadsScreen({super.key, required this.brokerId});

  @override
  State<BrokerLeadsScreen> createState() => _BrokerLeadsScreenState();
}

class _BrokerLeadsScreenState extends State<BrokerLeadsScreen> {
  List<dynamic> _leads = [];
  List<dynamic> _filteredLeads = [];
  bool _loading = true;
  String _search = '';
  String _selectedStatus = 'ALL';

  static const _statuses = [
    'ALL', 'NEW', 'CONTACTED', 'VISIT_PLANNED', 'VISIT_DONE', 'NEGOTIATING',
    'CLOSED_WON', 'CLOSED_LOST', 'DROPPED',
  ];

  static const _statusColors = {
    'NEW':           AppColors.info,
    'CONTACTED':     AppColors.warning,
    'VISIT_PLANNED': Color(0xFF7B61FF),
    'VISIT_DONE':    Color(0xFF2E7D32),
    'NEGOTIATING':   Color(0xFFFF6B35),
    'CLOSED_WON':    AppColors.success,
    'CLOSED_LOST':   AppColors.error,
    'DROPPED':       AppColors.textMuted,
  };

  @override
  void initState() {
    super.initState();
    _loadLeads();
  }

  static const _dummyLeads = [
    {
      'id': 0,
      'clientName': 'Rahul Sharma',
      'mobile': '9876543210',
      'email': 'rahul.sharma@email.com',
      'status': 'NEW',
      'leadType': 'PROPERTY_INQUIRY',
      'propertyTitle': '3BHK Apartment – Baner, Pune',
      'propertyCity': 'Pune',
      'propertyPrice': 8500000.0,
      'budget': 9000000.0,
      'inquiryDate': '2026-04-20T10:30:00',
      'message': 'Looking for a ready-to-move flat near metro.',
      'leadSource': 'APP',
    },
    {
      'id': -1,
      'clientName': 'Priya Mehta',
      'mobile': '9123456780',
      'email': 'priya.mehta@email.com',
      'status': 'VISIT_PLANNED',
      'leadType': 'HOME_LOAN',
      'propertyTitle': '2BHK Flat – Wakad, Pune',
      'propertyCity': 'Pune',
      'propertyPrice': 5500000.0,
      'budget': 6000000.0,
      'inquiryDate': '2026-04-22T14:00:00',
      'nextFollowUpDate': '2026-04-30T11:00:00',
      'message': 'Interested in home loan options as well.',
      'leadSource': 'WEBSITE',
    },
  ];

  Future<void> _loadLeads() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      final data = await LeadApiService.fetchBrokerLeads(brokerId: widget.brokerId);
      if (!mounted) return;
      _leads = data.isEmpty ? List.from(_dummyLeads) : data;
    } catch (e) {
      debugPrint('Error loading leads: $e');
      if (!mounted) return;
      _leads = List.from(_dummyLeads);
    }
    _applyFilters();
    if (mounted) setState(() => _loading = false);
  }

  void _applyFilters() {
    _filteredLeads = _leads.where((lead) {
      final name   = (lead['clientName'] ?? '').toString().toLowerCase();
      final mobile = (lead['mobile']     ?? '').toString().toLowerCase();
      final status = (lead['status']     ?? '').toString().toUpperCase();
      return (name.contains(_search) || mobile.contains(_search))
          && (_selectedStatus == 'ALL' || status == _selectedStatus);
    }).toList();
    if (mounted) setState(() {});
  }

  int _count(String status) =>
      _leads.where((l) => (l['status'] ?? '').toString().toUpperCase() == status).length;

  // ── Stats row ──────────────────────────────────────────────────────────────
  Widget _buildStats() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Row(
        children: [
          _StatTile(label: 'Total',      count: _leads.length,               color: AppColors.primary),
          const SizedBox(width: 8),
          _StatTile(label: 'New',        count: _count('NEW'),               color: AppColors.info),
          const SizedBox(width: 8),
          _StatTile(label: 'Contacted',  count: _count('CONTACTED'),         color: AppColors.warning),
          const SizedBox(width: 8),
          _StatTile(label: 'Visit Done', count: _count('VISIT_DONE'),        color: const Color(0xFF2E7D32)),
          const SizedBox(width: 8),
          _StatTile(label: 'Won',        count: _count('CLOSED_WON'),        color: AppColors.success),
        ],
      ),
    );
  }

  // ── Search bar ─────────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
      child: AppSearchField(
        hintText: 'Search by name or mobile',
        onChanged: (v) {
          _search = v.toLowerCase();
          _applyFilters();
        },
      ),
    );
  }

  // ── Status chips ───────────────────────────────────────────────────────────
  Widget _buildStatusChips() {
    return SizedBox(
      height: 42,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _statuses.length,
        itemBuilder: (_, i) {
          final s = _statuses[i];
          final selected = s == _selectedStatus;
          final color = _statusColors[s] ?? AppColors.primary;
          final label = s.replaceAll('_', ' ');
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(label),
              selected: selected,
              onSelected: (_) {
                setState(() => _selectedStatus = s);
                _applyFilters();
              },
              selectedColor: color.withOpacity(0.15),
              labelStyle: TextStyle(
                color: selected ? color : AppColors.textSecondary,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 12,
              ),
              side: BorderSide(color: selected ? color : AppColors.border),
              backgroundColor: AppColors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              showCheckmark: false,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            ),
          );
        },
      ),
    );
  }

  // ── Lead list ──────────────────────────────────────────────────────────────
  Widget _buildList() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_filteredLeads.isEmpty) return _emptyState();
    return RefreshIndicator(
      onRefresh: _loadLeads,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
        itemCount: _filteredLeads.length,
        itemBuilder: (_, i) => LeadCard(
          lead: _filteredLeads[i],
          onEdit: () => _showEditSheet(_filteredLeads[i]),
          onFollowUp: () => _showFollowUpSheet(_filteredLeads[i]),
        ),
      ),
    );
  }

  Widget _emptyState() {
    final isFiltered = _search.isNotEmpty || _selectedStatus != 'ALL';
    return Center(
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
              child: const Icon(Icons.people_outline, size: 36, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text(
              isFiltered ? 'No matching inquiries' : 'No inquiries yet',
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              isFiltered
                  ? 'Try adjusting your search or filter'
                  : 'Customer inquiries on your listings will appear here',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
            if (isFiltered) ...[
              const SizedBox(height: 20),
              OutlinedButton.icon(
                icon: const Icon(Icons.clear, size: 16),
                label: const Text('Clear filters'),
                onPressed: () {
                  setState(() { _search = ''; _selectedStatus = 'ALL'; });
                  _applyFilters();
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 40),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Edit / Status update bottom sheet ──────────────────────────────────────
  void _showEditSheet(Map lead) {
    String selectedStatus = (lead['status'] ?? 'NEW') as String;
    final remarkCtrl = TextEditingController(text: lead['remark'] as String? ?? '');
    bool saving = false;

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
              // Handle bar
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                lead['clientName'] ?? 'Update Lead',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                lead['propertyTitle'] ?? '',
                style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
              ),
              const SizedBox(height: 20),
              const Text('Status', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  'NEW', 'CONTACTED', 'VISIT_PLANNED', 'VISIT_DONE',
                  'NEGOTIATING', 'CLOSED_WON', 'CLOSED_LOST', 'DROPPED'
                ].map((s) {
                  final color = _statusColors[s] ?? AppColors.primary;
                  final active = s == selectedStatus;
                  return ChoiceChip(
                    label: Text(s.replaceAll('_', ' ')),
                    selected: active,
                    onSelected: (_) => setSheet(() => selectedStatus = s),
                    selectedColor: color.withOpacity(0.15),
                    labelStyle: TextStyle(
                      color: active ? color : AppColors.textSecondary,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 12,
                    ),
                    side: BorderSide(color: active ? color : AppColors.border),
                    backgroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    showCheckmark: false,
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Text('Remark', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: remarkCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Add a note…',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: saving
                      ? null
                      : () async {
                          setSheet(() => saving = true);
                          try {
                            final updated = await LeadApiService.updateLeadStatus(
                              leadId: lead['id'] as int,
                              status: selectedStatus,
                              remark: remarkCtrl.text.trim(),
                            );
                            // Patch in-memory lead
                            final idx = _leads.indexWhere((l) => l['id'] == lead['id']);
                            if (idx >= 0) {
                              setState(() {
                                _leads[idx] = updated;
                                _applyFilters();
                              });
                            }
                            if (ctx.mounted) Navigator.pop(ctx);
                            _showSnack('Status updated');
                          } catch (e) {
                            setSheet(() => saving = false);
                            _showSnack('Failed to update', error: true);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: saving
                      ? const SizedBox(width: 20, height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Save Changes'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ── Schedule follow-up bottom sheet ────────────────────────────────────────
  void _showFollowUpSheet(Map lead) {
    DateTime? selectedDate;
    final remarkCtrl = TextEditingController();
    bool saving = false;
    final dateFmt = DateFormat('dd MMM yyyy, hh:mm a');

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
              // Handle bar
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Schedule Follow-Up',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      Text(lead['clientName'] ?? '',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textMuted)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Date-time picker tile
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
                    context: ctx,
                    initialTime: TimeOfDay.now(),
                  );
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
                            ? dateFmt.format(selectedDate!)
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
              const SizedBox(height: 14),
              TextField(
                controller: remarkCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Note for this follow-up (optional)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              const SizedBox(height: 20),
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
                            final idx =
                                _leads.indexWhere((l) => l['id'] == lead['id']);
                            if (idx >= 0) {
                              setState(() {
                                _leads[idx] = updated;
                                _applyFilters();
                              });
                            }
                            if (ctx.mounted) Navigator.pop(ctx);
                            _showSnack('Follow-up scheduled');
                          } catch (e) {
                            setSheet(() => saving = false);
                            _showSnack('Failed to schedule', error: true);
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

  void _showSnack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? AppColors.error : AppColors.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.listingbackground,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Customer Inquiries'),
            if (!_loading)
              Text(
                '${_leads.length} total inquir${_leads.length == 1 ? 'y' : 'ies'}',
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.white70),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            tooltip: 'Refresh',
            onPressed: _loadLeads,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (!_loading && _leads.isNotEmpty) _buildStats(),
            _buildSearchBar(),
            _buildStatusChips(),
            Expanded(child: _buildList()),
          ],
        ),
      ),
    );
  }
}

// ── Stat tile ─────────────────────────────────────────────────────────────────

class _StatTile extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _StatTile({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text('$count',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w700, color: color)),
          Text(label,
              style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
