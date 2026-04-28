import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../theme/app_colors.dart';
import '../commons/common_widget.dart';

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
      monthlyRent: int.tryParse(_rentCtrl.text.trim()) ?? 0,
      securityDeposit: int.tryParse(_depositCtrl.text.trim()) ?? 0,
      maintenance: int.tryParse(_maintenanceCtrl.text.trim()) ?? 0,
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
      appBar: AppBar(
        title: const Text('Rent Agreement'),
        foregroundColor: AppColors.white,
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
      _field(_rentCtrl, 'Monthly Rent (₹)', required: true, keyboard: TextInputType.number),
      _field(_depositCtrl, 'Security Deposit (₹)', required: true, keyboard: TextInputType.number),
      _field(_maintenanceCtrl, 'Maintenance Charges (₹/month)', keyboard: TextInputType.number),
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
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, -2))],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (_step > 0) ...[
              OutlinedButton(
                onPressed: () => setState(() => _step--),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
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
      {bool required = false, int maxLines = 1, TextInputType? keyboard}) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboard,
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

  static final _dateFmt = DateFormat('dd MMMM yyyy');
  static final _moneyFmt = NumberFormat('#,##,###');

  String _inWords(int amount) {
    // Simple Indian number to words for common amounts
    if (amount == 0) return 'Zero';
    const ones = ['', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine',
      'Ten', 'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen', 'Sixteen', 'Seventeen', 'Eighteen', 'Nineteen'];
    const tens = ['', '', 'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty', 'Seventy', 'Eighty', 'Ninety'];

    String convert(int n) {
      if (n < 20) return ones[n];
      if (n < 100) return '${tens[n ~/ 10]}${n % 10 > 0 ? " ${ones[n % 10]}" : ""}';
      if (n < 1000) return '${ones[n ~/ 100]} Hundred${n % 100 > 0 ? " ${convert(n % 100)}" : ""}';
      if (n < 100000) return '${convert(n ~/ 1000)} Thousand${n % 1000 > 0 ? " ${convert(n % 1000)}" : ""}';
      if (n < 10000000) return '${convert(n ~/ 100000)} Lakh${n % 100000 > 0 ? " ${convert(n % 100000)}" : ""}';
      return '${convert(n ~/ 10000000)} Crore${n % 10000000 > 0 ? " ${convert(n % 10000000)}" : ""}';
    }

    return '${convert(amount)} Only';
  }

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

  Future<pw.Document> _buildPdf() async {
    final d = widget.data;
    final pdf = pw.Document();
    final endDate = DateTime(d.startDate.year, d.startDate.month + d.durationMonths, d.startDate.day);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (ctx) => [
          // Header
          pw.Center(
            child: pw.Column(children: [
              pw.Text('LEAVE AND LICENSE AGREEMENT',
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 4),
              pw.Text('(Rent Agreement)',
                  style: const pw.TextStyle(fontSize: 11)),
              pw.SizedBox(height: 4),
              pw.Text('This Agreement is made at ${d.propCity} on ${_dateFmt.format(d.startDate)}',
                  style: const pw.TextStyle(fontSize: 10)),
            ]),
          ),
          pw.Divider(height: 20),

          // Parties
          _pdfSection('BETWEEN THE PARTIES', [
            _pdfPara(
              'LICENSOR (Owner): ${d.ownerName}, residing at ${d.ownerAddress}, '
              'bearing ${d.ownerIdType} No. ${d.ownerIdNo}, '
              'hereinafter referred to as the "Owner" (of the First Part).',
            ),
            _pdfPara(
              'LICENSEE (Tenant): ${d.tenantName}, residing at ${d.tenantAddress}, '
              'bearing ${d.tenantIdType} No. ${d.tenantIdNo}, '
              'hereinafter referred to as the "Tenant" (of the Second Part).',
            ),
          ]),

          // Property
          _pdfSection('SCHEDULE OF PROPERTY', [
            _pdfPara(
              'The Owner hereby grants leave and license to the Tenant for the following property: '
              '${d.propType} situated at ${d.propAddress}, ${d.propCity}, ${d.propState} - ${d.propPincode}. '
              'The property is ${d.furnishing.toLowerCase()}.',
            ),
          ]),

          // Tenure
          _pdfSection('DURATION', [
            _pdfPara(
              'This Agreement shall be valid for a period of ${d.durationMonths} months, '
              'commencing from ${_dateFmt.format(d.startDate)} and ending on ${_dateFmt.format(endDate)}, '
              'unless terminated earlier as per the terms herein.',
            ),
            if (d.lockIn > 0)
              _pdfPara('Lock-in Period: ${d.lockIn} month(s) from the date of commencement.'),
            _pdfPara('Notice Period: ${d.noticePeriod} month(s) written notice required by either party for termination.'),
          ]),

          // Financial
          _pdfSection('LICENSE FEE AND DEPOSIT', [
            _pdfPara(
              'Monthly License Fee (Rent): ₹${_moneyFmt.format(d.monthlyRent)} '
              '(Rupees ${_inWords(d.monthlyRent)}), payable on or before the ${d.rentDay} of each month.',
            ),
            _pdfPara(
              'Security Deposit: ₹${_moneyFmt.format(d.securityDeposit)} '
              '(Rupees ${_inWords(d.securityDeposit)}), '
              'refundable at the end of the agreement period subject to deductions for damages if any.',
            ),
            if (d.maintenance > 0)
              _pdfPara(
                'Maintenance Charges: ₹${_moneyFmt.format(d.maintenance)} per month, payable along with the rent.',
              ),
          ]),

          // Furnishing
          if (d.furnishedItems.isNotEmpty)
            _pdfSection('FURNISHING DETAILS', [
              _pdfPara('The following items are provided by the Owner in the premises:'),
              pw.Wrap(
                spacing: 12,
                children: d.furnishedItems
                    .map((item) => pw.Text('• $item', style: const pw.TextStyle(fontSize: 10)))
                    .toList(),
              ),
            ]),

          // T&Cs
          _pdfSection('TERMS AND CONDITIONS', [
            _pdfPara(d.additionalTerms),
          ]),

          // Standard legal clauses
          _pdfSection('GENERAL CONDITIONS', [
            _pdfPara('1. This Agreement shall be governed by the laws of India.'),
            _pdfPara('2. Any dispute arising out of this Agreement shall be subject to the jurisdiction of courts at ${d.propCity}.'),
            _pdfPara('3. Both parties have read and understood the terms of this Agreement.'),
            _pdfPara('4. This Agreement constitutes the entire agreement between the parties and supersedes all prior negotiations.'),
          ]),

          pw.SizedBox(height: 40),

          // Signatures
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                pw.Container(width: 150, height: 1, color: PdfColors.black),
                pw.SizedBox(height: 4),
                pw.Text('Owner Signature', style: const pw.TextStyle(fontSize: 10)),
                pw.Text(d.ownerName, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                pw.Text('Date: ________________', style: const pw.TextStyle(fontSize: 9)),
              ]),
              pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                pw.Container(width: 150, height: 1, color: PdfColors.black),
                pw.SizedBox(height: 4),
                pw.Text('Tenant Signature', style: const pw.TextStyle(fontSize: 10)),
                pw.Text(d.tenantName, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                pw.Text('Date: ________________', style: const pw.TextStyle(fontSize: 9)),
              ]),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Center(
            child: pw.Text(
              'Witness 1: _______________________    Witness 2: _______________________',
              style: const pw.TextStyle(fontSize: 9),
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Center(
            child: pw.Text(
              'Note: This agreement should be registered/notarized for legal validity as per applicable law.',
              style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
            ),
          ),
        ],
      ),
    );
    return pdf;
  }

  pw.Widget _pdfSection(String title, List<pw.Widget> children) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(height: 12),
        pw.Text(title,
            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold,
                decoration: pw.TextDecoration.underline)),
        pw.SizedBox(height: 6),
        ...children,
      ],
    );
  }

  pw.Widget _pdfPara(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Text(text,
          style: const pw.TextStyle(fontSize: 10),
          textAlign: pw.TextAlign.justify),
    );
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    return Scaffold(
      backgroundColor: AppColors.listingbackground,
      appBar: AppBar(
        title: const Text('Agreement Preview'),
        foregroundColor: AppColors.white,
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
    final endDate = DateTime(d.startDate.year, d.startDate.month + d.durationMonths, d.startDate.day);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text('LEAVE AND LICENSE AGREEMENT',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          ),
          const Center(
            child: Text('(Rent Agreement)',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              'Made at ${d.propCity} on ${_dateFmt.format(d.startDate)}',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
          const Divider(height: 24),

          _previewSection('BETWEEN THE PARTIES'),
          _previewPara(
            'LICENSOR (Owner): ${d.ownerName}, residing at ${d.ownerAddress}, '
            'bearing ${d.ownerIdType} No. ${d.ownerIdNo}.',
          ),
          const SizedBox(height: 6),
          _previewPara(
            'LICENSEE (Tenant): ${d.tenantName}, residing at ${d.tenantAddress}, '
            'bearing ${d.tenantIdType} No. ${d.tenantIdNo}.',
          ),

          _previewSection('SCHEDULE OF PROPERTY'),
          _previewPara(
            '${d.propType} at ${d.propAddress}, ${d.propCity}, ${d.propState} - ${d.propPincode}. '
            '(${d.furnishing})',
          ),

          _previewSection('DURATION'),
          _previewPara(
            '${d.durationMonths} months: ${_dateFmt.format(d.startDate)} to ${_dateFmt.format(endDate)}.',
          ),
          if (d.lockIn > 0) _previewPara('Lock-in: ${d.lockIn} month(s).'),
          _previewPara('Notice period: ${d.noticePeriod} month(s).'),

          _previewSection('LICENSE FEE & DEPOSIT'),
          _previewKV('Monthly Rent', '₹ ${_moneyFmt.format(d.monthlyRent)} (${_inWords(d.monthlyRent)})'),
          _previewKV('Security Deposit', '₹ ${_moneyFmt.format(d.securityDeposit)} (${_inWords(d.securityDeposit)})'),
          if (d.maintenance > 0)
            _previewKV('Maintenance', '₹ ${_moneyFmt.format(d.maintenance)}/month'),
          _previewKV('Rent Due', '${d.rentDay} of each month'),

          if (d.furnishedItems.isNotEmpty) ...[
            _previewSection('FURNISHING'),
            _previewPara(d.furnishedItems.join(' • ')),
          ],

          _previewSection('TERMS & CONDITIONS'),
          _previewPara(d.additionalTerms),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _signatureBlock('Owner', d.ownerName),
              _signatureBlock('Tenant', d.tenantName),
            ],
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'Witness 1: ___________________    Witness 2: ___________________',
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _previewSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 6),
      child: Text(title,
          style: const TextStyle(
              fontWeight: FontWeight.w700, fontSize: 13, decoration: TextDecoration.underline)),
    );
  }

  Widget _previewPara(String text) {
    return Text(text,
        style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, height: 1.5),
        textAlign: TextAlign.justify);
  }

  Widget _previewKV(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _signatureBlock(String role, String name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(width: 130, height: 40, color: const Color(0xFFF5F5F5)),
        const SizedBox(height: 4),
        Text(role, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        Text(name,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
        const Text('Date: ___________',
            style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _previewBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, -2))],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            OutlinedButton.icon(
              icon: const Icon(Icons.share_outlined, size: 18),
              label: const Text('Share'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
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

// ── Data model ───────────────────────────────────────────────────────────────

class RentAgreementData {
  final String propAddress, propCity, propState, propPincode, propType, furnishing;
  final DateTime startDate;
  final String ownerName, ownerAddress, ownerIdType, ownerIdNo, ownerPhone;
  final String tenantName, tenantAddress, tenantIdType, tenantIdNo, tenantPhone;
  final int monthlyRent, securityDeposit, maintenance;
  final int durationMonths, noticePeriod, lockIn;
  final String rentDay;
  final List<String> furnishedItems;
  final String additionalTerms;

  const RentAgreementData({
    required this.propAddress, required this.propCity, required this.propState,
    required this.propPincode, required this.propType, required this.furnishing,
    required this.startDate, required this.ownerName, required this.ownerAddress,
    required this.ownerIdType, required this.ownerIdNo, required this.ownerPhone,
    required this.tenantName, required this.tenantAddress, required this.tenantIdType,
    required this.tenantIdNo, required this.tenantPhone, required this.monthlyRent,
    required this.securityDeposit, required this.maintenance, required this.durationMonths,
    required this.noticePeriod, required this.lockIn, required this.rentDay,
    required this.furnishedItems, required this.additionalTerms,
  });
}
