import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class LoanDocsChecklistScreen extends StatefulWidget {
  const LoanDocsChecklistScreen({super.key});

  @override
  State<LoanDocsChecklistScreen> createState() => _LoanDocsChecklistScreenState();
}

class _LoanDocsChecklistScreenState extends State<LoanDocsChecklistScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  final Map<String, bool> _checkedSalaried = {};
  final Map<String, bool> _checkedSelfEmp  = {};

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _tab.addListener(() => setState(() {}));
  }

  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  static const List<_DocCategory> _salariedCategories = [
    _DocCategory(icon: Icons.person_outlined, color: Color(0xFF1565C0), title: 'Identity & Address Proof',
      items: [
        _DocItem('Aadhaar Card', 'Both sides. Linked to mobile for e-KYC.'),
        _DocItem('PAN Card', 'Mandatory for all loan applications.'),
        _DocItem('Passport (if available)', 'Accepted as both ID and address proof.'),
        _DocItem('Voter ID / Driving Licence', 'Either one as additional ID proof.'),
        _DocItem('Utility Bill / Bank Statement (Address)', 'Latest, within 3 months, for current address.'),
        _DocItem('Passport-size photographs', 'Minimum 2–3 recent colour photos.'),
      ]),
    _DocCategory(icon: Icons.attach_money, color: Color(0xFF2E7D32), title: 'Income Documents',
      items: [
        _DocItem('Last 3 months salary slips', 'Original or authenticated copy from employer.'),
        _DocItem('Form 16 (last 2 years)', 'Issued by employer. Shows TDS deducted and CTC.'),
        _DocItem('Last 6 months bank statements', 'Savings/salary account showing salary credits.'),
        _DocItem('Latest appointment/offer letter', 'Shows designation and CTC.'),
        _DocItem('Employment certificate / confirmation letter', 'Certifying current employment tenure.'),
        _DocItem('IT Returns (ITR) for last 2 years', 'Filed ITR with acknowledgement, if applicable.'),
      ]),
    _DocCategory(icon: Icons.home_outlined, color: Color(0xFF6A1B9A), title: 'Property Documents',
      items: [
        _DocItem('Agreement to Sell / Beana', 'Signed copy between buyer and seller.'),
        _DocItem('Title / Sale Deed of property', 'Original or certified copy.'),
        _DocItem('Approved building plan', 'Sanctioned by local authority.'),
        _DocItem('Encumbrance Certificate (EC)', 'Last 15 years, from Sub-Registrar.'),
        _DocItem('Property tax receipts', 'Latest 2–3 years paid receipts.'),
        _DocItem('NOC from society / builder', 'For resale flat or under-construction property.'),
        _DocItem('Occupancy Certificate (if ready possession)', 'Mandatory for many banks.'),
        _DocItem('Construction cost estimate (if self-construction)', 'From a registered engineer/architect.'),
      ]),
    _DocCategory(icon: Icons.account_balance_outlined, color: Color(0xFFE65100), title: 'Loan & Bank Formalities',
      items: [
        _DocItem('Duly filled loan application form', 'Signed by all applicants / co-applicants.'),
        _DocItem('Cheque for processing fee', 'Or online payment as per bank policy.'),
        _DocItem('Existing loan statements (if any)', 'Last 12 months. For FOIR calculation.'),
        _DocItem('Co-applicant documents (if applicable)', 'Same set as primary applicant.'),
      ]),
  ];

  static const List<_DocCategory> _selfEmpCategories = [
    _DocCategory(icon: Icons.person_outlined, color: Color(0xFF1565C0), title: 'Identity & Address Proof',
      items: [
        _DocItem('Aadhaar Card', 'Both sides.'),
        _DocItem('PAN Card (personal)', 'Mandatory for individual and business.'),
        _DocItem('Voter ID / Passport / Driving Licence', 'For address proof.'),
        _DocItem('Passport-size photographs', 'Minimum 2–3 recent colour photos.'),
      ]),
    _DocCategory(icon: Icons.business_outlined, color: Color(0xFF2E7D32), title: 'Business Proof',
      items: [
        _DocItem('Business registration certificate', 'Partnership deed / MOA-AOA / Shops Act.'),
        _DocItem('GST registration certificate (if applicable)', 'With GSTIN.'),
        _DocItem('Business address proof', 'Utility bill or rent agreement for office.'),
        _DocItem('PAN Card of business entity', 'For company/LLP/partnership.'),
        _DocItem('Udyam / MSME registration (if applicable)', 'Helps in getting lower processing fee.'),
      ]),
    _DocCategory(icon: Icons.receipt_long_outlined, color: Color(0xFF6A1B9A), title: 'Income Documents',
      items: [
        _DocItem('ITR with computation (last 3 years)', 'Filed with acknowledgement receipt.'),
        _DocItem('CA Certified P&L account (last 3 years)', 'Audited or CA-certified statements.'),
        _DocItem('Balance Sheet (last 3 years)', 'Audited by chartered accountant.'),
        _DocItem('Last 12 months business bank statements', 'Primary business current account.'),
        _DocItem('Last 6 months personal bank statements', 'Personal savings account.'),
        _DocItem('GST returns (last 1 year)', 'GSTR-3B or GSTR-1 as applicable.'),
      ]),
    _DocCategory(icon: Icons.home_outlined, color: Color(0xFFE65100), title: 'Property Documents',
      items: [
        _DocItem('Agreement to Sell / Beana', 'Signed copy between buyer and seller.'),
        _DocItem('Title / Sale Deed', 'Original or certified copy.'),
        _DocItem('Approved building plan', 'Sanctioned by local authority.'),
        _DocItem('Encumbrance Certificate (EC)', 'Last 15 years from Sub-Registrar.'),
        _DocItem('Property tax receipts', 'Latest 2–3 years.'),
        _DocItem('NOC from society / builder', 'If resale or under-construction.'),
        _DocItem('Occupancy Certificate (if ready possession)', 'Required by most banks.'),
      ]),
    _DocCategory(icon: Icons.account_balance_outlined, color: Color(0xFF283593), title: 'Loan Formalities',
      items: [
        _DocItem('Duly filled loan application form', 'All applicants to sign.'),
        _DocItem('Cheque for processing fee', 'Or online payment.'),
        _DocItem('Existing loan statements', 'For FOIR / repayment track record.'),
        _DocItem('Co-applicant documents (if applicable)', 'Full set for co-applicant.'),
      ]),
  ];

  @override
  Widget build(BuildContext context) {
    final isSalaried = _tab.index == 0;
    final cats       = isSalaried ? _salariedCategories : _selfEmpCategories;
    final checked    = isSalaried ? _checkedSalaried : _checkedSelfEmp;
    final total      = cats.fold(0, (s, c) => s + c.items.length);
    final done       = checked.values.where((v) => v).length;

    return Scaffold(
      backgroundColor: AppColors.listingbackground,
      appBar: AppBar(
        title: const Text('Loan Document Checklist'),
        foregroundColor: AppColors.white,
        bottom: TabBar(
          controller: _tab,
          indicatorColor: AppColors.white,
          labelColor: AppColors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(text: 'Salaried'),
            Tab(text: 'Self-Employed'),
          ],
        ),
      ),
      body: Column(children: [
        _progressBar(done, total),
        Expanded(child: TabBarView(
          controller: _tab,
          children: [
            _buildList(_salariedCategories, _checkedSalaried),
            _buildList(_selfEmpCategories, _checkedSelfEmp),
          ],
        )),
      ]),
    );
  }

  Widget _progressBar(int done, int total) {
    final pct = total == 0 ? 0.0 : done / total;
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('$done of $total documents ready',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          Text('${(pct * 100).toInt()}%',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.primary)),
        ]),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct, minHeight: 6,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation(
              pct == 1.0 ? const Color(0xFF2E7D32) : AppColors.primary),
          ),
        ),
      ]),
    );
  }

  Widget _buildList(List<_DocCategory> cats, Map<String, bool> checked) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: cats.map((c) => _buildCategory(c, checked)).toList(),
    );
  }

  Widget _buildCategory(_DocCategory cat, Map<String, bool> checked) {
    final catDone = cat.items.where((i) => checked[i.title] == true).length;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(children: [
        Padding(
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
              Text('$catDone / ${cat.items.length} ready',
                  style: TextStyle(fontSize: 11,
                      color: catDone == cat.items.length ? const Color(0xFF2E7D32) : AppColors.textSecondary)),
            ])),
          ]),
        ),
        const Divider(height: 1),
        ...cat.items.map((item) => _buildDocItem(item, checked)),
      ]),
    );
  }

  Widget _buildDocItem(_DocItem doc, Map<String, bool> checked) {
    final isReady = checked[doc.title] ?? false;
    return InkWell(
      onTap: () => setState(() => checked[doc.title] = !isReady),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22, height: 22,
              decoration: BoxDecoration(
                color: isReady ? const Color(0xFF2E7D32) : AppColors.white,
                border: Border.all(
                    color: isReady ? const Color(0xFF2E7D32) : AppColors.border, width: 2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: isReady ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(doc.title,
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w500,
                    color: isReady ? AppColors.textSecondary : AppColors.textPrimary,
                    decoration: isReady ? TextDecoration.lineThrough : null)),
            const SizedBox(height: 2),
            Text(doc.hint, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
          ])),
        ]),
      ),
    );
  }
}

class _DocCategory {
  final IconData icon;
  final Color color;
  final String title;
  final List<_DocItem> items;
  const _DocCategory({required this.icon, required this.color, required this.title, required this.items});
}

class _DocItem {
  final String title;
  final String hint;
  const _DocItem(this.title, this.hint);
}
