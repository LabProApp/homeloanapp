import 'package:flutter/material.dart';
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
    return Material(
      color: const Color(0xFFF5F7FA), // ✅ fixes black background
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "EMI Calculator",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Form(
              key: _formKey,
              child: Column(
                children: [
                  _field("Loan Amount", principalCtrl),
                  _field("Interest Rate (%)", interestCtrl),
                  _field("Tenure (Years)", tenureCtrl),
                  _field("Monthly Income", incomeCtrl),
                  _field("Existing EMI", existingEmiCtrl),
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: loading ? null : calculateEmi,
                      child: loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Calculate EMI"),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            if (response != null) _resultCard(),
          ],
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
