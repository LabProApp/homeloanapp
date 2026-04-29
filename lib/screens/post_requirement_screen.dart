import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../commons/common_widget.dart';
import '../services/leads_service.dart';
import '../models/client_lead_model.dart';
import '../utility/money_input_formatter.dart';

const _kPropertyTypeLabels = {
  'APARTMENT':     'Apartment',
  'HOUSE':         'Independent House',
  'BUILDER_FLOOR': 'Builder Floor',
  'PLOT':          'Plot',
  'PG':            'PG / Studio',
  'OFFICE':        'Office',
  'SHOP':          'Shop',
  'SHOWROOM':      'Showroom',
  'CO_WORKING':    'Co-Working',
  'PLOT_SHOP':     'Plot/Shop',
  'AGRICULTURAL':  'Agricultural',
};

class PostRequirementScreen extends StatefulWidget {
  final int userId;
  const PostRequirementScreen({super.key, required this.userId});

  @override
  State<PostRequirementScreen> createState() => _PostRequirementScreenState();
}

class _PostRequirementScreenState extends State<PostRequirementScreen> {
  List<dynamic> _requirements = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await LeadApiService.fetchUserRequirements(widget.userId);
      setState(() => _requirements = data);
    } catch (_) {
      setState(() => _requirements = []);
    }
    setState(() => _loading = false);
  }

  Future<void> _delete(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Requirement'),
        content: const Text('Remove this property requirement?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await LeadApiService.deleteLead(id);
      _load();
      if (mounted) _snack('Requirement deleted');
    } catch (_) {
      if (mounted) _snack('Failed to delete', error: true);
    }
  }

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? AppColors.error : AppColors.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.listingbackground,
      appBar: GradientAppBar(
        titleWidget: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('My Requirements'),
            if (!_loading)
              Text('${_requirements.length} posted',
                  style: const TextStyle(fontSize: 12, color: AppColors.white70, fontWeight: FontWeight.w400)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh_outlined), onPressed: _load),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final posted = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => _RequirementFormScreen(userId: widget.userId)),
          );
          if (posted == true) _load();
        },
        icon: const Icon(Icons.add),
        label: const Text('Post Requirement'),
        backgroundColor: AppColors.primary,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _requirements.isEmpty
              ? _emptyState()
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
                    itemCount: _requirements.length,
                    itemBuilder: (_, i) => _RequirementCard(
                      req: _requirements[i],
                      onEdit: () async {
                        final updated = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => _RequirementFormScreen(
                              userId: widget.userId,
                              existing: _requirements[i],
                            ),
                          ),
                        );
                        if (updated == true) _load();
                      },
                      onDelete: () => _delete(_requirements[i]['id'] as int),
                    ),
                  ),
                ),
    );
  }

  Widget _emptyState() => Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), shape: BoxShape.circle),
                child: const Icon(Icons.search_outlined, size: 36, color: AppColors.primary),
              ),
              const SizedBox(height: 16),
              const Text('No requirements posted yet',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              const Text('Tap + Post Requirement to share what you\'re looking for.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
            ],
          ),
        ),
      );
}

// ── Requirement card ──────────────────────────────────────────────────────────

class _RequirementCard extends StatelessWidget {
  final Map req;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _RequirementCard({required this.req, required this.onEdit, required this.onDelete});

  static final _fmt = NumberFormat('#,##,###');
  static final _dateFmt = DateFormat('dd MMM yyyy');

  String _fmtDate(String? d) {
    if (d == null) return '-';
    try { return _dateFmt.format(DateTime.parse(d)); } catch (_) { return d; }
  }

  @override
  Widget build(BuildContext context) {
    final specs = (req['specifications'] ?? '') as String;
    final budget = req['budget'] ?? req['maxBudget'];
    final minBudget = req['minBudget'];
    final budgetText = (minBudget != null && budget != null)
        ? '₹${_fmt.format(minBudget)} – ₹${_fmt.format(budget)}'
        : budget != null ? '₹${_fmt.format(budget)}' : null;

    final lookingTo = (req['propertyType'] ?? '').toString().contains('RENT') ||
            (req['message'] ?? '').toString().toLowerCase().contains('rent')
        ? 'Rent'
        : 'Buy';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: const [BoxShadow(color: AppColors.shadowLight, blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('Looking to $lookingTo',
                      style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w700)),
                ),
                const Spacer(),
                // Edit
                InkWell(onTap: onEdit, borderRadius: BorderRadius.circular(8),
                  child: const Padding(padding: EdgeInsets.all(6),
                    child: Icon(Icons.edit_outlined, size: 18, color: AppColors.primary))),
                // Delete
                InkWell(onTap: onDelete, borderRadius: BorderRadius.circular(8),
                  child: const Padding(padding: EdgeInsets.all(6),
                    child: Icon(Icons.delete_outline, size: 18, color: AppColors.error))),
              ],
            ),
            const SizedBox(height: 10),
            // Property type + category
            Wrap(spacing: 8, runSpacing: 6, children: [
              if ((req['propertyType'] ?? '').toString().isNotEmpty)
                _chip(Icons.home_outlined, _kPropertyTypeLabels[req['propertyType']] ?? req['propertyType'] as String),
              if ((req['propertyCity'] ?? '').toString().isNotEmpty)
                _chip(Icons.location_on_outlined, req['propertyCity'] as String),
              if (budgetText != null)
                _chip(Icons.account_balance_wallet_outlined, budgetText),
            ]),
            // Specs (beds/baths/floor)
            if (specs.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(children: [
                const Icon(Icons.tune_outlined, size: 13, color: AppColors.textMuted),
                const SizedBox(width: 5),
                Expanded(child: Text(specs,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
              ]),
            ],
            // Message
            if ((req['message'] ?? '').toString().isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.chat_bubble_outline, size: 13, color: AppColors.textMuted),
                const SizedBox(width: 5),
                Expanded(child: Text(req['message'] as String,
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
              ]),
            ],
            const SizedBox(height: 8),
            Text('Posted: ${_fmtDate(req['inquiryDate'] as String?)}',
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }

  static Widget _chip(IconData icon, String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.07),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 11, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)),
        ]),
      );
}

// ── Requirement form (post / edit) ────────────────────────────────────────────

class _RequirementFormScreen extends StatefulWidget {
  final int userId;
  final Map? existing;
  const _RequirementFormScreen({required this.userId, this.existing});

  @override
  State<_RequirementFormScreen> createState() => _RequirementFormScreenState();
}

class _RequirementFormScreenState extends State<_RequirementFormScreen> {
  bool get isEdit => widget.existing != null;

  // Looking to
  String _lookingTo = 'Buy'; // Buy | Rent

  // Category
  String _category = 'Residential'; // Residential | Commercial

  // Property type options (API enum values)
  static const _residentialTypes = ['APARTMENT', 'HOUSE', 'BUILDER_FLOOR', 'PLOT', 'PG'];
  static const _commercialTypes  = ['OFFICE', 'SHOP', 'SHOWROOM', 'CO_WORKING', 'PLOT_SHOP'];
  String? _propertyType;

  // Residential specs
  String? _beds;
  String? _baths;
  String? _floor;

  static const _bedOptions   = ['1', '2', '3', '4', '5+'];
  static const _bathOptions  = ['1', '2', '3', '4+'];
  static const _floorOptions = ['Ground', '1–5', '6–10', '11+', 'Any'];

  // Location & budget
  final _cityCtrl    = TextEditingController();
  final _minBudgetCtrl = TextEditingController();
  final _maxBudgetCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (isEdit) _prefill();
  }

  void _prefill() {
    final e = widget.existing!;
    _lookingTo    = (e['specifications'] ?? '').toString().contains('Rent') ? 'Rent' : 'Buy';
    _propertyType = e['propertyType'] as String?;
    _cityCtrl.text     = (e['propertyCity'] ?? '') as String;
    _messageCtrl.text  = (e['message'] ?? '') as String;
    if (e['minBudget'] != null) _minBudgetCtrl.text = MoneyInputFormatter.format((e['minBudget'] as num));
    if (e['budget'] != null || e['maxBudget'] != null)
      _maxBudgetCtrl.text = MoneyInputFormatter.format(((e['budget'] ?? e['maxBudget']) as num));

    final specs = (e['specifications'] ?? '') as String;
    for (final part in specs.split('|').map((s) => s.trim())) {
      if (part.startsWith('Beds:'))  _beds  = part.replaceFirst('Beds:', '').trim();
      if (part.startsWith('Baths:')) _baths = part.replaceFirst('Baths:', '').trim();
      if (part.startsWith('Floor:')) _floor = part.replaceFirst('Floor:', '').trim();
    }
    if (['OFFICE', 'SHOP', 'SHOWROOM', 'CO_WORKING', 'PLOT_SHOP'].contains(_propertyType)) {
      _category = 'Commercial';
    }
  }

  @override
  void dispose() {
    _cityCtrl.dispose();
    _minBudgetCtrl.dispose();
    _maxBudgetCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  List<String> get _typeOptions =>
      _category == 'Residential' ? _residentialTypes : _commercialTypes;

  String _buildSpecs() {
    final parts = <String>[];
    if (_lookingTo.isNotEmpty) parts.add('Looking To: $_lookingTo');
    if (_beds  != null) parts.add('Beds: $_beds');
    if (_baths != null) parts.add('Baths: $_baths');
    if (_floor != null) parts.add('Floor: $_floor');
    return parts.join(' | ');
  }

  Future<void> _save() async {
    if (_propertyType == null) {
      _snack('Please select a property type', error: true);
      return;
    }
    setState(() => _saving = true);

    final lead = ClientLeadModel(
      id: isEdit ? widget.existing!['id'] as int : null,
      userId: widget.userId,
      leadType: 'PROPERTY_INQUIRY',
      leadSource: 'APP',
      propertyType: _propertyType,
      propertyCity: _cityCtrl.text.trim().isEmpty ? null : _cityCtrl.text.trim(),
      minBudget: MoneyInputFormatter.parse(_minBudgetCtrl.text),
      budget: MoneyInputFormatter.parse(_maxBudgetCtrl.text),
      maxBudget: MoneyInputFormatter.parse(_maxBudgetCtrl.text),
      message: _messageCtrl.text.trim().isEmpty ? null : _messageCtrl.text.trim(),
      specifications: _buildSpecs(),
      status: 'NEW',
      clientName: 'Self',
      mobile: '0000000000',
    );

    try {
      if (isEdit) {
        await LeadApiService.updateLead(
          leadId: widget.existing!['id'].toString(),
          payload: lead.toJson(),
        );
      } else {
        await LeadApiService.createLead(lead);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      _snack(isEdit ? 'Failed to update' : 'Failed to post requirement', error: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? AppColors.error : AppColors.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.listingbackground,
      appBar: GradientAppBar(title: isEdit ? 'Edit Requirement' : 'Post Requirement'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Looking to ─────────────────────────────────────────────
            _sectionTitle('Looking To'),
            const SizedBox(height: 8),
            _segmented(['Buy', 'Rent'], _lookingTo, (v) => setState(() => _lookingTo = v)),

            const SizedBox(height: 20),

            // ── Category ───────────────────────────────────────────────
            _sectionTitle('Category'),
            const SizedBox(height: 8),
            _segmented(['Residential', 'Commercial'], _category, (v) {
              setState(() { _category = v; _propertyType = null; });
            }),

            const SizedBox(height: 20),

            // ── Property type ──────────────────────────────────────────
            _sectionTitle('Property Type'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _typeOptions.map((t) => _selectChip(
                _kPropertyTypeLabels[t] ?? t, _propertyType == t,
                () => setState(() => _propertyType = t),
              )).toList(),
            ),

            const SizedBox(height: 20),

            // ── Residential specs ──────────────────────────────────────
            if (_category == 'Residential') ...[
              _sectionTitle('Bedrooms'),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 8,
                children: _bedOptions.map((b) => _selectChip(b, _beds == b,
                    () => setState(() => _beds = _beds == b ? null : b))).toList()),

              const SizedBox(height: 16),
              _sectionTitle('Bathrooms'),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 8,
                children: _bathOptions.map((b) => _selectChip(b, _baths == b,
                    () => setState(() => _baths = _baths == b ? null : b))).toList()),

              const SizedBox(height: 16),
              _sectionTitle('Floor Preference'),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 8,
                children: _floorOptions.map((f) => _selectChip(f, _floor == f,
                    () => setState(() => _floor = _floor == f ? null : f))).toList()),

              const SizedBox(height: 20),
            ],

            // ── Location ───────────────────────────────────────────────
            _sectionTitle('Preferred City / Location'),
            const SizedBox(height: 8),
            _textField(_cityCtrl, 'e.g. Pune, Baner', Icons.location_on_outlined),

            const SizedBox(height: 20),

            // ── Budget ─────────────────────────────────────────────────
            _sectionTitle('Budget Range (₹)'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _textField(_minBudgetCtrl, 'Min Budget', Icons.arrow_downward_outlined, isNumber: true, isMoney: true)),
                const SizedBox(width: 12),
                Expanded(child: _textField(_maxBudgetCtrl, 'Max Budget', Icons.arrow_upward_outlined, isNumber: true, isMoney: true)),
              ],
            ),

            const SizedBox(height: 20),

            // ── Message ────────────────────────────────────────────────
            _sectionTitle('Additional Requirements'),
            const SizedBox(height: 8),
            TextField(
              controller: _messageCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Describe any specific needs, preferred amenities, timeline, etc.',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.all(14),
                filled: true,
                fillColor: AppColors.white,
              ),
            ),

            const SizedBox(height: 32),

            // ── Submit ─────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: _saving
                    ? const SizedBox(width: 18, height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Icon(isEdit ? Icons.save_outlined : Icons.send_outlined),
                label: Text(isEdit ? 'Update Requirement' : 'Post Requirement',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _sectionTitle(String title) => Text(title,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary));

  Widget _segmented(List<String> options, String selected, ValueChanged<String> onSelect) {
    return Row(
      children: options.map((o) {
        final active = o == selected;
        return Expanded(
          child: GestureDetector(
            onTap: () => onSelect(o),
            child: Container(
              margin: EdgeInsets.only(right: o == options.last ? 0 : 8),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: active ? AppColors.primary : AppColors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: active ? AppColors.primary : AppColors.border),
              ),
              child: Text(o,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: active ? AppColors.white : AppColors.textSecondary)),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _selectChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withOpacity(0.12) : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppColors.primary : AppColors.border),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? AppColors.primary : AppColors.textSecondary)),
      ),
    );
  }

  Widget _textField(TextEditingController ctrl, String hint, IconData icon, {bool isNumber = false, bool isMoney = false}) {
    return TextField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      inputFormatters: isMoney ? [MoneyInputFormatter()] : null,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 18, color: AppColors.textMuted),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        filled: true,
        fillColor: AppColors.white,
      ),
    );
  }
}
