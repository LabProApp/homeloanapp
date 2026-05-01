import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_colors.dart';
import 'bank_apply_loan_dialog.dart';
import 'banks_listing_screen.dart';
import 'due_diligence_screen.dart';
import 'emi_calculator_screen.dart';
import 'favourite_property_listing_screen.dart';
import 'legal_service_providers_listing.dart';
import 'loan_eligibility_screen.dart';
import 'property_listing_screen.dart';
import 'rent_vs_buy_screen.dart';
import 'rental_listing_screen.dart';
import 'sale_agreement_screen.dart';
import 'stamp_duty_screen.dart';

class _StepInfo {
  final IconData icon;
  final Color color;
  final String title;
  final String description;
  const _StepInfo(this.icon, this.color, this.title, this.description);
}

class _ActionItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionItem(this.icon, this.label, this.onTap);
}

class BuyerJourneyScreen extends StatefulWidget {
  final int userId;
  const BuyerJourneyScreen({super.key, required this.userId});

  @override
  State<BuyerJourneyScreen> createState() => _BuyerJourneyScreenState();
}

class _BuyerJourneyScreenState extends State<BuyerJourneyScreen> {
  static const List<_StepInfo> _steps = [
    _StepInfo(Icons.search_rounded, Color(0xFF1565C0),
        'Search & Shortlist Properties',
        'Browse sale and rental listings. Add favourites to compare options.'),
    _StepInfo(Icons.verified_outlined, Color(0xFF00796B),
        'Check Loan Eligibility',
        'Understand your buying power before committing to a property.'),
    _StepInfo(Icons.calculate_outlined, Color(0xFF2E7D32),
        'Calculate EMI & Budget',
        'Estimate monthly payments and compare renting vs buying.'),
    _StepInfo(Icons.checklist_outlined, Color(0xFF6A1B9A),
        'Property Due Diligence',
        'Verify title deeds, encumbrances and run a legal compliance checklist.'),
    _StepInfo(Icons.account_balance_outlined, Color(0xFF1565C0),
        'Apply for Home Loan',
        'Compare bank interest rates and submit your home loan application.'),
    _StepInfo(Icons.gavel_rounded, Color(0xFF4E342E),
        'Legal Documentation',
        'Execute sale agreement, calculate stamp duty and register the property.'),
    _StepInfo(Icons.celebration_rounded, Color(0xFF2E7D32),
        'Complete Your Purchase',
        'Congratulations! Mark this final step to celebrate your new home.'),
  ];

  late List<bool> _completed;
  bool _loading = true;

  String get _prefsKey => 'buyer_journey_v1_${widget.userId}';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_prefsKey);
    if (!mounted) return;
    setState(() {
      _completed = (saved != null && saved.length == _steps.length)
          ? saved.map((s) => s == 'true').toList()
          : List.filled(_steps.length, false);
      _loading = false;
    });
  }

  Future<void> _toggle(int index) async {
    setState(() => _completed[index] = !_completed[index]);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        _prefsKey, _completed.map((b) => b.toString()).toList());
  }

  Future<void> _confirmReset() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Journey?'),
        content: const Text(
            'This will clear all your progress. This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Reset',
                  style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
    if (ok == true) {
      setState(() => _completed = List.filled(_steps.length, false));
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefsKey);
    }
  }

  int get _completedCount => _completed.where((b) => b).length;

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      backgroundColor: AppColors.listingbackground,
      appBar: AppBar(
        title: const Text('Home Buying Journey'),
        actions: [
          IconButton(
            icon: const Icon(Icons.restart_alt_rounded),
            tooltip: 'Reset progress',
            onPressed: _confirmReset,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildStepper(),
          if (_completedCount == _steps.length) ...[
            const SizedBox(height: 16),
            _buildCompletionBanner(),
          ],
        ],
      ),
    );
  }

  // ── Header card ──────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF8F00), Color(0xFFE65100)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE65100).withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.home_work_rounded, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Home Buying Journey',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.22),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$_completedCount / ${_steps.length}',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _completedCount / _steps.length,
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _completedCount == _steps.length
                ? 'Journey complete! Congratulations 🎉'
                : _completedCount == 0
                    ? 'Follow these ${_steps.length} steps to buy your perfect home'
                    : '${_steps.length - _completedCount} steps remaining — keep going!',
            style:
                TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.9)),
          ),
        ],
      ),
    );
  }

  // ── Stepper ──────────────────────────────────────────────────────────────────

  Widget _buildStepper() {
    return Column(
      children: List.generate(_steps.length, _buildStepRow),
    );
  }

  Widget _buildStepRow(int index) {
    final step = _steps[index];
    final isDone = _completed[index];
    final isLast = index == _steps.length - 1;
    final activeIndex = _completed.indexWhere((b) => !b);
    final isActive = !isDone && index == activeIndex;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Left: circle + connector line ─────────────────────────────
          SizedBox(
            width: 48,
            child: Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDone
                        ? step.color
                        : isActive
                            ? step.color.withOpacity(0.13)
                            : const Color(0xFFEEEEEE),
                    border: Border.all(
                      color: isDone || isActive ? step.color : AppColors.border,
                      width: 2,
                    ),
                  ),
                  child: isDone
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : Icon(step.icon,
                          size: 15,
                          color: isActive ? step.color : AppColors.textMuted),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: isDone
                          ? step.color.withOpacity(0.4)
                          : AppColors.border,
                    ),
                  ),
              ],
            ),
          ),

          // ── Right: content card ────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
              child: Container(
                margin: const EdgeInsets.only(top: 2),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isActive
                        ? step.color.withOpacity(0.4)
                        : AppColors.border,
                  ),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                              color: step.color.withOpacity(0.10),
                              blurRadius: 8,
                              offset: const Offset(0, 2))
                        ]
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            step.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isDone
                                  ? AppColors.textMuted
                                  : AppColors.textPrimary,
                              decoration: isDone
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ),
                        if (isDone)
                          TextButton(
                            onPressed: () => _toggle(index),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.textMuted,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 6),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text('Undo',
                                style: TextStyle(fontSize: 11)),
                          ),
                      ],
                    ),
                    if (!isDone) ...[
                      const SizedBox(height: 4),
                      Text(
                        step.description,
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            height: 1.4),
                      ),
                      const SizedBox(height: 10),
                      _buildActions(index),
                      if (isActive) ...[
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _toggle(index),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: step.color,
                              foregroundColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 10),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text('Mark as Complete',
                                style: TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(int index) {
    final actions = _getActions(index);
    if (actions.isEmpty) return const SizedBox.shrink();
    final color = _steps[index].color;
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: actions
          .map((a) => OutlinedButton.icon(
                icon: Icon(a.icon, size: 14),
                label: Text(a.label),
                onPressed: a.onTap,
                style: OutlinedButton.styleFrom(
                  foregroundColor: color,
                  side: BorderSide(color: color.withOpacity(0.5)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  textStyle: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ))
          .toList(),
    );
  }

  List<_ActionItem> _getActions(int index) {
    switch (index) {
      case 0: // Search & Shortlist
        return [
          _ActionItem(Icons.sell_outlined, 'Sale Properties',
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => PropertyListingScreen(userId: widget.userId)))),
          _ActionItem(Icons.apartment_outlined, 'Rental Properties',
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => RentalListingScreen(userId: widget.userId)))),
          _ActionItem(Icons.favorite_outlined, 'My Favourites',
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => FavouritePropertyListingScreen(userId: widget.userId)))),
        ];
      case 1: // Loan Eligibility
        return [
          _ActionItem(Icons.verified_outlined, 'Check Eligibility',
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoanEligibilityScreen()))),
        ];
      case 2: // EMI & Budget
        return [
          _ActionItem(Icons.calculate_outlined, 'EMI Calculator',
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EmiCalculatorScreen()))),
          _ActionItem(Icons.balance_outlined, 'Rent vs Buy',
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RentVsBuyScreen()))),
        ];
      case 3: // Due Diligence
        return [
          _ActionItem(Icons.checklist_outlined, 'Property Checklist',
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DueDiligenceScreen()))),
        ];
      case 4: // Apply Loan
        return [
          _ActionItem(Icons.corporate_fare_outlined, 'Banks & Rates',
              () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => BankPage(
                      userId: widget.userId,
                      onNavigateToEmi: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const EmiCalculatorScreen())))))),
          _ActionItem(Icons.account_balance_outlined, 'Apply for Loan',
              () => LoanApplySheet.show(context)),
        ];
      case 5: // Legal Docs
        return [
          _ActionItem(Icons.handshake_outlined, 'Sale Agreement',
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SaleAgreementScreen()))),
          _ActionItem(Icons.receipt_long_outlined, 'Stamp Duty',
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StampDutyScreen()))),
          _ActionItem(Icons.assignment_rounded, 'Legal Services',
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => LegalServicePage(userId: widget.userId)))),
        ];
      default: // Complete (step 6 — no actions)
        return [];
    }
  }

  // ── Completion banner ────────────────────────────────────────────────────────

  Widget _buildCompletionBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.success.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.celebration_rounded,
                color: AppColors.success, size: 26),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Journey Complete!',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.success)),
                SizedBox(height: 3),
                Text(
                  'Congratulations on completing all 7 steps of your home buying journey.',
                  style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
