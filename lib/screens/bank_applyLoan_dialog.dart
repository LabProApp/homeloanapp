// bank_applyLoan_dialog.dart (Grey Themed)

import 'package:flutter/material.dart';
import '../services/legal_service_api.dart';
import '../models/inquiry_request.dart';
import '../theme/app_colors.dart';

class LoanApplyDialog {
  static void show(BuildContext context) {
    final _formKey = GlobalKey<FormState>();

    // Controllers
    final nameController = TextEditingController();
    final mobileController = TextEditingController();
    final emailController = TextEditingController();
    final incomeController = TextEditingController();
    final commentsController = TextEditingController();
    final loanAmountController = TextEditingController();
    final tenureController = TextEditingController();
    final propertyStateController = TextEditingController();
    final propertyCityController = TextEditingController();

    bool isPropertyIdentified = false;

    final List<String> propertyTypes = [
      "HOUSE",
      "PLOT",
      "APARTMENT",
      "PLOT_SHOP",
      "SHOP",
      "PG",
      "BUILDER_FLOOR",
      "OFFICE",
      "CO_WORKING",
      "AGRICULTURAL",
      "SHOWROOM",
    ];

    String? selectedPropertyType;
    String inquiryType = "HOME_LOAN";
    bool _loading = false;

    const double vGap = 12;
    const Color primaryGrey = Colors.grey;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 24,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.85,
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          /// HEADER
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 20,
                              horizontal: 16,
                            ),
                            decoration: const BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                            ),
                            child: const Text(
                              'Raise Home Loan Inquiry',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                _buildTextField(
                                  label: "Full Name",
                                  controller: nameController,
                                  icon: Icons.person,
                                ),
                                const SizedBox(height: vGap),

                                _buildTextField(
                                  label: "Mobile Number",
                                  controller: mobileController,
                                  icon: Icons.phone,
                                  keyboardType: TextInputType.phone,
                                ),
                                const SizedBox(height: vGap),

                                _buildTextField(
                                  label: "Email",
                                  controller: emailController,
                                  icon: Icons.email,
                                  keyboardType: TextInputType.emailAddress,
                                  optional: true,
                                ),
                                const SizedBox(height: vGap),

                                _buildTextField(
                                  label: "Monthly Income",
                                  controller: incomeController,
                                  icon: Icons.currency_rupee,
                                  keyboardType: TextInputType.number,
                                  optional: true,
                                ),
                                const SizedBox(height: vGap),

                                _buildTextField(
                                  label: "Required Loan Amount",
                                  controller: loanAmountController,
                                  icon: Icons.money,
                                  keyboardType: TextInputType.number,
                                ),
                                const SizedBox(height: vGap),

                                _buildTextField(
                                  label: "Loan Tenure (Years)",
                                  controller: tenureController,
                                  icon: Icons.schedule,
                                  keyboardType: TextInputType.number,
                                ),
                                const SizedBox(height: vGap),

                                /// PROPERTY TYPE DROPDOWN
                                DropdownButtonFormField<String>(
                                  value: selectedPropertyType,
                                  items: propertyTypes
                                      .map(
                                        (type) => DropdownMenuItem(
                                          value: type,
                                          child: Text(
                                            type.replaceAll("_", " "),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (val) {
                                    setState(() {
                                      selectedPropertyType = val;
                                    });
                                  },
                                  decoration: _inputDecoration(
                                    label: "Property Type",
                                    icon: Icons.home,
                                  ),
                                ),
                                const SizedBox(height: vGap),

                                _buildTextField(
                                  label: "Property State",
                                  controller: propertyStateController,
                                  icon: Icons.map,
                                  optional: true,
                                ),
                                const SizedBox(height: vGap),

                                _buildTextField(
                                  label: "Property City",
                                  controller: propertyCityController,
                                  icon: Icons.location_city,
                                  optional: true,
                                ),

                                /// CHECKBOX
                                CheckboxListTile(
                                  title: const Text("Property Identified"),
                                  value: isPropertyIdentified,
                                  activeColor: primaryGrey,
                                  checkColor: Colors.white,
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  onChanged: (val) {
                                    setState(() {
                                      isPropertyIdentified = val ?? false;
                                    });
                                  },
                                ),

                                _buildTextField(
                                  label: "Comments",
                                  controller: commentsController,
                                  icon: Icons.comment,
                                  maxLines: 3,
                                  optional: true,
                                ),

                                const SizedBox(height: 16),

                                /// SUBMIT BUTTON
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: _loading
                                        ? null
                                        : () async {
                                            if (!_formKey.currentState!
                                                .validate())
                                              return;

                                            setState(() => _loading = true);

                                            final inquiry = Inquiry(
                                              applicantName: nameController.text
                                                  .trim(),
                                              mobileNumber: mobileController
                                                  .text
                                                  .trim(),
                                              email:
                                                  emailController.text
                                                      .trim()
                                                      .isEmpty
                                                  ? null
                                                  : emailController.text.trim(),
                                              monthlyIncome: double.tryParse(
                                                incomeController.text.trim(),
                                              ),
                                              inquiryType: inquiryType,
                                              comments:
                                                  commentsController.text
                                                      .trim()
                                                      .isEmpty
                                                  ? null
                                                  : commentsController.text
                                                        .trim(),
                                              requiredLoanAmount:
                                                  double.tryParse(
                                                    loanAmountController.text
                                                        .trim(),
                                                  ),
                                              loanTenureYears: int.tryParse(
                                                tenureController.text.trim(),
                                              ),
                                              propertyType:
                                                  selectedPropertyType,
                                              propertyState:
                                                  propertyStateController.text
                                                      .trim()
                                                      .isEmpty
                                                  ? null
                                                  : propertyStateController.text
                                                        .trim(),
                                              propertyCity:
                                                  propertyCityController.text
                                                      .trim()
                                                      .isEmpty
                                                  ? null
                                                  : propertyCityController.text
                                                        .trim(),
                                              propertyIdentified:
                                                  isPropertyIdentified,
                                              leadSource: "APP",
                                            );

                                            try {
                                              await LegalServiceApi.submitInquiry(
                                                inquiry,
                                              );
                                              if (!ctx.mounted) return;
                                              Navigator.pop(ctx);

                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  backgroundColor:
                                                      AppColors.success,
                                                  content: Text(
                                                    "Inquiry submitted successfully",
                                                  ),
                                                ),
                                              );
                                            } catch (e) {
                                              if (!ctx.mounted) return;
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  backgroundColor:
                                                      AppColors.error,
                                                  content: Text(
                                                    "Failed to submit inquiry: $e",
                                                  ),
                                                ),
                                              );
                                            } finally {
                                              if (ctx.mounted) {
                                                setState(
                                                  () => _loading = false,
                                                );
                                              }
                                            }
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryGrey,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: _loading
                                        ? const CircularProgressIndicator(
                                            color: Colors.white,
                                          )
                                        : const Text(
                                            "Submit Inquiry",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// TEXT FIELD BUILDER (GREY THEME)
  static Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool optional = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      cursorColor: Colors.grey,
      validator: (val) {
        if (!optional && (val == null || val.trim().isEmpty)) {
          return "Please enter $label";
        }
        return null;
      },
      decoration: _inputDecoration(label: label, icon: icon),
    );
  }

  static InputDecoration _inputDecoration({
    required String label,
    IconData? icon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey),
      prefixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.black54, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey.shade100,
    );
  }
}
