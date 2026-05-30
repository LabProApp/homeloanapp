import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_colors.dart';
import '../models/legal_service_model.dart';
import '../screens/legal_inquiry_dialog.dart';

// ── Public entry-point ────────────────────────────────────────────────────────

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
      builder: (ctx, controller) => Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: LegalServiceDetailPage(
            service: service, scrollController: controller, sheetContext: ctx),
      ),
    ),
  );
}

// ── Card ──────────────────────────────────────────────────────────────────────

class LegalServiceCard extends StatelessWidget {
  final LegalService service;

  const LegalServiceCard({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.10),
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => showLegalServiceDetailSheet(context, service),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header row ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _Avatar(name: service.legalName),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.legalName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${service.city}, ${service.state}',
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.textSecondary),
                        ),
                        if ((service.contactName ?? '').isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: Row(
                              children: [
                                const Icon(Icons.person_outline_rounded,
                                    size: 12, color: AppColors.textMuted),
                                const SizedBox(width: 4),
                                Text(
                                  service.contactName!,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      color: AppColors.textMuted),
                ],
              ),
            ),

            // ── Service chips ──────────────────────────────────────────
            if (service.services.isNotEmpty) ...[
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Wrap(
                  spacing: 7,
                  runSpacing: 6,
                  children: [
                    ...service.services.take(4).map(_serviceChip),
                    if (service.services.length > 4)
                      _overflowChip(service.services.length - 4),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            // ── Translucent action strip ───────────────────────────────
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary.withOpacity(0.03),
                    AppColors.primary.withOpacity(0.08),
                  ],
                ),
                border: Border(
                  top: BorderSide(
                      color: AppColors.primary.withOpacity(0.12)),
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _whatsApp(service.phone1, context),
                      icon: const Icon(Icons.chat_rounded, size: 16),
                      label: const Text('WhatsApp',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: AppColors.whatsAppGreen),
                        foregroundColor: AppColors.whatsAppGreen,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.secondary],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () => _call(service.phone1),
                        icon: const Icon(Icons.call_rounded, size: 16),
                        label: const Text('Call Now',
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600)),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Detail Page ───────────────────────────────────────────────────────────────

class LegalServiceDetailPage extends StatelessWidget {
  final LegalService service;
  final ScrollController? scrollController;
  final BuildContext? sheetContext;

  const LegalServiceDetailPage({
    super.key,
    required this.service,
    this.scrollController,
    this.sheetContext,
  });

  void _openInquiry(BuildContext context) {
    final preservice =
        service.services.isNotEmpty ? service.services.first : null;
    showModalBottomSheet(
      context: sheetContext ?? context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => InquiryDialog(
        providerName: service.legalName,
        preselectedService: preservice,
      ),
    );
  }

  void _share() {
    final serviceList = service.services
        .map((s) => s
            .split('_')
            .map((w) => w.isEmpty
                ? ''
                : w[0].toUpperCase() + w.substring(1).toLowerCase())
            .join(' '))
        .join(', ');
    Share.share(
      '${service.legalName}\n'
      '📍 ${service.city}, ${service.state}\n'
      '📞 ${service.phone1}\n'
      '✉️ ${service.email}\n\n'
      'Services: $serviceList',
      subject: service.legalName,
    );
  }

  Future<void> _openMaps(BuildContext context) async {
    final q = Uri.encodeComponent(
        '${service.address}, ${service.city}, ${service.state}');
    final uri = Uri.parse('https://maps.google.com/maps?q=$q');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open Maps')));
      }
    }
  }

  Future<void> _copyToClipboard(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        duration: Duration(seconds: 1),
      ),
    );
  }

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
                      style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: AppColors.primary),
                    foregroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _whatsApp(service.phone1, context),
                  icon: const Icon(Icons.chat_rounded, size: 18),
                  label: const Text('WhatsApp',
                      style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: AppColors.whatsAppGreen,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _openInquiry(context),
                  icon: const Icon(Icons.send_rounded, size: 18),
                  label: const Text('Inquire',
                      style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
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
            actions: [
              IconButton(
                icon: const Icon(Icons.share_rounded, color: Colors.white),
                onPressed: _share,
                tooltip: 'Share',
              ),
            ],
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
              background: Stack(
                children: [
                  Container(
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
                  if (service.status == 'ACTIVE')
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.4)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified_rounded,
                                size: 12, color: Colors.white),
                            SizedBox(width: 4),
                            Text(
                              'Verified',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
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
                        child: service.services.isEmpty
                            ? const Text('No services listed',
                                style: TextStyle(
                                    fontSize: 13, color: AppColors.textMuted))
                            : Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: service.services
                                    .map(_serviceChipLarge)
                                    .toList(),
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
                        onCopy: () =>
                            _copyToClipboard(context, service.phone1),
                      ),
                      if ((service.phone2 ?? '').isNotEmpty)
                        _TappableRow(
                          icon: Icons.phone_outlined,
                          label: 'Secondary',
                          value: service.phone2!,
                          onTap: () => _call(service.phone2!),
                          onCopy: () =>
                              _copyToClipboard(context, service.phone2!),
                        ),
                      _TappableRow(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value: service.email,
                        onTap: () =>
                            launchUrl(Uri.parse('mailto:${service.email}')),
                        onCopy: () =>
                            _copyToClipboard(context, service.email),
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
                      InkWell(
                        onTap: () => _openMaps(context),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.directions_rounded,
                                  size: 16, color: AppColors.primary),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  '${service.city}, ${service.state}, ${service.country}',
                                  style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.primary),
                                ),
                              ),
                              const Icon(Icons.open_in_new,
                                  size: 14, color: AppColors.textMuted),
                            ],
                          ),
                        ),
                      ),
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
        color: AppColors.border,
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

// ── Helpers (shared between card and detail) ──────────────────────────────────

Future<void> _call(String phone) async {
  final clean = phone.replaceAll(RegExp(r'[^0-9]'), '');
  if (clean.isEmpty) return;
  await launchUrl(Uri.parse('tel:$clean'));
}

Future<void> _whatsApp(String phone, BuildContext context) async {
  final clean = phone.replaceAll(RegExp(r'[^0-9]'), '');
  if (clean.isEmpty) return;
  final num = clean.startsWith('91') ? clean : '91$clean';
  const msg = 'I would like to inquire about legal services';
  final uri = Uri.parse('https://wa.me/$num?text=${Uri.encodeComponent(msg)}');
  final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!launched && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('WhatsApp is not installed on this device')),
    );
  }
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
      color: AppColors.surfaceSubtle,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.border),
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
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Center(
        child: Text(
          name[0].toUpperCase(),
          style: const TextStyle(
              color: AppColors.primary,
              fontSize: 24,
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
  final VoidCallback? onCopy;

  const _TappableRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    this.onCopy,
  });

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
            if (onCopy != null)
              GestureDetector(
                onTap: onCopy,
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.copy_all_rounded,
                      size: 14, color: AppColors.textMuted),
                ),
              )
            else
              const Icon(Icons.open_in_new,
                  size: 14, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
