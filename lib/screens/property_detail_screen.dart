import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/property_model.dart';
import '../models/client_lead_model.dart';
import '../services/leads_service.dart';
import '../services/property_api_service.dart';
import '../theme/app_colors.dart';
import '../utility/amenity_icon.dart';
import 'package:readmore/readmore.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../commons/common_widget.dart';
import '../commons/common_util.dart';
import 'property_add_screen.dart';
import 'emi_calculator_screen.dart';
import '../screens/bank_apply_loan_dialog.dart';
import '../screens/stamp_duty_screen.dart';
import '../screens/rent_vs_buy_screen.dart';
import '../screens/due_diligence_screen.dart';
import '../models/property_journey_model.dart';
import '../services/journey_service.dart';
import 'property_journey_screen.dart';

class PropertyDetailScreen extends StatefulWidget {
  final PropertyModel property;
  final int userId;

  const PropertyDetailScreen({
    super.key,
    required this.property,
    required this.userId,
  });

  @override
  State<PropertyDetailScreen> createState() =>
      _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  static final _fmt = NumberFormat('#,##,###');

  int _currentIndex = 0;
  bool _isFavourite = false;
  bool _sendingLead = false;
  bool _deleting = false;
  PropertyJourneyModel? _journey;

  @override
  void initState() {
    super.initState();
    _loadJourney();
  }

  bool get isOwner =>
      widget.property.postedByUser != null &&
      widget.property.postedByUser == widget.userId;

  bool get _isRent =>
      widget.property.rentOrSale?.toUpperCase() == 'RENT';

  bool get _isResidential =>
      widget.property.category?.toUpperCase() == 'RESIDENTIAL';

  List<String> get _images {
    if (widget.property.documentList != null &&
        widget.property.documentList!.isNotEmpty) {
      return widget.property.documentList!
          .map((e) => e.docUrl ?? '')
          .where((u) => u.isNotEmpty)
          .toList();
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
      icon = Icons.storefront_outlined;
      bg = const Color(0xFFE8F5E9);
      iconColor = const Color(0xFF2E7D32);
      label = widget.property.type ?? 'Commercial';
    } else if (isPlot) {
      icon = Icons.landscape_outlined;
      bg = const Color(0xFFFBE9E7);
      iconColor = const Color(0xFF6D4C41);
      label = 'Plot';
    } else {
      icon = Icons.home_outlined;
      bg = const Color(0xFFFFF3E0);
      iconColor = const Color(0xFFE65100);
      label = widget.property.type ?? 'Property';
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
    if (widget.property.amenities != null && widget.property.amenities!.isNotEmpty) {
      return widget.property.amenities!
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    if (widget.property.amenitiesAsList != null && widget.property.amenitiesAsList!.isNotEmpty) {
      return widget.property.amenitiesAsList!.map((e) => e.toString()).toList();
    }
    return [];
  }

  String get _priceText {
    if (_isRent) {
      return widget.property.monthlyRent != null
          ? '₹ ${_fmt.format(widget.property.monthlyRent)} / month'
          : '-';
    }
    return widget.property.price != null
        ? '₹ ${_fmt.format(widget.property.price)}'
        : '-';
  }

  // ── Journey ──────────────────────────────────────────────────────────────────

  Future<void> _loadJourney() async {
    if (widget.property.id == null) return;
    final j = await JourneyService.findByPropertyId(widget.userId, widget.property.id!);
    if (!mounted) return;
    setState(() => _journey = j);
  }

  Future<void> _openJourney() async {
    if (widget.property.id == null) return;
    PropertyJourneyModel journey;
    if (_journey == null) {
      final now = DateTime.now();
      journey = PropertyJourneyModel.create(
        userId: widget.userId,
        propertyId: widget.property.id!,
        propertyTitle: widget.property.title ?? 'Property',
        propertyCity: widget.property.city,
        propertyType: widget.property.type,
        propertyPrice: widget.property.price?.toDouble(),
      );
      // Auto-complete step 0 (Confirm Property) since user is on the detail screen
      journey.steps[0] = JourneyStepState(
        status: JourneyStepStatus.completed,
        completedAt: now,
      );
      journey.updatedAt = now;
      await JourneyService.save(journey);
    } else {
      journey = _journey!;
    }
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PropertyJourneyScreen(journey: journey, userId: widget.userId),
      ),
    );
    _loadJourney();
  }

  Widget _journeyButton() {
    final j = _journey;
    final label = j == null
        ? 'Start Purchase Journey'
        : j.isComplete
            ? 'View Journey  ✓'
            : 'Continue Journey  •  ${j.completedCount}/6 done';

    return GestureDetector(
      onTap: _openJourney,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF8F00), Color(0xFFE65100)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE65100).withOpacity(0.30),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.route_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Actions ─────────────────────────────────────────────────────────────────

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Property'),
        content:
            const Text('Are you sure you want to delete this property?'),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              minimumSize: const Size(80, 40),
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
              minimumSize: const Size(88, 40),
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 10),
            ),
            onPressed: () async {
              Navigator.pop(context);
              await _deleteProperty();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteProperty() async {
    if (widget.property.id == null) return;
    setState(() => _deleting = true);
    try {
      await PropertyApiService.deleteProperty(widget.property.id!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Property deleted successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Could not delete. Please try again.'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

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
      clientName: prefs.getString('userName'),
      email: prefs.getString('userEmail'),
      mobile: prefs.getString('userMobile'),
      propertyTitle: widget.property.title,
      propertyCity: widget.property.city,
      propertyPrice: widget.property.price,
      preferredPropertyType: widget.property.type,
      preferredBudget: widget.property.price,
      inquiryDate: DateTime.now().toIso8601String(),
      status: 'NEW',
      contacted: false,
      leadSource: 'Property Interest',
      remark:
          'User showed interest from property ${widget.property.title}',
    );
    try {
      await LeadApiService.createLead(lead);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Interest sent successfully')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              const Text('You already showed interest in this property'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _sendingLead = false);
    }
  }

  void _shareProperty() {
    Share.share(
        '${widget.property.title}\n$_priceText\n${widget.property.address}');
  }

  void _callOwner() {
    final phone = widget.property.contactNumber;
    if (phone.isEmpty) return;
    AppUtils.call(phone);
  }

  void _openWhatsApp() {
    final phone = widget.property.contactNumber;
    if (phone.isEmpty) return;
    AppUtils.whatsapp(
        phone, "Hi, I'm interested in ${widget.property.title}");
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.listingbackground,
      bottomNavigationBar: _bottomBar(),
      body: CustomScrollView(
        slivers: [
          // ── Image header ───────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.transparent,
            iconTheme:
                const IconThemeData(color: AppColors.white),
            actions: const [],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  _images.isEmpty
                      ? _typePlaceholder()
                      : PageView.builder(
                    itemCount: _images.length,
                    onPageChanged: (i) =>
                        setState(() => _currentIndex = i),
                    itemBuilder: (_, i) => CachedNetworkImage(
                              imageUrl: _images[i],
                              fit: BoxFit.cover,
                              fadeInDuration:
                                  const Duration(milliseconds: 250),
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

                  // Price
                  Positioned(
                    bottom: 40,
                    left: 16,
                    child: Text(
                      _priceText,
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
                          margin: const EdgeInsets.symmetric(
                              horizontal: 4),
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

                  // Action icons (top-right)
                  Positioned(
                    top: MediaQuery.of(context).padding.top +
                        kToolbarHeight +
                        8,
                    right: 12,
                    child: Column(
                      children: [
                        _iconCircle(
                          _isFavourite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          _toggleFavorite,
                        ),
                        const SizedBox(height: 6),
                        _iconCircle(Icons.share, _shareProperty),
                        const SizedBox(height: 6),
                        _iconCircle(Icons.call, _callOwner),
                        if (!isOwner) ...[
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

          // ── Content ────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Title
                  Text(
                    widget.property.title ?? '-',
                    style:
                        Theme.of(context).textTheme.titleLarge?.copyWith(
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
                              .where((s) =>
                                  s != null && s.isNotEmpty)
                              .join(', '),
                          style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Feature chips
                  _featureRow(),

                  const SizedBox(height: 20),

                  // Description
                  _sectionTitle('Description'),
                  const SizedBox(height: 8),
                  ReadMoreText(
                    widget.property.description ?? '-',
                    trimLines: 3,
                    trimMode: TrimMode.Line,
                  ),

                  const SizedBox(height: 24),

                  // Pricing
                  _sectionTitle(_isRent ? 'Rent Details' : 'Pricing'),
                  _card([
                    if (_isRent) ...[
                      if (widget.property.monthlyRent != null)
                        _DetailRow('Monthly Rent',
                            '₹ ${_fmt.format(widget.property.monthlyRent)}'),
                      if (widget.property.securityDeposit != null)
                        _DetailRow('Security Deposit',
                            '₹ ${_fmt.format(widget.property.securityDeposit)}'),
                      if (widget.property.preferredTenants != null)
                        _DetailRow('Preferred Tenants',
                            widget.property.preferredTenants!),
                      if (widget.property.leaseDuration != null)
                        _DetailRow('Lease Duration', widget.property.leaseDuration!),
                      if (widget.property.noticePeriod != null)
                        _DetailRow('Notice Period', widget.property.noticePeriod!),
                      if (widget.property.maintenanceIncluded != null)
                        _DetailRow('Maintenance',
                            widget.property.maintenanceIncluded! ? 'Included' : 'Not Included'),
                    ] else ...[
                      if (widget.property.price != null)
                        _DetailRow('Price',
                            '₹ ${_fmt.format(widget.property.price)}'),
                    ],
                    if (widget.property.brokerage != null)
                      _DetailRow('Brokerage',
                          '₹ ${_fmt.format(widget.property.brokerage)}'),
                    if (widget.property.negotiable == true)
                      const _DetailRow('Negotiable', 'Yes'),
                    if (widget.property.loanAvailable == true)
                      const _DetailRow('Loan Available', 'Yes'),
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

                  const SizedBox(height: 20),

                  // Property Details
                  _sectionTitle('Property Details'),
                  _card([
                    if (widget.property.type != null)
                      _DetailRow('Type', widget.property.type!),
                    if (widget.property.category != null)
                      _DetailRow('Category', widget.property.category!),
                    if (widget.property.projectName != null &&
                        widget.property.projectName!.isNotEmpty)
                      _DetailRow('Project', widget.property.projectName!),
                    if (_isResidential &&
                        widget.property.bedrooms != null)
                      _DetailRow('Bedrooms',
                          widget.property.bedrooms.toString()),
                    if (_isResidential &&
                        widget.property.bathrooms != null)
                      _DetailRow('Bathrooms',
                          widget.property.bathrooms.toString()),
                    if (widget.property.furnishing != null)
                      _DetailRow(
                          'Furnishing', widget.property.furnishing!),
                    if (widget.property.parkingType != null ||
                        widget.property.parkingCount != null)
                      _DetailRow(
                        'Parking',
                        [
                          widget.property.parkingType,
                          widget.property.parkingCount != null
                              ? '(${widget.property.parkingCount})'
                              : null,
                        ]
                            .whereType<String>()
                            .join(' ')
                            .trim(),
                      ),
                    if (widget.property.facing != null)
                      _DetailRow('Facing', widget.property.facing!),
                    if (widget.property.propertyAge != null)
                      _DetailRow('Age', widget.property.propertyAge!),
                    if (widget.property.constructionStatus != null)
                      _DetailRow('Construction',
                          widget.property.constructionStatus!),
                  ]),

                  const SizedBox(height: 20),

                  // Area & Floor
                  _sectionTitle('Area & Floor'),
                  _card([
                    if (widget.property.superArea != null)
                      _DetailRow('Super Area',
                          '${widget.property.superArea!.toStringAsFixed(0)} sqft'),
                    if (widget.property.carpetArea != null)
                      _DetailRow('Carpet Area',
                          '${widget.property.carpetArea!.toStringAsFixed(0)} sqft'),
                    if (widget.property.floorNumber != null ||
                        widget.property.totalFloors != null)
                      _DetailRow(
                        'Floor',
                        '${widget.property.floorNumber ?? '-'} of ${widget.property.totalFloors ?? '-'}',
                      ),
                  ]),

                  const SizedBox(height: 20),

                  // Other Details
                  _sectionTitle('Other Details'),
                  _card([
                    if (widget.property.ownershipType != null)
                      _DetailRow('Ownership',
                          widget.property.ownershipType!),
                    if (widget.property.reraApproved != null)
                      _DetailRow(
                          'RERA Approved',
                          widget.property.reraApproved == true
                              ? 'Yes'
                              : 'No'),
                    if (widget.property.reraApproved == true &&
                        widget.property.reraNumber != null)
                      _DetailRow(
                          'RERA Number', widget.property.reraNumber!),
                    if (widget.property.petsAllowed != null)
                      _DetailRow('Pets Allowed',
                          widget.property.petsAllowed! ? 'Yes' : 'No'),
                    if (widget.property.nonVegAllowed != null)
                      _DetailRow('Non-Veg',
                          widget.property.nonVegAllowed! ? 'Yes' : 'No'),
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
                                  color: Color(0x14000000),
                                  blurRadius: 4),
                            ],
                          ),
                          child: Column(
                            children: [
                              Icon(data.icon,
                                  color: AppColors.primary),
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

                  // Quick Tools
                  _sectionTitle('Quick Tools'),
                  const SizedBox(height: 12),
                  _quickToolsRow(),
                  const SizedBox(height: 20),

                  // Owner Details
                  _sectionTitle('Owner Details'),
                  _card([
                    if (widget.property.postedBy != null &&
                        widget.property.postedBy!.isNotEmpty)
                      _DetailRow(
                          'Posted By', widget.property.postedBy!),
                    if (widget.property.contactNumber.isNotEmpty)
                      _DetailRow(
                          'Contact', widget.property.contactNumber),
                    if (widget.property.verified != null)
                      _DetailRow(
                          'Verified',
                          widget.property.verified! ? 'Yes' : 'No'),
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

  // ── Quick Tools ──────────────────────────────────────────────────────────────

  Widget _quickToolsRow() {
    final price = widget.property.price?.toDouble();
    final tools = <_ToolItem>[
      if (!_isRent) _ToolItem(
        Icons.calculate_outlined, 'Stamp Duty', const Color(0xFF1565C0),
        () => Navigator.push(context, MaterialPageRoute(
          builder: (_) => StampDutyScreen(initialAmount: price),
        )),
      ),
      if (!_isRent) _ToolItem(
        Icons.balance_outlined, 'Rent vs Buy', const Color(0xFF2E7D32),
        () => Navigator.push(context, MaterialPageRoute(
          builder: (_) => RentVsBuyScreen(initialPropertyPrice: price),
        )),
      ),
      _ToolItem(
        Icons.checklist_outlined, 'Due Diligence', const Color(0xFF6A1B9A),
        () => Navigator.push(context, MaterialPageRoute(
          builder: (_) => const DueDiligenceScreen(),
        )),
      ),
    ];

    return Row(
      children: tools.map((t) => Expanded(child: Padding(
        padding: const EdgeInsets.only(right: 8),
        child: InkWell(
          onTap: t.onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: t.color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: t.color.withOpacity(0.2)),
            ),
            child: Column(children: [
              Icon(t.icon, color: t.color, size: 22),
              const SizedBox(height: 4),
              Text(t.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: t.color, fontWeight: FontWeight.w600)),
            ]),
          ),
        ),
      ))).toList(),
    );
  }

  // ── Section helpers ──────────────────────────────────────────────────────────

  Widget _featureRow() {
    final area =
        widget.property.superArea ?? widget.property.carpetArea;
    final features = <Widget>[];

    if (_isResidential) {
      if (widget.property.bedrooms != null) {
        features.add(_Feature(Icons.bed_rounded,
            '${widget.property.bedrooms} Beds'));
      }
      if (widget.property.bathrooms != null) {
        features.add(_Feature(Icons.bathtub_outlined,
            '${widget.property.bathrooms} Baths'));
      }
    }
    if (area != null) {
      features.add(_Feature(
          Icons.square_foot, '${area.toStringAsFixed(0)} sqft'));
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
    if (children.isEmpty) {
      return const SizedBox.shrink();
    }
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

  // ── Bottom bar ───────────────────────────────────────────────────────────────

  void _openEmiSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.92,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: EmiCalculatorScreen(
            initialAmount: widget.property.price?.toDouble(),
            scrollController: controller,
          ),
        ),
      ),
    );
  }

  Widget _bottomBar() {
    final phone = widget.property.contactNumber;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black.withOpacity(0.07),
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
          child: isOwner ? _ownerBar() : _buyerBar(phone),
        ),
      ),
    );
  }

  Widget _ownerBar() => Row(
        children: [
          Expanded(
            child: AppButton(
              text: 'Modify',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PostPropertyScreen(
                    userId: widget.userId,
                    propertyToEdit: widget.property,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: _deleting ? null : _confirmDelete,
              child: _deleting
                  ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.error))
                  : const Text('Delete',
                      style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      );

  Widget _buyerBar(String phone) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Primary: Contact buttons ───────────────────────────────────
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: 'Call Owner',
                  onTap: phone.isEmpty ? null : () => AppUtils.call(phone),
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
                  onPressed: phone.isEmpty ? null : _openWhatsApp,
                ),
              ),
            ],
          ),
          // ── Journey button (sale only) ────────────────────────────────
          if (!_isRent) ...[
            const SizedBox(height: 8),
            _journeyButton(),
          ],
          // ── Secondary: Quick tool chips (sale only) ────────────────────
          if (!_isRent) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                _toolChip(Icons.calculate_outlined, 'EMI Calc',
                    AppColors.primary, _openEmiSheet),
                const SizedBox(width: 8),
                _toolChip(Icons.account_balance_outlined, 'Apply Loan',
                    AppColors.secondary, () => LoanApplySheet.show(context)),
                const SizedBox(width: 8),
                _toolChip(Icons.checklist_outlined, 'Due Diligence',
                    const Color(0xFF6A1B9A),
                    () => Navigator.push(context, MaterialPageRoute(
                        builder: (_) => const DueDiligenceScreen()))),
              ],
            ),
          ],
        ],
      );

  Widget _toolChip(IconData icon, String label, Color color, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withOpacity(0.25)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(height: 3),
              Text(label,
                  style: TextStyle(
                      fontSize: 10,
                      color: color,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Reusable sub-widgets ─────────────────────────────────────────────────────

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
        Text(
          label,
          style: const TextStyle(
              fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _ToolItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ToolItem(this.icon, this.label, this.color, this.onTap);
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
            child: Text(
              title,
              style: const TextStyle(
                  color: AppColors.textMuted, fontSize: 13),
            ),
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
