import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_colors.dart';
import '../models/legal_service_model.dart';
import '../services/legal_service_api.dart';
import '../screens/legalInquiry_dialog.dart';
import '../cards/legal_service_card.dart';

/// 🔥 Faster + Bouncy Scroll Behavior
class FastScrollBehavior extends MaterialScrollBehavior {
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics(
      parent: AlwaysScrollableScrollPhysics(),
    );
  }
}

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
      });
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.listingbackground,
      appBar: AppBar(
        title: const Text("Legal & Documentation"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.vertical(top: Radius.circular(14)),
                  ),
                  builder: (_) => const InquiryDialog(),
                );
              },
              icon:
              const Icon(Icons.support_agent, color: AppColors.primary),
              label: const Text(
                "Inquiry",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              style: TextButton.styleFrom(backgroundColor: Colors.white),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          /// 🔍 SEARCH (HEIGHT = 40)
          Padding(
            padding: const EdgeInsets.all(8),
            child: SizedBox(
              height: 40,
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: "Search by name, city or service",
                  prefixIcon: const Icon(Icons.search, size: 20),
                  isDense: true,
                  contentPadding:
                  const EdgeInsets.symmetric(vertical: 4),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),

          /// 📜 LIST
          Expanded(
            child: ScrollConfiguration(
              behavior: FastScrollBehavior(),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount:
                _filteredProviders.length + (_isLoading ? 1 : 0),
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}
