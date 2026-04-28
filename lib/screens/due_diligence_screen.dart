import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class DueDiligenceScreen extends StatefulWidget {
  const DueDiligenceScreen({super.key});

  @override
  State<DueDiligenceScreen> createState() => _DueDiligenceScreenState();
}

class _DueDiligenceScreenState extends State<DueDiligenceScreen> {
  final Map<String, bool> _checked = {};
  String? _expandedCategory;

  static const List<_Category> _categories = [
    _Category(
      icon: Icons.gavel_outlined,
      color: Color(0xFF1565C0),
      title: 'Title & Ownership',
      items: [
        _Item('Verify original Sale Deed / Title Deed in seller\'s name',
            'Confirms seller is the legal owner. Get certified copy from Sub-Registrar.'),
        _Item('Check chain of title for last 30 years',
            'Ensure continuous and uninterrupted ownership with no missing links.'),
        _Item('Obtain Encumbrance Certificate (EC) for last 15 years',
            'Confirms property is free from mortgages, liens, or legal liabilities.'),
        _Item('Verify property is not part of any family dispute / succession',
            'Check court records. Get NOC from all co-heirs if inherited property.'),
        _Item('Check for any Power of Attorney (PoA) transactions',
            'If sold via PoA, verify PoA is valid, registered, and not revoked.'),
      ],
    ),
    _Category(
      icon: Icons.apartment_outlined,
      color: Color(0xFF2E7D32),
      title: 'Approvals & Clearances',
      items: [
        _Item('Verify Approved Building Plan from local authority',
            'Ensure construction matches the sanctioned plan. Extra floors may be illegal.'),
        _Item('Check Occupancy Certificate (OC) / Completion Certificate (CC)',
            'OC certifies the building is safe and fit for occupation.'),
        _Item('Verify land use / zoning (residential/commercial/agricultural)',
            'Agricultural or industrial land cannot be used for residential construction.'),
        _Item('Check for any demolition or eviction notices',
            'Verify with local municipal authority. Check Collector\'s records.'),
        _Item('Verify FSI/FAR utilization is within limits',
            'Over-built properties may face demolition orders from authorities.'),
      ],
    ),
    _Category(
      icon: Icons.verified_outlined,
      color: Color(0xFF6A1B9A),
      title: 'RERA Verification',
      items: [
        _Item('Verify project is registered under RERA',
            'Check at your state RERA portal. Get RERA registration number from builder.'),
        _Item('Check RERA completion date vs. actual delivery',
            'Delays give buyer right to claim compensation or refund.'),
        _Item('Verify promoter has no ongoing litigation or complaint on RERA portal',
            'Check complaints section on state RERA website.'),
        _Item('Confirm project details on RERA match brochure/agreement',
            'Carpet area on RERA should match what is being sold to you.'),
      ],
    ),
    _Category(
      icon: Icons.account_balance_outlined,
      color: Color(0xFFE65100),
      title: 'Financial Dues',
      items: [
        _Item('Obtain No Dues Certificate from housing society',
            'Confirms seller has no outstanding maintenance dues.'),
        _Item('Verify property tax receipts are up to date',
            'Get latest paid receipt from municipal office or online portal.'),
        _Item('Check for any outstanding home loan / mortgage',
            'Get bank NOC / loan closure letter. Verify in Encumbrance Certificate.'),
        _Item('Confirm electricity and water bills are paid',
            'Obtain paid bills and check for any MSEB/BWSSB/BESCOM arrears.'),
        _Item('Check for BBMP/BMC betterment charges or development charges',
            'Some properties have pending charges payable to the authority.'),
      ],
    ),
    _Category(
      icon: Icons.description_outlined,
      color: Color(0xFF00695C),
      title: 'Documentation',
      items: [
        _Item('Collect all original title documents from seller',
            'Title deeds, previous sale deeds, mutation records, survey sketch.'),
        _Item('Verify property mutation / khata in seller\'s name',
            'Khata/Patta confirms property records in local civic body.'),
        _Item('Check survey/measurement records match actual site',
            'Get survey number and verify with village/city survey records.'),
        _Item('Obtain NOC from society / RWA for transfer',
            'Required for flats. Confirm society has no objection to the sale.'),
        _Item('Verify PAN details of seller for TDS compliance',
            'Buyer must deduct 1% TDS on properties above ₹50 lakhs (Section 194IA).'),
      ],
    ),
    _Category(
      icon: Icons.home_work_outlined,
      color: Color(0xFF283593),
      title: 'Physical Verification',
      items: [
        _Item('Visit the property at different times of the day',
            'Check for water logging, noise, sunlight, and neighborhood conditions.'),
        _Item('Verify actual carpet area vs. sold area',
            'Measure and confirm. Builder sometimes inflates super-built-up area.'),
        _Item('Check structural quality: walls, roof, plumbing, electrical',
            'Consider hiring a structural engineer for independent assessment.'),
        _Item('Verify no encroachment on the property',
            'Physical boundaries should match the title deed plot dimensions.'),
        _Item('Check proximity to amenities: school, hospital, transport',
            'Also check for nuisances: liquor shops, slaughter houses, industries.'),
      ],
    ),
  ];

  int get _total => _categories.fold(0, (sum, c) => sum + c.items.length);
  int get _done  => _checked.values.where((v) => v).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.listingbackground,
      appBar: AppBar(
        title: const Text('Property Due Diligence'),
        foregroundColor: AppColors.white,
      ),
      body: Column(children: [
        _progressHeader(),
        Expanded(child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: _categories.map(_buildCategory).toList(),
        )),
      ]),
    );
  }

  Widget _progressHeader() {
    final pct = _total == 0 ? 0.0 : _done / _total;
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('$_done of $_total checks completed',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: pct == 1.0 ? const Color(0xFFE8F5E9) : AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              pct == 1.0 ? 'Complete ✓' : '${(pct * 100).toInt()}%',
              style: TextStyle(
                fontWeight: FontWeight.w700, fontSize: 12,
                color: pct == 1.0 ? const Color(0xFF2E7D32) : AppColors.primary,
              ),
            ),
          ),
        ]),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct, minHeight: 6,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation(pct == 1.0 ? const Color(0xFF2E7D32) : AppColors.primary),
          ),
        ),
      ]),
    );
  }

  Widget _buildCategory(_Category cat) {
    final isExpanded = _expandedCategory == cat.title;
    final catDone = cat.items.where((i) => _checked[i.title] == true).length;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(children: [
        InkWell(
          onTap: () => setState(() => _expandedCategory = isExpanded ? null : cat.title),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: cat.color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(cat.icon, color: cat.color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(cat.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                Text('$catDone / ${cat.items.length} done',
                    style: TextStyle(fontSize: 11,
                        color: catDone == cat.items.length ? const Color(0xFF2E7D32) : AppColors.textSecondary)),
              ])),
              Icon(isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: AppColors.textSecondary),
            ]),
          ),
        ),
        if (isExpanded) ...[
          const Divider(height: 1),
          ...cat.items.map((item) => _buildItem(item)),
        ],
      ]),
    );
  }

  Widget _buildItem(_Item item) {
    final checked = _checked[item.title] ?? false;
    return InkWell(
      onTap: () => setState(() => _checked[item.title] = !checked),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22, height: 22,
              decoration: BoxDecoration(
                color: checked ? const Color(0xFF2E7D32) : AppColors.white,
                border: Border.all(color: checked ? const Color(0xFF2E7D32) : AppColors.border, width: 2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: checked
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.title,
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w500,
                    color: checked ? AppColors.textSecondary : AppColors.textPrimary,
                    decoration: checked ? TextDecoration.lineThrough : null)),
            const SizedBox(height: 3),
            Text(item.hint, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
          ])),
        ]),
      ),
    );
  }
}

class _Category {
  final IconData icon;
  final Color color;
  final String title;
  final List<_Item> items;
  const _Category({required this.icon, required this.color, required this.title, required this.items});
}

class _Item {
  final String title;
  final String hint;
  const _Item(this.title, this.hint);
}
