import 'package:flutter/material.dart';
import 'package:property/theme/app_colors.dart';

/// ---------------- MODEL ----------------
class LegalServiceProvider {
  final String name;
  final String city;
  final String image;
  final List<String> services;

  LegalServiceProvider({
    required this.name,
    required this.city,
    required this.image,
    required this.services,
  });
}

/// ---------------- DEMO DATA ----------------
final List<LegalServiceProvider> serviceProviders = [
  LegalServiceProvider(
    name: 'Sharma Legal Services',
    city: 'Mohali',
    image: 'https://cdn-icons-png.flaticon.com/512/1995/1995574.png',
    services: [
      'Sale Deed',
      'Agreement to Sell',
      'Legal Verification',
      'Property Registration',
    ],
  ),
  LegalServiceProvider(
    name: 'SK Documents',
    city: 'Sector 10, Panchkula',
    image: 'https://cdn-icons-png.flaticon.com/512/3135/3135715.png',
    services: [
      'Home Loan Docs',
      'Notary',
      'Stamp Duty',
      'Rent Agreement',
      'EC & Title Check',
    ],
  ),
  LegalServiceProvider(
    name: 'Agarwal Documentation',
    city: 'Chandigarh',
    image: 'https://cdn-icons-png.flaticon.com/512/3135/3135715.png',
    services: [
      'Home Loan Docs',
      'Notary',
      'Stamp Duty',
      'EC & Title Check',
    ],
  ),
];

/// ---------------- SCREEN ----------------
class LegalServicePage extends StatelessWidget {
  const LegalServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: serviceProviders.length,
        itemBuilder: (context, index) {
          final provider = serviceProviders[index];

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
                          backgroundColor: AppColors.primary,
                          backgroundImage: NetworkImage(provider.image),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                provider.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                provider.city,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    /// 🔹 SERVICES OFFERED
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: provider.services.map((service) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            service,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 18),
                    const Divider(),
                    const SizedBox(height: 10),

                    /// 🔹 CONTACT BUTTONS
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
        height: 48,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: color),
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
