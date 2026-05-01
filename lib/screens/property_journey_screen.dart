import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/property_journey_model.dart';
import '../services/journey_service.dart';
import '../theme/app_colors.dart';
import 'bank_apply_loan_dialog.dart';
import 'banks_listing_screen.dart';
import 'due_diligence_screen.dart';
import 'emi_calculator_screen.dart';
import 'legal_service_providers_listing.dart';
import 'loan_docs_checklist_screen.dart';
import 'loan_eligibility_screen.dart';
import 'sale_agreement_screen.dart';
import 'stamp_duty_screen.dart';

// ── Step metadata ─────────────────────────────────────────────────────────────

class _StepInfo {
  final IconData icon;
  final Color color;
  final String title;
  final String description;
  const _StepInfo(this.icon, this.color, this.title, this.description);
}

const _steps = [
  _StepInfo(
    Icons.home_work_outlined,
    Color(0xFFD97706),
    'Confirm Property Selection',
    'You have selected this property to begin your purchase journey. '
        'Review all details and confirm this is your final choice before proceeding.',
  ),
  _StepInfo(
    Icons.calculate_outlined,
    Color(0xFF2563EB),
    'Calculate Loan Affordability',
    'Check your estimated monthly EMI and find out how much home loan you are '
        'eligible for based on your income and existing obligations.',
  ),
  _StepInfo(
    Icons.fact_check_outlined,
    Color(0xFF7C3AED),
    'Property Due Diligence',
    'Verify title deed, building approvals, RERA registration, encumbrances, '
        'and all legal clearances before making an offer or paying any token amount.',
  ),
  _StepInfo(
    Icons.account_balance_outlined,
    Color(0xFF059669),
    'Apply for Home Loan',
    'Compare home loan interest rates from leading banks and NBFCs, '
        'gather required documents, and submit your loan application.',
  ),
  _StepInfo(
    Icons.gavel_outlined,
    Color(0xFFDC2626),
    'Legal & Documentation',
    'Engage a verified property lawyer for sale deed review, title search, '
        'legal due diligence report, and registration assistance.',
  ),
  _StepInfo(
    Icons.celebration_outlined,
    Color(0xFF059669),
    'Finalise & Register',
    'Execute the sale agreement, pay stamp duty and registration charges, '
        'and register the property in your name to complete the purchase.',
  ),
];

// ── Screen ────────────────────────────────────────────────────────────────────

class PropertyJourneyScreen extends StatefulWidget {
  final PropertyJourneyModel journey;
  final int userId;

  const PropertyJourneyScreen({
    super.key,
    required this.journey,
    required this.userId,
  });

  @override
  State<PropertyJourneyScreen> createState() => _PropertyJourneyScreenState();
}

class _PropertyJourneyScreenState extends State<PropertyJourneyScreen> {
  static final _priceFmt = NumberFormat('#,##,###');
  static final _dateFmt = DateFormat('d MMM');

  late PropertyJourneyModel _journey;

  @override
  void initState() {
    super.initState();
    _journey = widget.journey;
  }

  // ── Step toggle ───────────────────────────────────────────────────────────

  Future<void> _toggleStep(int index) async {
    setState(() {
      final step = _journey.steps[index];
      if (step.status == JourneyStepStatus.completed) {
        step.status = JourneyStepStatus.pending;
        step.completedAt = null;
      } else {
        step.status = JourneyStepStatus.completed;
        step.completedAt = DateTime.now();
      }
      _journey.updatedAt = DateTime.now();
    });
    await JourneyService.save(_journey);
  }

  // ── Navigation helpers ────────────────────────────────────────────────────

  void _push(Widget screen) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));

  void _openEmi() =>
      _push(EmiCalculatorScreen(initialAmount: _journey.propertyPrice));

  void _openLoanEligibility() => _push(const LoanEligibilityScreen());

  void _openDueDiligence() => _push(const DueDiligenceScreen());

  void _openLoanDocs() => _push(const LoanDocsChecklistScreen());

  void _openBanks() =>
      _push(BankPage(userId: widget.userId));

  void _applyLoan() => LoanApplySheet.show(context);

  void _openLegal() =>
      _push(LegalServicePage(userId: widget.userId));

  void _openSaleAgreement() => _push(const SaleAgreementScreen());

  void _openStampDuty() =>
      _push(StampDutyScreen(initialAmount: _journey.propertyPrice));

  // ── Delete journey ────────────────────────────────────────────────────────

  Future<void> _confirmDelete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Journey?'),
        content: const Text(
            'This will remove all progress for this property journey. This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete',
                  style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
    if (ok == true && mounted) {
      await JourneyService.delete(_journey.id);
      if (mounted) Navigator.pop(context);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.listingbackground,
      appBar: AppBar(
        title: const Text('Purchase Journey'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete journey',
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _PropertyHeader(),
            const SizedBox(height: 12),
            _ProgressCard(),
            if (_journey.isComplete) ...[
              const SizedBox(height: 12),
              _CompletionBanner(),
            ],
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              child: _buildStepper(),
            ),
          ],
        ),
      ),
    );
  }

  // ── Property header card ──────────────────────────────────────────────────

  Widget _PropertyHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFFF59E0B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.home_outlined,
                color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _journey.propertyTitle,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (_journey.propertyCity != null) ...[
                  const SizedBox(height: 2),
                  Text(_journey.propertyCity!,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 13)),
                ],
                if (_journey.propertyPrice != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    '₹ ${_priceFmt.format(_journey.propertyPrice)}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Progress card ─────────────────────────────────────────────────────────

  Widget _ProgressCard() {
    final count = _journey.completedCount;
    final progress = count / 6;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '$count of 6 steps completed',
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary),
              ),
              const Spacer(),
              Text('${(progress * 100).round()}%',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _journey.isComplete
                          ? AppColors.success
                          : AppColors.primary)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation(
                  _journey.isComplete ? AppColors.success : AppColors.primary),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Started ${DateFormat("d MMM yyyy").format(_journey.createdAt)}',
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  // ── Completion banner ─────────────────────────────────────────────────────

  Widget _CompletionBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: AppColors.success.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          const Icon(Icons.celebration_rounded,
              color: AppColors.success, size: 32),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Journey Complete! 🎉',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.success)),
                SizedBox(height: 3),
                Text(
                    'Congratulations on completing your property purchase journey.',
                    style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Stepper ───────────────────────────────────────────────────────────────

  Widget _buildStepper() {
    return Column(
      children: List.generate(
        6,
        (i) => _buildStepRow(i),
      ),
    );
  }

  Widget _buildStepRow(int index) {
    final step = _journey.steps[index];
    final isDone = step.status == JourneyStepStatus.completed;
    final isLast = index == 5;
    final info = _steps[index];
    final activeIdx = _journey.activeStepIndex;
    final isActive = index == activeIdx;

    final circleColor = isDone
        ? AppColors.success
        : isActive
            ? info.color
            : AppColors.border;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Left: circle + line ──────────────────────────────────────
          SizedBox(
            width: 38,
            child: Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                      color: circleColor, shape: BoxShape.circle),
                  child: Center(
                    child: isDone
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : Text('${index + 1}',
                            style: TextStyle(
                              color: isActive
                                  ? Colors.white
                                  : AppColors.textMuted,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            )),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: isDone
                          ? AppColors.success.withOpacity(0.35)
                          : AppColors.border,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // ── Right: content ───────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: _buildStepCard(index, info, step, isDone, isActive),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCard(int index, _StepInfo info, JourneyStepState step,
      bool isDone, bool isActive) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDone
            ? AppColors.surfaceSubtle
            : isActive
                ? info.color.withOpacity(0.04)
                : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDone
              ? AppColors.border
              : isActive
                  ? info.color.withOpacity(0.3)
                  : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────
          Row(
            children: [
              Icon(info.icon,
                  size: 18,
                  color: isDone ? AppColors.textMuted : info.color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  info.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDone
                        ? AppColors.textMuted
                        : AppColors.textPrimary,
                    decoration:
                        isDone ? TextDecoration.lineThrough : null,
                    decorationColor: AppColors.textMuted,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              if (isDone)
                _StatusPill('Done', AppColors.success)
              else if (isActive)
                _StatusPill('Up next', info.color),
            ],
          ),

          // ── Completed state ──────────────────────────────────────────
          if (isDone) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.check_circle_outline,
                    size: 13, color: AppColors.success),
                const SizedBox(width: 4),
                Text(
                  step.completedAt != null
                      ? 'Completed ${_dateFmt.format(step.completedAt!)}'
                      : 'Completed',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.success),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => _toggleStep(index),
                  child: const Text('Undo',
                      style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.textMuted)),
                ),
              ],
            ),
          ],

          // ── Pending / active state ───────────────────────────────────
          if (!isDone) ...[
            const SizedBox(height: 8),
            Text(info.description,
                style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.5)),
            if (index != 0) ...[
              const SizedBox(height: 12),
              _buildActions(index, info.color),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _toggleStep(index),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: info.color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    textStyle: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  child: const Text('Mark as Complete'),
                ),
              ),
            ] else ...[
              // Step 0 is auto-completed — show a subtle note
              const SizedBox(height: 8),
              Text(
                'Tap "Mark as Complete" when you have confirmed your property choice.',
                style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                    fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _toggleStep(index),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: info.color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    textStyle: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  child: const Text('Confirm Selection'),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  // ── Per-step action buttons ───────────────────────────────────────────────

  Widget _buildActions(int index, Color color) {
    final btns = _actionButtons(index, color);
    if (btns.isEmpty) return const SizedBox.shrink();
    return Wrap(spacing: 8, runSpacing: 8, children: btns);
  }

  List<Widget> _actionButtons(int index, Color color) {
    OutlinedButton btn(String label, IconData icon, VoidCallback onTap) {
      return OutlinedButton.icon(
        icon: Icon(icon, size: 14),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color.withOpacity(0.5)),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          textStyle: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600),
        ),
        onPressed: onTap,
      );
    }

    switch (index) {
      case 1:
        return [
          btn('EMI Calculator', Icons.calculate_outlined, _openEmi),
          btn('Loan Eligibility', Icons.verified_outlined, _openLoanEligibility),
        ];
      case 2:
        return [
          btn('Due Diligence Checklist', Icons.checklist_outlined, _openDueDiligence),
          btn('Loan Docs Checklist', Icons.folder_outlined, _openLoanDocs),
        ];
      case 3:
        return [
          btn('Compare Banks & Rates', Icons.corporate_fare_outlined, _openBanks),
          btn('Apply for Loan', Icons.send_outlined, _applyLoan),
        ];
      case 4:
        return [
          btn('Find Legal Service Providers', Icons.gavel_outlined, _openLegal),
        ];
      case 5:
        return [
          btn('Sale Agreement', Icons.description_outlined, _openSaleAgreement),
          btn('Stamp Duty Calculator', Icons.receipt_long_outlined, _openStampDuty),
        ];
      default:
        return [];
    }
  }

  // ── Status pill ───────────────────────────────────────────────────────────

  Widget _StatusPill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }
}
