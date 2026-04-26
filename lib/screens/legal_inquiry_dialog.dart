import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/legal_service_api.dart';
import '../models/inquiry_request.dart';
import '../commons/common_widget.dart';

class InquiryDialog extends StatefulWidget {
  const InquiryDialog({super.key});

  @override
  State<InquiryDialog> createState() => _InquiryDialogState();
}

class _InquiryDialogState extends State<InquiryDialog> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _messageController = TextEditingController();

  bool _loading = false;

  final List<String> _services = [
    "DOCUMENT_SERVICES",
    "PROPERTY_REGISTRATION",
    "RENT_AGREEMENT",
  ];

  String _selectedService = "DOCUMENT_SERVICES";

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final inquiry = Inquiry(
        applicantName: _nameController.text.trim(),
        mobileNumber: _phoneController.text.trim(),
        inquiryType: _selectedService,
        comments: _messageController.text.trim(),
        leadSource: "APP",
      );

      await LegalServiceApi.submitInquiry(inquiry);

      if (!mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.success,
          content: Text("Inquiry submitted successfully"),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.error,
          content: Text("Failed to submit inquiry"),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.listingbackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Raise an Inquiry',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              /// NAME
              _buildTextField(
                controller: _nameController,
                label: "Full Name",
                validator: (v) => v == null || v.isEmpty ? "Enter your name" : null,
              ),
              const SizedBox(height: 12),

              /// PHONE
              _buildTextField(
                controller: _phoneController,
                label: "Mobile Number",
                keyboardType: TextInputType.phone,
                validator: (v) =>
                v == null || v.length != 10 ? "Enter valid 10-digit number" : null,
              ),
              const SizedBox(height: 12),

              /// SERVICE
              DropdownButtonFormField<String>(
                value: _selectedService,
                items: _services
                    .map(
                      (s) => DropdownMenuItem(
                    value: s,
                    child: Text(s.replaceAll("_", " ")),
                  ),
                )
                    .toList(),
                onChanged: (v) => setState(() => _selectedService = v!),
                decoration: _inputDecoration(label: "Service"),
              ),
              const SizedBox(height: 12),

              /// MESSAGE
              _buildTextField(
                controller: _messageController,
                label: "Message",
                maxLines: 3,
              ),
              const SizedBox(height: 20),

              /// SUBMIT BUTTON
              /// SUBMIT BUTTON (AppButton)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: AppButton(
                  text: "Submit Inquiry",
                  isLoading: _loading,
                  onTap: _loading ? null : _submit,
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  /// STANDARD WHITE ROUNDED TEXTFIELD
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: _inputDecoration(label: label),
    );
  }

  InputDecoration _inputDecoration({required String label}) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
