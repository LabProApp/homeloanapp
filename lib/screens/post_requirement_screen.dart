import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../commons/common_widget.dart';
import '../models/client_lead_model.dart';
import '../services/leads_service.dart';
import '../theme/app_colors.dart';
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

// ── List screen ───────────────────────────────────────────────────────────────

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
    if (mounted) setState(() => _loading = true);
    try {
      final data = await LeadApiService.fetchUserRequirements(widget.userId);
      if (mounted) setState(() { _requirements = data; _loading = false; });
    } catch (_) {
      if (mounted) setState(() { _requirements = []; _loading = false; });
    }
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
    final body = _loading
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
              );

    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(color: AppColors.listingbackground, child: body),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton.extended(
            heroTag: 'postReqFab',
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
        ),
      ],
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

  static final _fmt     = NumberFormat('#,##,###');
  static final _dateFmt = DateFormat('dd MMM yyyy');

  String _fmtDate(String? d) {
    if (d == null) return '-';
    try { return _dateFmt.format(DateTime.parse(d)); } catch (_) { return d; }
  }

  String _fmtBudget(num? min, num? max) {
    if (min != null && max != null) return '₹${_fmt.format(min)} – ₹${_fmt.format(max)}';
    if (max != null) return '₹${_fmt.format(max)}';
    if (min != null) return '₹${_fmt.format(min)}+';
    return '';
  }

  Future<void> _call(String? mobile) async {
    if (mobile == null || mobile.isEmpty || mobile == '0000000000') return;
    final uri = Uri(scheme: 'tel', path: mobile);
    if (await canLaunchUrl(uri)) launchUrl(uri);
  }

  Future<void> _sms(String? mobile) async {
    if (mobile == null || mobile.isEmpty || mobile == '0000000000') return;
    final uri = Uri(scheme: 'sms', path: mobile);
    if (await canLaunchUrl(uri)) launchUrl(uri);
  }

  Future<void> _email(String? emailAddr) async {
    if (emailAddr == null || emailAddr.isEmpty) return;
    final uri = Uri(scheme: 'mailto', path: emailAddr);
    if (await canLaunchUrl(uri)) launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final specs       = (req['specifications'] ?? '') as String;
    final name        = (req['clientName'] ?? '').toString();
    final mobile      = (req['mobile'] ?? '').toString();
    final emailAddr   = (req['email'] ?? '').toString();
    final city        = (req['propertyCity'] ?? '').toString();
    final propType    = (req['propertyType'] ?? '').toString();
    final minBudget   = req['minBudget'] as num?;
    final maxBudget   = (req['budget'] ?? req['maxBudget']) as num?;
    final budgetText  = _fmtBudget(minBudget, maxBudget);
    final message     = (req['message'] ?? '').toString();

    // Derive looking-to from specs string first, then fallback
    String lookingTo = 'Buy';
    for (final part in specs.split('|').map((s) => s.trim())) {
      if (part.startsWith('Looking To:')) {
        lookingTo = part.replaceFirst('Looking To:', '').trim();
        break;
      }
    }

    final hasPhone  = mobile.isNotEmpty && mobile != '0000000000';
    final hasEmail  = emailAddr.isNotEmpty;

    final lookingToColor = lookingTo == 'Rent' ? AppColors.warning : AppColors.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: const [BoxShadow(color: AppColors.shadowLight, blurRadius: 8, offset: Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Header band ──────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: lookingToColor.withOpacity(0.06),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: lookingToColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('Looking to $lookingTo',
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                ),
                if (propType.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      _kPropertyTypeLabels[propType] ?? propType,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: lookingToColor),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                const Spacer(),
                InkWell(onTap: onEdit, borderRadius: BorderRadius.circular(8),
                    child: const Padding(padding: EdgeInsets.all(6),
                        child: Icon(Icons.edit_outlined, size: 17, color: AppColors.primary))),
                InkWell(onTap: onDelete, borderRadius: BorderRadius.circular(8),
                    child: const Padding(padding: EdgeInsets.all(6),
                        child: Icon(Icons.delete_outline, size: 17, color: AppColors.error))),
              ],
            ),
          ),

          // ── Body ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Name + date row
                Row(
                  children: [
                    const Icon(Icons.person_outline, size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        name.isNotEmpty && name != 'Self' ? name : 'Self',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      ),
                    ),
                    Text(_fmtDate(req['inquiryDate'] as String?),
                        style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  ],
                ),

                const SizedBox(height: 8),

                // Location + budget chips
                Wrap(spacing: 8, runSpacing: 6, children: [
                  if (city.isNotEmpty)
                    _chip(Icons.location_on_outlined, city),
                  if (budgetText.isNotEmpty)
                    _chip(Icons.account_balance_wallet_outlined, budgetText),
                ]),

                // Specs (beds / baths / floor)
                if (specs.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _infoRow(Icons.tune_outlined, _specsDisplay(specs)),
                ],

                // Message
                if (message.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  _infoRow(Icons.chat_bubble_outline, message, maxLines: 2),
                ],

                // Contact info
                if (hasPhone || hasEmail) ...[
                  const Divider(height: 16, thickness: 0.5),
                  if (hasPhone) _infoRow(Icons.phone_outlined, mobile),
                  if (hasEmail) ...[
                    if (hasPhone) const SizedBox(height: 4),
                    _infoRow(Icons.email_outlined, emailAddr),
                  ],
                ],

                // Action buttons — call / SMS / email
                if (hasPhone || hasEmail) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      if (hasPhone) ...[
                        _actionBtn(
                          icon: Icons.call_outlined,
                          label: 'Call',
                          color: AppColors.success,
                          onTap: () => _call(mobile),
                        ),
                        const SizedBox(width: 8),
                        _actionBtn(
                          icon: Icons.sms_outlined,
                          label: 'SMS',
                          color: AppColors.primary,
                          onTap: () => _sms(mobile),
                        ),
                      ],
                      if (hasEmail) ...[
                        if (hasPhone) const SizedBox(width: 8),
                        _actionBtn(
                          icon: Icons.email_outlined,
                          label: 'Email',
                          color: AppColors.warning,
                          onTap: () => _email(emailAddr),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Remove "Looking To: X" part from specs for display (already shown in header)
  String _specsDisplay(String specs) {
    return specs
        .split('|')
        .map((s) => s.trim())
        .where((s) => !s.startsWith('Looking To:'))
        .join(' | ');
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

  static Widget _infoRow(IconData icon, String text, {int maxLines = 1}) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 13, color: AppColors.textMuted),
          const SizedBox(width: 5),
          Expanded(
            child: Text(text,
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ),
        ],
      );

  static Widget _actionBtn({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.10),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.30)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 5),
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
          ]),
        ),
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

  // Intent
  String _lookingTo = 'Buy';

  // Category
  String _category = 'Residential';

  static const _residentialTypes = ['APARTMENT', 'HOUSE', 'BUILDER_FLOOR', 'PLOT', 'PG'];
  static const _commercialTypes  = ['OFFICE', 'SHOP', 'SHOWROOM', 'CO_WORKING', 'PLOT_SHOP'];
  String? _propertyType;

  // Specs
  String? _beds;
  String? _baths;
  String? _floor;

  static const _bedOptions   = ['1', '2', '3', '4', '5+'];
  static const _bathOptions  = ['1', '2', '3', '4+'];
  static const _floorOptions = ['Ground', '1–5', '6–10', '11+', 'Any'];

  // Controllers
  final _nameCtrl      = TextEditingController();
  final _phoneCtrl     = TextEditingController();
  final _emailCtrl     = TextEditingController();
  final _cityCtrl      = TextEditingController();
  final _minBudgetCtrl = TextEditingController();
  final _maxBudgetCtrl = TextEditingController();
  final _messageCtrl   = TextEditingController();

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (isEdit) _prefill();
  }

  void _prefill() {
    final e = widget.existing!;

    // Intent
    final specs = (e['specifications'] ?? '') as String;
    for (final part in specs.split('|').map((s) => s.trim())) {
      if (part.startsWith('Looking To:')) {
        _lookingTo = part.replaceFirst('Looking To:', '').trim();
        break;
      }
    }

    _propertyType = e['propertyType'] as String?;
    if (['OFFICE', 'SHOP', 'SHOWROOM', 'CO_WORKING', 'PLOT_SHOP'].contains(_propertyType)) {
      _category = 'Commercial';
    }

    final name = (e['clientName'] ?? '') as String;
    _nameCtrl.text  = name != 'Self' ? name : '';
    final mob = (e['mobile'] ?? '') as String;
    _phoneCtrl.text = mob != '0000000000' ? mob : '';
    _emailCtrl.text = (e['email'] ?? '') as String;
    _cityCtrl.text  = (e['propertyCity'] ?? '') as String;
    _messageCtrl.text = (e['message'] ?? '') as String;

    if (e['minBudget'] != null)
      _minBudgetCtrl.text = MoneyInputFormatter.format(e['minBudget'] as num);
    final maxB = e['budget'] ?? e['maxBudget'];
    if (maxB != null)
      _maxBudgetCtrl.text = MoneyInputFormatter.format(maxB as num);

    for (final part in specs.split('|').map((s) => s.trim())) {
      if (part.startsWith('Beds:'))  _beds  = part.replaceFirst('Beds:', '').trim();
      if (part.startsWith('Baths:')) _baths = part.replaceFirst('Baths:', '').trim();
      if (part.startsWith('Floor:')) _floor = part.replaceFirst('Floor:', '').trim();
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
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
    parts.add('Looking To: $_lookingTo');
    if (_beds  != null) parts.add('Beds: $_beds');
    if (_baths != null) parts.add('Baths: $_baths');
    if (_floor != null) parts.add('Floor: $_floor');
    return parts.join(' | ');
  }

  String? _validate() {
    // Mandatory: city
    if (_cityCtrl.text.trim().isEmpty) return 'Please enter a preferred city or location';
    // Mandatory: either phone or email
    final phone = _phoneCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    if (phone.isEmpty && email.isEmpty) return 'Please provide at least a phone number or email';
    if (phone.isNotEmpty) {
      final digits = phone.replaceAll(RegExp(r'\D'), '');
      if (digits.length != 10 && !(digits.length == 12 && digits.startsWith('91'))) {
        return 'Please enter a valid 10-digit mobile number';
      }
    }
    if (email.isNotEmpty && !RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email)) {
      return 'Please enter a valid email address';
    }
    if (_propertyType == null) return 'Please select a property type';
    return null;
  }

  Future<void> _save() async {
    final err = _validate();
    if (err != null) { _snack(err, error: true); return; }

    setState(() => _saving = true);

    final phone = _phoneCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final name  = _nameCtrl.text.trim();

    final lead = ClientLeadModel(
      id:           isEdit ? widget.existing!['id'] as int : null,
      userId:       widget.userId,
      leadType:     'PROPERTY_INQUIRY',
      leadSource:   'APP',
      clientName:   name.isNotEmpty ? name : 'Self',
      mobile:       phone.isNotEmpty ? phone : '0000000000',
      email:        email.isNotEmpty ? email : null,
      propertyType: _propertyType,
      propertyCity: _cityCtrl.text.trim(),
      minBudget:    MoneyInputFormatter.parse(_minBudgetCtrl.text),
      budget:       MoneyInputFormatter.parse(_maxBudgetCtrl.text),
      maxBudget:    MoneyInputFormatter.parse(_maxBudgetCtrl.text),
      message:      _messageCtrl.text.trim().isEmpty ? null : _messageCtrl.text.trim(),
      specifications: _buildSpecs(),
      status:       'NEW',
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

            // ── Contact details card ───────────────────────────────────
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader(Icons.person_outline, 'Contact Details'),
                  const SizedBox(height: 14),
                  _textField(_nameCtrl, 'Full Name (optional)', Icons.badge_outlined,
                      keyboardType: TextInputType.name),
                  const SizedBox(height: 12),
                  _textField(
                    _phoneCtrl, 'Phone Number *', Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
                  ),
                  const SizedBox(height: 12),
                  _textField(_emailCtrl, 'Email Address', Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 4),
                  const Text('* Phone or email is required',
                      style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Intent card ────────────────────────────────────────────
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader(Icons.search_outlined, 'What are you looking for?'),
                  const SizedBox(height: 14),
                  _label('Looking To *'),
                  const SizedBox(height: 8),
                  _segmented(['Buy', 'Rent'], _lookingTo, (v) => setState(() => _lookingTo = v)),
                  const SizedBox(height: 16),
                  _label('Category'),
                  const SizedBox(height: 8),
                  _segmented(['Residential', 'Commercial'], _category, (v) {
                    setState(() { _category = v; _propertyType = null; });
                  }),
                  const SizedBox(height: 16),
                  _label('Property Type *'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: _typeOptions.map((t) => _selectChip(
                      _kPropertyTypeLabels[t] ?? t, _propertyType == t,
                      () => setState(() => _propertyType = t),
                    )).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Residential specs card ─────────────────────────────────
            if (_category == 'Residential')
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionHeader(Icons.tune_outlined, 'Specifications'),
                    const SizedBox(height: 14),
                    _label('Bedrooms'),
                    const SizedBox(height: 8),
                    Wrap(spacing: 8, runSpacing: 8,
                        children: _bedOptions.map((b) => _selectChip(b, _beds == b,
                            () => setState(() => _beds = _beds == b ? null : b))).toList()),
                    const SizedBox(height: 14),
                    _label('Bathrooms'),
                    const SizedBox(height: 8),
                    Wrap(spacing: 8, runSpacing: 8,
                        children: _bathOptions.map((b) => _selectChip(b, _baths == b,
                            () => setState(() => _baths = _baths == b ? null : b))).toList()),
                    const SizedBox(height: 14),
                    _label('Floor Preference'),
                    const SizedBox(height: 8),
                    Wrap(spacing: 8, runSpacing: 8,
                        children: _floorOptions.map((f) => _selectChip(f, _floor == f,
                            () => setState(() => _floor = _floor == f ? null : f))).toList()),
                  ],
                ),
              ),

            if (_category == 'Residential') const SizedBox(height: 12),

            // ── Location + budget card ─────────────────────────────────
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader(Icons.location_on_outlined, 'Location & Budget'),
                  const SizedBox(height: 14),
                  _label('City / Location *'),
                  const SizedBox(height: 8),
                  _textField(_cityCtrl, 'e.g. Pune, Baner', Icons.location_on_outlined),
                  const SizedBox(height: 14),
                  _label('Budget Range (₹)'),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(child: _textField(_minBudgetCtrl, 'Min', Icons.arrow_downward_outlined,
                        isNumber: true, isMoney: true)),
                    const SizedBox(width: 12),
                    Expanded(child: _textField(_maxBudgetCtrl, 'Max', Icons.arrow_upward_outlined,
                        isNumber: true, isMoney: true)),
                  ]),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Additional details card ────────────────────────────────
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader(Icons.notes_outlined, 'Additional Details'),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _messageCtrl,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Describe specific needs, amenities, timeline, etc.',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.all(14),
                      filled: true,
                      fillColor: AppColors.listingbackground,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Submit ─────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
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

  Widget _card({required Widget child}) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: const [BoxShadow(color: AppColors.shadowLight, blurRadius: 4, offset: Offset(0, 2))],
        ),
        child: child,
      );

  Widget _sectionHeader(IconData icon, String title) => Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.10),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: AppColors.primary),
          ),
          const SizedBox(width: 10),
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        ],
      );

  Widget _label(String text) => Text(text,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary));

  Widget _segmented(List<String> options, String selected, ValueChanged<String> onSelect) {
    return Row(
      children: options.map((o) {
        final active = o == selected;
        return Expanded(
          child: GestureDetector(
            onTap: () => onSelect(o),
            child: Container(
              margin: EdgeInsets.only(right: o == options.last ? 0 : 8),
              padding: const EdgeInsets.symmetric(vertical: 11),
              decoration: BoxDecoration(
                color: active ? AppColors.primary : AppColors.listingbackground,
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.listingbackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppColors.primary : AppColors.border),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? AppColors.white : AppColors.textSecondary)),
      ),
    );
  }

  Widget _textField(
    TextEditingController ctrl,
    String hint,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    bool isNumber = false,
    bool isMoney  = false,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : keyboardType,
      inputFormatters: isMoney ? [MoneyInputFormatter()] : inputFormatters,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 18, color: AppColors.textMuted),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        filled: true,
        fillColor: AppColors.listingbackground,
      ),
    );
  }
}
