import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../commons/common_util.dart';
import '../commons/common_widget.dart';
import '../config/app_config.dart';
import '../models/plan_change_request_model.dart';
import '../services/feature_flags.dart';
import '../services/plan_request_service.dart';
import '../theme/app_colors.dart';

/// User-facing "Subscription & Plans" screen.
///
/// Shows the user's current plan, a side-by-side comparison of the three
/// tiers (BASIC / DELUX / PREMIUM), an in-app **Request Upgrade** flow
/// (Option B — creates a {@link PlanChangeRequestModel}), and a
/// **Contact Support** WhatsApp deep-link fallback (Option A).
class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  static final _fmt = NumberFormat('#,##,###');

  String _currentPlan = 'BASIC';
  double _planPrice = 0;
  List<PlanChangeRequestModel> _requests = const [];
  bool _loading = true;
  bool _submitting = false;

  PlanChangeRequestModel? get _pendingRequest {
    for (final r in _requests) {
      if (r.isPending) return r;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final plan = await FeatureFlags.planName();
    final price = await FeatureFlags.planPriceYearly();
    try {
      final reqs = await PlanRequestApiService.getMyRequests();
      if (!mounted) return;
      setState(() {
        _currentPlan = plan.isNotEmpty ? plan : 'BASIC';
        _planPrice = price;
        _requests = reqs;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _currentPlan = plan.isNotEmpty ? plan : 'BASIC';
        _planPrice = price;
        _loading = false;
      });
    }
  }

  // ── Actions ─────────────────────────────────────────────────────────────────

  Future<void> _requestUpgrade(String plan) async {
    if (_pendingRequest != null) {
      _snack('You already have a pending request — cancel it first to switch.',
          isError: true);
      return;
    }
    final confirmed = await _confirmDialog(
      title: 'Request upgrade to $plan?',
      message:
          'We\'ll notify our sales team. Once payment is confirmed they will activate your $plan plan.',
      confirmLabel: 'Submit Request',
    );
    if (confirmed != true) return;

    setState(() => _submitting = true);
    try {
      final req = await PlanRequestApiService.submit(plan: plan);
      if (!mounted) return;
      setState(() {
        _requests = [req, ..._requests];
      });
      _snack('Request submitted. We\'ll be in touch shortly.');
    } catch (e) {
      _snack(e.toString().replaceFirst('Exception: ', ''), isError: true);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _cancelPending() async {
    final pending = _pendingRequest;
    if (pending == null || pending.id == null) return;
    final confirmed = await _confirmDialog(
      title: 'Cancel this request?',
      message: 'Your pending ${pending.requestedPlan} request will be withdrawn.',
      confirmLabel: 'Cancel Request',
      destructive: true,
    );
    if (confirmed != true) return;

    setState(() => _submitting = true);
    try {
      final updated = await PlanRequestApiService.cancel(pending.id!);
      if (!mounted) return;
      setState(() {
        _requests = [
          updated,
          ..._requests.where((r) => r.id != updated.id),
        ];
      });
      _snack('Request cancelled.');
    } catch (e) {
      _snack(e.toString().replaceFirst('Exception: ', ''), isError: true);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _contactSupport(String plan) async {
    final message =
        'Hi, I would like to upgrade my KeyBricks plan to $plan. My userId is ${(await SharedPreferences.getInstance()).getInt('userId') ?? '?'}.';
    try {
      await AppUtils.whatsapp(AppConfig.supportWhatsApp, message);
    } catch (_) {
      _snack('Couldn\'t open WhatsApp. Email us at ${AppConfig.supportEmail} instead.',
          isError: true);
    }
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.listingbackground,
      appBar: GradientAppBar(
        titleWidget: const Text('Subscription & Plans',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 18)),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _currentPlanCard(),
                    if (_pendingRequest != null) ...[
                      const SizedBox(height: 14),
                      _pendingRequestCard(),
                    ],
                    const SizedBox(height: 22),
                    const Text('Choose a plan',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 12),
                    _planCard(
                      plan: 'BASIC',
                      priceLabel: 'Free',
                      tagline: 'Get started — browse & enquire',
                      features: const [
                        'Browse Buy/Sell & Rent/PG listings',
                        'EMI Calculator + Stamp Duty + Rent vs Buy',
                        'Post Requirement (lead-collection)',
                        'Home Buying Journey tracker',
                      ],
                      gradient: const [Color(0xFF94A3B8), Color(0xFF64748B)],
                    ),
                    const SizedBox(height: 12),
                    _planCard(
                      plan: 'DELUX',
                      priceLabel: '₹ ${_fmt.format(9999)} / year',
                      tagline: 'For active sellers & loan seekers',
                      features: const [
                        'Everything in BASIC',
                        'Bank Loans — compare & apply',
                        'Post up to 250 property listings',
                      ],
                      gradient: const [Color(0xFF1565C0), Color(0xFF0D47A1)],
                    ),
                    const SizedBox(height: 12),
                    _planCard(
                      plan: 'PREMIUM',
                      priceLabel: '₹ ${_fmt.format(19999)} / year',
                      tagline: 'For agents and power users',
                      features: const [
                        'Everything in DELUX',
                        'Post up to 500 property listings',
                        'Documentation — Rent / Sale Agreements & Legal',
                      ],
                      gradient: const [AppColors.primary, AppColors.primaryDark],
                    ),
                    const SizedBox(height: 18),
                    _supportFooter(),
                    if (_requests.isNotEmpty) ...[
                      const SizedBox(height: 22),
                      _historySection(),
                    ],
                  ],
                ),
              ),
      ),
    );
  }

  // ── Sub-widgets ─────────────────────────────────────────────────────────────

  Widget _currentPlanCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.navy, AppColors.slate],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('YOUR PLAN',
              style: TextStyle(
                  fontSize: 11,
                  color: AppColors.goldAccent,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2)),
          const SizedBox(height: 6),
          Text(_currentPlan,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.4)),
          const SizedBox(height: 4),
          Text(
            _planPrice <= 0 ? 'Free tier' : '₹ ${_fmt.format(_planPrice)} / year',
            style: const TextStyle(color: AppColors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _pendingRequestCard() {
    final p = _pendingRequest!;
    final when = p.requestedAt != null
        ? DateFormat('d MMM, h:mm a').format(p.requestedAt!.toLocal())
        : '';
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.goldAccent.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.goldAccent.withOpacity(0.6)),
      ),
      child: Row(
        children: [
          const Icon(Icons.hourglass_top_rounded,
              color: AppColors.goldAccent, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pending: ${p.requestedPlan}',
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                if (when.isNotEmpty)
                  Text('Submitted $when',
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textMuted)),
              ],
            ),
          ),
          TextButton(
            onPressed: _submitting ? null : _cancelPending,
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _planCard({
    required String plan,
    required String priceLabel,
    required String tagline,
    required List<String> features,
    required List<Color> gradient,
  }) {
    final isCurrent = plan == _currentPlan;
    final isFree = plan == 'BASIC';
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isCurrent ? gradient.last : AppColors.border,
            width: isCurrent ? 1.6 : 1),
        boxShadow: const [
          BoxShadow(color: AppColors.shadowLight, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(plan,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4)),
              ),
              const SizedBox(width: 10),
              Text(priceLabel,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              const Spacer(),
              if (isCurrent)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('CURRENT',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.success,
                          letterSpacing: 0.6)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(tagline,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textMuted, height: 1.3)),
          const SizedBox(height: 10),
          ...features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle_rounded,
                        size: 14, color: gradient.last),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(f,
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              height: 1.35)),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 10),
          if (!isFree && !isCurrent) _upgradeActions(plan, gradient),
        ],
      ),
    );
  }

  Widget _upgradeActions(String plan, List<Color> gradient) {
    final disabled = _submitting || _pendingRequest != null;
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: InkWell(
            onTap: disabled ? null : () => _requestUpgrade(plan),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 11),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: disabled ? [AppColors.disabled, AppColors.disabled] : gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Request Upgrade',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: InkWell(
            onTap: () => _contactSupport(plan),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 11),
              decoration: BoxDecoration(
                color: AppColors.whatsAppGreen.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.whatsAppGreen, width: 1),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_rounded,
                      size: 15, color: AppColors.whatsAppGreen),
                  SizedBox(width: 5),
                  Text(
                    'Chat',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.whatsAppGreen,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _supportFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.support_agent_rounded,
              color: AppColors.primary, size: 22),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Questions about pricing or features?',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
          TextButton.icon(
            onPressed: () => _contactSupport(_currentPlan),
            icon: const Icon(Icons.chat_rounded,
                size: 16, color: AppColors.whatsAppGreen),
            label: const Text('WhatsApp',
                style: TextStyle(color: AppColors.whatsAppGreen)),
            style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8)),
          ),
        ],
      ),
    );
  }

  Widget _historySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Request history',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
        const SizedBox(height: 10),
        ..._requests.map(_historyRow),
      ],
    );
  }

  Widget _historyRow(PlanChangeRequestModel r) {
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
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 8, height: 38,
            decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(4)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${r.requestedPlan} · ${r.status}',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                if (when.isNotEmpty)
                  Text(when,
                      style: const TextStyle(
                          fontSize: 10, color: AppColors.textMuted)),
                if (r.isRejected && r.rejectionReason?.isNotEmpty == true)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text('Reason: ${r.rejectionReason}',
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.error)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  Future<bool?> _confirmDialog({
    required String title,
    required String message,
    required String confirmLabel,
    bool destructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Not now')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  destructive ? AppColors.error : AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }

  void _snack(String text, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(text),
        duration: const Duration(seconds: 3),
        backgroundColor: isError ? AppColors.error : null,
      ));
  }
}
