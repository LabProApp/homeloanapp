import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/legal_service_model.dart';
import '../services/legal_service_api.dart';
import '../screens/legal_inquiry_dialog.dart';
import '../screens/rent_agreement_screen.dart';
import '../screens/sale_agreement_screen.dart';
import '../screens/due_diligence_screen.dart';
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
  bool _fabExpanded = false;

  final List<LegalService> _providers = [];
  bool _isLoading = false;
  bool _isLastPage = false;
  int _page = 0;
  String? _error;
  String? _selectedCategory;

  static const Map<String, String> _categoryLabels = {
    'DOCUMENT_SERVICES': 'Document Services',
    'PROPERTY_REGISTRATION': 'Property Registration',
    'RENT_AGREEMENT': 'Rent Agreement',
  };

  @override
  void initState() {
    super.initState();
    _fetchProviders();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        !_isLastPage) {
      _fetchProviders();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchProviders() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final response = await LegalServiceApi.fetchProviders(page: _page);
      if (!mounted) return;
      setState(() {
        _page++;
        _isLastPage = response.last;
        _providers.addAll(response.content);
        _error = null;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
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
    var list = _providers;

    if (_selectedCategory != null) {
      list = list.where((p) => p.services.contains(_selectedCategory)).toList();
    }

    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) return list;

    return list.where((p) {
      return p.legalName.toLowerCase().contains(q) ||
          p.city.toLowerCase().contains(q) ||
          p.services.any((s) => s.toLowerCase().contains(q));
    }).toList();
  }

  Widget _miniActionButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
          ),
          child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
        ),
        const SizedBox(width: 8),
        FloatingActionButton.small(
          heroTag: label,
          onPressed: onTap,
          backgroundColor: color,
          child: Icon(icon, size: 20),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String? value, String label) {
    final selected = _selectedCategory == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => setState(() => _selectedCategory = value),
        backgroundColor: Colors.white,
        selectedColor: AppColors.primary.withOpacity(0.15),
        checkmarkColor: AppColors.primary,
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          color: selected ? AppColors.primary : AppColors.textSecondary,
        ),
        side: BorderSide(
          color: selected ? AppColors.primary : AppColors.border,
        ),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 4),
      ),
    );
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
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      cacheExtent: 800,
      addAutomaticKeepAlives: false,
      padding: const EdgeInsets.all(16),
      itemCount: _filteredProviders.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _filteredProviders.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return LegalServiceCard(service: _filteredProviders[index]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.listingbackground,
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (_fabExpanded) ...[
            _miniActionButton(
              Icons.checklist_outlined, 'Due Diligence', const Color(0xFF6A1B9A),
              () { setState(() => _fabExpanded = false); Navigator.push(context, MaterialPageRoute(builder: (_) => const DueDiligenceScreen())); },
            ),
            const SizedBox(height: 8),
            _miniActionButton(
              Icons.handshake_outlined, 'Sale Agreement', const Color(0xFF2E7D32),
              () { setState(() => _fabExpanded = false); Navigator.push(context, MaterialPageRoute(builder: (_) => const SaleAgreementScreen())); },
            ),
            const SizedBox(height: 8),
            _miniActionButton(
              Icons.description_outlined, 'Rent Agreement', AppColors.primary,
              () { setState(() => _fabExpanded = false); Navigator.push(context, MaterialPageRoute(builder: (_) => const RentAgreementScreen())); },
            ),
            const SizedBox(height: 8),
          ],
          FloatingActionButton(
            onPressed: () => setState(() => _fabExpanded = !_fabExpanded),
            backgroundColor: AppColors.primary,
            child: AnimatedRotation(
              turns: _fabExpanded ? 0.125 : 0,
              duration: const Duration(milliseconds: 200),
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
      appBar: GradientAppBar(
        title: 'Legal & Documentation',
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: OutlinedButton.icon(
              onPressed: () => showModalBottomSheet(
                context: context,
                useSafeArea: true,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const InquiryDialog(),
              ),
              icon: const Icon(Icons.support_agent_rounded, size: 18),
              label: const Text('Inquiry'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.white,
                side: BorderSide(color: AppColors.white.withOpacity(0.7)),
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

          // ── Category filter chips ──────────────────────────────────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
            child: Row(
              children: [
                _buildFilterChip(null, 'All'),
                ..._categoryLabels.entries
                    .map((e) => _buildFilterChip(e.key, e.value)),
              ],
            ),
          ),

          // ── Result count ──────────────────────────────────────────
          if (!_isLoading || _providers.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${_filteredProviders.length} provider${_filteredProviders.length == 1 ? '' : 's'} found',
                  style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500),
                ),
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
