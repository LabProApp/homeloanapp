import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utility/money_input_formatter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../theme/app_colors.dart';
import '../commons/common_widget.dart';
import '../templates/sale_agreement_template.dart';
import '../templates/agreement_helpers.dart';

class SaleAgreementScreen extends StatefulWidget {
  const SaleAgreementScreen({super.key});

  @override
  State<SaleAgreementScreen> createState() => _SaleAgreementScreenState();
}

class _SaleAgreementScreenState extends State<SaleAgreementScreen> {
  final _formKey = GlobalKey<FormState>();
  int _step = 0;

  // Property
  final _propAddressCtrl = TextEditingController();
  final _propCityCtrl    = TextEditingController();
  final _propStateCtrl   = TextEditingController();
  final _propPincodeCtrl = TextEditingController();
  String _propType       = 'Residential Flat';

  // Seller
  final _sellerNameCtrl  = TextEditingController();
  final _sellerAddrCtrl  = TextEditingController();
  final _sellerIdNoCtrl  = TextEditingController();
  String _sellerIdType   = 'Aadhaar';
  final _sellerPhoneCtrl = TextEditingController();

  // Buyer
  final _buyerNameCtrl   = TextEditingController();
  final _buyerAddrCtrl   = TextEditingController();
  final _buyerIdNoCtrl   = TextEditingController();
  String _buyerIdType    = 'Aadhaar';
  final _buyerPhoneCtrl  = TextEditingController();

  // Financial & Dates
  final _priceCtrl       = TextEditingController();
  final _tokenCtrl       = TextEditingController();
  String _paymentMode    = 'NEFT/RTGS';
  DateTime _tokenDate    = DateTime.now();
  DateTime _balanceDate  = DateTime.now().add(const Duration(days: 60));
  DateTime _possessionDate = DateTime.now().add(const Duration(days: 90));

  final _termsCtrl = TextEditingController(text:
    '1. The Seller confirms clear and marketable title to the property.\n'
    '2. No part of the property is under dispute, litigation, or government acquisition.\n'
    '3. All existing tenants/occupants shall vacate before possession handover.\n'
    '4. The Seller shall provide all original title documents, approved plans, and NOCs.\n'
    '5. Any increase in stamp duty or registration charges after this date shall be borne by the Buyer.\n'
    '6. The property shall be handed over in the same condition as inspected by the Buyer.\n'
    '7. The Buyer has verified the property documents and is satisfied with the title.',
  );

  static const _propTypes = ['Residential Flat', 'Independent House', 'Villa', 'Plot', 'Commercial Space', 'Office'];
  static const _idTypes   = ['Aadhaar', 'PAN Card', 'Passport', 'Voter ID', 'Driving Licence'];
  static const _payModes  = ['Cash', 'NEFT/RTGS', 'Cheque', 'Demand Draft', 'UPI'];

  final List<String> _stepTitles = ['Property', 'Seller Details', 'Buyer Details', 'Financial Terms', 'Terms & Conditions'];

  @override
  void dispose() {
    for (final c in [
      _propAddressCtrl, _propCityCtrl, _propStateCtrl, _propPincodeCtrl,
      _sellerNameCtrl, _sellerAddrCtrl, _sellerIdNoCtrl, _sellerPhoneCtrl,
      _buyerNameCtrl, _buyerAddrCtrl, _buyerIdNoCtrl, _buyerPhoneCtrl,
      _priceCtrl, _tokenCtrl, _termsCtrl,
    ]) { c.dispose(); }
    super.dispose();
  }

  SaleAgreementData _buildData() => SaleAgreementData(
    propAddress: _propAddressCtrl.text.trim(),
    propCity: _propCityCtrl.text.trim(),
    propState: _propStateCtrl.text.trim(),
    propPincode: _propPincodeCtrl.text.trim(),
    propType: _propType,
    sellerName: _sellerNameCtrl.text.trim(),
    sellerAddress: _sellerAddrCtrl.text.trim(),
    sellerIdType: _sellerIdType,
    sellerIdNo: _sellerIdNoCtrl.text.trim(),
    sellerPhone: _sellerPhoneCtrl.text.trim(),
    buyerName: _buyerNameCtrl.text.trim(),
    buyerAddress: _buyerAddrCtrl.text.trim(),
    buyerIdType: _buyerIdType,
    buyerIdNo: _buyerIdNoCtrl.text.trim(),
    buyerPhone: _buyerPhoneCtrl.text.trim(),
    saleConsideration: MoneyInputFormatter.parseInt(_priceCtrl.text) ?? 0,
    tokenAmount: MoneyInputFormatter.parseInt(_tokenCtrl.text) ?? 0,
    tokenDate: _tokenDate,
    balanceDate: _balanceDate,
    possessionDate: _possessionDate,
    paymentMode: _paymentMode,
    additionalTerms: _termsCtrl.text.trim(),
  );

  void _preview() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => SaleAgreementPreviewScreen(data: _buildData()),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.listingbackground,
      appBar: AppBar(
        title: const Text('Sale Agreement / Beana'),
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
      body: Column(children: [
        _stepHeader(),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          child: Form(key: _formKey, child: _buildStep()),
        )),
      ]),
      bottomNavigationBar: _bottomNav(),
    );
  }

  Widget _stepHeader() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Row(children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(16)),
          child: Center(child: Text('${_step + 1}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700))),
        ),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_stepTitles[_step], style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          Text('Step ${_step + 1} of ${_stepTitles.length}',
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ])),
      ]),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0: return _stepProperty();
      case 1: return _stepSeller();
      case 2: return _stepBuyer();
      case 3: return _stepFinancial();
      case 4: return _stepTerms();
      default: return const SizedBox.shrink();
    }
  }

  Widget _stepProperty() => _card([
    _dropdown('Property Type', _propTypes, _propType, (v) => setState(() => _propType = v!)),
    _field(_propAddressCtrl, 'Full Property Address', required: true, maxLines: 2),
    _row([_field(_propCityCtrl, 'City', required: true), _field(_propStateCtrl, 'State', required: true)]),
    _field(_propPincodeCtrl, 'Pincode', keyboard: TextInputType.number),
  ]);

  Widget _stepSeller() => _card([
    _field(_sellerNameCtrl, 'Seller Full Name', required: true),
    _field(_sellerAddrCtrl, 'Seller Address', required: true, maxLines: 2),
    _row([
      _dropdown('ID Type', _idTypes, _sellerIdType, (v) => setState(() => _sellerIdType = v!)),
      _field(_sellerIdNoCtrl, 'ID Number', required: true),
    ]),
    _field(_sellerPhoneCtrl, 'Mobile Number', keyboard: TextInputType.phone),
  ]);

  Widget _stepBuyer() => _card([
    _field(_buyerNameCtrl, 'Buyer Full Name', required: true),
    _field(_buyerAddrCtrl, 'Buyer Address', required: true, maxLines: 2),
    _row([
      _dropdown('ID Type', _idTypes, _buyerIdType, (v) => setState(() => _buyerIdType = v!)),
      _field(_buyerIdNoCtrl, 'ID Number', required: true),
    ]),
    _field(_buyerPhoneCtrl, 'Mobile Number', keyboard: TextInputType.phone),
  ]);

  Widget _stepFinancial() => _card([
    _field(_priceCtrl, 'Total Sale Price (₹)', required: true, keyboard: TextInputType.number, isMoney: true),
    _field(_tokenCtrl, 'Token / Advance (Beana) Amount (₹)', required: true, keyboard: TextInputType.number, isMoney: true),
    _dropdown('Payment Mode', _payModes, _paymentMode, (v) => setState(() => _paymentMode = v!)),
    _datePicker('Token Date', _tokenDate, (d) => setState(() => _tokenDate = d)),
    _datePicker('Balance Payment Due By', _balanceDate, (d) => setState(() => _balanceDate = d)),
    _datePicker('Possession Date', _possessionDate, (d) => setState(() => _possessionDate = d)),
    if (_priceCtrl.text.isNotEmpty && _tokenCtrl.text.isNotEmpty) ...[
      const SizedBox(height: 4),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.07), borderRadius: BorderRadius.circular(10)),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Balance Payable', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          Text(
            () {
              final price = MoneyInputFormatter.parseInt(_priceCtrl.text) ?? 0;
              final token = MoneyInputFormatter.parseInt(_tokenCtrl.text) ?? 0;
              return '₹ ${NumberFormat('#,##,###').format(price - token)}';
            }(),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary),
          ),
        ]),
      ),
    ],
  ]);

  Widget _stepTerms() => Column(children: [
    Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text('Standard sale terms are pre-filled. Edit or add custom conditions below.',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
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
        maxLines: 14,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
          hintText: 'Enter terms and conditions...',
        ),
      ),
    ),
  ]);

  Widget _bottomNav() {
    final isLast = _step == _stepTitles.length - 1;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, -2))],
      ),
      child: SafeArea(top: false, child: Row(children: [
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
        Expanded(child: isLast
          ? AppButton(text: 'Preview Agreement', onTap: _preview)
          : AppButton(text: 'Next', onTap: () {
              if (_formKey.currentState?.validate() ?? false) setState(() => _step++);
            })),
      ])),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Widget _card(List<Widget> children) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.white, borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children.expand((w) => [w, const SizedBox(height: 12)]).toList()..removeLast(),
    ),
  );

  Widget _field(TextEditingController ctrl, String label,
      {bool required = false, int maxLines = 1, TextInputType? keyboard, bool isMoney = false}) =>
    TextFormField(
      controller: ctrl, maxLines: maxLines, keyboardType: keyboard,
      inputFormatters: isMoney ? [MoneyInputFormatter()] : null,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12), isDense: true,
      ),
      validator: required ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null : null,
    );

  Widget _row(List<Widget> children) => Row(
    children: children.expand((w) => [Expanded(child: w), const SizedBox(width: 10)]).toList()..removeLast(),
  );

  Widget _dropdown(String label, List<String> items, String value, ValueChanged<String?> onChanged) =>
    DropdownButtonFormField<String>(
      value: value, onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12), isDense: true,
      ),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13)))).toList(),
    );

  Widget _datePicker(String label, DateTime value, ValueChanged<DateTime> onChanged) =>
    InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context, initialDate: value,
          firstDate: DateTime(2020), lastDate: DateTime(2030),
        );
        if (picked != null) onChanged(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12), isDense: true,
          suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
        ),
        child: Text(DateFormat('dd MMM yyyy').format(value), style: const TextStyle(fontSize: 13)),
      ),
    );
}

// ── Preview Screen ───────────────────────────────────────────────────────────

class SaleAgreementPreviewScreen extends StatefulWidget {
  final SaleAgreementData data;
  const SaleAgreementPreviewScreen({super.key, required this.data});

  @override
  State<SaleAgreementPreviewScreen> createState() => _SaleAgreementPreviewState();
}

class _SaleAgreementPreviewState extends State<SaleAgreementPreviewScreen> {
  bool _downloading = false;

  Future<void> _downloadPdf() async {
    setState(() => _downloading = true);
    try {
      final pdf  = await SaleAgreementTemplate.buildPdf(widget.data);
      final dir  = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/sale_agreement_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(await pdf.save());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Saved to ${file.path}'),
        action: SnackBarAction(
          label: 'Share',
          onPressed: () => Share.shareXFiles([XFile(file.path)], text: 'Sale Agreement / Beana'),
        ),
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  Future<void> _print() async {
    final pdf = await SaleAgreementTemplate.buildPdf(widget.data);
    await Printing.layoutPdf(onLayout: (_) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.listingbackground,
      appBar: AppBar(
        title: const Text('Agreement Preview'),
        foregroundColor: AppColors.white,
        actions: [
          IconButton(icon: const Icon(Icons.print_outlined), onPressed: _print, tooltip: 'Print'),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          draftBanner(),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
            ),
            child: SaleAgreementTemplate.buildPreview(widget.data),
          ),
          const SizedBox(height: 80),
        ]),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, -2))],
        ),
        child: SafeArea(top: false, child: Row(children: [
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
          Expanded(child: AppButton(
            text: _downloading ? 'Generating...' : 'Download PDF',
            onTap: _downloading ? null : _downloadPdf,
          )),
        ])),
      ),
    );
  }
}
