// bank_applyLoan_dialog.dart (updated for Legal Inquiry with Property Type dropdown)
import 'package:flutter/material.dart';
import 'package:property/services/legal_service_api.dart';
import 'package:property/models/inquiry_request.dart';
import 'package:property/theme/app_colors.dart';

class LoanApplyDialog {
  static void show(BuildContext context) {
    final _formKey = GlobalKey<FormState>();

    // Applicant Details
    final TextEditingController nameController = TextEditingController();
    final TextEditingController mobileController = TextEditingController();
    final TextEditingController emailController = TextEditingController();

    final TextEditingController incomeController = TextEditingController();
    final TextEditingController commentsController = TextEditingController();

    // Loan Details

    final TextEditingController loanAmountController = TextEditingController();
    final TextEditingController tenureController = TextEditingController();

    // Property Details
    final TextEditingController propertyStateController =
        TextEditingController();
    final TextEditingController propertyCityController =
        TextEditingController();

    bool isPropertyIdentified = false;

    // Property Type Dropdown
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

    // Inquiry type
    String inquiryType = "HOME_LOAN";

    bool _loading = false;

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
                          // Header
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 20,
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: const BorderRadius.only(
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

                          // Applicant & Loan & Property Details
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                /// 🔹 Applicant Details
                                _buildTextField(
                                  label: "Full Name",
                                  controller: nameController,
                                  icon: Icons.person,
                                ),
                                _buildTextField(
                                  label: "Mobile Number",
                                  controller: mobileController,
                                  icon: Icons.phone,
                                  keyboardType: TextInputType.phone,
                                ),
                                _buildTextField(
                                  label: "Email",
                                  controller: emailController,
                                  icon: Icons.email,
                                  keyboardType: TextInputType.emailAddress,
                                  optional: true,
                                ),
                                _buildTextField(
                                  label: "Monthly Income",
                                  controller: incomeController,
                                  icon: Icons.currency_rupee,
                                  keyboardType: TextInputType.number,
                                  optional: true,
                                ),

                                /// 🔹 Loan Details
                                _buildTextField(
                                  label: "Required Loan Amount",
                                  controller: loanAmountController,
                                  icon: Icons.money,
                                  keyboardType: TextInputType.number,
                                ),
                                _buildTextField(
                                  label: "Loan Tenure (Years)",
                                  controller: tenureController,
                                  icon: Icons.schedule,
                                  keyboardType: TextInputType.number,
                                ),

                                /// 🔹 Property Details
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 6,
                                  ),
                                  child: DropdownButtonFormField<String>(
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
                                    onChanged: (val) =>
                                        selectedPropertyType = val,
                                    decoration: InputDecoration(
                                      labelText: "Property Type",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey[100],
                                    ),
                                    validator: (_) => null, // optional field
                                  ),
                                ),
                                _buildTextField(
                                  label: "Property State",
                                  controller: propertyStateController,
                                  icon: Icons.map,
                                  optional: true,
                                ),
                                _buildTextField(
                                  label: "Property City",
                                  controller: propertyCityController,
                                  icon: Icons.location_city,
                                  optional: true,
                                ),

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

                                _buildTextField(
                                  label: "Comments",
                                  controller: commentsController,
                                  icon: Icons.comment,
                                  maxLines: 3,
                                  optional: true,
                                ),
                                const SizedBox(height: 16),

                                // Submit Button
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
                                              if (ctx.mounted)
                                                setState(
                                                  () => _loading = false,
                                                );
                                            }
                                          },
                                    style: ElevatedButton.styleFrom(
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

  static Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool optional = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: (val) {
          if (!optional && (val == null || val.trim().isEmpty)) {
            return "Please enter $label";
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon) : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.grey[100],
        ),
      ),
    );
  }
}
