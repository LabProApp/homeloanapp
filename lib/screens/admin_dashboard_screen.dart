import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../commons/common_widget.dart';
import '../models/admin_stats_model.dart';
import '../models/plan_change_request_model.dart';
import '../models/user_model.dart';
import '../services/admin_service.dart';
import '../theme/app_colors.dart';

/// Admin-only home for the mobile app.
///
/// Three tabs:
///   Overview — counts cards (users, properties, pending, active subs)
///   Requests — pending plan-change requests with inline approve/reject
///   Users    — paginated user search with a "change plan" action
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.listingbackground,
      appBar: GradientAppBar(
        titleWidget: const Text(
          'Admin',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: AppColors.goldAccent,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: AppColors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Requests'),
            Tab(text: 'Users'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: const [
          _OverviewTab(),
          _RequestsTab(),
          _UsersTab(),
        ],
      ),
    );
  }
}

// ─── Overview tab ──────────────────────────────────────────────────────────────

class _OverviewTab extends StatefulWidget {
  const _OverviewTab();

  @override
  State<_OverviewTab> createState() => _OverviewTabState();
}

class _OverviewTabState extends State<_OverviewTab> {
  AdminStatsModel? _stats;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final s = await AdminApiService.getStats();
      if (!mounted) return;
      setState(() {
        _stats = s;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return AppErrorState(message: _error!, onRetry: _load, icon: Icons.error_outline_rounded);
    }
    final s = _stats!;
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.6,
            children: [
              _StatCard(
                label: 'Total Users',
                value: s.totalUsers,
                icon: Icons.groups_outlined,
                color: const Color(0xFF1565C0),
              ),
              _StatCard(
                label: 'Listings',
                value: s.totalProperties,
                icon: Icons.home_work_outlined,
                color: AppColors.primary,
                subline:
                    '${s.propertiesForSale} sale · ${s.propertiesForRent} rent',
              ),
              _StatCard(
                label: 'Pending Requests',
                value: s.pendingPlanRequests,
                icon: Icons.pending_actions_outlined,
                color: AppColors.goldAccent,
                highlighted: s.pendingPlanRequests > 0,
              ),
              _StatCard(
                label: 'Active Subscriptions',
                value: s.activeSubscriptions,
                icon: Icons.workspace_premium_outlined,
                color: AppColors.success,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _planBreakdownCard(s),
        ],
      ),
    );
  }

  Widget _planBreakdownCard(AdminStatsModel s) {
    final byPlan = s.usersByPlan;
    final order = ['BASIC', 'DELUX', 'PREMIUM'];
    final total = byPlan.values.fold<int>(0, (acc, v) => acc + v);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Users by plan',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary),
          ),
          const SizedBox(height: 10),
          for (final p in order)
            _planRow(p, byPlan[p] ?? 0, total),
          // surface any legacy enum values (REGULAR / ELITE) so admins see them
          for (final entry in byPlan.entries)
            if (!order.contains(entry.key) && entry.value > 0)
              _planRow(entry.key, entry.value, total),
        ],
      ),
    );
  }

  Widget _planRow(String plan, int count, int total) {
    final pct = total == 0 ? 0.0 : count / total;
    final color = switch (plan) {
      'PREMIUM' => AppColors.primary,
      'DELUX' => const Color(0xFF1565C0),
      'BASIC' => AppColors.textMuted,
      _ => AppColors.warning,
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(plan,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
              ),
              Text('$count',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 6,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;
  final String? subline;
  final bool highlighted;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.subline,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: highlighted ? color : color.withOpacity(0.18),
            width: highlighted ? 1.4 : 1),
        boxShadow: const [
          BoxShadow(color: AppColors.shadowLight, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$value',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: color),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600),
              ),
              if (subline != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(subline!,
                      style: const TextStyle(
                          fontSize: 10, color: AppColors.textMuted)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Requests tab ──────────────────────────────────────────────────────────────

class _RequestsTab extends StatefulWidget {
  const _RequestsTab();

  @override
  State<_RequestsTab> createState() => _RequestsTabState();
}

class _RequestsTabState extends State<_RequestsTab> {
  List<PlanChangeRequestModel> _requests = const [];
  bool _loading = true;
  String? _error;
  String _statusFilter = 'PENDING';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await AdminApiService.listRequests(status: _statusFilter);
      if (!mounted) return;
      setState(() {
        _requests = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  Future<void> _approve(PlanChangeRequestModel r) async {
    final years = await _askYears();
    if (years == null) return;
    try {
      await AdminApiService.approveRequest(r.id!, durationYears: years);
      _snack('Approved ${r.requestedPlan} for user #${r.userId}');
      _load();
    } catch (e) {
      _snack(e.toString().replaceFirst('Exception: ', ''), error: true);
    }
  }

  Future<void> _reject(PlanChangeRequestModel r) async {
    final reason = await _askReason();
    if (reason == null) return;
    try {
      await AdminApiService.rejectRequest(r.id!, reason: reason);
      _snack('Rejected request #${r.id}');
      _load();
    } catch (e) {
      _snack(e.toString().replaceFirst('Exception: ', ''), error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _statusBar(),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? AppErrorState(message: _error!, onRetry: _load, icon: Icons.error_outline_rounded)
                  : _requests.isEmpty
                      ? _emptyState()
                      : RefreshIndicator(
                          onRefresh: _load,
                          child: ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemBuilder: (_, i) => _requestCard(_requests[i]),
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemCount: _requests.length,
                          ),
                        ),
        ),
      ],
    );
  }

  Widget _statusBar() {
    Widget chip(String label) {
      final selected = _statusFilter == label;
      return Padding(
        padding: const EdgeInsets.only(right: 6),
        child: ChoiceChip(
          label: Text(label),
          selected: selected,
          onSelected: (_) {
            setState(() => _statusFilter = label);
            _load();
          },
          selectedColor: AppColors.primary,
          backgroundColor: AppColors.white,
          labelStyle: TextStyle(
            color: selected ? Colors.white : AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      color: AppColors.listingbackground,
      child: Row(
        children: [
          chip('PENDING'),
          chip('APPROVED'),
          chip('REJECTED'),
          chip('CANCELLED'),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined,
                size: 56, color: AppColors.textMuted.withOpacity(0.5)),
            const SizedBox(height: 8),
            Text(
              'No $_statusFilter requests',
              style: const TextStyle(color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _requestCard(PlanChangeRequestModel r) {
    final color = switch (r.status) {
      'APPROVED' => AppColors.success,
      'REJECTED' => AppColors.error,
      'CANCELLED' => AppColors.textMuted,
      _ => AppColors.goldAccent,
    };
    final when = r.requestedAt != null
        ? DateFormat('d MMM yyyy, h:mm a').format(r.requestedAt!.toLocal())
        : '';
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(r.status,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: color,
                        letterSpacing: 0.6)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'User #${r.userId} → ${r.requestedPlan}',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
          if (when.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(when,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textMuted)),
            ),
          if (r.notes != null && r.notes!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(r.notes!,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary)),
            ),
          if (r.isRejected && r.rejectionReason?.isNotEmpty == true)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text('Reason: ${r.rejectionReason}',
                  style: const TextStyle(fontSize: 11, color: AppColors.error)),
            ),
          if (r.isPending) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.close_rounded, size: 16),
                    label: const Text('Reject'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      minimumSize: const Size.fromHeight(38),
                    ),
                    onPressed: () => _reject(r),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check_rounded, size: 16),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(38),
                    ),
                    onPressed: () => _approve(r),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<int?> _askYears() async {
    int years = 1;
    return showDialog<int>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Approve for how many years?'),
        content: StatefulBuilder(
          builder: (_, setLocal) => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_rounded),
                onPressed: years <= 1 ? null : () => setLocal(() => years--),
              ),
              Text('$years year${years == 1 ? '' : 's'}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700)),
              IconButton(
                icon: const Icon(Icons.add_rounded),
                onPressed: years >= 5 ? null : () => setLocal(() => years++),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, years),
              child: const Text('Approve')),
        ],
      ),
    );
  }

  Future<String?> _askReason() async {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reject — reason'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(
              hintText: 'e.g. Payment not received'),
          maxLength: 500,
          autofocus: true,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              final r = ctrl.text.trim();
              if (r.isEmpty) return;
              Navigator.pop(context, r);
            },
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  void _snack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(msg),
        backgroundColor: error ? AppColors.error : null,
        duration: const Duration(seconds: 3),
      ));
  }
}

// ─── Users tab ─────────────────────────────────────────────────────────────────

class _UsersTab extends StatefulWidget {
  const _UsersTab();

  @override
  State<_UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends State<_UsersTab> {
  final TextEditingController _searchCtrl = TextEditingController();
  String? _planFilter; // null = all

  List<UserModel> _users = const [];
  int _page = 0;
  int _total = 0;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load(reset: true);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load({bool reset = false}) async {
    setState(() {
      _loading = true;
      if (reset) {
        _users = const [];
        _page = 0;
      }
      _error = null;
    });
    try {
      final res = await AdminApiService.listUsers(
        plan: _planFilter,
        search: _searchCtrl.text,
        page: _page,
        size: 50,
      );
      if (!mounted) return;
      setState(() {
        _users = reset ? res.users : [..._users, ...res.users];
        _total = res.total;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  Future<void> _changePlan(UserModel u) async {
    final picked = await showModalBottomSheet<_PlanPick>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ChangePlanSheet(currentPlan: u.userPackage),
    );
    if (picked == null) return;
    try {
      await AdminApiService.assignPlan(
        userId: u.id,
        plan: picked.plan,
        durationYears: picked.years,
        reason: picked.reason,
      );
      _snack('Set ${u.name} to ${picked.plan}');
      _load(reset: true);
    } catch (e) {
      _snack(e.toString().replaceFirst('Exception: ', ''), error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _searchBar(),
        Expanded(
          child: _loading && _users.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : _error != null && _users.isEmpty
                  ? AppErrorState(message: _error!, onRetry: () => _load(reset: true), icon: Icons.error_outline_rounded)
                  : RefreshIndicator(
                      onRefresh: () => _load(reset: true),
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemBuilder: (_, i) => _userCard(_users[i]),
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemCount: _users.length,
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _searchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      color: AppColors.listingbackground,
      child: Column(
        children: [
          TextField(
            controller: _searchCtrl,
            onSubmitted: (_) => _load(reset: true),
            decoration: InputDecoration(
              hintText: 'Search by name, email or mobile',
              prefixIcon: const Icon(Icons.search_rounded, size: 18),
              suffixIcon: _searchCtrl.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18),
                      onPressed: () {
                        _searchCtrl.clear();
                        _load(reset: true);
                      },
                    ),
              filled: true,
              fillColor: AppColors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _planChip('All', null),
              _planChip('BASIC', 'BASIC'),
              _planChip('DELUX', 'DELUX'),
              _planChip('PREMIUM', 'PREMIUM'),
              const Spacer(),
              Text('$_total total',
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textMuted)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _planChip(String label, String? value) {
    final selected = _planFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) {
          setState(() => _planFilter = value);
          _load(reset: true);
        },
        selectedColor: AppColors.primary,
        backgroundColor: AppColors.white,
        labelStyle: TextStyle(
          color: selected ? Colors.white : AppColors.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _userCard(UserModel u) {
    final initial = u.name.isNotEmpty ? u.name[0].toUpperCase() : 'U';
    final planColor = switch (u.userPackage) {
      'PREMIUM' => AppColors.primary,
      'DELUX' => const Color(0xFF1565C0),
      _ => AppColors.textMuted,
    };
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: planColor.withOpacity(0.18),
            child: Text(initial,
                style: TextStyle(
                    color: planColor, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        u.name.isNotEmpty ? u.name : '(no name)',
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: planColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        u.userPackage.isNotEmpty ? u.userPackage : 'BASIC',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: planColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${u.email}${u.mobile.isNotEmpty ? ' · ${u.mobile}' : ''}',
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Change plan',
            icon: const Icon(Icons.edit_rounded, size: 18),
            onPressed: () => _changePlan(u),
          ),
        ],
      ),
    );
  }

  void _snack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(msg),
        backgroundColor: error ? AppColors.error : null,
        duration: const Duration(seconds: 3),
      ));
  }
}

// ─── Change-plan bottom sheet ──────────────────────────────────────────────────

class _PlanPick {
  final String plan;
  final int years;
  final String? reason;
  _PlanPick(this.plan, this.years, this.reason);
}

class _ChangePlanSheet extends StatefulWidget {
  final String currentPlan;
  const _ChangePlanSheet({required this.currentPlan});

  @override
  State<_ChangePlanSheet> createState() => _ChangePlanSheetState();
}

class _ChangePlanSheetState extends State<_ChangePlanSheet> {
  String _plan = 'BASIC';
  int _years = 1;
  final TextEditingController _reasonCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _plan = ['BASIC', 'DELUX', 'PREMIUM'].contains(widget.currentPlan)
        ? widget.currentPlan
        : 'BASIC';
  }

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16, right: 16, top: 14,
          bottom: MediaQuery.of(context).viewInsets.bottom + 14,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Change plan',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: ['BASIC', 'DELUX', 'PREMIUM']
                  .map((p) => ChoiceChip(
                        label: Text(p),
                        selected: _plan == p,
                        onSelected: (_) => setState(() => _plan = p),
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                            color: _plan == p
                                ? Colors.white
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.w700),
                      ))
                  .toList(),
            ),
            if (_plan != 'BASIC') ...[
              const SizedBox(height: 16),
              const Text('Duration',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: _years <= 1 ? null : () => setState(() => _years--),
                  ),
                  Text('$_years year${_years == 1 ? '' : 's'}',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: _years >= 5 ? null : () => setState(() => _years++),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            TextField(
              controller: _reasonCtrl,
              maxLength: 500,
              decoration: const InputDecoration(
                labelText: 'Reason (for the audit trail)',
                hintText: 'e.g. Paid via NEFT ref #12345',
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => Navigator.pop(
                  context,
                  _PlanPick(_plan, _years, _reasonCtrl.text),
                ),
                child: const Text('Apply'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
