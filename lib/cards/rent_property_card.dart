import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/property_model.dart';
import '../models/ClientLead_model.dart';
import '../services/leads_service.dart';
import '../theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../services/property_api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
          .map((doc) => doc.fileUrl)
          .whereType<String>()
          .toList();
      if (urls.isNotEmpty) return urls;
    }
    return ['assets/images/house1.jpg'];
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.property.propertyStatus ?? "Available";

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          SizedBox(
            height: 420,
            width: double.infinity,
            child: PageView.builder(
              itemCount: _images.length,
              onPageChanged: (i) => setState(() => currentIndex = i),
              itemBuilder: (_, i) {
                final img = _images[i];
                return img.startsWith('assets/')
                    ? Image.asset(img, fit: BoxFit.cover)
                    : Image.network(img,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholderImage());
              },
            ),
          ),

          /// TOP STATUS
          Positioned(top: 12, left: 12, child: _pill(status)),

          /// ICONS
          Positioned(
            top: 8,
            right: 8,
            child: Column(
              children: [
                _iconCircle(
                  _isFavourite ? Icons.favorite : Icons.favorite_border,
                  _toggleFavorite,
                ),
                const SizedBox(height: 8),
                _iconCircle(Icons.share, _shareProperty),
                const SizedBox(height: 8),
                _iconCircle(Icons.call, _callOwner),
                if (widget.showWhatsAppIcon) ...[
                  const SizedBox(height: 8),
                  _iconCircle(Icons.chat, _openWhatsApp),
                ],
              ],
            ),
          ),

          /// BOTTOM DETAILS
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
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// TITLE
                      Text(
                        widget.property.title ?? "-",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 4),

                      /// LOCATION
                      Text(
                        "${widget.property.location ?? ""}, ${widget.property.city ?? ""}",
                        style:
                        const TextStyle(fontSize: 13, color: Colors.white70),
                      ),

                      const SizedBox(height: 6),

                      /// META
                      Row(
                        children: [
                          _meta("Type", widget.property.type),
                          _meta("Beds", widget.property.bedrooms?.toString()),
                       //   _meta("Furn.", widget.property.furnishingStatus),
                        ],
                      ),

                      const SizedBox(height: 8),

                      /// PRICE + CTA
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.property.price != null
                                ? "₹ ${NumberFormat('#,##,###').format(widget.property.price)} / month"
                                : "-",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          _contactButton(),
                        ],
                      )
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

  Widget _meta(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Text(
        "$label: $value",
        style: const TextStyle(fontSize: 12, color: Colors.white70),
      ),
    );
  }

  Widget _contactButton() {
    return GestureDetector(
      onTap: _sendingLead ? null : _createLead,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: _sendingLead
            ? const SizedBox(
          height: 14,
          width: 14,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        )
            : const Text(
          "Contact Owner",
          style: TextStyle(
            fontSize: 12,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _pill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text,
          style: const TextStyle(fontSize: 11, color: Colors.white)),
    );
  }

  Widget _placeholderImage() {
    return Image.asset('assets/images/house1.jpg', fit: BoxFit.cover);
  }

  /// ❤️ Favourite
  Future<void> _toggleFavorite() async {
    await PropertyApiService.toggleFavourite(
      userId: widget.userId!,
      propertyId: widget.property.id!,
    );
    setState(() => _isFavourite = !_isFavourite);
  }

  /// 🆕 CREATE LEAD
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
      "Check this rental property: ${widget.property.title}\n₹${widget.property.price}/month",
    );
  }

  Future<void> _callOwner() async {
    final phone = widget.property.contactNumber;
    if (phone == null || phone.isEmpty) return;
    await launchUrl(Uri.parse("tel:$phone"));
  }

  Future<void> _openWhatsApp() async {
    final phone = widget.property.contactNumber;
    if (phone == null || phone.isEmpty) return;
    await launchUrl(Uri.parse("https://wa.me/$phone"),
        mode: LaunchMode.externalApplication);
  }

  Widget _iconCircle(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 20,
        backgroundColor: Colors.black45,
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}