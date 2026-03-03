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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: onEdit,
              )
            ],
          ),

          const SizedBox(height: 6),
          Text("📞 ${lead["mobile"] ?? "-"}"),
          if (lead["email"] != null) Text("✉️ ${lead["email"]}"),

          const Divider(),
          Text("🏠 ${lead["propertyTitle"] ?? "-"}"),
          Text("📍 ${lead["propertyCity"] ?? "-"}"),
          Text("💰 Price: ₹${lead["propertyPrice"] ?? "-"}"),

          const Divider(),
          Text("🎯 Preference: ${lead["preferredPropertyType"] ?? "-"}"),
          Text("💼 Budget: ₹${lead["preferredBudget"] ?? "-"}"),

          const Divider(),
          Text("🗓 Inquiry: ${_formatDate(lead["inquiryDate"])}"),
          Text("☎️ Contacted: ${_formatDate(lead["contactedDate"])}"),
          Text("⏭ Follow-up: ${_formatDate(lead["nextFollowUpDate"])}"),

          const Divider(),
          Text("📌 Lead Source: ${lead["leadSource"] ?? "-"}"),
          Text("📝 Remark: ${lead["remark"] ?? "-"}"),

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

  Widget _statusBadge(String? status) {
    Color color = Colors.grey;
    switch (status) {
      case "NEW":
        color = Colors.blue;
        break;
      case "CONTACTED":
        color = Colors.orange;
        break;
      case "CLOSED":
        color = Colors.green;
        break;
      case "DROPPED":
        color = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
      child: Text(status ?? "-", style: TextStyle(color: color, fontWeight: FontWeight.bold)),
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