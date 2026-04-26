import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/property_model.dart';
import '../models/client_lead_model.dart';
import '../services/leads_service.dart';
import '../theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../services/property_api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utility/amenity_icon.dart';

class RentPropertyCard extends StatefulWidget {
  final PropertyModel property;
  final bool showWhatsAppIcon;
  final bool showAmenitiesExpandable;
  final int? userId;

  const RentPropertyCard({
    super.key,
    required this.property,
    this.userId,
    this.showWhatsAppIcon = true,
    this.showAmenitiesExpandable = true,
  });

  @override
  State<RentPropertyCard> createState() => _RentPropertyCardState();
}

class _RentPropertyCardState extends State<RentPropertyCard> {
  int currentIndex = 0;
  bool _isFavourite = false;
  bool _sendingLead = false;

  List<String> get _images {
    if (widget.property.documentList != null &&
        widget.property.documentList!.isNotEmpty) {
      final urls = widget.property.documentList!
          .map((doc) => doc.docUrl)
          .whereType<String>()
          .toList();
      if (urls.isNotEmpty) return urls;
    }
    return ['assets/images/house1.jpg'];
  }

  String get rent {
    if (widget.property.monthlyRent != null) {
      return "₹ ${NumberFormat('#,##,###').format(widget.property.monthlyRent)} / month";
    }
    if (widget.property.price != null) {
      return "₹ ${NumberFormat('#,##,###').format(widget.property.price)} / month";
    }
    return "-";
  }

  @override
  Widget build(BuildContext context) {

    final status =
        widget.property.constructionStatus ?? widget.property.propertyStatus ?? "-";
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [

          /// IMAGE
          SizedBox(
            height: 400, // reduced
            width: double.infinity,
            child: PageView.builder(
              itemCount: _images.length,
              onPageChanged: (i) => setState(() => currentIndex = i),
              itemBuilder: (_, i) {
                final img = _images[i];
                return img.startsWith('assets/')
                    ? Image.asset(img, fit: BoxFit.cover)
                    : Image.network(
                  img,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _placeholderImage(),
                );
              },
            ),
          ),

          /// STATUS
          Positioned(top: 12, left: 12, child: _pill(status)),

          /// VERIFIED
          if (widget.property.verified == true)
            Positioned(
              top: 12,
              left: 100,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.verified, size: 10, color: Colors.white),
                    SizedBox(width: 3),
                    Text("Verified",
                        style: TextStyle(fontSize: 9, color: Colors.white)),
                  ],
                ),
              ),
            ),

          /// ICONS (WITH INTEREST)
          Positioned(
            top: 8,
            right: 8,
            child: Column(
              children: [
                _iconCircle(
                    _isFavourite ? Icons.favorite : Icons.favorite_border,
                    _toggleFavorite),
                const SizedBox(height: 6),

                _iconCircle(Icons.share, _shareProperty),
                const SizedBox(height: 6),

                _iconCircle(Icons.call, _callOwner),
                const SizedBox(height: 6),

                /// ⭐ INTEREST ICON
                _iconCircle(Icons.star, _sendingLead ? null : _createLead),

                if (widget.showWhatsAppIcon) ...[
                  const SizedBox(height: 6),
                  _iconCircle(Icons.chat, _openWhatsApp),
                ],
              ],
            ),
          ),

          /// BOTTOM DETAILS (COMPACT)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              borderRadius:
              const BorderRadius.vertical(bottom: Radius.circular(18)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  color: Colors.black.withOpacity(0.45),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      /// TITLE
                      Text(
                        widget.property.title ?? "-",
                        style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),

                      const SizedBox(height: 2),

                      /// LOCATION
                      Text(
                        "${widget.property.location ?? ""}, ${widget.property.city ?? ""}",
                        style: const TextStyle(
                            fontSize: 12, color: Colors.white70),
                      ),

                      const SizedBox(height: 4),

                      /// META
                      Row(
                        children: [
                          _metaIcon(Icons.bed,
                              "${widget.property.bedrooms ?? '-'}"),
                          _metaIcon(Icons.bathtub,
                              "${widget.property.bathrooms ?? '-'}"),
                          _metaIcon(
                              Icons.square_foot,
                              widget.property.superArea != null
                                  ? "${widget.property.superArea!.toInt()} sqft"
                                  : "-"),
                          _metaIcon(
                              Icons.layers,
                              widget.property.floorNumber != null
                                  ? "Fl ${widget.property.floorNumber}"
                                  : "-"),
                        ],
                      ),

                      const SizedBox(height: 4),

                      /// RENT
                      Text(
                        rent,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),

                      if (widget.showAmenitiesExpandable &&
                          widget.property.amenitiesAsList != null &&
                          widget.property.amenitiesAsList!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        _amenitiesRow(),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
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
                Icon(a.icon, size: 12, color: Colors.white70),
                const SizedBox(width: 3),
                Text(a.label,
                    style:
                    const TextStyle(fontSize: 10, color: Colors.white70)),
              ],
            ),
          );
        }),
        if (amenities.length > 4)
          Text("+${amenities.length - 4} more",
              style: const TextStyle(fontSize: 10, color: Colors.white70)),
      ],
    );
  }

  Widget _metaIcon(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Row(
        children: [
          Icon(icon, size: 12, color: Colors.white70),
          const SizedBox(width: 3),
          Text(text,
              style: const TextStyle(fontSize: 11, color: Colors.white)),
        ],
      ),
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
    return Image.asset('assets/images/house1.jpg', fit: BoxFit.cover);
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
      clientName: prefs.getString("userName") ?? "",
      email: prefs.getString("userEmail") ?? "",
      mobile: prefs.getString("userMobile") ?? "",
      propertyTitle: widget.property.title,
      propertyCity: widget.property.city,
      propertyPrice: widget.property.price,
      preferredPropertyType: widget.property.type,
      preferredBudget: widget.property.price,
      inquiryDate: DateTime.now().toIso8601String(),
      status: "NEW",
      contacted: false,
      leadSource: "Rental Property Interest",
      remark:
      "User interested in rental property ${widget.property.title ?? ""}",
    );

    try {
      await LeadApiService.createLead(lead);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Owner will contact you soon")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("You already contacted for this property"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _sendingLead = false);
    }
  }

  void _shareProperty() {
    Share.share(
        "Check this rental property: ${widget.property.title}\n$rent");
  }

  Future<void> _callOwner() async {
    final phone = widget.property.contactNumber;
    if (phone.isEmpty) return;
    await launchUrl(Uri.parse("tel:$phone"));
  }

  Future<void> _openWhatsApp() async {
    final phone = widget.property.contactNumber;
    if (phone.isEmpty) return;
    await launchUrl(Uri.parse("https://wa.me/$phone"),
        mode: LaunchMode.externalApplication);
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