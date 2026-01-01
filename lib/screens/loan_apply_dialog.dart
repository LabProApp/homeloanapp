// loan_apply_dialog.dart
import 'package:flutter/material.dart';
import 'package:property/models/bank_model.dart';

class LoanApplyDialog {
  /// Show the loan apply popup with input fields
  static void show(BuildContext context, FetchBanks bank) {
    final _formKey = GlobalKey<FormState>();

    // Controllers for text fields
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
        return StatefulBuilder(
          builder: (ctx, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
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
                                icon: Icons.attach_money),
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
                              controlAffinity: ListTileControlAffinity.leading,
                              onChanged: (val) {
                                setState(() {
                                  isPropertyIdentified = val ?? false;
                                });
                              },
                            ),
                            const SizedBox(height: 10),
                            // Apply button
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                  Theme.of(context).primaryColor,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    // Collect input
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

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            "Loan application submitted!"),
                                      ),
                                    );

                                    // Debug print
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
                                child: const Text(
                                  "Apply",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
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
            );
          },
        );
      },
    );
  }

  // Helper to build styled text field with icon
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
