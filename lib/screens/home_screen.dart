import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Callback used by HomeScreen tiles to request navigation to a named section.
typedef HomeNavigate = void Function(_HomeAction action);

enum _HomeAction {
  buySell,
  rentPg,
  myFavourites,
  myPostings,
  myInquiries,
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
}

class HomeScreen extends StatelessWidget {
  final int userId;
  final String userName;
  final HomeNavigate onNavigate;

  const HomeScreen({
    super.key,
    required this.userId,
    required this.userName,
    required this.onNavigate,
  });

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
                  // ── Properties ──────────────────────────────────────────
                  _section(context, 'Properties', Icons.home_rounded,
                      AppColors.primary, [
                    _Tile(Icons.sell_outlined,      'Buy / Sell',    'Find & list sale properties',  const Color(0xFF1565C0), _HomeAction.buySell),
                    _Tile(Icons.apartment_outlined, 'Rent / PG',     'Rental & PG listings',         const Color(0xFF00838F), _HomeAction.rentPg),
                    _Tile(Icons.favorite_outlined,  'My Favourites', 'Your favourite properties',    AppColors.error,        _HomeAction.myFavourites),
                  ]),
                  const SizedBox(height: 24),

                  // ── Finance & Loans ─────────────────────────────────────
                  _section(context, 'Finance & Loans', Icons.account_balance_rounded,
                      const Color(0xFF1B5E20), [
                    _Tile(Icons.calculate_outlined,       'EMI Calculator',  'Estimate monthly instalment',  const Color(0xFF2E7D32), _HomeAction.emiCalculator),
                    _Tile(Icons.account_balance_outlined, 'Apply Home Loan', 'Explore bank loan offers',     const Color(0xFF1565C0), _HomeAction.homeLoan),
                    _Tile(Icons.verified_outlined,        'Home Loan Eligibility', 'Check your loan eligibility', const Color(0xFF00796B), _HomeAction.loanEligibility),
                    _Tile(Icons.corporate_fare_outlined,  'Banks & Rates',   'Compare bank interest rates',  const Color(0xFF4527A0), _HomeAction.banks),
                    _Tile(Icons.balance_outlined,         'Rent vs Buy Calculator', 'Compare renting vs buying', const Color(0xFF00838F), _HomeAction.rentVsBuy),
                  ]),
                  const SizedBox(height: 24),

                  // ── Legal & Documentation ───────────────────────────────
                  _section(context, 'Legal & Documentation', Icons.gavel_rounded,
                      const Color(0xFF6A1B9A), [
                    _Tile(Icons.receipt_long_outlined, 'Stamp Duty Charges', 'Calculate stamp duty charges', const Color(0xFF1565C0), _HomeAction.stampDuty),
                    _Tile(Icons.description_outlined,  'Rent Agreement',  'Generate rental agreement',      const Color(0xFF00838F), _HomeAction.rentAgreement),
                    _Tile(Icons.handshake_outlined,    'Sale Agreement',  'Generate sale deed agreement',   const Color(0xFF4E342E), _HomeAction.saleAgreement),
                    _Tile(Icons.assignment_rounded,    'Legal Services',  'Find verified legal vendors',    const Color(0xFF6A1B9A), _HomeAction.legalServices),
                    _Tile(Icons.checklist_outlined,    'Property Checklist', 'Property verification checklist', const Color(0xFFE65100), _HomeAction.dueDiligence),
                  ]),
                  const SizedBox(height: 24),

                  // ── My Activity ─────────────────────────────────────────
                  _section(context, 'My Activity', Icons.person_rounded,
                      const Color(0xFF4527A0), [
                    _Tile(Icons.business_center_outlined, 'My Postings',     'Properties you have listed',   const Color(0xFF4527A0), _HomeAction.myPostings),
                    _Tile(Icons.groups_outlined,          'Client Inquiries', 'Leads, follow-ups & status',  AppColors.primary,      _HomeAction.myInquiries),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Hero / greeting ────────────────────────────────────────────────────────
  Widget _buildHero(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.fromLTRB(
            20, MediaQuery.of(context).padding.top + 16, 20, 24),
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, ${userName.isNotEmpty ? userName.split(' ').first : 'there'} 👋',
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white),
            ),
            const SizedBox(height: 4),
            const Text(
              'What are you looking for today?',
              style: TextStyle(fontSize: 14, color: Colors.white70),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _heroPill(Icons.home_rounded,       'Buy/Sell',     () => onNavigate(_HomeAction.buySell)),
                const SizedBox(width: 8),
                _heroPill(Icons.apartment_rounded,  'Rent/PG',      () => onNavigate(_HomeAction.rentPg)),
                const SizedBox(width: 8),
                _heroPill(Icons.calculate_outlined, 'EMI Calculator', () => onNavigate(_HomeAction.emiCalculator)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _heroPill(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.25)),
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(height: 4),
              Text(label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
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
              .map((t) => _TileCard(tile: t, onTap: () => onNavigate(t.action)))
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
  final _HomeAction action;
  const _Tile(this.icon, this.title, this.subtitle, this.color, this.action);
}

// ── Tile card widget ───────────────────────────────────────────────────────────

class _TileCard extends StatelessWidget {
  final _Tile tile;
  final VoidCallback onTap;

  const _TileCard({required this.tile, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: tile.color.withOpacity(0.18)),
          boxShadow: const [
            BoxShadow(
                color: AppColors.shadowLight,
                blurRadius: 6,
                offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: tile.color.withOpacity(0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(tile.icon, color: tile.color, size: 19),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    tile.title,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    tile.subtitle,
                    style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textMuted,
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
