import 'package:flutter/material.dart';
import '../services/legal_service_api.dart';
import '../models/inquiry_request.dart';
import '../theme/app_colors.dart';
import '../commons/common_widget.dart';

class LoanApplySheet {
  static void show(BuildContext context) {
    final _formKey = GlobalKey<FormState>();

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
    String? selectedPropertyType;
    String inquiryType = "HOME_LOAN";
    bool _loading = false;

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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.orange.shade50,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: SizedBox(
                height: MediaQuery.of(ctx).size.height * 0.85,
                child: Column(
                  children: [
                    /// HEADER
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'Home Loan Inquiry',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    /// FORM
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              const SizedBox(height: 8),
                              _buildTextField(
                                label: "Full Name",
                                controller: nameController,
                                icon: Icons.person,
                              ),
                              const SizedBox(height: 10),
                              _buildTextField(
                                label: "Mobile Number",
                                controller: mobileController,
                                icon: Icons.phone,
                                keyboardType: TextInputType.phone,
                              ),
                              const SizedBox(height: 10),
                              _buildTextField(
                                label: "Email",
                                controller: emailController,
                                icon: Icons.email,
                                keyboardType: TextInputType.emailAddress,
                                optional: true,
                              ),
                              const SizedBox(height: 10),
                              _buildTextField(
                                label: "Monthly Income",
                                controller: incomeController,
                                icon: Icons.currency_rupee,
                                keyboardType: TextInputType.number,
                                optional: true,
                              ),
                              const SizedBox(height: 10),
                              _buildTextField(
                                label: "Required Loan Amount",
                                controller: loanAmountController,
                                icon: Icons.money,
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: 10),
                              _buildTextField(
                                label: "Loan Tenure (Years)",
                                controller: tenureController,
                                icon: Icons.schedule,
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: 10),

                              /// PROPERTY TYPE
                              DropdownButtonFormField<String>(
                                value: selectedPropertyType,
                                items: propertyTypes
                                    .map(
                                      (type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(type.replaceAll("_", " ")),
                                  ),
                                )
                                    .toList(),
                                onChanged: (val) {
                                  setState(() {
                                    selectedPropertyType = val;
                                  });
                                },
                                decoration: _bottomSheetInputDecoration(
                                  label: "Property Type",
                                  icon: Icons.home,
                                ),
                              ),
                              const SizedBox(height: 10),
                              _buildTextField(
                                label: "Property State",
                                controller: propertyStateController,
                                icon: Icons.map,
                                optional: true,
                              ),
                              const SizedBox(height: 10),
                              _buildTextField(
                                label: "Property City",
                                controller: propertyCityController,
                                icon: Icons.location_city,
                                optional: true,
                              ),
                              CheckboxListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                title: const Text("Property Identified"),
                                value: isPropertyIdentified,
                                activeColor: AppColors.primary,
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
                              const SizedBox(height: 60),
                            ],
                          ),
                        ),
                      ),
                    ),

                    /// STICKY SUBMIT BUTTON
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: AppButton(
                        text: "Submit Inquiry",
                        isLoading: _loading,
                        onTap: () async {
                          if (!_formKey.currentState!.validate()) return;

                          setState(() => _loading = true);

                          final inquiry = Inquiry(
                            applicantName: nameController.text.trim(),
                            mobileNumber: mobileController.text.trim(),
                            email: emailController.text.trim().isEmpty
                                ? null
                                : emailController.text.trim(),
                            monthlyIncome: double.tryParse(
                                incomeController.text.trim()),
                            inquiryType: inquiryType,
                            comments: commentsController.text.trim().isEmpty
                                ? null
                                : commentsController.text.trim(),
                            requiredLoanAmount: double.tryParse(
                                loanAmountController.text.trim()),
                            loanTenureYears:
                            int.tryParse(tenureController.text.trim()),
                            propertyType: selectedPropertyType,
                            propertyState: propertyStateController.text.trim().isEmpty
                                ? null
                                : propertyStateController.text.trim(),
                            propertyCity: propertyCityController.text.trim().isEmpty
                                ? null
                                : propertyCityController.text.trim(),
                            propertyIdentified: isPropertyIdentified,
                            leadSource: "APP",
                          );

                          try {
                            await LegalServiceApi.submitInquiry(inquiry);
                            if (!ctx.mounted) return;
                            Navigator.pop(ctx);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: AppColors.success,
                                content: Text(
                                    "Inquiry submitted successfully"),
                              ),
                            );
                          } catch (e) {
                            if (!ctx.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: AppColors.error,
                                content: Text("Failed to submit inquiry: $e"),
                              ),
                            );
                          } finally {
                            if (ctx.mounted) setState(() => _loading = false);
                          }
                        },
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
      validator: (val) {
        if (!optional && (val == null || val.trim().isEmpty)) {
          return "Please enter $label";
        }
        return null;
      },
      decoration: _bottomSheetInputDecoration(label: label, icon: icon),
    );
  }

  static InputDecoration _bottomSheetInputDecoration({
    required String label,
    IconData? icon,
  }) {
    return InputDecoration(
      labelText: label,
      isDense: true,
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      labelStyle: const TextStyle(color: Colors.grey),
      prefixIcon: icon != null
          ? Icon(icon, size: 20, color: Colors.grey)
          : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }
}
