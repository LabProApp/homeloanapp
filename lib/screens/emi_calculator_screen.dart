import 'package:flutter/material.dart';
import 'package:property/theme/app_colors.dart';
import '../models/calcLoanRequest.dart';
import '../models/calcLoanResponse.dart';
import '../services/emi_service.dart';

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
  final incomeCtrl = TextEditingController();
  final existingEmiCtrl = TextEditingController();

  bool loading = false;
  CalcLoanResponse? response;

  @override
  void initState() {
    super.initState();

    /// ✅ Clear everything on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _resetForm();
    });
  }

  void _resetForm() {
    _formKey.currentState?.reset();

    principalCtrl.clear();
    interestCtrl.clear();
    tenureCtrl.clear();
    incomeCtrl.clear();
    existingEmiCtrl.clear();

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
    incomeCtrl.dispose();
    existingEmiCtrl.dispose();
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
        monthlyIncome: double.parse(incomeCtrl.text),
        existingEmi: double.parse(existingEmiCtrl.text),
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
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "EMI Calculator",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              /// 🔳 FORM CARD
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _field("Loan Amount", principalCtrl),
                        _field("Interest Rate (%)", interestCtrl),
                        _field("Tenure (Years)", tenureCtrl),
                        _field("Monthly Income", incomeCtrl),
                        _field("Existing EMI", existingEmiCtrl),
                        const SizedBox(height: 20),

                        /// 🤍 WHITE BUTTON
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: loading ? null : calculateEmi,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.primary,
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: loading
                                ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            )
                                : const Text(
                              "Calculate EMI",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              /// 📊 RESULT
              if (response != null) _resultCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        validator: (v) => v == null || v.isEmpty ? "Required" : null,
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
            _row("Affordable EMI", response!.affordableEmi),
            _row("Eligible Loan", response!.eligibleLoan),
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
