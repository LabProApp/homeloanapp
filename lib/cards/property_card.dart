import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/property_model.dart';
import '../theme/app_colors.dart';
import '../utility/amenity_icon.dart';
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

  TextStyle get priceStyle => TextStyle(
    fontFamily: 'Poppins',
    fontSize: 17,
    fontWeight: FontWeight.bold,
    color: AppColors.white,
  );

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
    return widget.property.amenitiesAsList?.map((e) => e.toString()).toList() ?? [];
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
                    : Image.network(img, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholderImage());
              },
            ),
          ),

          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.75),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                status,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

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
                            child: Text(
                              widget.property.title ?? "-",
                              style: titleStyle,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              widget.property.rentOrSale ?? "-",
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),
                      Text(widget.property.location ?? "-", style: bodyStyle),

                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.person, size: 14, color: Colors.white70),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              "Posted by: ${widget.property.postedBy ?? "Owner"}",
                              style: metaStyle,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "${widget.property.city ?? "-"} | ${widget.property.state ?? "-"}",
                              style: bodyStyle,
                            ),
                          ),
                          const Icon(Icons.square_foot, size: 14, color: Colors.white70),
                          const SizedBox(width: 4),
                          Text(
                            widget.property.superArea != null
                                ? "${widget.property.superArea!.toStringAsFixed(0)} Sqft"
                                : "-",
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "${widget.property.category ?? "-"} | ${widget.property.type ?? "-"}",
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
    return Image.asset('assets/images/house1.jpg', fit: BoxFit.cover);
  }

  void _toggleFavorite() {}
  Widget _iconCircle(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: const CircleAvatar(
        radius: 20,
        backgroundColor: Colors.black45,
        child: Icon(Icons.favorite_border, color: Colors.white),
      ),
    );
  }
}