import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/calcLoanRequest.dart';
import '../models/calcLoanResponse.dart';
import '../services/emi_service.dart';
import '../commons/common_widget.dart'; // 👈 AppButton

class EmiCalculatorScreen extends StatefulWidget {
  const EmiCalculatorScreen({super.key});

  @override
  State<EmiCalculatorScreen> createState() => _EmiCalculatorScreenState();
}

class _EmiCalculatorScreenState extends State<EmiCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();

  final principalCtrl = TextEditingController();
  final interestCtrl = TextEditingController();
  final tenureCtrl = TextEditingController();

  bool loading = false;
  CalcLoanResponse? response;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _resetForm();
    });
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    principalCtrl.clear();
    interestCtrl.clear();
    tenureCtrl.clear();

    setState(() {
      response = null;
      loading = false;
    });
  }

  @override
  void dispose() {
    principalCtrl.dispose();
    interestCtrl.dispose();
    tenureCtrl.dispose();
    super.dispose();
  }

  Future<void> calculateEmi() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      final request = CalcLoanRequest(
        principal: double.parse(principalCtrl.text),
        annualInterestRate: double.parse(interestCtrl.text),
        tenureYears: int.parse(tenureCtrl.text),
        includeSchedule: false,
      );

      final res = await LoanApiService.calculateLoan(request);
      setState(() => response = res);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Calculation failed")),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.listingbackground, // 👈 dashboard style
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "EMI Calculator",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            /// 🔳 FORM CARD
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _field("Loan Amount", principalCtrl),
                      _field("Interest Rate (%)", interestCtrl),
                      _field("Tenure (Years)", tenureCtrl),
                      const SizedBox(height: 14),

                      /// ✅ STANDARD AppButton
                      AppButton(
                        text: "Calculate EMI",
                        isLoading: loading,
                        onTap: calculateEmi,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// 📊 RESULT
            if (response != null) _resultCard(),
          ],
        ),
      ),
    );
  }

  /// 🔹 SLIM TEXT FIELD
  Widget _field(String label, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        validator: (v) => v == null || v.isEmpty ? "Required" : null,
        decoration: InputDecoration(
          labelText: label,
          isDense: true, // 👈 slimmer
          contentPadding:
          const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          filled: true,
          fillColor: AppColors.textBoxbackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _resultCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _row("Monthly EMI", response!.monthlyPayment.toDouble()),
            _row("Total Interest", response!.totalInterest.toDouble()),
            _row("Total Payment", response!.totalPayment.toDouble()),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text("₹ ${value.toStringAsFixed(2)}"),
        ],
      ),
    );
  }
}
