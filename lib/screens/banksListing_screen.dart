import 'package:flutter/material.dart';
import '../models/bank_model.dart';
import '../services/bank_service.dart';
import '../theme/app_colors.dart';
import '../cards/bank_card.dart';
import '../screens/bank_rates_compare_dialog.dart';

class BankPage extends StatefulWidget {
  final String? userId;


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

  /// ✅ Track selected banks using IDs
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
          .where(
            (b) =>
            (b.bankName ?? '')
                .toLowerCase()
                .contains(value.toLowerCase()),
      )
          .toList();
    });
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          children: [
            _topBar(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: _searchBar(),
            ),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  /// 🔝 Top bar with Compare button
  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Banks",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          /// ✅ Show only when 2+ banks selected
          if (_selectedBankIds.length >= 2)
            ElevatedButton.icon(
              onPressed: _showCompareDialog,
              icon: const Icon(Icons.compare_arrows),
              label: const Text("Compare"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
        ],
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
      return const Center(
        child: Text(
          "No banks found",
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.white),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isLoading = true;
                _error = null;
              });
              _loadBanks();
            },
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }
}
