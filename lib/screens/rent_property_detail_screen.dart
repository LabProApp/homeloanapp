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
import 'package:url_launcher/url_launcher.dart';
import '../commons/common_widget.dart';
import '../commons/common_util.dart';

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
  int currentIndex = 0;
  bool _isFavourite = false;
  bool _sendingLead = false;

  List<String> get _images {
    if (widget.property.documentList != null &&
        widget.property.documentList!.isNotEmpty) {
      final urls = widget.property.documentList!
          .map((e) => e.docUrl)
          .where((url) => url.isNotEmpty)
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
    if (widget.property.amenitiesAsList != null) {
      return widget.property.amenitiesAsList!.map((e) => e.toString()).toList();
    }
    return [];
  }

  String get rent {
    if (widget.property.monthlyRent != null) {
      return "₹ ${_fmt.format(widget.property.monthlyRent)} / month";
    }
    if (widget.property.price != null) {
      return "₹ ${_fmt.format(widget.property.price)} / month";
    }
    return "-";
  }

  Widget _iconCircle(IconData icon, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 18,
        backgroundColor: Colors.black45,
        child: _sendingLead && icon == Icons.star
            ? const SizedBox(
                height: 12,
                width: 12,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : Icon(icon, size: 18, color: Colors.white),
      ),
    );
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
      clientName: prefs.getString('userName') ?? '',
      email: prefs.getString('userEmail') ?? '',
      mobile: prefs.getString('userMobile') ?? '',
      propertyTitle: widget.property.title,
      propertyCity: widget.property.city,
      propertyPrice: widget.property.price,
      preferredPropertyType: widget.property.type,
      preferredBudget: widget.property.price,
      inquiryDate: DateTime.now().toIso8601String(),
      status: 'NEW',
      contacted: false,
      leadSource: 'Rental Property Interest',
      remark: 'User interested in rental property ${widget.property.title ?? ""}',
    );
    try {
      await LeadApiService.createLead(lead);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Owner will contact you soon')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You already contacted for this property'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _sendingLead = false);
    }
  }

  void _shareProperty() {
    Share.share('${widget.property.title}\nRent: $rent\n${widget.property.address}');
  }

  void _callOwner() {
    final phone = widget.property.contactNumber.trim();
    if (phone.isEmpty) return;
    AppUtils.call(phone);
  }

  void _openWhatsApp() {
    final phone = widget.property.contactNumber.trim();
    if (phone.isEmpty) return;
    AppUtils.whatsapp(phone, 'Hi, I am interested in your property ${widget.property.title}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      bottomNavigationBar: _bottomButtons(),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppColors.primary,
            actions: const [],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  PageView.builder(
                    itemCount: _images.length,
                    onPageChanged: (i) => setState(() => currentIndex = i),
                    itemBuilder: (_, i) {
                      final img = _images[i];
                      return img.startsWith('assets/')
                          ? Image.asset(img, fit: BoxFit.cover)
                          : Image.network(img, fit: BoxFit.cover);
                    },
                  ),
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
                          width: currentIndex == i ? 10 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: currentIndex == i
                                ? Colors.white
                                : AppColors.imageCaptionText,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ),
                  ),

                  /// Action icon column (matches listing card icons)
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
                        _iconCircle(Icons.call, _callOwner),
                        const SizedBox(height: 6),
                        _iconCircle(Icons.star, _sendingLead ? null : _createLead),
                        const SizedBox(height: 6),
                        _iconCircle(Icons.chat, _openWhatsApp),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// PRICE
                  Text(
                    rent,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),

                  const SizedBox(height: 6),

                  /// TITLE
                  Text(
                    widget.property.title ?? "-",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 6),

                  /// ADDRESS
                  Text(
                    "${widget.property.address ?? ""}, ${widget.property.city ?? ""}",
                    style: TextStyle(color: AppColors.textSecondary),
                  ),

                  if (widget.property.landmark != null)
                    Text(
                      "Near ${widget.property.landmark}",
                      style: TextStyle(color: AppColors.textSecondary),
                    ),

                  const SizedBox(height: 16),

                  /// STATS
                  _featureRow(),

                  const SizedBox(height: 20),

                  /// DESCRIPTION
                  _sectionTitle("About Property"),
                  const SizedBox(height: 8),

                  ReadMoreText(
                    widget.property.description ??
                        "Property details will be updated soon.",
                    trimLines: 3,
                    trimMode: TrimMode.Line,
                    trimCollapsedText: " Read More",
                    trimExpandedText: " Read Less",
                    moreStyle: TextStyle(color: AppColors.primary),
                    lessStyle: TextStyle(color: AppColors.primary),
                  ),

                  const SizedBox(height: 24),

                  /// LOCATION
                  _sectionTitle("Location Details"),
                  const SizedBox(height: 10),
                  _locationCard(),

                  const SizedBox(height: 24),

                  /// AREA
                  _sectionTitle("Area Details"),
                  const SizedBox(height: 10),
                  _areaCard(),

                  const SizedBox(height: 24),

                  /// HIGHLIGHTS
                  _sectionTitle("Property Highlights"),
                  const SizedBox(height: 10),
                  _highlightCard(),

                  const SizedBox(height: 24),

                  /// RENT DETAILS
                  _sectionTitle("Rental Details"),
                  const SizedBox(height: 10),
                  _rentalCard(),

                  const SizedBox(height: 24),

                 /* /// TENANT
                  _sectionTitle("Tenant Preferences"),
                  const SizedBox(height: 10),
                  _tenantCard(),*/

                  const SizedBox(height: 24),

                  /// AMENITIES
                  if (_amenities.isNotEmpty) ...[
                    _sectionTitle("Amenities"),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 20,
                      runSpacing: 16,
                      children: _amenities.map((amenity) {
                        final data = AmenityIcon.getAmenity(amenity);
                        return SizedBox(
                          width: 70,
                          child: Column(
                            children: [
                              Icon(data.icon,
                                  color: AppColors.primary, size: 26),
                              const SizedBox(height: 6),
                              Text(data.label,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  /// OWNER
                  _sectionTitle("Owner Details"),
                  const SizedBox(height: 10),
                  _ownerCard(),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _featureRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _Feature(Icons.bed, "${widget.property.bedrooms ?? '-'} Beds"),
        _Feature(Icons.bathtub, "${widget.property.bathrooms ?? '-'} Baths"),
        _Feature(Icons.square_foot,
            "${widget.property.superArea?.toStringAsFixed(0) ?? '-'} sqft"),
      ],
    );
  }

  Widget _locationCard() {
    return _card([
      _DetailRow("City", widget.property.city ?? "-"),
      _DetailRow("State", widget.property.state ?? "-"),
      _DetailRow("Landmark", widget.property.landmark ?? "-"),
    ]);
  }

  Widget _areaCard() {
    return _card([
      _DetailRow(
          "Carpet Area",
          widget.property.carpetArea != null
              ? "${widget.property.carpetArea} sqft"
              : "-"),
      _DetailRow(
          "Super Area",
          widget.property.superArea != null
              ? "${widget.property.superArea} sqft"
              : "-"),
    ]);
  }

  Widget _highlightCard() {
    return _card([
      _DetailRow("Property Type", widget.property.type ?? "-"),
      _DetailRow("Floor",
          "${widget.property.floorNumber ?? "-"} / ${widget.property.totalFloors ?? "-"}"),
      _DetailRow("Facing", widget.property.facing ?? "-"),
      _DetailRow("Property Age", widget.property.propertyAge ?? "-"),
      _DetailRow("Parking", widget.property.parkingCount ?? "-"),
      _DetailRow("Furnishing", widget.property.furnishing ?? "-"),
    ]);
  }

  Widget _rentalCard() {
    return _card([
      _DetailRow("Monthly Rent", rent),
      _DetailRow(
          "Security Deposit",
          widget.property.securityDeposit != null
              ? "₹ ${_fmt.format(widget.property.securityDeposit)}"
              : "-"),
      _DetailRow(
          "Maintenance Included",
          widget.property.maintenanceIncluded == true ? "Yes" : "No"),
    ]);
  }

 /* Widget _tenantCard() {
    return _card([
      _DetailRow("Preferred Tenants", widget.property.preferredTenants ?? "Any"),
      _DetailRow(
          "Pets Allowed", widget.property.petsAllowed == true ? "Yes" : "No"),
      _DetailRow("Non Veg Allowed",
          widget.property.nonVegAllowed == true ? "Yes" : "No"),
    ]);
  }*/

  Widget _ownerCard() {
    return _card([
      _DetailRow("Posted By", widget.property.postedBy ?? "-"),
      _DetailRow(
          "Verified", widget.property.verified == true ? "Yes" : "No"),
      _DetailRow("Contact", widget.property.contactNumber),
      _DetailRow("Posted On", AppUtils.formatDate(widget.property.postDate) ?? "-"),
    ]);
  }

  Widget _card(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: children),
    );
  }

  Widget _bottomButtons() {
    final phone = widget.property.contactNumber.trim();
    final hasPhone = phone.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: AppButton(
              text: "Call Owner",
              onTap: hasPhone ? () => AppUtils.call(phone) : null,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: AppButton(
              text: "WhatsApp",
              onTap: hasPhone
                  ? () => AppUtils.whatsapp(
                        phone,
                        "Hi, I am interested in your property ${widget.property.title}",
                      )
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _Feature extends StatelessWidget {
  final IconData icon;
  final String label;

  const _Feature(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}