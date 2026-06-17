import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../commons/common_widget.dart';
import '../theme/app_colors.dart';

/// Comprehensive side-by-side feature comparison for BASIC / DELUX / PREMIUM.
///
/// Typically pushed from [SubscriptionScreen] via the "Compare features" link.
/// The footer CTA pops back to the caller (or falls back to the subscription
/// screen if this was the root route).
class PlanFeaturesScreen extends StatelessWidget {
  const PlanFeaturesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.listingbackground,
      appBar: GradientAppBar(
        titleWidget: const Text(
          'Plan Comparison',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),
        ),
      ),
      body: Column(
        children: [
          const _PlanHeaderRow(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ..._kSections.map(_SectionWidget.new),
                  const _FooterCta(),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Data ────────────────────────────────────────────────────────────────────

class _Section {
  final String title;
  final List<_FRow> rows;
  const _Section(this.title, this.rows);
}

class _FRow {
  final String name;
  final bool basic;
  final bool delux;
  final bool premium;
  // Non-empty label overrides the check/cross icon for that plan cell.
  final String basicLabel;
  final String deluxLabel;
  final String premiumLabel;

  const _FRow(
    this.name,
    this.basic,
    this.delux,
    this.premium, [
    this.basicLabel = '',
    this.deluxLabel = '',
    this.premiumLabel = '',
  ]);
}

const _kSections = <_Section>[
  _Section('Properties & Browsing', [
    _FRow('Browse Buy/Sell listings',   true,  true,  true),
    _FRow('Browse Rent/PG listings',    true,  true,  true),
    _FRow('My Favourites',              true,  true,  true),
  ]),
  _Section('Post & Leads', [
    _FRow('Post Requirement (free lead)', true,  true,  true),
    _FRow('Post Property Listings',       false, true,  true, '', 'up to 250', 'up to 500'),
  ]),
  _Section('Calculators & Tools', [
    _FRow('EMI Calculator',              true, true, true),
    _FRow('Stamp Duty Calculator',       true, true, true),
    _FRow('Rent vs Buy Calculator',      true, true, true),
    _FRow('Loan Eligibility Calculator', true, true, true),
    _FRow('Due Diligence Checklist',     true, true, true),
  ]),
  _Section('Finance & Loans', [
    _FRow('Bank Rates Comparison',  false, true, true),
    _FRow('Apply for Home Loan',    false, true, true),
  ]),
  _Section('Home Buying Journey', [
    _FRow('Journey Tracker',        true, true, true),
  ]),
  _Section('Documentation & Legal', [
    _FRow('Rent Agreements',            false, false, true),
    _FRow('Sale Agreements',            false, false, true),
    _FRow('Legal Service Providers',    false, false, true),
  ]),
];

// ── Widgets ─────────────────────────────────────────────────────────────────

const _kColWidth = 68.0;
const _kBasicColor  = Color(0xFF64748B);
const _kDeluxColor  = Color(0xFF1565C0);
const _kPremiumColor = AppColors.primaryDark; // 0xFFB45309

class _PlanHeaderRow extends StatelessWidget {
  const _PlanHeaderRow();

  static final _fmt = NumberFormat('#,##,###');

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.navy,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Feature',
              style: TextStyle(
                  color: AppColors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3),
            ),
          ),
          _HeaderCell('BASIC',   'Free',                     _kBasicColor),
          _HeaderCell('DELUX',   '₹${_fmt.format(9999)}',    _kDeluxColor),
          _HeaderCell('PREMIUM', '₹${_fmt.format(19999)}',   _kPremiumColor),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String plan;
  final String price;
  final Color color;
  const _HeaderCell(this.plan, this.price, this.color);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _kColWidth,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: color.withOpacity(0.85),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              plan,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.4),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            price,
            style:
                const TextStyle(color: AppColors.white70, fontSize: 9),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SectionWidget extends StatelessWidget {
  final _Section section;
  const _SectionWidget(this.section);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          color: AppColors.scaffoldBg,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
          child: Text(
            section.title.toUpperCase(),
            style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.textMuted,
                letterSpacing: 0.7),
          ),
        ),
        ...section.rows.map(_FeatureRowWidget.new),
      ],
    );
  }
}

class _FeatureRowWidget extends StatelessWidget {
  final _FRow row;
  const _FeatureRowWidget(this.row);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
            bottom: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              row.name,
              style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textSecondary,
                  height: 1.35),
            ),
          ),
          _Cell(row.basic,   row.basicLabel,   _kBasicColor),
          _Cell(row.delux,   row.deluxLabel,   _kDeluxColor),
          _Cell(row.premium, row.premiumLabel, _kPremiumColor),
        ],
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  final bool enabled;
  final String label;
  final Color planColor;
  const _Cell(this.enabled, this.label, this.planColor);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _kColWidth,
      child: Center(
        child: label.isNotEmpty
            ? Text(
                label,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: planColor),
                textAlign: TextAlign.center,
              )
            : Icon(
                enabled
                    ? Icons.check_circle_rounded
                    : Icons.cancel_rounded,
                size: 18,
                color: enabled ? AppColors.success : AppColors.disabled,
              ),
      ),
    );
  }
}

class _FooterCta extends StatelessWidget {
  const _FooterCta();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.navy, AppColors.slate],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            'Ready to upgrade?',
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          const Text(
            'Visit Plans to request an upgrade or change.',
            style: TextStyle(color: AppColors.white70, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              },
              child: const Text(
                'Back to Plans',
                style:
                    TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
