import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/property_model.dart';
import '../models/client_lead_model.dart';
import '../services/leads_service.dart';
import '../services/property_api_service.dart';
import '../theme/app_colors.dart';
import '../commons/common_util.dart';
import '../utility/amenity_icon.dart';

class PropertyCard extends StatefulWidget {
  final PropertyModel property;
  final bool showWhatsAppIcon;
  final int? userId;
  final bool showAmenitiesExpandable;

  const PropertyCard({
    super.key,
    required this.property,
    this.userId,
    this.showWhatsAppIcon = true,
    this.showAmenitiesExpandable = true,
  });

  @override
  State<PropertyCard> createState() => _PropertyCardState();
}

class _PropertyCardState extends State<PropertyCard> {
  static final _fmt = NumberFormat('#,##,###');

  int currentIndex = 0;
  bool _isFavourite = false;
  bool _sendingLead = false;

  List<String> get _images {
    final docs = widget.property.documentList;
    if (docs != null && docs.isNotEmpty) {
      final urls = docs
          .map((e) => e.docUrl)
          .where((url) => url != null && url.isNotEmpty)
          .cast<String>()
          .toList();
      if (urls.isNotEmpty) return urls;
    }
    return [
      "assets/images/house1.jpg",
      "assets/images/house2.jpg",
      "assets/images/house3.jpg",
    ];
  }

  @override
  Widget build(BuildContext context) {
    final property = widget.property;

    final status =
        property.constructionStatus ?? property.propertyStatus ?? "-";

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [

          /// IMAGE
          SizedBox(
            height: 430, // reduced
            width: double.infinity,
            child: PageView.builder(
              itemCount: _images.length,
              onPageChanged: (i) => setState(() => currentIndex = i),
              itemBuilder: (_, i) {
                final img = _images[i];

                return img.startsWith("assets/")
                    ? Image.asset(img, fit: BoxFit.cover)
                    : Image.network(
                  img,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _placeholderImage(),
                );
              },
            ),
          ),

          /// IMAGE COUNT
          Positioned(
            bottom: 155,
            right: 12,
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "${currentIndex + 1}/${_images.length}",
                style: const TextStyle(
                    color: Colors.white, fontSize: 10),
              ),
            ),
          ),

          /// STATUS
          Positioned(
            top: 12,
            left: 12,
            child: _pill(status),
          ),

          /// TOP ICONS (INCLUDING INTEREST)
          Positioned(
            top: 8,
            right: 8,
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

                /// 🔥 NEW INTEREST ICON
                _iconCircle(Icons.star, _sendingLead ? null : _createLead),

                if (widget.showWhatsAppIcon) ...[
                  const SizedBox(height: 6),
                  _iconCircle(Icons.chat, _openWhatsApp),
                ],
              ],
            ),
          ),

          /// BOTTOM DETAILS — gradient overlay (no BackdropFilter, GPU-free)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(16)),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xE8000000)],
                  stops: [0.0, 1.0],
                ),
              ),
              padding: const EdgeInsets.fromLTRB(12, 32, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// TITLE
                  Text(
                    property.title ?? "-",
                    style: const TextStyle(
                        fontSize: 17,
                        color: Colors.white,
                        fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 2),

                  /// LOCATION
                  Text(
                    property.location ?? "-",
                    style: const TextStyle(
                        color: AppColors.imageCaptionText, fontSize: 12),
                  ),

                  const SizedBox(height: 2),

                  /// CITY + PRICE
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "${property.city ?? "-"} | ${property.state ?? "-"}",
                          style: const TextStyle(
                              color: AppColors.imageCaptionText, fontSize: 11),
                        ),
                      ),
                      Text(
                        property.price != null
                            ? "₹ ${_fmt.format(property.price)}"
                            : "-",
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  ),

                  const SizedBox(height: 2),

                  /// DATE
                  Text(
                    "Posted: ${AppUtils.formatDate(property.postDate)}",
                    style: const TextStyle(
                        fontSize: 10, color: AppColors.imageCaptionText),
                  ),

                  const SizedBox(height: 6),

                  /// FEATURES
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _feature(Icons.bed,
                          "${property.bedrooms ?? '-'} Beds"),
                      _feature(Icons.bathtub,
                          "${property.bathrooms ?? '-'} Bath"),
                      _feature(Icons.square_foot,
                          "${property.superArea ?? '-'} sqft"),
                    ],
                  ),

                  if (widget.showAmenitiesExpandable &&
                      widget.property.amenitiesAsList != null &&
                      widget.property.amenitiesAsList!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    _amenitiesRow(),
                  ],
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  /// AMENITIES
  Widget _amenitiesRow() {
    final amenities = widget.property.amenitiesAsList!;
    final visible = amenities.take(4);

    return Row(
      children: [
        ...visible.map((e) {
          final a = AmenityIcon.getAmenity(e.toString());
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Row(
              children: [
                Icon(a.icon, size: 12, color: AppColors.imageCaptionText),
                const SizedBox(width: 3),
                Text(a.label,
                    style:
                    const TextStyle(fontSize: 10, color: AppColors.imageCaptionText)),
              ],
            ),
          );
        }),
        if (amenities.length > 4)
          Text("+${amenities.length - 4} more",
              style: const TextStyle(fontSize: 10, color: AppColors.imageCaptionText)),
      ],
    );
  }

  Widget _feature(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 12, color: AppColors.imageCaptionText),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
              fontSize: 10,
              color: Colors.white,
              fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _pill(String text, {Color color = Colors.black}) {
    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style:
        const TextStyle(fontSize: 10, color: Colors.white),
      ),
    );
  }

  Widget _placeholderImage() {
    return Image.asset("assets/images/house1.jpg",
        fit: BoxFit.cover);
  }

  Future<void> _toggleFavorite() async {
    await PropertyApiService.toggleFavourite(
      userId: widget.userId!,
      propertyId: widget.property.id!,
    );
    setState(() => _isFavourite = !_isFavourite);
  }

  Future<void> _createLead() async {
    if (widget.userId == null || widget.property.id == null) return;

    setState(() => _sendingLead = true);

    final prefs = await SharedPreferences.getInstance();

    final lead = ClientLeadModel(
      brokerId: widget.property.postedByUser,
      userId: widget.userId!,
      propertyId: widget.property.id!,
      clientName: prefs.getString("userName"),
      email: prefs.getString("userEmail"),
      mobile: prefs.getString("userMobile"),
      propertyTitle: widget.property.title,
      propertyCity: widget.property.city,
      propertyPrice: widget.property.price,
      preferredPropertyType: widget.property.type,
      preferredBudget: widget.property.price,
      inquiryDate: DateTime.now().toIso8601String(),
      status: "NEW",
      contacted: false,
      leadSource: "Property Interest",
      remark:
      "User showed interest from property ${widget.property.title}",
    );

    try {
      await LeadApiService.createLead(lead);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Interest sent successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                "You already showed interest in this property"),
            backgroundColor: Colors.red),
      );
    }

    setState(() => _sendingLead = false);
  }

  void _shareProperty() {
    Share.share(
        "Check this property: ${widget.property.title}\n₹${widget.property.price}");
  }

  Future<void> _callOwner() async {
    final phone = widget.property.contactNumber;
    if (phone == null || phone.isEmpty) return;
    AppUtils.call(phone);
  }

  Future<void> _openWhatsApp() async {
    final phone = widget.property.contactNumber;
    if (phone == null || phone.isEmpty) return;

    AppUtils.whatsapp(
        phone, "Hi, I am interested in your property ${widget.property.title}");
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
}