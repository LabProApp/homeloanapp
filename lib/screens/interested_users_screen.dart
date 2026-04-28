import 'package:flutter/material.dart';
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

  static const _statuses = ['ALL', 'NEW', 'CONTACTED', 'CLOSED', 'DROPPED'];

  static const _statusColors = {
    'NEW':       AppColors.info,
    'CONTACTED': AppColors.warning,
    'CLOSED':    AppColors.success,
    'DROPPED':   AppColors.error,
  };

  @override
  void initState() {
    super.initState();
    _loadLeads();
  }

  Future<void> _loadLeads() async {
    setState(() => _loading = true);
    try {
      final data = await LeadApiService.fetchBrokerLeads(brokerId: widget.brokerId);
      _leads = data;
      _applyFilters();
    } catch (e) {
      debugPrint('Error loading leads: $e');
    }
    setState(() => _loading = false);
  }

  void _applyFilters() {
    _filteredLeads = _leads.where((lead) {
      final name   = (lead['clientName'] ?? '').toString().toLowerCase();
      final mobile = (lead['mobile']     ?? '').toString().toLowerCase();
      final status = (lead['status']     ?? '').toString().toUpperCase();
      return (name.contains(_search) || mobile.contains(_search))
          && (_selectedStatus == 'ALL' || status == _selectedStatus);
    }).toList();
    setState(() {});
  }

  int _count(String status) =>
      _leads.where((l) => (l['status'] ?? '').toString().toUpperCase() == status).length;

  // ── Stats row ──────────────────────────────────────────────────────────────
  Widget _buildStats() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Row(
        children: [
          _StatTile(label: 'Total',     count: _leads.length,      color: AppColors.primary),
          const SizedBox(width: 8),
          _StatTile(label: 'New',       count: _count('NEW'),       color: AppColors.info),
          const SizedBox(width: 8),
          _StatTile(label: 'Contacted', count: _count('CONTACTED'), color: AppColors.warning),
          const SizedBox(width: 8),
          _StatTile(label: 'Closed',    count: _count('CLOSED'),    color: AppColors.success),
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
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(s),
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
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_filteredLeads.isEmpty) return _emptyState();
    return RefreshIndicator(
      onRefresh: _loadLeads,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
        itemCount: _filteredLeads.length,
        itemBuilder: (_, i) => LeadCard(
          lead: _filteredLeads[i],
          onEdit: () => _editLeadDialog(_filteredLeads[i]),
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

  void _editLeadDialog(Map lead) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Center(
            child: Text(
              'Edit Lead UI here for ${lead["clientName"]}',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      ),
    );
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
                    fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.white70),
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
    return Expanded(
      child: Container(
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
                    fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}
