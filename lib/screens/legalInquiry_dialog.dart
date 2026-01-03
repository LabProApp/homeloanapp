import 'package:flutter/material.dart';
import 'package:property/theme/app_colors.dart';
import 'package:property/services/legal_service_api.dart';
import 'package:property/models/inquiry_request.dart';

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
    setState(() => _loading = true);
    print("Submit called");  // 🔹 Debug log

    try {
      final inquiry = Inquiry(
        applicantName: _nameController.text.trim(),
        mobileNumber: _phoneController.text.trim(),
        inquiryType: _selectedService,
        comments: _messageController.text.trim(),
        leadSource: "APP",
      );

      print("Inquiry object: $inquiry");  // 🔹 Debug log

      await LegalServiceApi.submitInquiry(inquiry);

      if (!mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.success,
          content: Text("Inquiry submitted successfully"),
        ),
      );
    } catch (e, st) {
      print("Submit error: $e"); // 🔹 Debug log
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                v == null || v.isEmpty ? "Enter your name" : null,
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
                v == null || v.length != 10
                    ? "Enter valid 10-digit number"
                    : null,
              ),
              const SizedBox(height: 12),

              /// 🔹 SERVICE
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
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    "Submit Inquiry",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
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
