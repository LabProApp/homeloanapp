import 'package:flutter/material.dart';
import 'package:property/models/bank_model.dart';
import 'package:property/screens/bankDetails_screen.dart';
import 'package:property/screens/bank_applyLoan_dialog.dart';
import 'package:property/services/bank_service.dart';
import 'package:property/theme/app_colors.dart';

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
  String _query = '';

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

  /// ✅ SIMPLE API CALL (YOUR REQUESTED APPROACH)
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
      _query = value.toLowerCase();
      _filteredBanks = _allBanks
          .where((b) =>
          (b.bankName ?? '').toLowerCase().contains(_query))
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

            Expanded(
              child: _buildBody(),
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
      return _emptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredBanks.length,
      itemBuilder: (_, index) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: _BankCard(bank: _filteredBanks[index]),
      ),
    );
  }

  Widget _searchBar() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _search,
        decoration: const InputDecoration(
          hintText: "Search bank",
          prefixIcon: Icon(Icons.search),
          border: InputBorder.none,
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

  Widget _emptyState() {
    return const Center(
      child: Text("No banks found"),
    );
  }
}

/// 🏦 BANK CARD
class _BankCard extends StatelessWidget {
  final FetchBanks bank;

  const _BankCard({required this.bank});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BankDetailPage(bank: bank),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                bank.bankName ?? "Bank",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  _info("Interest", "${bank.interestRate}%"),
                  const SizedBox(width: 12),
                  _info("Tenure", "${bank.tenureYears} yrs"),
                ],
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () =>
                      LoanApplyDialog.show(context, bank),
                  child: const Text("Apply Now"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _info(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
