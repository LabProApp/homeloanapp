import 'package:flutter/material.dart';
import 'package:property/models/bank_model.dart';
import 'package:property/services/bank_service.dart';
import 'package:property/theme/app_colors.dart';
import 'package:property/cards/bank_card.dart';

class BankPage extends StatefulWidget {
  const BankPage({super.key});

  @override
  State<BankPage> createState() => _BankPageState();
}

class _BankPageState extends State<BankPage> {
  final TextEditingController _searchController = TextEditingController();
  final BankApiService _bankService = BankApiService();

  List<FetchBanks> _allBanks = [];
  List<FetchBanks> _filteredBanks = [];

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
          .where((b) =>
          (b.bankName ?? '')
              .toLowerCase()
              .contains(value.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: _searchBar(),
            ),
            Expanded(child: _buildBody()),
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
      return const Center(child: Text("No banks found"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      itemCount: _filteredBanks.length,
      itemBuilder: (_, index) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: BankCard(bank: _filteredBanks[index]),
      ),
    );
  }

  Widget _searchBar() {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _search,
        textAlignVertical: TextAlignVertical.center, // ✅ KEY
        decoration: const InputDecoration(
          hintText: "Search bank",
          border: InputBorder.none,
          isDense: true, // ✅ KEY
          prefixIcon: Icon(Icons.search, size: 20),
        ),
      ),
    );
  }



  Widget _errorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
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
