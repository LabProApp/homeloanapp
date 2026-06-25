import 'package:flutter/material.dart';
import '../services/legal_service_api.dart';
import '../models/inquiry_request.dart';
import '../theme/app_colors.dart';
import '../commons/common_widget.dart';
import '../utility/money_input_formatter.dart';

class LoanApplySheet extends StatefulWidget {
  const LoanApplySheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.listingbackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const LoanApplySheet(),
    );
  }

  @override
  State<LoanApplySheet> createState() => _LoanApplySheetState();
}

class _LoanApplySheetState extends State<LoanApplySheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _incomeCtrl = TextEditingController();
  final _commentsCtrl = TextEditingController();
  final _loanAmountCtrl = TextEditingController();
  final _tenureCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();

  bool _isPropertyIdentified = false;
  String? _selectedPropertyType;
  bool _loading = false;

  static const List<String> _propertyTypes = [
    'HOUSE', 'PLOT', 'APARTMENT', 'PLOT_SHOP', 'SHOP',
    'PG', 'BUILDER_FLOOR', 'OFFICE', 'CO_WORKING', 'AGRICULTURAL', 'SHOWROOM',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _mobileCtrl.dispose();
    _emailCtrl.dispose();
    _incomeCtrl.dispose();
    _commentsCtrl.dispose();
    _loanAmountCtrl.dispose();
    _tenureCtrl.dispose();
    _stateCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.85 - MediaQuery.of(context).viewInsets.bottom,
        child: Column(
          children: [
            // ── Header ───────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: const Text(
                'Home Loan Inquiry',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // ── Form ─────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      _field(label: 'Full Name', ctrl: _nameCtrl, icon: Icons.person),
                      const SizedBox(height: 10),
                      _field(
                          label: 'Mobile Number',
                          ctrl: _mobileCtrl,
                          icon: Icons.phone,
                          keyboard: TextInputType.phone),
                      const SizedBox(height: 10),
                      _field(
                          label: 'Email',
                          ctrl: _emailCtrl,
                          icon: Icons.email,
                          keyboard: TextInputType.emailAddress,
                          optional: true),
                      const SizedBox(height: 10),
                      _field(
                          label: 'Monthly Income',
                          ctrl: _incomeCtrl,
                          icon: Icons.currency_rupee,
                          keyboard: TextInputType.number,
                          optional: true,
                          isMoney: true),
                      const SizedBox(height: 10),
                      _field(
                          label: 'Required Loan Amount',
                          ctrl: _loanAmountCtrl,
                          icon: Icons.money,
                          keyboard: TextInputType.number,
                          isMoney: true),
                      const SizedBox(height: 10),
                      _field(
                          label: 'Loan Tenure (Years)',
                          ctrl: _tenureCtrl,
                          icon: Icons.schedule,
                          keyboard: TextInputType.number),
                      const SizedBox(height: 10),

                      // Property Type
                      DropdownButtonFormField<String>(
                        value: _selectedPropertyType,
                        decoration: _inputDeco(label: 'Property Type', icon: Icons.home),
                        items: _propertyTypes
                            .map((t) => DropdownMenuItem(
                                value: t, child: Text(t.replaceAll('_', ' '))))
                            .toList(),
                        onChanged: (val) => setState(() => _selectedPropertyType = val),
                      ),
                      const SizedBox(height: 10),
                      _field(
                          label: 'Property State',
                          ctrl: _stateCtrl,
                          icon: Icons.map,
                          optional: true),
                      const SizedBox(height: 10),
                      _field(
                          label: 'Property City',
                          ctrl: _cityCtrl,
                          icon: Icons.location_city,
                          optional: true),
                      CheckboxListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Property Identified'),
                        value: _isPropertyIdentified,
                        activeColor: AppColors.primary,
                        controlAffinity: ListTileControlAffinity.leading,
                        onChanged: (val) =>
                            setState(() => _isPropertyIdentified = val ?? false),
                      ),
                      _field(
                          label: 'Comments',
                          ctrl: _commentsCtrl,
                          icon: Icons.comment,
                          maxLines: 3,
                          optional: true),
                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ),
            ),

            // ── Submit ───────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(
                  16, 8, 16, 8 + MediaQuery.of(context).viewPadding.bottom),
              child: AppButton(
                text: 'Submit Inquiry',
                isLoading: _loading,
                onTap: _loading ? null : _submit,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final inquiry = Inquiry(
      applicantName: _nameCtrl.text.trim(),
      mobileNumber: _mobileCtrl.text.trim(),
      email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
      monthlyIncome: MoneyInputFormatter.parse(_incomeCtrl.text),
      inquiryType: 'HOME_LOAN',
      comments: _commentsCtrl.text.trim().isEmpty ? null : _commentsCtrl.text.trim(),
      requiredLoanAmount: MoneyInputFormatter.parse(_loanAmountCtrl.text),
      loanTenureYears: int.tryParse(_tenureCtrl.text.trim()),
      propertyType: _selectedPropertyType,
      propertyState: _stateCtrl.text.trim().isEmpty ? null : _stateCtrl.text.trim(),
      propertyCity: _cityCtrl.text.trim().isEmpty ? null : _cityCtrl.text.trim(),
      propertyIdentified: _isPropertyIdentified,
      leadSource: 'APP',
    );

    try {
      await LegalServiceApi.submitInquiry(inquiry);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.success,
          content: Text('Inquiry submitted successfully'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.error,
          content: Text('Failed to submit inquiry: $e'),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _field({
    required String label,
    required TextEditingController ctrl,
    IconData? icon,
    TextInputType keyboard = TextInputType.text,
    int maxLines = 1,
    bool optional = false,
    bool isMoney = false,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboard,
      maxLines: maxLines,
      inputFormatters: isMoney ? [MoneyInputFormatter()] : null,
      validator: (val) {
        if (!optional && (val == null || val.trim().isEmpty)) {
          return 'Please enter $label';
        }
        return null;
      },
      decoration: _inputDeco(label: label, icon: icon),
    );
  }

  InputDecoration _inputDeco({required String label, IconData? icon}) {
    return InputDecoration(
      labelText: label,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      labelStyle: const TextStyle(color: AppColors.textMuted),
      prefixIcon: icon != null ? Icon(icon, size: 20, color: AppColors.textMuted) : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }
}
