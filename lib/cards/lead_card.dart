import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_colors.dart';
import '../commons/common_widget.dart';

class LeadCard extends StatelessWidget {
  final Map lead;
  final VoidCallback onEdit;

  const LeadCard({
    super.key,
    required this.lead,
    required this.onEdit,
  });

  String _formatDate(String? date) {
    if (date == null) return "-";
    return DateFormat("dd MMM yyyy").format(DateTime.parse(date));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  lead["clientName"] ?? "Client",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              _statusBadge(lead["status"]),
              IconButton(
                icon: const Icon(Icons.edit, color: AppColors.primary),
                onPressed: onEdit,
              )
            ],
          ),

          const SizedBox(height: 6),
          _infoRow(Icons.phone_outlined, lead["mobile"] ?? "-"),
          if (lead["email"] != null)
            _infoRow(Icons.email_outlined, lead["email"]),

          const Divider(),
          _infoRow(Icons.home_outlined, lead["propertyTitle"] ?? "-"),
          _infoRow(Icons.location_on_outlined, lead["propertyCity"] ?? "-"),
          _infoRow(Icons.currency_rupee_outlined, "Price: ₹${lead["propertyPrice"] ?? "-"}"),

          const Divider(),
          _infoRow(Icons.tune_outlined, "Preference: ${lead["preferredPropertyType"] ?? "-"}"),
          _infoRow(Icons.account_balance_wallet_outlined, "Budget: ₹${lead["preferredBudget"] ?? "-"}"),

          const Divider(),
          _infoRow(Icons.calendar_today_outlined, "Inquiry: ${_formatDate(lead["inquiryDate"])}"),
          _infoRow(Icons.call_outlined, "Contacted: ${_formatDate(lead["contactedDate"])}"),
          _infoRow(Icons.schedule_outlined, "Follow-up: ${_formatDate(lead["nextFollowUpDate"])}"),

          const Divider(),
          _infoRow(Icons.push_pin_outlined, "Source: ${lead["leadSource"] ?? "-"}"),
          _infoRow(Icons.notes_outlined, "Remark: ${lead["remark"] ?? "-"}"),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 34,
                  child: AppButton(
                    text: "Call",
                    onTap: () => _call(lead["mobile"]),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 34,
                  child: AppButton(
                    text: "WhatsApp",
                    onTap: () => _whatsapp(lead["mobile"]),
                  ),
                ),
              ),
            ],
          )
        ]),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: AppColors.textMuted),
          const SizedBox(width: 6),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  Widget _statusBadge(String? status) {
    Color color;
    switch (status) {
      case "NEW":
        color = AppColors.info;
        break;
      case "CONTACTED":
        color = AppColors.warning;
        break;
      case "CLOSED":
        color = AppColors.success;
        break;
      case "DROPPED":
        color = AppColors.error;
        break;
      default:
        color = AppColors.textMuted;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status ?? "-",
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Future<void> _call(String? phone) async {
    if (phone == null || phone.isEmpty) return;
    final uri = Uri.parse("tel:$phone");
    await launchUrl(uri);
  }

  Future<void> _whatsapp(String? phone) async {
    if (phone == null || phone.isEmpty) return;
    final uri = Uri.parse("https://wa.me/$phone");
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}