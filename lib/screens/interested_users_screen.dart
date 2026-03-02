import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_colors.dart';
import '../services/leads_service.dart';

class BrokerLeadsScreen extends StatefulWidget {
  final String userId;

  const BrokerLeadsScreen({
    super.key,
    required this.userId,
  });

  @override
  State<BrokerLeadsScreen> createState() => _BrokerLeadsScreenState();
}

class _BrokerLeadsScreenState extends State<BrokerLeadsScreen> {
  bool _isLoading = true;
  String _error = "";

  List<dynamic> _leads = [];

  DateTime? _startDate;
  DateTime? _endDate;
  List<String> _selectedStatus = [];

  final List<String> _statusList = [
    "NEW",
    "CONTACTED",
    "VISIT PLANNED",
    "CLOSED",
    "DROPPED"
  ];

  @override
  void initState() {
    super.initState();
    _loadLeads();
  }

  Future<void> _loadLeads() async {
    try {
      setState(() {
        _isLoading = true;
        _error = "";
      });

      final data = await LeadApiService.fetchBrokerLeads(
        brokerId: widget.userId,
        status: _selectedStatus,
        startDate: _startDate,
        endDate: _endDate,
      );

      setState(() {
        _leads = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  String _formatDate(String? date) {
    if (date == null) return "-";
    return DateFormat("dd MMM yyyy").format(DateTime.parse(date));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.listingbackground,
      appBar: AppBar(
        title: const Text("My Leads"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  Widget _buildList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error.isNotEmpty) {
      return Center(child: Text("❌ $_error"));
    }

    if (_leads.isEmpty) {
      return const Center(child: Text("No leads found"));
    }

    return RefreshIndicator(
      onRefresh: _loadLeads,
      child: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: _leads.length,
        itemBuilder: (context, index) {
          final lead = _leads[index];

          return Card(
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// HEADER
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lead["clientName"] ?? "Client",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _statusBadge(lead["status"]),
                    ],
                  ),

                  const SizedBox(height: 6),

                  /// CONTACT INFO
                  Text("📞 ${lead["mobile"] ?? "-"}"),
                  if (lead["email"] != null)
                    Text("✉️ ${lead["email"]}"),

                  const Divider(),

                  /// PROPERTY SNAPSHOT
                  Text("🏠 ${lead["propertyTitle"] ?? "-"}"),
                  Text("📍 ${lead["propertyCity"] ?? "-"}"),
                  Text("💰 Price: ₹${lead["propertyPrice"] ?? "-"}"),

                  const SizedBox(height: 4),

                  /// CLIENT PREFERENCE
                  Text("🎯 Preference: ${lead["preferredPropertyType"] ?? "-"}"),
                  Text("💼 Budget: ₹${lead["preferredBudget"] ?? "-"}"),

                  const Divider(),

                  /// DATES
                  Text("🗓 Inquiry: ${_formatDate(lead["inquiryDate"])}"),
                  Text("☎️ Contacted: ${_formatDate(lead["contactedDate"])}"),
                  Text("⏭ Follow-up: ${_formatDate(lead["nextFollowUpDate"])}"),

                  const Divider(),

                  /// META
                  Text("📌 Lead Source: ${lead["leadSource"] ?? "-"}"),
                  Text("📝 Remark: ${lead["remark"] ?? "-"}"),

                  const SizedBox(height: 10),

                  /// ACTIONS
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _call(lead["mobile"]),
                          icon: const Icon(Icons.call),
                          label: const Text("Call"),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green),
                          onPressed: () => _whatsapp(lead["mobile"]),
                          icon: const Icon(Icons.chat),
                          label: const Text("WhatsApp"),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        },
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
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status ?? "-",
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
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