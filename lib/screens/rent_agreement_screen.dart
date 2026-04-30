import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utility/money_input_formatter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../theme/app_colors.dart';
import '../commons/common_widget.dart';
import '../templates/rent_agreement_template.dart';

// ── Main Form Screen ─────────────────────────────────────────────────────────

class RentAgreementScreen extends StatefulWidget {
  const RentAgreementScreen({super.key});

  @override
  State<RentAgreementScreen> createState() => _RentAgreementScreenState();
}

class _RentAgreementScreenState extends State<RentAgreementScreen> {
  final _formKey = GlobalKey<FormState>();
  int _step = 0;

  // Property
  final _propAddressCtrl   = TextEditingController();
  final _propCityCtrl      = TextEditingController();
  final _propStateCtrl     = TextEditingController();
  final _propPincodeCtrl   = TextEditingController();
  String _propType         = 'Residential Flat';
  String _furnishing       = 'Semi-Furnished';
  DateTime _startDate      = DateTime.now();

  // Owner (Licensor)
  final _ownerNameCtrl     = TextEditingController();
  final _ownerAddrCtrl     = TextEditingController();
  final _ownerIdNoCtrl     = TextEditingController();
  String _ownerIdType      = 'Aadhaar';
  final _ownerPhoneCtrl    = TextEditingController();

  // Tenant (Licensee)
  final _tenantNameCtrl    = TextEditingController();
  final _tenantAddrCtrl    = TextEditingController();
  final _tenantIdNoCtrl    = TextEditingController();
  String _tenantIdType     = 'Aadhaar';
  final _tenantPhoneCtrl   = TextEditingController();

  // Financial
  final _rentCtrl          = TextEditingController();
  final _depositCtrl       = TextEditingController();
  final _maintenanceCtrl   = TextEditingController();
  int _durationMonths      = 11;
  int _noticePeriod        = 1;
  int _lockIn              = 0;
  String _rentDay          = '5th';

  // Furnishing items
  final Map<String, bool> _furnishItems = {
    'Bed': false, 'Wardrobe': false, 'Sofa': false, 'Dining Table': false,
    'Refrigerator': false, 'Washing Machine': false, 'AC': false, 'Geyser': false,
    'TV': false, 'Microwave': false, 'Curtains': false, 'Fans': false,
  };

  // T&Cs (additional)
  final _termsCtrl = TextEditingController(text:
    '1. The Tenant shall use the premises only for residential purposes.\n'
    '2. The Tenant shall not sublet or assign the premises without prior written consent of the Owner.\n'
    '3. The Tenant shall keep the premises clean and shall not make any structural alterations.\n'
    '4. The Owner shall be responsible for major repairs. Minor repairs shall be borne by the Tenant.\n'
    '5. The Tenant shall pay electricity, water and other utility bills directly.\n'
    '6. Pets are not allowed unless specifically agreed in writing.\n'
    '7. The security deposit shall be refunded within 30 days of vacation, subject to deductions for damages.',
  );

  static const _propTypes = ['Residential Flat', 'Independent House', 'Villa', 'Studio Apartment', 'Commercial Space'];
  static const _furnishingTypes = ['Unfurnished', 'Semi-Furnished', 'Fully Furnished'];
  static const _idTypes = ['Aadhaar', 'PAN Card', 'Passport', 'Voter ID', 'Driving Licence'];
  static const _rentDays = ['1st', '5th', '7th', '10th', '15th'];

  final List<String> _stepTitles = [
    'Property Details',
    'Owner Details',
    'Tenant Details',
    'Financial Terms',
    'Furnishing',
    'Terms & Conditions',
  ];

  @override
  void dispose() {
    for (final c in [
      _propAddressCtrl, _propCityCtrl, _propStateCtrl, _propPincodeCtrl,
      _ownerNameCtrl, _ownerAddrCtrl, _ownerIdNoCtrl, _ownerPhoneCtrl,
      _tenantNameCtrl, _tenantAddrCtrl, _tenantIdNoCtrl, _tenantPhoneCtrl,
      _rentCtrl, _depositCtrl, _maintenanceCtrl, _termsCtrl,
    ]) { c.dispose(); }
    super.dispose();
  }

  bool _validateStep() {
    return _formKey.currentState?.validate() ?? false;
  }

  RentAgreementData _buildData() {
    final furnishedItems = _furnishItems.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();
    return RentAgreementData(
      propAddress: _propAddressCtrl.text.trim(),
      propCity: _propCityCtrl.text.trim(),
      propState: _propStateCtrl.text.trim(),
      propPincode: _propPincodeCtrl.text.trim(),
      propType: _propType,
      furnishing: _furnishing,
      startDate: _startDate,
      ownerName: _ownerNameCtrl.text.trim(),
      ownerAddress: _ownerAddrCtrl.text.trim(),
      ownerIdType: _ownerIdType,
      ownerIdNo: _ownerIdNoCtrl.text.trim(),
      ownerPhone: _ownerPhoneCtrl.text.trim(),
      tenantName: _tenantNameCtrl.text.trim(),
      tenantAddress: _tenantAddrCtrl.text.trim(),
      tenantIdType: _tenantIdType,
      tenantIdNo: _tenantIdNoCtrl.text.trim(),
      tenantPhone: _tenantPhoneCtrl.text.trim(),
      monthlyRent: MoneyInputFormatter.parseInt(_rentCtrl.text) ?? 0,
      securityDeposit: MoneyInputFormatter.parseInt(_depositCtrl.text) ?? 0,
      maintenance: MoneyInputFormatter.parseInt(_maintenanceCtrl.text) ?? 0,
      durationMonths: _durationMonths,
      noticePeriod: _noticePeriod,
      lockIn: _lockIn,
      rentDay: _rentDay,
      furnishedItems: furnishedItems,
      additionalTerms: _termsCtrl.text.trim(),
    );
  }

  void _previewAgreement() {
    if (!_validateStep()) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RentAgreementPreviewScreen(data: _buildData()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.listingbackground,
      appBar: GradientAppBar(
        title: 'Rent Agreement',
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (_step + 1) / _stepTitles.length,
            backgroundColor: Colors.white24,
            valueColor: const AlwaysStoppedAnimation(Colors.white),
          ),
        ),
      ),
      body: Column(
        children: [
          _stepIndicator(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              child: Form(
                key: _formKey,
                child: _buildStep(),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _bottomNav(),
    );
  }

  Widget _stepIndicator() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text('${_step + 1}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_stepTitles[_step],
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                Text('Step ${_step + 1} of ${_stepTitles.length}',
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0: return _stepProperty();
      case 1: return _stepOwner();
      case 2: return _stepTenant();
      case 3: return _stepFinancial();
      case 4: return _stepFurnishing();
      case 5: return _stepTerms();
      default: return const SizedBox.shrink();
    }
  }

  Widget _stepProperty() {
    return _card([
      _dropdown('Property Type', _propTypes, _propType, (v) => setState(() => _propType = v!)),
      _field(_propAddressCtrl, 'Full Address', required: true, maxLines: 2),
      _row([
        _field(_propCityCtrl, 'City', required: true),
        _field(_propStateCtrl, 'State', required: true),
      ]),
      _field(_propPincodeCtrl, 'Pincode', keyboard: TextInputType.number),
      _dropdown('Furnishing', _furnishingTypes, _furnishing, (v) => setState(() => _furnishing = v!)),
      _datePicker(),
    ]);
  }

  Widget _stepOwner() {
    return _card([
      _field(_ownerNameCtrl, 'Owner Full Name', required: true),
      _field(_ownerAddrCtrl, 'Owner Address', required: true, maxLines: 2),
      _row([
        _dropdown('ID Type', _idTypes, _ownerIdType, (v) => setState(() => _ownerIdType = v!)),
        _field(_ownerIdNoCtrl, 'ID Number', required: true),
      ]),
      _field(_ownerPhoneCtrl, 'Mobile Number', keyboard: TextInputType.phone),
    ]);
  }

  Widget _stepTenant() {
    return _card([
      _field(_tenantNameCtrl, 'Tenant Full Name', required: true),
      _field(_tenantAddrCtrl, 'Permanent Address', required: true, maxLines: 2),
      _row([
        _dropdown('ID Type', _idTypes, _tenantIdType, (v) => setState(() => _tenantIdType = v!)),
        _field(_tenantIdNoCtrl, 'ID Number', required: true),
      ]),
      _field(_tenantPhoneCtrl, 'Mobile Number', keyboard: TextInputType.phone),
    ]);
  }

  Widget _stepFinancial() {
    return _card([
      _field(_rentCtrl, 'Monthly Rent (₹)', required: true, keyboard: TextInputType.number, isMoney: true),
      _field(_depositCtrl, 'Security Deposit (₹)', required: true, keyboard: TextInputType.number, isMoney: true),
      _field(_maintenanceCtrl, 'Maintenance Charges (₹/month)', keyboard: TextInputType.number, isMoney: true),
      _dropdown('Rent Due Day', _rentDays, _rentDay, (v) => setState(() => _rentDay = v!)),
      _stepper('Duration (months)', _durationMonths, 1, 60, (v) => setState(() => _durationMonths = v)),
      _stepper('Lock-in Period (months)', _lockIn, 0, 12, (v) => setState(() => _lockIn = v)),
      _stepper('Notice Period (months)', _noticePeriod, 1, 6, (v) => setState(() => _noticePeriod = v)),
    ]);
  }

  Widget _stepFurnishing() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.07),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'Select items provided by the Owner. These will be listed in the agreement.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            children: _furnishItems.keys.map((item) {
              final selected = _furnishItems[item]!;
              return FilterChip(
                label: Text(item, style: const TextStyle(fontSize: 12)),
                selected: selected,
                onSelected: (v) => setState(() => _furnishItems[item] = v),
                selectedColor: AppColors.primary.withOpacity(0.15),
                checkmarkColor: AppColors.primary,
                side: BorderSide(color: selected ? AppColors.primary : AppColors.border),
                labelStyle: TextStyle(color: selected ? AppColors.primary : AppColors.textPrimary),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _stepTerms() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.07),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'Standard terms are pre-filled. Edit or add custom terms below.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
          ),
          child: TextFormField(
            controller: _termsCtrl,
            maxLines: 12,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
              hintText: 'Enter terms and conditions...',
            ),
          ),
        ),
      ],
    );
  }

  Widget _bottomNav() {
    final isLast = _step == _stepTitles.length - 1;
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, -2))],
        ),
        child: Row(
          children: [
            if (_step > 0) ...[
              OutlinedButton(
                onPressed: () => setState(() => _step--),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  minimumSize: const Size(0, 52),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Back'),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: isLast
                  ? AppButton(text: 'Preview Agreement', onTap: _previewAgreement)
                  : AppButton(
                      text: 'Next',
                      onTap: () {
                        if (_validateStep()) setState(() => _step++);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Reusable form widgets ────────────────────────────────────────────────

  Widget _card(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children.expand((w) => [w, const SizedBox(height: 12)]).toList()..removeLast(),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label,
      {bool required = false, int maxLines = 1, TextInputType? keyboard, bool isMoney = false}) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboard,
      inputFormatters: isMoney ? [MoneyInputFormatter()] : null,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        isDense: true,
      ),
      validator: required
          ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null
          : null,
    );
  }

  Widget _row(List<Widget> children) {
    return Row(
      children: children.expand((w) => [Expanded(child: w), const SizedBox(width: 10)]).toList()
        ..removeLast(),
    );
  }

  Widget _dropdown(String label, List<String> items, String value, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        isDense: true,
      ),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13)))).toList(),
    );
  }

  Widget _stepper(String label, int value, int min, int max, ValueChanged<int> onChanged) {
    return Row(
      children: [
        Expanded(child: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary))),
        IconButton(
          icon: const Icon(Icons.remove_circle_outline, color: AppColors.primary),
          onPressed: value > min ? () => onChanged(value - 1) : null,
          padding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
        ),
        Container(
          width: 36,
          alignment: Alignment.center,
          child: Text('$value', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
          onPressed: value < max ? () => onChanged(value + 1) : null,
          padding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }

  Widget _datePicker() {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _startDate,
          firstDate: DateTime.now().subtract(const Duration(days: 30)),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) setState(() => _startDate = picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Agreement Start Date',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          isDense: true,
          suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
        ),
        child: Text(DateFormat('dd MMM yyyy').format(_startDate),
            style: const TextStyle(fontSize: 13)),
      ),
    );
  }
}

// ── Preview Screen ───────────────────────────────────────────────────────────

class RentAgreementPreviewScreen extends StatefulWidget {
  final RentAgreementData data;
  const RentAgreementPreviewScreen({super.key, required this.data});

  @override
  State<RentAgreementPreviewScreen> createState() => _RentAgreementPreviewScreenState();
}

class _RentAgreementPreviewScreenState extends State<RentAgreementPreviewScreen> {
  bool _downloading = false;

  Future<void> _downloadPdf() async {
    setState(() => _downloading = true);
    try {
      final pdf = await _buildPdf();
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/rent_agreement_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(await pdf.save());

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Saved to ${file.path}'),
          action: SnackBarAction(
            label: 'Share',
            onPressed: () => Share.shareXFiles([XFile(file.path)], text: 'Rent Agreement'),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  Future<void> _printPdf() async {
    final pdf = await _buildPdf();
    await Printing.layoutPdf(onLayout: (_) async => pdf.save());
  }


  Future<pw.Document> _buildPdf() => RentAgreementTemplate.buildPdf(widget.data);

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    return Scaffold(
      backgroundColor: AppColors.listingbackground,
      appBar: GradientAppBar(
        title: 'Agreement Preview',
        actions: [
          IconButton(
            icon: const Icon(Icons.print_outlined),
            onPressed: _printPdf,
            tooltip: 'Print / Preview',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _previewBanner(),
            const SizedBox(height: 16),
            _previewDoc(d),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: _previewBottomBar(),
    );
  }

  Widget _previewBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFFB74D)),
      ),
      child: Row(
        children: const [
          Icon(Icons.info_outline, color: Color(0xFFE65100), size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'This is a draft agreement. It should be registered/notarized for full legal validity.',
              style: TextStyle(fontSize: 11, color: Color(0xFFBF360C)),
            ),
          ),
        ],
      ),
    );
  }


  Widget _previewDoc(RentAgreementData d) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: RentAgreementTemplate.buildPreview(d),
    );
  }

  Widget _previewBottomBar() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, -2))],
        ),
        child: Row(
          children: [
            OutlinedButton.icon(
              icon: const Icon(Icons.share_outlined, size: 18),
              label: const Text('Share'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                minimumSize: const Size(0, 52),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _downloading ? null : _downloadPdf,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: AppButton(
                text: _downloading ? 'Generating...' : 'Download PDF',
                onTap: _downloading ? null : _downloadPdf,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
