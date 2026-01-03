import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:property/models/property_model.dart';
import 'package:property/theme/app_colors.dart';
import 'package:property/utility/amenity_icon.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

class PropertyCard extends StatefulWidget {
  final PropertyModel property;
  final bool showWhatsAppIcon;
  final bool showAmenitiesExpandable;

  const PropertyCard({
    super.key,
    required this.property,
    this.showWhatsAppIcon = true,
    this.showAmenitiesExpandable = true,
  });

  @override
  State<PropertyCard> createState() => _PropertyCardState();
}

class _PropertyCardState extends State<PropertyCard> {
  int currentIndex = 0;
  bool _amenitiesExpanded = false;

  List<String> get _images {
    if (widget.property.documentList != null &&
        widget.property.documentList!.isNotEmpty) {
      final urls = widget.property.documentList!
          .map((doc) => doc.docUrl)
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

  List<String> get _amenities {
    return widget.property.amenitiesAsList?.map((e) => e.toString()).toList() ??
        [];
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // IMAGE CAROUSEL (Taller)
          SizedBox(
            height: 480, // increased height for bigger card
            width: double.infinity,
            child: PageView.builder(
              itemCount: _images.length,
              onPageChanged: (i) => setState(() => currentIndex = i),
              itemBuilder: (_, i) {
                final img = _images[i];
                if (img.startsWith('assets/')) {
                  return Image.asset(
                    img,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  );
                } else {
                  return Image.network(
                    img,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (_, __, ___) => _placeholderImage(),
                  );
                }
              },
            ),
          ),

          // PAGE INDICATORS
          Positioned(
            bottom: 200,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _images.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: currentIndex == i ? 12 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: currentIndex == i ? Colors.white : Colors.white54,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
          ),

          // ACTION ICONS
          // FAVORITE + ACTION ICONS
          Positioned(
            top: 12,
            right: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // WhatsApp Icon
                const SizedBox(height: 12),
                _iconCircle(Icons.favorite_border, _openWhatsApp),
                const SizedBox(height: 12),
                _iconCircle(Icons.message, _openWhatsApp),
                // Call Icon
                const SizedBox(height: 12),
                _iconCircle(Icons.phone, _callOwner),
                // Share Icon
                const SizedBox(height: 12),
                _iconCircle(Icons.share, _shareProperty),
              ],
            ),
          ),

          // BLUR OVERLAY WITH DETAILS & AMENITIES
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(16),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  color: Colors.black.withOpacity(0.4), // darker for contrast
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // TITLE + RENT/SALE
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.property.title ?? "-",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              widget.property.rentOrSale ?? "-",
                              style: TextStyle(color: AppColors.cardBg),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // CITY | STATE + AREA
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "${widget.property.city ?? "-"} | ${widget.property.state ?? "-"}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ),
                          const Icon(
                            Icons.square_foot,
                            size: 14,
                            color: Colors.white70,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.property.superArea != null
                                ? "${widget.property.superArea!.toStringAsFixed(0)} Sqft"
                                : "-",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // CATEGORY | TYPE + PRICE
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "${widget.property.category ?? "-"} | ${widget.property.type ?? "-"}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ),

                          Text(
                            widget.property.price != null
                                ? "₹ ${NumberFormat('#,##,###.##').format(widget.property.price)}"
                                : "-",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // AMENITIES
                      if (widget.showAmenitiesExpandable &&
                          _amenities.isNotEmpty)
                        Column(
                          children: [
                            GestureDetector(
                              onTap: () => setState(
                                () => _amenitiesExpanded = !_amenitiesExpanded,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    _amenitiesExpanded
                                        ? "Hide Amenities"
                                        : "Show Amenities",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Icon(
                                    _amenitiesExpanded
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                            if (_amenitiesExpanded)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Wrap(
                                  spacing: 20,
                                  runSpacing: 16,
                                  children: _amenities.map((amenity) {
                                    return SizedBox(
                                      width: 70,
                                      child: Column(
                                        children: [
                                          Icon(
                                            AmenityIcon.getIcon(amenity),
                                            size: 26,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            amenity,
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                          ],
                        ),
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

  Widget _placeholderImage() {
    final placeholders = [
      'assets/images/house1.jpg',
      'assets/images/house2.jpg',
      'assets/images/house3.jpg',
    ];
    final img = placeholders[currentIndex % placeholders.length];
    return Image.asset(img, fit: BoxFit.cover, width: double.infinity);
  }

  Future<void> _openWhatsApp() async {
    final message =
        "Hi, I'm interested in this property:\n${widget.property.title ?? "-"}\nPrice: ₹${widget.property.price?.toStringAsFixed(2) ?? "-"}";
    final url = Uri.parse(
      "https://wa.me/${widget.property.contactNumber}?text=${Uri.encodeComponent(message)}",
    );
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  void _shareProperty() {
    Share.share(
      "${widget.property.title ?? "-"}\n"
      "${widget.property.city ?? "-"}, ${widget.property.state ?? "-"}\n"
      "Price: ₹${widget.property.price?.toStringAsFixed(2) ?? "-"}",
    );
  }

  Future<void> _callOwner() async {
    final url = Uri.parse("tel:${widget.property.contactNumber}");
    await launchUrl(url);
  }

  Widget _iconCircle(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 20,
        backgroundColor: Colors.black45,
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}
