import 'package:flutter/material.dart';
import 'package:property/theme/app_colors.dart';
import 'package:property/models/legalservice_model.dart';

class LegalServicePage extends StatefulWidget {
  const LegalServicePage({super.key});

  @override
  State<LegalServicePage> createState() => _LegalServicePageState();
}

class _LegalServicePageState extends State<LegalServicePage> {
  final TextEditingController _searchController = TextEditingController();
  late List<LegalServiceProvider> _filteredProviders;

  @override
  void initState() {
    super.initState();
    _filteredProviders = serviceProviders;
  }

  void _filterProviders(String query) {
    setState(() {
      _filteredProviders = serviceProviders.where((provider) {
        final q = query.toLowerCase();
        return provider.name.toLowerCase().contains(q) ||
            provider.city.toLowerCase().contains(q) ||
            provider.services.any(
                  (service) => service.toLowerCase().contains(q),
            );
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Column(
        children: [
          /// 🔍 SEARCH BAR
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: _filterProviders,
              decoration: InputDecoration(
                hintText: "Search by name, city or service",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          /// 📃 LIST
          Expanded(
            child: _filteredProviders.isEmpty
                ? Center(
              child: Text(
                "No service providers found",
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredProviders.length,
              itemBuilder: (context, index) {
                final provider = _filteredProviders[index];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Card(
                    elevation: 4,
                    shadowColor: Colors.black12,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// 🔹 HEADER
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 32,
                                backgroundImage:
                                NetworkImage(provider.image),
                                backgroundColor:
                                AppColors.lightBrown,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      provider.name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color:
                                        AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      provider.city,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color:
                                        AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          /// 🔹 SERVICES
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children:
                            provider.services.map((service) {
                              return Container(
                                padding:
                                const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.primary
                                      .withOpacity(0.1),
                                  borderRadius:
                                  BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppColors.primary
                                        .withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  service,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight:
                                    FontWeight.w500,
                                    color:
                                    AppColors.textDark,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 18),
                          const Divider(),
                          const SizedBox(height: 10),

                          /// 🔹 CONTACT ACTIONS
                          Row(
                            children: [
                              Expanded(
                                child: _ActionButton(
                                  icon: Icons.call,
                                  label: 'Call',
                                  color: AppColors.success,
                                  onTap: () {
                                    // TODO: Call provider
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _ActionButton(
                                  icon: Icons.message,
                                  label: 'WhatsApp',
                                  color: AppColors.primary,
                                  onTap: () {
                                    // TODO: WhatsApp provider
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// 🔹 Action Button Widget
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
        height: 48,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
