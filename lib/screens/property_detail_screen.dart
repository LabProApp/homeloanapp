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

  int currentIndex = 0;
  bool _isFavourite = false;
  bool _sendingLead = false;

  /// ✅ OWNER CHECK
  bool get isOwner =>
      widget.property.postedByUser != null &&
          widget.property.postedByUser == widget.userId;

  /// 📸 Images
  List<String> get _images {
    if (widget.property.documentList != null &&
        widget.property.documentList!.isNotEmpty) {
      return widget.property.documentList!
          .map((e) => e.docUrl ?? "")
          .toList();
    }
    return [
      'assets/images/house1.jpg',
      'assets/images/house2.jpg',
      'assets/images/house3.jpg',
    ];
  }

  /// 🧩 Amenities
  List<String> get _amenities {
    if (widget.property.amenitiesAsList != null) {
      return widget.property.amenitiesAsList!
          .map((e) => e.toString())
          .toList();
    }
    return [];
  }

  /// 💰 Price Logic (Sale + Rent handled)
  String get priceText {
    if (widget.property.rentOrSale == "RENT") {
      return widget.property.monthlyRent != null
          ? "₹ ${_fmt.format(widget.property.monthlyRent)} / month"
          : "-";
    } else {
      return widget.property.price != null
          ? "₹ ${_fmt.format(widget.property.price)}"
          : "-";
    }
  }

  /// 🗑️ DELETE CONFIRMATION
  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Property"),
        content: const Text("Are you sure you want to delete this property?"),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              minimumSize: const Size(80, 40),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              minimumSize: const Size(88, 40),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            onPressed: () async {
              Navigator.pop(context);

              // 🔥 TODO: Call your delete API here
              // await PropertyApiService.deleteProperty(widget.property.id);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Property deleted")),
              );

              Navigator.pop(context); // go back
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
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
      remark: 'User showed interest from property ${widget.property.title}',
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
        const SnackBar(
            content: Text('You already showed interest in this property'),
            backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _sendingLead = false);
    }
  }

  void _shareProperty() {
    Share.share('${widget.property.title}\n$priceText\n${widget.property.address}');
  }

  void _callOwner() {
    final phone = widget.property.contactNumber ?? '';
    if (phone.isEmpty) return;
    AppUtils.call(phone);
  }

  void _openWhatsApp() {
    final phone = widget.property.contactNumber ?? '';
    if (phone.isEmpty) return;
    AppUtils.whatsapp(phone, "Hi, I'm interested in ${widget.property.title}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      bottomNavigationBar: _bottomButtons(),
      body: CustomScrollView(
        slivers: [

          /// 🔥 IMAGE HEADER
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.transparent,
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              if (isOwner)
                IconButton(
                  icon: Icon(Icons.delete, color: AppColors.error),
                  onPressed: _confirmDelete,
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [

                  PageView.builder(
                    itemCount: _images.length,
                    onPageChanged: (i) => setState(() => currentIndex = i),
                    itemBuilder: (_, i) {
                      final img = _images[i];
                      return img.startsWith('assets/')
                          ? Image.asset(img, fit: BoxFit.cover)
                          : Image.network(
                        img,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Image.asset('assets/images/house1.jpg',
                                fit: BoxFit.cover),
                      );
                    },
                  ),

                  /// Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.4),
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),

                  /// Price
                  Positioned(
                    bottom: 40,
                    left: 16,
                    child: Text(
                      priceText,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    ),
                  ),

                  /// Indicator
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

          /// 🔽 CONTENT
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// TITLE + LOCATION
                  Text(
                    widget.property.title ?? "-",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "${widget.property.address ?? ""}, ${widget.property.city ?? ""}",
                    style: TextStyle(color: AppColors.textSecondary),
                  ),

                  const SizedBox(height: 16),

                  /// FEATURES
                  _featureRow(),

                  const SizedBox(height: 20),

                  /// DESCRIPTION
                  _sectionTitle("Description"),
                  const SizedBox(height: 8),
                  ReadMoreText(
                    widget.property.description ?? "-",
                    trimLines: 3,
                    trimMode: TrimMode.Line,
                  ),

                  const SizedBox(height: 24),

                  /// LOCATION SECTION
                  _sectionTitle("Location"),
                  _card([
                    _DetailRow("Address", widget.property.address ?? "-"),
                    _DetailRow("City", widget.property.city ?? "-"),
                    _DetailRow("State", widget.property.state ?? "-"),
                    _DetailRow("Landmark", widget.property.landmark ?? "-"),
                  ]),

                  const SizedBox(height: 20),

                  /// AREA SECTION
                  _sectionTitle("Area"),
                  _card([
                    _DetailRow("Carpet Area",
                        "${widget.property.carpetArea ?? "-"} sqft"),
                    _DetailRow("Super Area",
                        "${widget.property.superArea ?? "-"} sqft"),
                  ]),

                  const SizedBox(height: 20),

                  /// PROPERTY DETAILS
                  _sectionTitle("Property Details"),
                  _card([
                    _DetailRow("Type", widget.property.type ?? "-"),
                    _DetailRow("Category", widget.property.category ?? "-"),
                    _DetailRow("Bedrooms",
                        widget.property.bedrooms?.toString() ?? "-"),
                    _DetailRow("Bathrooms",
                        widget.property.bathrooms?.toString() ?? "-"),
                    _DetailRow("Floor",
                        "${widget.property.floorNumber ?? "-"} / ${widget.property.totalFloors ?? "-"}"),
                    _DetailRow("Facing", widget.property.facing ?? "-"),
                    _DetailRow("Furnishing", widget.property.furnishing ?? "-"),
                    _DetailRow("Age", widget.property.propertyAge ?? "-"),
                  ]),

                  const SizedBox(height: 20),

                  /// EXTRA DETAILS
                  _sectionTitle("Other Details"),
                  _card([
                    _DetailRow("Construction",
                        widget.property.constructionStatus ?? "-"),
                    _DetailRow("Ownership",
                        widget.property.ownershipType ?? "-"),
                    _DetailRow("RERA Approved",
                        widget.property.reraApproved == true ? "Yes" : "No"),
                    _DetailRow("RERA Number",
                        widget.property.reraNumber ?? "-"),
                  ]),

                  const SizedBox(height: 20),

                  /// AMENITIES
                  if (_amenities.isNotEmpty) ...[
                    _sectionTitle("Amenities"),
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
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(color: Colors.black12, blurRadius: 4)
                            ],
                          ),
                          child: Column(
                            children: [
                              Icon(data.icon, color: AppColors.primary),
                              const SizedBox(height: 6),
                              Text(data.label,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 11)),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],

                  const SizedBox(height: 20),

                  /// OWNER
                  _sectionTitle("Owner Details"),
                  _card([
                    _DetailRow("Posted By", widget.property.postedBy ?? "-"),
                    _DetailRow("Contact",
                        widget.property.contactNumber ?? "-"),
                    _DetailRow(
                        "Verified",
                        widget.property.verified == true ? "Yes" : "No"),
                    _DetailRow("Posted On",
                        AppUtils.formatDate(widget.property.postDate) ?? "-"),
                  ]),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  /// FEATURES
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

  /// COMMON CARD
  Widget _card(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4)
        ],
      ),
      child: Column(children: children),
    );
  }

  /// BUTTONS
  Widget _bottomButtons() {
    final phone = widget.property.contactNumber ?? "";

    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.white,
      child: Row(
        children: [
          /// OWNER BUTTONS
          if (isOwner) ...[
            Expanded(
              child: AppButton(
                text: "Modify",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PostPropertyScreen(
                        userId: widget.userId,
                        propertyToEdit: widget.property, // ✅ prefilled
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: AppButton(
                text: "Delete",
                onTap: _confirmDelete,
              ),
            ),
          ] else ...[
            Expanded(
              child: AppButton(
                text: "Call",
                onTap: phone.isEmpty ? null : () => AppUtils.call(phone),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: AppButton(
                text: "WhatsApp",
                onTap: phone.isEmpty
                    ? null
                    : () => AppUtils.whatsapp(
                  phone,
                  "Hi, I'm interested in ${widget.property.title}",
                ),
              ),
            ),
          ],
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

/// SMALL WIDGETS

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