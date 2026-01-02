import 'package:flutter/material.dart';
import 'package:property/theme/app_colors.dart';
import 'package:property/services/legalInquiry_service.dart';

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

  String _selectedService = "Property Registration";
  bool _loading = false;

  final List<String> _services = [
    "Property Legal Consultation",
    "Property Registration",
    "Agreement to Sell(Beanna)",
    "Rent Agreement",
    "Loan Documentation Support",
  ];

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final success = await InquiryService.submitInquiry(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      service: _selectedService,
      message: _messageController.text.trim(),
    );

    setState(() => _loading = false);

    if (!mounted) return;

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor:
        success ? AppColors.success : AppColors.error,
        content: Text(
          success
              ? "Inquiry submitted successfully"
              : "Failed to submit inquiry",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
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
              /// 🔹 TITLE
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Raise an Inquiry",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
              const SizedBox(height: 16),

              /// 🔹 NAME
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Full Name",
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                v!.isEmpty ? "Enter your name" : null,
              ),
              const SizedBox(height: 12),

              /// 🔹 PHONE
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "Mobile Number",
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                v!.length < 10 ? "Enter valid number" : null,
              ),
              const SizedBox(height: 12),

              /// 🔹 SERVICE
              DropdownButtonFormField<String>(
                value: _selectedService,
                items: _services
                    .map(
                      (s) => DropdownMenuItem(
                    value: s,
                    child: Text(s),
                  ),
                )
                    .toList(),
                onChanged: (v) => setState(() {
                  _selectedService = v!;
                }),
                decoration: const InputDecoration(
                  labelText: "Service",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              /// 🔹 MESSAGE
              TextFormField(
                controller: _messageController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Message",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              /// 🔹 SUBMIT
              SizedBox(
                width: double.infinity,
                height: 60,

                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // 👈 radius here
                    ),
                    elevation: 4, // optional: nice depth
                  ),
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const CircularProgressIndicator(
                    color: Colors.white,

                  )
                      : const Text(
                    "Submit Inquiry",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
