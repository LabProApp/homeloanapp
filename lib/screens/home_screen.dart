import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Callback used by HomeScreen tiles to request navigation to a named section.
typedef HomeNavigate = void Function(HomeAction action);

enum HomeAction {
  buySell,
  rentPg,
  myFavourites,
  myPostings,
  myInquiries,
  myJourneys,
  homeLoan,
  emiCalculator,
  stampDuty,
  rentVsBuy,
  legalServices,
  rentAgreement,
  saleAgreement,
  dueDiligence,
  loanEligibility,
  banks,
  postRequirement,
  startJourney,
}

class HomeScreen extends StatelessWidget {
  final int userId;
  final String userName;
  final String planName;
  final HomeNavigate onNavigate;
  /// Returns true if the given action is locked for the current plan.
  /// Null means all actions are unlocked (safe default).
  final bool Function(HomeAction)? isLocked;
  final VoidCallback? onViewPlans;

  const HomeScreen({
    super.key,
    required this.userId,
    required this.userName,
    this.planName = '',
    required this.onNavigate,
    this.isLocked,
    this.onViewPlans,
  });

  bool _locked(HomeAction action) => isLocked?.call(action) ?? false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.listingbackground,
      body: CustomScrollView(
        slivers: [
          _buildHero(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Journey banner ──────────────────────────────────────
                  _journeyBanner(),
                  const SizedBox(height: 20),

                  // ── Properties ──────────────────────────────────────────
                  _section(context, 'Properties', Icons.home_rounded,
                      AppColors.primary, [
                    _Tile(Icons.sell_outlined,      'Buy / Sell',       'Find & list sale properties',              const Color(0xFF1565C0), HomeAction.buySell),
                    _Tile(Icons.apartment_outlined, 'Rent / PG',        'PG & Rental properties',                   const Color(0xFF00838F), HomeAction.rentPg),
                    _Tile(Icons.favorite_outlined,  'My Favourites',    'Your favourite properties',                AppColors.error,        HomeAction.myFavourites),
                    _Tile(Icons.post_add_outlined,  'Post Requirement', 'Free — share what you\'re looking for',    AppColors.primary,      HomeAction.postRequirement, highlighted: true),
                  ]),
                  const SizedBox(height: 24),

                  // ── Finance & Loans ─────────────────────────────────────
                  _section(context, 'Finance & Loans', Icons.account_balance_rounded,
                      const Color(0xFF1B5E20), [
                    _Tile(Icons.corporate_fare_outlined,  'Banks & Rates',          'Compare bank interest rates',        const Color(0xFF4527A0), HomeAction.banks),
                    _Tile(Icons.account_balance_outlined, 'Inquire Home Loan',      'Explore bank loan offers',           const Color(0xFF1565C0), HomeAction.homeLoan),
                    _Tile(Icons.calculate_outlined,       'EMI Calculator',         'Estimate monthly installment',       const Color(0xFF2E7D32), HomeAction.emiCalculator),
                    _Tile(Icons.verified_outlined,        'Home Loan Eligibility',  'Check your Home loan eligibility',   const Color(0xFF00796B), HomeAction.loanEligibility),
                    _Tile(Icons.balance_outlined,         'Rent vs Buy Calculator', 'Compare renting vs buying',          const Color(0xFF00838F), HomeAction.rentVsBuy),
                  ]),
                  const SizedBox(height: 24),

                  // ── Legal & Documentation ───────────────────────────────
                  _section(context, 'Legal & Documentation', Icons.gavel_rounded,
                      const Color(0xFF6A1B9A), [
                    _Tile(Icons.assignment_rounded,    'Legal Services',     'Reach out to Verified legal vendors',  const Color(0xFF6A1B9A), HomeAction.legalServices),
                    _Tile(Icons.description_outlined,  'Rent Agreement',     'Generate rental agreement',            const Color(0xFF00838F), HomeAction.rentAgreement),
                    _Tile(Icons.handshake_outlined,    'Sale Agreement',     'Generate sale deed agreement',         const Color(0xFF4E342E), HomeAction.saleAgreement),
                    _Tile(Icons.checklist_outlined,    'Property Checklist', 'Property verification checklist',      const Color(0xFFE65100), HomeAction.dueDiligence),
                    _Tile(Icons.receipt_long_outlined, 'Stamp Duty Charges', 'Calculate stamp duty charges',         const Color(0xFF1565C0), HomeAction.stampDuty),
                  ]),
                  const SizedBox(height: 24),

                  // ── My Activity ─────────────────────────────────────────
                  _section(context, 'My Activity', Icons.person_rounded,
                      const Color(0xFF4527A0), [
                    _Tile(Icons.route,                    'My Journeys',     'Track your purchase journeys', const Color(0xFF0277BD), HomeAction.myJourneys),
                    _Tile(Icons.business_center_outlined, 'My Postings',     'Properties you have listed',   const Color(0xFF4527A0), HomeAction.myPostings),
                    _Tile(Icons.groups_outlined,          'Client Inquiries', 'Leads, follow-ups & status',  AppColors.primary,      HomeAction.myInquiries),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Journey banner ─────────────────────────────────────────────────────────
  Widget _journeyBanner() {
    return GestureDetector(
      onTap: () => onNavigate(HomeAction.startJourney),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF8F00), Color(0xFFE65100)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE65100).withOpacity(0.30),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.home_work_rounded, color: Colors.white, size: 16),
            SizedBox(width: 8),
            Text(
              'Start Journey',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
            SizedBox(width: 6),
            Icon(Icons.arrow_forward_rounded, color: Colors.white70, size: 14),
          ],
        ),
      ),
    );
  }

  // ── Hero / greeting ────────────────────────────────────────────────────────
  Widget _buildHero(BuildContext context) {
    final topPad = (MediaQuery.maybeOf(context)?.padding.top ?? 0) + 16;
    return SliverToBoxAdapter(
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        child: Container(
          padding: EdgeInsets.fromLTRB(20, topPad, 20, 36),
          decoration: const BoxDecoration(color: AppColors.navy),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/images/house1.jpg',
                  fit: BoxFit.cover,
                  alignment: Alignment.bottomCenter,
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.navy.withOpacity(0.88),
                        AppColors.slate.withOpacity(0.72),
                        AppColors.primaryDark.withOpacity(0.55),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          'Hello, ${userName.isNotEmpty ? userName.split(' ').first : 'there'} 👋',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                      if (planName.isNotEmpty)
                        _planBadge(planName),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Find. Finance. Finalize.',
                    style: TextStyle(
                        fontSize: 13,
                        color: AppColors.goldAccent,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.4),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'What are you looking for today?',
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  const SizedBox(height: 20),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _heroPill(Icons.home_rounded, 'Buy/Sell',
                            () => onNavigate(HomeAction.buySell),
                            locked: _locked(HomeAction.buySell)),
                        const SizedBox(width: 8),
                        _heroPill(Icons.apartment_rounded, 'Rent/PG',
                            () => onNavigate(HomeAction.rentPg),
                            locked: _locked(HomeAction.rentPg)),
                        const SizedBox(width: 8),
                        _heroPill(Icons.post_add_outlined,
                            'Post Home/\nOffice Req.',
                            () => onNavigate(HomeAction.postRequirement)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _planBadge(String plan) {
    final color = switch (plan.toUpperCase()) {
      'PREMIUM' => AppColors.goldAccent,
      'DELUX'   => const Color(0xFF64B5F6),
      _         => Colors.white60,
    };
    return GestureDetector(
      onTap: onViewPlans,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.55)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.workspace_premium_rounded, size: 12, color: color),
            const SizedBox(width: 4),
            Text(plan,
                style: TextStyle(
                    fontSize: 11,
                    color: color,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4)),
            if (onViewPlans != null) ...[
              const SizedBox(width: 5),
              Icon(Icons.arrow_forward_ios_rounded, size: 9, color: color.withOpacity(0.7)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _heroPill(IconData icon, String label, VoidCallback onTap,
      {bool locked = false}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
          decoration: BoxDecoration(
            color: locked
                ? Colors.white.withOpacity(0.06)
                : AppColors.glass,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: locked
                    ? Colors.white.withOpacity(0.12)
                    : AppColors.glassBorder,
                width: 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(icon,
                      color: locked ? Colors.white38 : Colors.white, size: 26),
                  if (locked)
                    const Positioned(
                      right: -6,
                      top: -4,
                      child: Icon(Icons.lock_rounded,
                          size: 11, color: Colors.white54),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: locked ? Colors.white38 : Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      height: 1.2)),
            ],
          ),
        ),
      ),
    );
  }

  // ── Category section ───────────────────────────────────────────────────────
  Widget _section(BuildContext context, String title, IconData icon,
      Color accent, List<_Tile> tiles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3, height: 18,
              decoration: BoxDecoration(
                  color: accent, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(width: 8),
            Icon(icon, size: 18, color: accent),
            const SizedBox(width: 6),
            Text(title,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
          ],
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 2.6,
          children: tiles
              .map((t) => _TileCard(
                    tile: t,
                    locked: _locked(t.action),
                    onTap: () => onNavigate(t.action),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

// ── Tile model ─────────────────────────────────────────────────────────────────

class _Tile {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final HomeAction action;
  final bool highlighted;
  const _Tile(this.icon, this.title, this.subtitle, this.color, this.action,
      {this.highlighted = false});
}

// ── Tile card widget ───────────────────────────────────────────────────────────

class _TileCard extends StatelessWidget {
  final _Tile tile;
  final bool locked;
  final VoidCallback onTap;

  const _TileCard({required this.tile, required this.locked, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // locked tiles override highlighted: we never render the free-tier gradient
    // as locked, since postRequirement is always free.
    final hi = tile.highlighted && !locked;

    final bg       = locked ? const Color(0xFFF0F0F0) : (hi ? null : AppColors.white);
    final iconBg   = locked ? const Color(0xFFE0E0E0) : (hi ? Colors.white.withOpacity(0.22) : tile.color.withOpacity(0.10));
    final iconColor = locked ? Colors.grey.shade400   : (hi ? Colors.white : tile.color);
    final titleColor   = locked ? Colors.grey.shade400 : (hi ? Colors.white : AppColors.textPrimary);
    final subtitleColor = locked ? Colors.grey.shade400 : (hi ? AppColors.white70 : AppColors.textMuted);
    final borderColor  = locked
        ? Colors.grey.shade300
        : (hi ? Colors.transparent : tile.color.withOpacity(0.18));

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: hi ? null : bg,
          gradient: hi
              ? const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
          boxShadow: locked
              ? null
              : [
                  BoxShadow(
                      color: hi
                          ? AppColors.primary.withOpacity(0.30)
                          : AppColors.shadowLight,
                      blurRadius: hi ? 10 : 6,
                      offset: const Offset(0, 2)),
                ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(tile.icon, color: iconColor, size: 19),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          tile.title,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: titleColor),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (hi) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'FREE',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primaryDark,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ],
                      if (locked) ...[
                        const SizedBox(width: 4),
                        Icon(Icons.lock_rounded,
                            size: 11, color: Colors.grey.shade400),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    locked ? 'Upgrade to unlock' : tile.subtitle,
                    style: TextStyle(
                        fontSize: 10,
                        color: subtitleColor,
                        height: 1.3),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
