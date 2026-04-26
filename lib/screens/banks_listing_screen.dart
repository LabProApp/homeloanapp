import 'package:flutter/material.dart';
import '../models/bank_model.dart';
import '../services/bank_service.dart';
import '../theme/app_colors.dart';
import '../cards/bank_card.dart';
import '../screens/bank_rates_compare_dialog.dart';
import '../screens/bank_apply_loan_dialog.dart';

class BankPage extends StatefulWidget {
  final int? userId;

  const BankPage({
    super.key,
    this.userId,
  });

  @override
  State<BankPage> createState() => _BankPageState();
}

class _BankPageState extends State<BankPage> {
  final TextEditingController _searchController = TextEditingController();
  final BankApiService _bankService = BankApiService();

  List<Bank> _allBanks = [];
  List<Bank> _filteredBanks = [];

  /// Track selected banks using IDs
  final Set<int> _selectedBankIds = {};

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBanks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBanks() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await _bankService.fetchBanks();
      setState(() {
        _allBanks = data;
        _filteredBanks = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _search(String value) {
    setState(() {
      _filteredBanks = _allBanks
          .where((b) =>
          (b.bankName ?? '').toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.listingbackground,

      appBar: AppBar(
        title: const Text("Home Loans & Banks"),

        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: OutlinedButton.icon(
              onPressed: () => LoanApplySheet.show(context),
              icon: const Icon(Icons.support_agent_rounded, size: 18),
              label: const Text('Inquiry'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white70),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
        ],
      ),

      body: SafeArea(
        child: Column(
          children: [
            /// 🔍 SEARCH + 🔁 COMPARE ROW
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Expanded(child: _searchBar()),
                  const SizedBox(width: 8),
                  if (_selectedBankIds.length >= 2)
                    OutlinedButton.icon(
                      onPressed: _showCompareDialog,
                      icon: const Icon(Icons.compare_arrows_rounded, size: 18),
                      label: const Text('Compare'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                ],
              ),
            ),

            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadBanks,
                child: _buildBody(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return _errorState(_error!);
    }

    if (_filteredBanks.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.2),
          const Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.account_balance_outlined, size: 72, color: AppColors.textMuted),
                SizedBox(height: 16),
                Text(
                  "No banks found",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                SizedBox(height: 8),
                Text(
                  "Try a different search term.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: _filteredBanks.length,
      itemBuilder: (_, index) {
        final bank = _filteredBanks[index];
        final bankId = bank.id;

        final isSelected =
            bankId != null && _selectedBankIds.contains(bankId);

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: BankCard(
            bank: bank,
            showCompareCheckbox: true,
            isCompared: isSelected,
            onCompareChanged: (checked) {
              if (bankId == null) return;

              setState(() {
                checked
                    ? _selectedBankIds.add(bankId)
                    : _selectedBankIds.remove(bankId);
              });
            },
          ),
        );
      },
    );
  }

  Widget _searchBar() {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _search,
        decoration: const InputDecoration(
          hintText: "Search bank",
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search, size: 20),
        ),
      ),
    );
  }

  // ================= Compare Dialog =================

  void _showCompareDialog() {
    final selectedBanks = _allBanks
        .where((b) => b.id != null && _selectedBankIds.contains(b.id))
        .toList();

    BankCompareDialog.show(context, selectedBanks);
  }

  Widget _errorState(String message) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_rounded, size: 64, color: AppColors.textMuted),
              const SizedBox(height: 16),
              const Text(
                "Couldn't load banks",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              const Text(
                "Check your connection and try again.",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                icon: const Icon(Icons.refresh_rounded),
                label: const Text("Retry"),
                onPressed: _loadBanks,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
