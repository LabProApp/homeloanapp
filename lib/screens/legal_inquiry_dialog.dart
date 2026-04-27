import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/legal_service_api.dart';
import '../models/inquiry_request.dart';
import '../commons/common_widget.dart';

class InquiryDialog extends StatefulWidget {
  final String? providerName;
  final String? preselectedService;

  const InquiryDialog({
    super.key,
    this.providerName,
    this.preselectedService,
  });

  @override
  State<InquiryDialog> createState() => _InquiryDialogState();
}

class _InquiryDialogState extends State<InquiryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _messageController = TextEditingController();

  bool _loading = false;
  late String _selectedService;

  static const Map<String, String> _serviceLabels = {
    'DOCUMENT_SERVICES': 'Document Services',
    'PROPERTY_REGISTRATION': 'Property Registration',
    'RENT_AGREEMENT': 'Rent Agreement',
  };

  @override
  void initState() {
    super.initState();
    _selectedService =
        (widget.preselectedService != null &&
                _serviceLabels.containsKey(widget.preselectedService))
            ? widget.preselectedService!
            : 'DOCUMENT_SERVICES';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final commentParts = <String>[];
    if ((widget.providerName ?? '').isNotEmpty) {
      commentParts.add('Provider: ${widget.providerName}');
    }
    if (_messageController.text.trim().isNotEmpty) {
      commentParts.add(_messageController.text.trim());
    }

    try {
      await LegalServiceApi.submitInquiry(Inquiry(
        applicantName: _nameController.text.trim(),
        mobileNumber: _phoneController.text.trim(),
        inquiryType: _selectedService,
        comments: commentParts.isEmpty ? null : commentParts.join(' | '),
        leadSource: 'APP',
      ));

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.success,
          content: Text('Inquiry submitted successfully'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.error,
          content: Text('Failed to submit inquiry'),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Colored header band ─────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 14, 4, 14),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                const Icon(Icons.support_agent_rounded,
                    color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Raise an Inquiry',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                      if ((widget.providerName ?? '').isNotEmpty)
                        Text(
                          widget.providerName!,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),

          // ── Form ────────────────────────────────────────────────────
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _field(
                      controller: _nameController,
                      label: 'Full Name',
                      icon: Icons.person_outline_rounded,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Enter your name'
                          : null,
                    ),
                    const SizedBox(height: 12),

                    _field(
                      controller: _phoneController,
                      label: 'Mobile Number',
                      icon: Icons.phone_outlined,
                      keyboard: TextInputType.phone,
                      validator: (v) {
                        if (v == null) return 'Enter a valid 10-digit number';
                        final digits = v.replaceAll(RegExp(r'\D'), '');
                        final valid = digits.length == 10 ||
                            (digits.length == 12 && digits.startsWith('91'));
                        return valid ? null : 'Enter a valid 10-digit number';
                      },
                    ),
                    const SizedBox(height: 12),

                    // Service type
                    DropdownButtonFormField<String>(
                      value: _selectedService,
                      decoration: _inputDeco(
                          label: 'Service Type', icon: Icons.gavel_rounded),
                      items: _serviceLabels.entries
                          .map((e) => DropdownMenuItem(
                              value: e.key, child: Text(e.value)))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _selectedService = v!),
                    ),
                    const SizedBox(height: 12),

                    _field(
                      controller: _messageController,
                      label: 'Message (optional)',
                      icon: Icons.comment_outlined,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: AppButton(
                        text: 'Submit Inquiry',
                        isLoading: _loading,
                        onTap: _loading ? null : _submit,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      maxLines: maxLines,
      validator: validator,
      decoration: _inputDeco(label: label, icon: icon),
    );
  }

  InputDecoration _inputDeco({required String label, required IconData icon}) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      isDense: true,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      labelStyle: const TextStyle(color: AppColors.textMuted),
      prefixIcon: Icon(icon, size: 20, color: AppColors.textMuted),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
