import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_colors.dart';
import '../models/legal_service_model.dart';
import '../services/legal_service_api.dart';
import '../screens/legal_inquiry_dialog.dart';
import '../cards/legal_service_card.dart';
import '../commons/common_widget.dart';

class LegalServicePage extends StatefulWidget {

  final int? userId;

  const LegalServicePage({
    super.key,
    this.userId,
  });

  @override
  State<LegalServicePage> createState() => _LegalServicePageState();
}

class _LegalServicePageState extends State<LegalServicePage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  final List<LegalService> _providers = [];
  bool _isLoading = false;
  bool _isLastPage = false;
  int _page = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchProviders();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200 &&
          !_isLoading &&
          !_isLastPage) {
        _fetchProviders();
      }
    });
  }

  Future<void> _fetchProviders() async {
    setState(() => _isLoading = true);

    try {
      final response = await LegalServiceApi.fetchProviders(page: _page);
      setState(() {
        _page++;
        _isLastPage = response.last;
        _providers.addAll(response.content);
        _error = null;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshProviders() async {
    setState(() {
      _providers.clear();
      _page = 0;
      _isLastPage = false;
      _error = null;
    });
    await _fetchProviders();
  }

  List<LegalService> get _filteredProviders {
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) return _providers;

    return _providers.where((p) {
      return p.legalName.toLowerCase().contains(q) ||
          p.city.toLowerCase().contains(q) ||
          p.services.any((s) => s.toLowerCase().contains(q));
    }).toList();
  }

  Future<void> _call(String phone) async {
    final cleanedPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanedPhone.isEmpty) return;

    final uri = Uri.parse("tel:$cleanedPhone");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _whatsApp(String phone) async {
    final cleanedPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanedPhone.isEmpty) return;

    final whatsappNumber =
    cleanedPhone.startsWith('91') ? cleanedPhone : '91$cleanedPhone';

    final message = "I would like to inquire about legal services";
    final uri = Uri.parse(
      "https://wa.me/$whatsappNumber?text=${Uri.encodeComponent(message)}",
    );

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Widget _buildList() {
    if (_isLoading && _providers.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _providers.isEmpty) {
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
                  "Couldn't load providers",
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
                  onPressed: _refreshProviders,
                ),
              ],
            ),
          ),
        ],
      );
    }

    if (_filteredProviders.isEmpty && !_isLoading) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.2),
          const Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.gavel_outlined, size: 72, color: AppColors.textMuted),
                SizedBox(height: 16),
                Text(
                  "No providers found",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                SizedBox(height: 8),
                Text(
                  "Try searching by a different name, city, or service type.",
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
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: _filteredProviders.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _filteredProviders.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final p = _filteredProviders[index];
        return LegalServiceCard(
          service: p,
          onCall: () => _call(p.phone1),
          onWhatsApp: () => _whatsApp(p.phone1),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.listingbackground,
      appBar: AppBar(
        title: const Text("Legal & Documentation"),

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
              onPressed: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
                ),
                builder: (_) => const InquiryDialog(),
              ),
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: AppSearchField(
              controller: _searchController,
              hintText: "Search by name, city or service",
              onChanged: (_) => setState(() {}),
            ),
          ),

          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshProviders,
              child: _buildList(),
            ),
          ),
        ],
      ),
    );
  }
}
