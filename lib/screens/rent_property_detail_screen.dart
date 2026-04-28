import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:readmore/readmore.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../commons/common_util.dart';
import '../commons/common_widget.dart';
import '../models/client_lead_model.dart';
import '../models/property_model.dart';
import '../services/leads_service.dart';
import '../services/property_api_service.dart';
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
    return [
      'assets/images/house1.jpg',
      'assets/images/house2.jpg',
      'assets/images/house3.jpg',
    ];
  }

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
      await LeadApiService.createLead(lead);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: const Text('Owner will contact you soon'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: const Text('You already contacted for this property'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
    } finally {
      if (mounted) setState(() => _sendingLead = false);
    }
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
                  PageView.builder(
                    itemCount: _images.length,
                    onPageChanged: (i) => setState(() => _currentIndex = i),
                    itemBuilder: (_, i) {
                      final img = _images[i];
                      return img.startsWith('assets/')
                          ? Image.asset(img, fit: BoxFit.cover)
                          : Image.network(
                              img,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Image.asset(
                                  'assets/images/house1.jpg',
                                  fit: BoxFit.cover),
                            );
                    },
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
                        const SizedBox(height: 6),
                        _iconCircle(Icons.call,
                            () => AppUtils.call(widget.property.contactNumber)),
                        if (!_isOwner) ...[
                          const SizedBox(height: 6),
                          _iconCircle(
                            Icons.star_border_rounded,
                            _sendingLead ? null : _createLead,
                          ),
                        ],
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
                  _card([
                    if (widget.property.postedBy != null &&
                        widget.property.postedBy!.isNotEmpty)
                      _DetailRow('Posted By', widget.property.postedBy!),
                    if (widget.property.contactNumber.isNotEmpty)
                      _DetailRow('Contact', widget.property.contactNumber),
                    if (widget.property.verified != null)
                      _DetailRow(
                          'Verified', widget.property.verified! ? 'Yes' : 'No'),
                    if (widget.property.postDate != null)
                      _DetailRow(
                        'Posted On',
                        AppUtils.formatDate(widget.property.postDate) ??
                            widget.property.postDate!,
                      ),
                  ]),

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

  Widget _bottomBar() {
    final phone = widget.property.contactNumber.trim();
    final hasPhone = phone.isNotEmpty;

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
            Expanded(
              child: AppButton(
                text: 'Call Owner',
                onTap: hasPhone ? () => AppUtils.call(phone) : null,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.chat_rounded, size: 18),
                label: const Text('WhatsApp',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.whatsAppGreen,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: hasPhone
                    ? () => AppUtils.whatsapp(phone,
                        "Hi, I'm interested in your rental: ${widget.property.title}")
                    : null,
              ),
            ),
          ],
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
