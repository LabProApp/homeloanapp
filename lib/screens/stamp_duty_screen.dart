import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../commons/common_widget.dart';

class StampDutyScreen extends StatefulWidget {
  final double? initialAmount;
  const StampDutyScreen({super.key, this.initialAmount});

  @override
  State<StampDutyScreen> createState() => _StampDutyScreenState();
}

class _StampDutyScreenState extends State<StampDutyScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _priceCtrl = TextEditingController();
  static final _fmt = NumberFormat('#,##,###');

  String  _selectedState = 'Maharashtra';
  String  _ownerGender   = 'Male';
  bool    _isUrban       = true;
  _Result? _result;

  @override
  void initState() {
    super.initState();
    if (widget.initialAmount != null) {
      _priceCtrl.text = widget.initialAmount!.toInt().toString();
    }
  }

  @override
  void dispose() { _priceCtrl.dispose(); super.dispose(); }

  // ── State-wise stamp duty data ─────────────────────────────────────────────
  // Format: { state: { 'male': stampDuty%, 'female': stampDuty%, 'reg': regFee%, 'note': '' } }
  static const Map<String, Map<String, dynamic>> _rates = {
    'Andhra Pradesh':   {'male': 5.0, 'female': 5.0,  'reg': 1.0, 'note': '+ 0.5% transfer duty'},
    'Bihar':            {'male': 6.3, 'female': 5.7,  'reg': 2.0, 'note': 'Reduced rate for women'},
    'Delhi':            {'male': 6.0, 'female': 4.0,  'reg': 1.0, 'note': 'Female buyers get 2% concession'},
    'Goa':              {'male': 3.5, 'female': 3.5,  'reg': 1.0, 'note': 'One of the lowest rates'},
    'Gujarat':          {'male': 4.9, 'female': 4.9,  'reg': 1.0, 'note': 'No gender differentiation'},
    'Haryana':          {'male': 7.0, 'female': 5.0,  'reg': 2.0, 'note': 'Urban areas'},
    'Himachal Pradesh': {'male': 6.0, 'female': 4.0,  'reg': 2.0, 'note': 'Female concession applies'},
    'Jharkhand':        {'male': 4.0, 'female': 4.0,  'reg': 3.0, 'note': 'Fixed rate'},
    'Karnataka':        {'male': 5.6, 'female': 5.6,  'reg': 1.0, 'note': '+ 0.5% cess + 0.1% surcharge'},
    'Kerala':           {'male': 8.0, 'female': 8.0,  'reg': 2.0, 'note': 'Highest in India'},
    'Madhya Pradesh':   {'male': 7.5, 'female': 7.5,  'reg': 3.0, 'note': '+ 10% surcharge on stamp duty'},
    'Maharashtra':      {'male': 6.0, 'female': 5.0,  'reg': 1.0, 'note': '1% metro cess applicable in Mumbai'},
    'Odisha':           {'male': 5.0, 'female': 4.0,  'reg': 2.0, 'note': 'Female concession applies'},
    'Punjab':           {'male': 7.0, 'female': 5.0,  'reg': 1.0, 'note': 'Female concession applies'},
    'Rajasthan':        {'male': 6.0, 'female': 5.0,  'reg': 1.0, 'note': '+ 20% surcharge on urban'},
    'Tamil Nadu':       {'male': 7.0, 'female': 7.0,  'reg': 4.0, 'note': 'One of the highest reg fees'},
    'Telangana':        {'male': 5.0, 'female': 5.0,  'reg': 0.5, 'note': '+ 1.5% transfer duty'},
    'Uttar Pradesh':    {'male': 7.0, 'female': 6.0,  'reg': 1.0, 'note': 'Female concession of 1%'},
    'Uttarakhand':      {'male': 5.0, 'female': 3.75, 'reg': 2.0, 'note': 'Female concession applies'},
    'West Bengal':      {'male': 6.0, 'female': 6.0,  'reg': 1.0, 'note': 'Urban. Rural: 5%'},
  };

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final price     = double.parse(_priceCtrl.text.trim());
    final rateMap   = _rates[_selectedState]!;
    final sdPct     = (_ownerGender == 'Female' ? rateMap['female'] : rateMap['male']) as double;
    final regPct    = rateMap['reg'] as double;
    final note      = rateMap['note'] as String;

    final stampDuty = price * sdPct / 100;
    final regFee    = price * regPct / 100;
    final total     = stampDuty + regFee;

    setState(() {
      _result = _Result(
        propertyValue: price,
        state: _selectedState,
        stampDutyPct: sdPct,
        regFeePct: regPct,
        stampDuty: stampDuty,
        regFee: regFee,
        total: total,
        note: note,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.listingbackground,
      appBar: AppBar(
        title: const Text('Stamp Duty Calculator'),
        foregroundColor: AppColors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _infoCard(),
          const SizedBox(height: 16),
          _formCard(),
          const SizedBox(height: 16),
          AppButton(text: 'Calculate', onTap: _calculate),
          if (_result != null) ...[
            const SizedBox(height: 24),
            _resultCard(_result!),
            const SizedBox(height: 16),
            _breakdownCard(_result!),
            const SizedBox(height: 16),
            _noteCard(_result!.note),
          ],
          const SizedBox(height: 32),
        ]),
      ),
    );
  }

  Widget _infoCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(children: [
        Icon(Icons.info_outline, color: AppColors.primary, size: 20),
        const SizedBox(width: 10),
        const Expanded(child: Text(
          'Rates are indicative and may change. Verify with your Sub-Registrar before payment.',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        )),
      ]),
    );
  }

  Widget _formCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Form(
        key: _formKey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Property Details',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 16),

          // State dropdown
          DropdownButtonFormField<String>(
            value: _selectedState,
            onChanged: (v) => setState(() => _selectedState = v!),
            decoration: InputDecoration(
              labelText: 'State',
              prefixIcon: const Icon(Icons.location_on_outlined, size: 20),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              isDense: true,
            ),
            items: _rates.keys.map((s) => DropdownMenuItem(
              value: s, child: Text(s, style: const TextStyle(fontSize: 13)),
            )).toList(),
          ),
          const SizedBox(height: 12),

          // Property value
          TextFormField(
            controller: _priceCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: 'Property Value (₹)',
              hintText: 'e.g. 5000000',
              prefixIcon: const Icon(Icons.currency_rupee, size: 18),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              isDense: true,
            ),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
          ),
          const SizedBox(height: 16),

          // Gender
          const Text('Owner Gender', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 8),
          Row(children: ['Male', 'Female', 'Joint'].map((g) {
            final sel = _ownerGender == g;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(g),
                selected: sel,
                onSelected: (_) => setState(() => _ownerGender = g),
                selectedColor: AppColors.primary.withOpacity(0.15),
                labelStyle: TextStyle(
                    color: sel ? AppColors.primary : AppColors.textPrimary,
                    fontWeight: sel ? FontWeight.w600 : FontWeight.normal),
                side: BorderSide(color: sel ? AppColors.primary : AppColors.border),
              ),
            );
          }).toList()),
        ]),
      ),
    );
  }

  Widget _resultCard(_Result r) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Total Payable (Stamp Duty + Registration)',
            style: TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 6),
        Text('₹ ${_fmt.format(r.total.toInt())}',
            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text('on property value ₹ ${_fmt.format(r.propertyValue.toInt())} in ${r.state}',
            style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ]),
    );
  }

  Widget _breakdownCard(_Result r) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Column(children: [
        _breakRow('Property Value', '₹ ${_fmt.format(r.propertyValue.toInt())}', isHeader: true),
        const Divider(height: 20),
        _breakRow('Stamp Duty (${r.stampDutyPct}%)', '₹ ${_fmt.format(r.stampDuty.toInt())}'),
        const SizedBox(height: 10),
        _breakRow('Registration Fee (${r.regFeePct}%)', '₹ ${_fmt.format(r.regFee.toInt())}'),
        const Divider(height: 20),
        _breakRow('Total Payable', '₹ ${_fmt.format(r.total.toInt())}', isTotal: true),
      ]),
    );
  }

  Widget _breakRow(String label, String value, {bool isHeader = false, bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: isTotal ? 14 : 13,
                fontWeight: isTotal || isHeader ? FontWeight.w700 : FontWeight.normal,
                color: isHeader ? AppColors.textSecondary : AppColors.textPrimary)),
        Text(value,
            style: TextStyle(
                fontSize: isTotal ? 15 : 13,
                fontWeight: FontWeight.w700,
                color: isTotal ? AppColors.primary : AppColors.textPrimary)),
      ],
    );
  }

  Widget _noteCard(String note) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFFCC02).withOpacity(0.6)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.lightbulb_outline, color: Color(0xFFE65100), size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(note,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
      ]),
    );
  }
}

class _Result {
  final double propertyValue, stampDutyPct, regFeePct, stampDuty, regFee, total;
  final String state, note;
  const _Result({
    required this.propertyValue, required this.state,
    required this.stampDutyPct, required this.regFeePct,
    required this.stampDuty, required this.regFee, required this.total,
    required this.note,
  });
}
