// bank_applyLoan_dialog.dart
import 'package:flutter/material.dart';
import 'package:property/models/bank_model.dart';
import 'package:property/theme/app_colors.dart';

class LoanApplyDialog {
  static void show(BuildContext context, FetchBanks bank) {
    final _formKey = GlobalKey<FormState>();

    // Controllers
    final TextEditingController nameController = TextEditingController();
    final TextEditingController ageController = TextEditingController();
    final TextEditingController maxLoanController = TextEditingController();
    final TextEditingController maxTenureController = TextEditingController();
    final TextEditingController professionController = TextEditingController();
    final TextEditingController cityController = TextEditingController();
    final TextEditingController stateController = TextEditingController();
    bool isPropertyIdentified = false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            insetPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.85),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            vertical: 20, horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        child: Text(
                          '${bank.bankName ?? "Bank"} Loan Application',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ),

                      // Instruction text
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Text(
                          "Please fill in your details carefully. Fields marked with * are mandatory.",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      // Form
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              _buildTextField(
                                  label: "Name",
                                  controller: nameController,
                                  icon: Icons.person),
                              _buildTextField(
                                  label: "Age",
                                  controller: ageController,
                                  keyboardType: TextInputType.number,
                                  icon: Icons.cake),
                              _buildTextField(
                                  label: "Max Loan Required",
                                  controller: maxLoanController,
                                  keyboardType: TextInputType.number,
                                  icon: Icons.currency_rupee),
                              _buildTextField(
                                  label: "Max Tenure (years)",
                                  controller: maxTenureController,
                                  keyboardType: TextInputType.number,
                                  icon: Icons.schedule),
                              _buildTextField(
                                  label: "Profession",
                                  controller: professionController,
                                  icon: Icons.work),
                              _buildTextField(
                                  label: "City",
                                  controller: cityController,
                                  icon: Icons.location_city),
                              _buildTextField(
                                  label: "State",
                                  controller: stateController,
                                  icon: Icons.map),
                              CheckboxListTile(
                                title: const Text("Property Identified"),
                                value: isPropertyIdentified,
                                controlAffinity:
                                ListTileControlAffinity.leading,
                                onChanged: (val) {
                                  setState(() {
                                    isPropertyIdentified = val ?? false;
                                  });
                                },
                              ),
                              const SizedBox(height: 10),

                              // Gradient Apply button
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      final applicantName =
                                      nameController.text.trim();
                                      final age = int.tryParse(
                                          ageController.text.trim()) ??
                                          0;
                                      final maxLoanRequired = double.tryParse(
                                          maxLoanController.text.trim()) ??
                                          0;
                                      final maxTenure = double.tryParse(
                                          maxTenureController.text.trim()) ??
                                          0;
                                      final profession =
                                      professionController.text.trim();
                                      final city = cityController.text.trim();
                                      final state = stateController.text.trim();

                                      Navigator.pop(ctx);

                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              "Loan application submitted!"),
                                        ),
                                      );

                                      print({
                                        "applicantName": applicantName,
                                        "age": age,
                                        "maxLoanRequired": maxLoanRequired,
                                        "maxTenure": maxTenure,
                                        "profession": profession,
                                        "city": city,
                                        "state": state,
                                        "isPropertyIdentified":
                                        isPropertyIdentified,
                                      });
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: Ink(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColors.primary,
                                          AppColors.primary.withOpacity(0.8)
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: const Text(
                                        "Apply",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
      },
    );
  }

  static Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: (val) {
          if (val == null || val.trim().isEmpty) {
            return "Please enter $label";
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.grey[100],
        ),
      ),
    );
  }
}
