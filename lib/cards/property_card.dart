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
class PropertyCard extends StatefulWidget {
  final PropertyModel property;
  final bool showWhatsAppIcon;
  final bool showAmenitiesExpandable;
  final int? userId;

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
  int currentIndex = 0;
  bool _isFavourite = false;
  bool _sendingLead = false;

  TextStyle get titleStyle => const TextStyle(
    fontFamily: 'Poppins',
    fontSize: 21,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  TextStyle get bodyStyle => const TextStyle(
    fontFamily: 'Poppins',
    fontSize: 13,
    color: Colors.white70,
  );

  TextStyle get metaStyle => const TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12,
    color: Colors.white70,
    fontWeight: FontWeight.w500,
  );

  TextStyle get priceStyle => const TextStyle(
    fontFamily: 'Poppins',
    fontSize: 17,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  List<String> get _images {
    if (widget.property.documentList != null &&
        widget.property.documentList!.isNotEmpty) {
      final urls = widget.property.documentList!
          .map((doc) => doc.fileUrl)
          .whereType<String>()
          .toList();
      if (urls.isNotEmpty) return urls;
    }
    return [
      'assets/images/house1.jpg',
      'assets/images/house2.jpg',
      'assets/images/house3.jpg',
    ];
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.property.constructionStatus ??
        widget.property.propertyStatus ??
        ".";

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          SizedBox(
            height: 480,
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
          Positioned(
            top: 12,
            left: 12,
            child: _pill(status),
          ),

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
              const BorderRadius.vertical(bottom: Radius.circular(16)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  color: Colors.black.withOpacity(0.4),
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(widget.property.title ?? "-", style: titleStyle),
                          ),
                          _pill(widget.property.rentOrSale ?? "-",
                              color: AppColors.primary),
                        ],
                      ),

                      const SizedBox(height: 4),
                      Text(widget.property.location ?? "-", style: bodyStyle),

                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "${widget.property.city ?? "-"} | ${widget.property.state ?? "-"}",
                              style: bodyStyle,
                            ),
                          ),
                          Text(
                            widget.property.price != null
                                ? "₹ ${NumberFormat('#,##,###').format(widget.property.price)}"
                                : "-",
                            style: priceStyle,
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      /// ⭐ INTEREST BUTTON
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: _sendingLead ? null : _createLead,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
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
                              "Interested",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
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

  Widget _pill(String text, {Color color = Colors.black}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 11, color: Colors.white),
      ),
    );
  }

  Widget _placeholderImage() {
    return Image.asset('assets/images/house1.jpg', fit: BoxFit.cover);
  }

  /// ❤️ Favourite API
  Future<void> _toggleFavorite() async {
    await PropertyApiService.toggleFavourite(
      userId: widget.userId!,
      propertyId: widget.property.id!,
    );
    setState(() => _isFavourite = !_isFavourite);
  }

  /// 🆕 CREATE LEAD
  /// 🆕 CREATE LEAD
  Future<void> _createLead() async {
    if (widget.userId == null || widget.property.id == null) return;

    setState(() => _sendingLead = true);

    final prefs = await SharedPreferences.getInstance();

    final String clientName = prefs.getString("userName") ?? "";
    final String email = prefs.getString("userEmail") ?? "";
    final String mobile = prefs.getString("userMobile") ?? "";

    final lead = ClientLeadModel(
      brokerId: widget.property.postedByUser,
      userId: widget.userId!,
      propertyId: widget.property.id!,
      clientName: clientName,
      email: email,
      mobile: mobile,
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
      "User showed interest from property ${widget.property.title ?? ""} in ${widget.property.city ?? ""}",
    );

    try {
      await LeadApiService.createLead(lead);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Interest sent successfully")),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("You already showed interest in this property"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _sendingLead = false);
      }
    }
  }

  /// 📤 SHARE
  void _shareProperty() {
    Share.share(
      "Check this property: ${widget.property.title}\n₹${widget.property.price}",
    );
  }

  /// 📞 CALL
  Future<void> _callOwner() async {
    final phone = widget.property.contactNumber;
    if (phone == null || phone.isEmpty) return;
    await launchUrl(Uri.parse("tel:$phone"));
  }

  /// 💬 WHATSAPP
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