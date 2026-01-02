import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:property/theme/app_colors.dart';
import 'package:property/models/legalservice_model.dart';
import 'package:property/services/legal_service_api.dart';
import 'package:property/screens/legalInquiry_dialog.dart';

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
  const LegalServicePage({super.key});

  @override
  State<LegalServicePage> createState() => _LegalServicePageState();
}

class _LegalServicePageState extends State<LegalServicePage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  List<LegalService> _providers = [];
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
      final response =
      await LegalServiceApi.fetchProviders(page: _page);

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

    if (cleanedPhone.isEmpty) {
      debugPrint("Invalid phone number");
      return;
    }

    final uri = Uri.parse("tel:$cleanedPhone");

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      debugPrint("Cannot make a call on this device");
    }
  }


  Future<void> _whatsApp(String phone) async {
    // Remove spaces, +, -, etc.
    final cleanedPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');

    if (cleanedPhone.isEmpty) {
      debugPrint("Invalid phone number");
      return;
    }

    // India country code handling
    final whatsappNumber =
    cleanedPhone.startsWith('91') ? cleanedPhone : '91$cleanedPhone';

    final uri = Uri.parse("https://wa.me/$whatsappNumber");

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      debugPrint("WhatsApp not installed or cannot launch");
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
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
                    BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (_) => const InquiryDialog(),
                );
              },
              icon: const Icon(Icons.support_agent,
                  color: AppColors.primary),
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
          /// 🔍 Search
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: "Search by name, city or service",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          /// 📃 Fast + Bouncy List
          Expanded(
            child: ScrollConfiguration(
              behavior: FastScrollBehavior(),
              child: ListView.builder(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
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

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: AppColors.primary,
                                child: Text(
                                  p.legalName[0].toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      p.legalName,
                                      style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      "${p.city}, ${p.state}",
                                      style:
                                      const TextStyle(fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: p.services
                                .map((s) => Chip(
                              label: Text(
                                s,
                                style: const TextStyle(
                                    fontSize: 12),
                              ),
                            ))
                                .toList(),
                          ),

                          const Divider(),

                          Row(
                            children: [
                              Expanded(
                                child: _ActionButton(
                                  icon: Icons.call,
                                  label: "Call",
                                  color: AppColors.success,
                                  onTap: () => _call(p.phone1),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _ActionButton(
                                  icon: Icons.message,
                                  label: "WhatsApp",
                                  color: AppColors.primary,
                                  onTap: () => _whatsApp(p.phone1),
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
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------------- ACTION BUTTON ----------------

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.4),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
