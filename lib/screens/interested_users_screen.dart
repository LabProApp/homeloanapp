import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/leads_service.dart';
import '../cards/lead_card.dart';
import '../commons/common_widget.dart';

class BrokerLeadsScreen extends StatefulWidget {
  final int brokerId;

  const BrokerLeadsScreen({
    super.key,
    required this.brokerId,
  });

  @override
  State<BrokerLeadsScreen> createState() => _BrokerLeadsScreenState();
}

class _BrokerLeadsScreenState extends State<BrokerLeadsScreen> {
  List<dynamic> _leads = [];
  List<dynamic> _filteredLeads = [];

  bool _loading = true;

  String _search = "";
  String _selectedStatus = "ALL";

  final List<String> _statuses = ["ALL", "NEW", "CONTACTED", "CLOSED", "DROPPED"];

  @override
  void initState() {
    super.initState();
    _loadLeads();
  }

  Future<void> _loadLeads() async {
    setState(() => _loading = true);

    try {
      final data = await LeadApiService.fetchBrokerLeads(
        brokerId: widget.brokerId,
      );

      _leads = data;
      _applyFilters();
    } catch (e) {
      debugPrint("Error loading leads: $e");
    }

    setState(() => _loading = false);
  }

  void _applyFilters() {
    _filteredLeads = _leads.where((lead) {
      final name = (lead["clientName"] ?? "").toString().toLowerCase();
      final mobile = (lead["mobile"] ?? "").toString().toLowerCase();
      final status = (lead["status"] ?? "").toString().toUpperCase();

      final matchesSearch =
          name.contains(_search) || mobile.contains(_search);

      final matchesStatus =
          _selectedStatus == "ALL" || status == _selectedStatus;

      return matchesSearch && matchesStatus;
    }).toList();

    setState(() {});
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
      child: AppSearchField(
        hintText: "Search by name or mobile",
        onChanged: (value) {
          _search = value.toLowerCase();
          _applyFilters();
        },
      ),
    );
  }

  Widget _buildStatusChips() {
    return SizedBox(
      height: 42,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _statuses.length,
        itemBuilder: (context, index) {
          final status = _statuses[index];
          final selected = status == _selectedStatus;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(status),
              selected: selected,
              onSelected: (_) {
                _selectedStatus = status;
                _applyFilters();
              },
              selectedColor: AppColors.primary.withOpacity(0.18),
            ),
          );
        },
      ),
    );
  }

  Widget _buildList() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_filteredLeads.isEmpty) {
      return const Center(child: Text("No leads found"));
    }

    return RefreshIndicator(
      onRefresh: _loadLeads,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _filteredLeads.length,
        itemBuilder: (context, index) {
          final lead = _filteredLeads[index];

          return LeadCard(
            lead: lead,
            onEdit: () {
              _editLeadDialog(lead);
            },
          );
        },
      ),
    );
  }

  void _editLeadDialog(Map lead) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: Center(
              child: Text(
                "Edit Lead UI here for ${lead["clientName"]}",
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customer Inquiries')),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            _buildStatusChips(),
            const SizedBox(height: 6),
            Expanded(child: _buildList()),
          ],
        ),
      ),
    );
  }
}