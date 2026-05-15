import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/cache_manager.dart';
import 'package:readmore/readmore.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../commons/common_util.dart';
import '../commons/common_widget.dart';
import '../models/client_lead_model.dart';
import '../models/property_model.dart';
import '../models/user_model.dart';
import '../services/leads_service.dart';
import '../services/property_api_service.dart';
import '../services/property_share_service.dart';
import '../services/user_service.dart';
import '../theme/app_colors.dart';
import '../utility/amenity_icon.dart';

class RentalPropertyDetailScreen extends StatefulWidget {
  final PropertyModel property;
  final int userId;

  const RentalPropertyDetailScreen({
    super.key,
    required this.property,
    required this.userId,
  });

  @override
  State<RentalPropertyDetailScreen> createState() =>
      _RentalPropertyDetailScreenState();
}

class _RentalPropertyDetailScreenState
    extends State<RentalPropertyDetailScreen> {
  static final _fmt = NumberFormat('#,##,###');

  int _currentIndex = 0;
  bool _isFavourite = false;
  bool _sendingLead = false;

  UserModel? _owner;
  bool _loadingOwner = false;

  @override
  void initState() {
    super.initState();
    _loadOwner();
  }

  Future<void> _loadOwner() async {
    final ownerId = widget.property.postedByUser;
    if (ownerId == null || ownerId == 0) return;
    setState(() => _loadingOwner = true);
    try {
      final user = await UserApiService.getProfile(ownerId);
      if (!mounted) return;
      setState(() => _owner = user);
    } catch (_) {
      // Silently fall back to property fields.
    } finally {
      if (mounted) setState(() => _loadingOwner = false);
    }
  }

  bool get _isOwner =>
      widget.property.postedByUser != null &&
      widget.property.postedByUser == widget.userId;

  bool get _isResidential =>
      widget.property.category?.toUpperCase() == 'RESIDENTIAL';

  List<String> get _images {
    if (widget.property.documentList != null &&
        widget.property.documentList!.isNotEmpty) {
      final urls = widget.property.documentList!
          .map((e) => e.docUrl ?? '')
          .where((u) => u.isNotEmpty)
          .toList();
      if (urls.isNotEmpty) return urls;
    }
    return [];
  }

  Widget _typePlaceholder() {
    final type = widget.property.type?.toUpperCase() ?? '';
    final category = widget.property.category?.toUpperCase() ?? '';
    final isCommercial = ['SHOP', 'OFFICE', 'SHOWROOM', 'CO WORKING'].contains(type) || category == 'COMMERCIAL';
    final isPlot = type == 'PLOT';

    final IconData icon;
    final Color bg;
    final Color iconColor;
    final String label;

    if (isCommercial) {
      icon = Icons.business_outlined;
      bg = const Color(0xFFE0F7FA);
      iconColor = const Color(0xFF00695C);
      label = widget.property.type ?? 'Commercial';
    } else if (isPlot) {
      icon = Icons.landscape_outlined;
      bg = const Color(0xFFFBE9E7);
      iconColor = const Color(0xFF6D4C41);
      label = 'Plot';
    } else {
      icon = Icons.apartment_outlined;
      bg = const Color(0xFFE8EAF6);
      iconColor = const Color(0xFF283593);
      label = widget.property.type ?? 'Rental';
    }

    return Container(
      color: bg,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: iconColor),
          const SizedBox(height: 8),
          Text(label,
              style: TextStyle(color: iconColor.withOpacity(0.7), fontSize: 13)),
        ],
      ),
    );
  }

  Widget _imgPlaceholder() => Container(
        color: AppColors.surfaceSubtle,
        child: const Center(
          child: Icon(Icons.image_outlined, size: 40, color: AppColors.border),
        ),
      );

  List<String> get _amenities {
    if (widget.property.amenities != null &&
        widget.property.amenities!.isNotEmpty) {
      return widget.property.amenities!
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    if (widget.property.amenitiesAsList != null &&
        widget.property.amenitiesAsList!.isNotEmpty) {
      return widget.property.amenitiesAsList!.map((e) => e.toString()).toList();
    }
    return [];
  }

  String get _rentText {
    if (widget.property.monthlyRent != null) {
      return '₹ ${_fmt.format(widget.property.monthlyRent)} / month';
    }
    if (widget.property.price != null) {
      return '₹ ${_fmt.format(widget.property.price)} / month';
    }
    return '-';
  }

  // ── Actions ──────────────────────────────────────────────────────────────────

  Future<void> _toggleFavorite() async {
    if (widget.property.id == null) return;
    await PropertyApiService.toggleFavourite(
      userId: widget.userId,
      propertyId: widget.property.id!,
    );
    setState(() => _isFavourite = !_isFavourite);
  }

  Future<void> _createLead() async {
    if (widget.property.id == null) return;
    setState(() => _sendingLead = true);
    final prefs = await SharedPreferences.getInstance();
    final lead = ClientLeadModel(
      brokerId: widget.property.postedByUser,
      userId: widget.userId,
      propertyId: widget.property.id!,
      leadType: 'PROPERTY_INQUIRY',
      clientName: prefs.getString('userName') ?? '',
      email: prefs.getString('userEmail') ?? '',
      mobile: prefs.getString('userMobile') ?? '',
      propertyTitle: widget.property.title,
      propertyCity: widget.property.city,
      propertyPrice: widget.property.monthlyRent ?? widget.property.price,
      preferredPropertyType: widget.property.type,
      preferredBudget: widget.property.monthlyRent ?? widget.property.price,
      inquiryDate: DateTime.now().toIso8601String(),
      status: 'NEW',
      contacted: false,
      leadSource: 'Rental Property Interest',
      remark: 'User interested in rental: ${widget.property.title ?? ""}',
    );
    try {
      final res = await LeadApiService.createLead(lead);
      if (!mounted) return;
      final alreadySent = res['inquiryAlreadySent'] == true;
      final serverMsg = (res['responseMessage'] as String?)?.trim();
      _showSnack(
        alreadySent
            ? (serverMsg?.isNotEmpty == true
                ? serverMsg!
                : 'Inquiry already sent')
            : (serverMsg?.isNotEmpty == true
                ? serverMsg!
                : 'Owner will contact you soon'),
        backgroundColor: alreadySent ? null : AppColors.success,
      );
    } catch (e) {
      if (!mounted) return;
      _showSnack('Could not send interest. Please try again.',
          backgroundColor: AppColors.error);
    } finally {
      if (mounted) setState(() => _sendingLead = false);
    }
  }

  void _showSnack(String text, {Color? backgroundColor}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(text),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
  }

  void _shareProperty() {
    Share.share(
        '${widget.property.title}\nRent: $_rentText\n${widget.property.address}');
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.listingbackground,
      bottomNavigationBar: _bottomBar(),
      body: CustomScrollView(
        slivers: [
          // ── Image header ─────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.transparent,
            iconTheme: const IconThemeData(color: AppColors.white),
            actions: const [],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  _images.isEmpty
                      ? _typePlaceholder()
                      : PageView.builder(
                          itemCount: _images.length,
                          onPageChanged: (i) => setState(() => _currentIndex = i),
                          itemBuilder: (_, i) => CachedNetworkImage(
                            cacheManager: AppCacheManager.instance,
                            imageUrl: _images[i],
                            fit: BoxFit.cover,
                            fadeInDuration: const Duration(milliseconds: 250),
                            placeholder: (_, __) => _imgPlaceholder(),
                            errorWidget: (_, __, ___) => _typePlaceholder(),
                          ),
                        ),

                  // Gradient overlay
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0x66000000),
                          Colors.transparent,
                          Color(0xB3000000),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),

                  // Rent price
                  Positioned(
                    bottom: 40,
                    left: 16,
                    child: Text(
                      _rentText,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Page indicator
                  Positioned(
                    bottom: 12,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _images.length,
                        (i) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentIndex == i ? 10 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: _currentIndex == i
                                ? AppColors.white
                                : AppColors.imageCaptionText,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Action icons
                  Positioned(
                    top: MediaQuery.of(context).padding.top + kToolbarHeight + 8,
                    right: 12,
                    child: Column(
                      children: [
                        _iconCircle(
                          _isFavourite ? Icons.favorite : Icons.favorite_border,
                          _toggleFavorite,
                        ),
                        const SizedBox(height: 6),
                        _iconCircle(Icons.share, _shareProperty),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Content ──────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    widget.property.title ?? '-',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          [
                            widget.property.address,
                            widget.property.city,
                          ]
                              .where((s) => s != null && s.isNotEmpty)
                              .join(', '),
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  if (widget.property.landmark != null &&
                      widget.property.landmark!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.near_me_outlined,
                            size: 13, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Text(
                          'Near ${widget.property.landmark}',
                          style: const TextStyle(
                              color: AppColors.textMuted, fontSize: 12),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Feature chips
                  _featureRow(),

                  const SizedBox(height: 20),

                  // Description
                  _sectionTitle('About Property'),
                  const SizedBox(height: 8),
                  ReadMoreText(
                    widget.property.description ??
                        'Property details will be updated soon.',
                    trimLines: 3,
                    trimMode: TrimMode.Line,
                    trimCollapsedText: ' Read More',
                    trimExpandedText: ' Read Less',
                    moreStyle: const TextStyle(color: AppColors.primary),
                    lessStyle: const TextStyle(color: AppColors.primary),
                  ),

                  const SizedBox(height: 24),

                  // Rent Details
                  _sectionTitle('Rental Details'),
                  _card([
                    _DetailRow('Monthly Rent', _rentText),
                    if (widget.property.securityDeposit != null)
                      _DetailRow('Security Deposit',
                          '₹ ${_fmt.format(widget.property.securityDeposit)}'),
                    if (widget.property.brokerage != null)
                      _DetailRow('Brokerage',
                          '₹ ${_fmt.format(widget.property.brokerage)}'),
                    if (widget.property.preferredTenants != null)
                      _DetailRow(
                          'Preferred Tenants', widget.property.preferredTenants!),
                    if (widget.property.leaseDuration != null)
                      _DetailRow('Lease Duration', widget.property.leaseDuration!),
                    if (widget.property.noticePeriod != null)
                      _DetailRow('Notice Period', widget.property.noticePeriod!),
                    if (widget.property.maintenanceIncluded != null)
                      _DetailRow('Maintenance',
                          widget.property.maintenanceIncluded! ? 'Included' : 'Not Included'),
                    if (widget.property.negotiable == true)
                      const _DetailRow('Negotiable', 'Yes'),
                  ]),

                  const SizedBox(height: 20),

                  // Tenant Preferences
                  if (widget.property.petsAllowed != null ||
                      widget.property.nonVegAllowed != null) ...[
                    _sectionTitle('Tenant Preferences'),
                    _card([
                      if (widget.property.petsAllowed != null)
                        _DetailRow('Pets Allowed',
                            widget.property.petsAllowed! ? 'Yes' : 'No'),
                      if (widget.property.nonVegAllowed != null)
                        _DetailRow('Non-Veg Allowed',
                            widget.property.nonVegAllowed! ? 'Yes' : 'No'),
                    ]),
                    const SizedBox(height: 20),
                  ],

                  // Property Details
                  _sectionTitle('Property Details'),
                  _card([
                    if (widget.property.type != null)
                      _DetailRow('Type', widget.property.type!),
                    if (widget.property.category != null)
                      _DetailRow('Category', widget.property.category!),
                    if (_isResidential && widget.property.bedrooms != null)
                      _DetailRow('Bedrooms', widget.property.bedrooms.toString()),
                    if (_isResidential && widget.property.bathrooms != null)
                      _DetailRow('Bathrooms', widget.property.bathrooms.toString()),
                    if (widget.property.furnishing != null)
                      _DetailRow('Furnishing', widget.property.furnishing!),
                    if (widget.property.facing != null)
                      _DetailRow('Facing', widget.property.facing!),
                    if (widget.property.propertyAge != null)
                      _DetailRow('Property Age', widget.property.propertyAge!),
                    if (widget.property.parkingCount != null)
                      _DetailRow('Parking', widget.property.parkingCount!),
                    if (widget.property.constructionStatus != null)
                      _DetailRow('Construction', widget.property.constructionStatus!),
                  ]),

                  const SizedBox(height: 20),

                  // Area & Floor
                  _sectionTitle('Area & Floor'),
                  _card([
                    if (widget.property.superArea != null)
                      _DetailRow('Super Area',
                          '${widget.property.superArea!.toStringAsFixed(0)} sq.ft'),
                    if (widget.property.carpetArea != null)
                      _DetailRow('Carpet Area',
                          '${widget.property.carpetArea!.toStringAsFixed(0)} sq.ft'),
                    if (widget.property.floorNumber != null ||
                        widget.property.totalFloors != null)
                      _DetailRow(
                        'Floor',
                        '${widget.property.floorNumber ?? '-'} of ${widget.property.totalFloors ?? '-'}',
                      ),
                  ]),

                  const SizedBox(height: 20),

                  // Location
                  _sectionTitle('Location'),
                  _card([
                    if (widget.property.address != null &&
                        widget.property.address!.isNotEmpty)
                      _DetailRow('Address', widget.property.address!),
                    if (widget.property.city != null &&
                        widget.property.city!.isNotEmpty)
                      _DetailRow('City', widget.property.city!),
                    if (widget.property.state != null &&
                        widget.property.state!.isNotEmpty)
                      _DetailRow('State', widget.property.state!),
                    if (widget.property.landmark != null &&
                        widget.property.landmark!.isNotEmpty)
                      _DetailRow('Landmark', widget.property.landmark!),
                  ]),

                  // Amenities
                  if (_amenities.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _sectionTitle('Amenities'),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _amenities.map((a) {
                        final data = AmenityIcon.getAmenity(a);
                        return Container(
                          width: 90,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                            boxShadow: const [
                              BoxShadow(
                                  color: Color(0x14000000), blurRadius: 4),
                            ],
                          ),
                          child: Column(
                            children: [
                              Icon(data.icon, color: AppColors.primary),
                              const SizedBox(height: 6),
                              Text(
                                data.label,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Owner Details
                  _sectionTitle('Owner Details'),
                  _ownerCard(),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Section helpers ───────────────────────────────────────────────────────────

  Widget _featureRow() {
    final area = widget.property.superArea ?? widget.property.carpetArea;
    final features = <Widget>[];
    if (_isResidential) {
      if (widget.property.bedrooms != null) {
        features.add(_Feature(Icons.bed_rounded, '${widget.property.bedrooms} Beds'));
      }
      if (widget.property.bathrooms != null) {
        features.add(_Feature(Icons.bathtub_outlined, '${widget.property.bathrooms} Baths'));
      }
    }
    if (area != null) {
      features.add(_Feature(Icons.square_foot, '${area.toStringAsFixed(0)} sqft'));
    }
    if (features.isEmpty) return const SizedBox.shrink();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: features,
    );
  }

  Widget _sectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
        ),
      ],
    );
  }

  Widget _ownerCard() {
    final ownerName = (_owner?.name.isNotEmpty ?? false)
        ? _owner!.name
        : (widget.property.postedBy ?? '');
    final ownerEmail = _owner?.email ?? '';
    final ownerMobile = (_owner?.mobile.isNotEmpty ?? false)
        ? _owner!.mobile
        : widget.property.contactNumber;

    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 4),
        ],
      ),
      child: Column(
        children: [
          if (_loadingOwner && _owner == null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          if (ownerName.isNotEmpty) _DetailRow('Name', ownerName),
          if (ownerEmail.isNotEmpty) _DetailRow('Email', ownerEmail),
          if (ownerMobile.isNotEmpty) _DetailRow('Phone', ownerMobile),
          if (widget.property.verified != null)
            _DetailRow(
                'Verified', widget.property.verified! ? 'Yes' : 'No'),
          if (widget.property.postDate != null)
            _DetailRow(
              'Posted On',
              AppUtils.formatDate(widget.property.postDate) ??
                  widget.property.postDate!,
            ),
        ],
      ),
    );
  }

  Widget _card(List<Widget> children) {
    if (children.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 4),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _iconCircle(IconData icon, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 18,
        backgroundColor: AppColors.imageOverlay,
        child: _sendingLead && icon == Icons.star_border_rounded
            ? const SizedBox(
                height: 12,
                width: 12,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.white),
              )
            : Icon(icon, size: 18, color: AppColors.white),
      ),
    );
  }

  // ── Bottom bar ────────────────────────────────────────────────────────────────

  String get _ownerPhone {
    final m = _owner?.mobile ?? '';
    return m.isNotEmpty ? m : widget.property.contactNumber;
  }

  void _callOwner() {
    final phone = _ownerPhone;
    if (phone.isEmpty) return;
    AppUtils.call(phone);
  }

  Future<void> _openWhatsApp() async {
    final phone = _ownerPhone;
    if (phone.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final msg = PropertyShareService.inquiryWhatsAppText(
      widget.property,
      buyerName: prefs.getString('userName'),
      buyerPhone: prefs.getString('userMobile'),
      buyerEmail: prefs.getString('userEmail'),
    );
    try {
      await AppUtils.whatsapp(phone, msg);
    } catch (e) {
      if (!mounted) return;
      _showSnack(e.toString(), backgroundColor: AppColors.error);
    }
  }

  Widget _bottomBar() {
    final hasPhone = _ownerPhone.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            color: Colors.black.withOpacity(0.06),
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            _smallIconBtn(
                Icons.call, AppColors.primary, hasPhone ? _callOwner : null),
            const SizedBox(width: 8),
            _smallIconBtn(Icons.chat_rounded, AppColors.whatsAppGreen,
                hasPhone ? _openWhatsApp : null),
            const Spacer(),
            _interestedBtn(),
          ],
        ),
      ),
    );
  }

  Widget _smallIconBtn(IconData icon, Color color, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color.withOpacity(onTap == null ? 0.04 : 0.10),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: color.withOpacity(onTap == null ? 0.10 : 0.25)),
        ),
        child: Icon(icon,
            size: 22,
            color: onTap == null ? color.withOpacity(0.4) : color),
      ),
    );
  }

  Widget _interestedBtn() {
    return InkWell(
      onTap: (_isOwner || _sendingLead) ? null : _createLead,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: _isOwner ? AppColors.disabled : AppColors.primary,
          borderRadius: BorderRadius.circular(22),
        ),
        child: _sendingLead
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : const Text(
                'Interested',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}

// ── Reusable sub-widgets ──────────────────────────────────────────────────────

class _Feature extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Feature(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
        const SizedBox(height: 6),
        Text(label,
            style: const TextStyle(
                fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String title;
  final String value;
  const _DetailRow(this.title, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(title,
                style: const TextStyle(
                    color: AppColors.textMuted, fontSize: 13)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
