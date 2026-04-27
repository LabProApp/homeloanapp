import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_colors.dart';
import '../models/legal_service_model.dart';

// ── Public entry-point (mirrors showBankDetailSheet pattern) ─────────────────

void showLegalServiceDetailSheet(BuildContext context, LegalService service) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: LegalServiceDetailPage(
            service: service, scrollController: controller),
      ),
    ),
  );
}

// ── Card ─────────────────────────────────────────────────────────────────────

class LegalServiceCard extends StatelessWidget {
  final LegalService service;

  const LegalServiceCard({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.08),
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => showLegalServiceDetailSheet(context, service),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header row ──────────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _Avatar(name: service.legalName),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.legalName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${service.city}, ${service.state}',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      color: AppColors.textMuted),
                ],
              ),

              // ── Service chips ────────────────────────────────────────
              if (service.services.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    ...service.services.take(3).map(_serviceChip),
                    if (service.services.length > 3)
                      _overflowChip(service.services.length - 3),
                  ],
                ),
              ],

              const SizedBox(height: 14),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // ── Action row ───────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          showLegalServiceDetailSheet(context, service),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        side: const BorderSide(color: AppColors.primary),
                        foregroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('View Details',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _call(service.phone1),
                      icon: const Icon(Icons.call_rounded, size: 16),
                      label: const Text('Call Now',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Detail Page ───────────────────────────────────────────────────────────────

class LegalServiceDetailPage extends StatelessWidget {
  final LegalService service;
  final ScrollController? scrollController;

  const LegalServiceDetailPage(
      {super.key, required this.service, this.scrollController});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.listingbackground,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _call(service.phone1),
                  icon: const Icon(Icons.call_rounded, size: 18),
                  label: const Text('Call',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: AppColors.primary),
                    foregroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _whatsApp(service.phone1),
                  icon: const Icon(Icons.chat_rounded, size: 18),
                  label: const Text('WhatsApp',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: const Color(0xFF25D366),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: CustomScrollView(
        controller: scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── AppBar ─────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 190,
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              titlePadding: const EdgeInsets.only(bottom: 16),
              title: Text(
                service.legalName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [Shadow(offset: Offset(0, 1), blurRadius: 3)],
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.warning]),
                ),
                child: Center(
                  child: Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.4), width: 1.5),
                    ),
                    child: Center(
                      child: Text(
                        service.legalName[0].toUpperCase(),
                        style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Content ────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [

                  // Quick Info
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 64,
                            child: Row(
                              children: [
                                _stat(Icons.location_city_rounded,
                                    service.city, 'City'),
                                _vDivider(),
                                _stat(Icons.map_outlined, service.state,
                                    'State'),
                                if ((service.planPackage ?? '').isNotEmpty) ...[
                                  _vDivider(),
                                  _stat(Icons.workspace_premium_rounded,
                                      service.planPackage!, 'Plan'),
                                ],
                              ],
                            ),
                          ),
                          if ((service.contactName ?? '').isNotEmpty) ...[
                            const SizedBox(height: 12),
                            const Divider(height: 1),
                            const SizedBox(height: 12),
                            _detailRow(Icons.person_outline_rounded,
                                'Contact Person', service.contactName!),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Services Offered
                  _SectionCard(
                    icon: Icons.gavel_rounded,
                    title: 'Services Offered',
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              service.services.map(_serviceChipLarge).toList(),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Contact
                  _SectionCard(
                    icon: Icons.contacts_outlined,
                    title: 'Contact',
                    children: [
                      _TappableRow(
                        icon: Icons.phone_outlined,
                        label: 'Primary',
                        value: service.phone1,
                        onTap: () => _call(service.phone1),
                      ),
                      if ((service.phone2 ?? '').isNotEmpty)
                        _TappableRow(
                          icon: Icons.phone_outlined,
                          label: 'Secondary',
                          value: service.phone2!,
                          onTap: () => _call(service.phone2!),
                        ),
                      _TappableRow(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value: service.email,
                        onTap: () =>
                            launchUrl(Uri.parse('mailto:${service.email}')),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Address
                  _SectionCard(
                    icon: Icons.location_on_outlined,
                    title: 'Address',
                    children: [
                      _detailRowPad(
                          Icons.home_outlined, '', service.address),
                      _detailRowPad(
                          Icons.location_city_outlined,
                          '',
                          '${service.city}, ${service.state}, ${service.country}'),
                    ],
                  ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(IconData icon, String value, String label) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(height: 4),
          Text(value,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          Text(label,
              style:
                  const TextStyle(fontSize: 11, color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _vDivider() => Container(
        width: 1,
        height: 40,
        color: Colors.grey.shade200,
        margin: const EdgeInsets.symmetric(horizontal: 4),
      );

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 8),
        Text('$label: ',
            style:
                const TextStyle(fontSize: 13, color: AppColors.textMuted)),
        Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textPrimary))),
      ],
    );
  }
}

// ── Helpers (shared between card and detail) ─────────────────────────────────

Future<void> _call(String phone) async {
  final clean = phone.replaceAll(RegExp(r'[^0-9]'), '');
  if (clean.isEmpty) return;
  await launchUrl(Uri.parse('tel:$clean'));
}

Future<void> _whatsApp(String phone) async {
  final clean = phone.replaceAll(RegExp(r'[^0-9]'), '');
  if (clean.isEmpty) return;
  final num = clean.startsWith('91') ? clean : '91$clean';
  const msg = 'I would like to inquire about legal services';
  await launchUrl(
    Uri.parse('https://wa.me/$num?text=${Uri.encodeComponent(msg)}'),
    mode: LaunchMode.externalApplication,
  );
}

Widget _serviceChip(String s) {
  final label = s
      .split('_')
      .map((w) => w.isEmpty
          ? ''
          : w[0].toUpperCase() + w.substring(1).toLowerCase())
      .join(' ');
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: AppColors.primary.withOpacity(0.08),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.primary.withOpacity(0.25)),
    ),
    child: Text(label,
        style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.primary)),
  );
}

Widget _serviceChipLarge(String s) {
  final label = s
      .split('_')
      .map((w) => w.isEmpty
          ? ''
          : w[0].toUpperCase() + w.substring(1).toLowerCase())
      .join(' ');
  return Chip(
    label: Text(label,
        style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.primary)),
    backgroundColor: AppColors.primary.withOpacity(0.08),
    side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    visualDensity: VisualDensity.compact,
  );
}

Widget _overflowChip(int count) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: Text('+$count more',
        style:
            const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
  );
}

Widget _detailRowPad(IconData icon, String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 10),
        if (label.isNotEmpty) ...[
          SizedBox(
              width: 110,
              child: Text(label,
                  style: const TextStyle(
                      color: AppColors.textMuted, fontSize: 13))),
        ],
        Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textPrimary))),
      ],
    ),
  );
}

// ── Reusable sub-widgets ──────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String name;
  const _Avatar({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Center(
        child: Text(
          name[0].toUpperCase(),
          style: const TextStyle(
              color: AppColors.primary,
              fontSize: 20,
              fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final IconData? icon;

  const _SectionCard(
      {required this.title, required this.children, this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon ?? Icons.info_outline_rounded,
                    color: AppColors.primary),
                const SizedBox(width: 8),
                Text(title,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
              ],
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }
}

class _TappableRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _TappableRow(
      {required this.icon,
      required this.label,
      required this.value,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 10),
            SizedBox(
                width: 80,
                child: Text(label,
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 13))),
            Expanded(
              child: Text(value,
                  style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.primary,
                      decoration: TextDecoration.underline),
                  overflow: TextOverflow.ellipsis),
            ),
            const Icon(Icons.open_in_new, size: 14, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
