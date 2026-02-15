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
          // IMAGE CAROUSEL
          SizedBox(
            height: 480,
            width: double.infinity,
            child: PageView.builder(
              itemCount: _images.length,
              onPageChanged: (i) => setState(() => currentIndex = i),
              itemBuilder: (_, i) {
                final img = _images[i];
                if (img.startsWith('assets/')) {
                  return Image.asset(img,
                      fit: BoxFit.cover, width: double.infinity);
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

          // STATUS BADGE
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
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
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
          Positioned(
            top: 12,
            right: 12,
            child: Column(
              children: [
                const SizedBox(height: 12),

                _iconCircle(Icons.favorite_border, _toggleFavorite),
                const SizedBox(height: 12),

                if (widget.showWhatsAppIcon)
                  _iconCircle(Icons.message, _openWhatsApp),
                const SizedBox(height: 12),

                _iconCircle(Icons.phone, _callOwner),
                const SizedBox(height: 12),

                _iconCircle(Icons.share, _shareProperty),
              ],
            ),
          ),


          // BLUR DETAILS
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
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
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
                                horizontal: 10, vertical: 4),
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

                      // LOCATION
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "${widget.property.location ?? "-"}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // POSTED BY
                      Row(
                        children: [
                          const Icon(Icons.person, size: 14, color: Colors.white70),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              "Posted by: ${widget.property.postedBy ?? "Owner"}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
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
                          const Icon(Icons.square_foot,
                              size: 14, color: Colors.white70),
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
                                ? "₹ ${NumberFormat('#,##,###').format(widget.property.price)}"
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
                              onTap: () => setState(() =>
                              _amenitiesExpanded = !_amenitiesExpanded),
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
                                            AmenityIcon.getAmenity(amenity).icon,
                                            size: 26,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            AmenityIcon.getAmenity(amenity).label,
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
    if (widget.property.contactNumber == null) return;

    String phone = widget.property.contactNumber!;
    if (!phone.startsWith("91")) phone = "91$phone";

    final title = widget.property.title ?? "-";
    final location = widget.property.location;

    final message = StringBuffer()
      ..writeln("Hello, I hope you are doing well.\n")
      ..writeln("I am interested in the following property and would like more details:")
      ..writeln(title);

    if (location != null && location.trim().isNotEmpty) {
      message.writeln("Location: $location");
    }

    message
      ..writeln("\nKindly let me know the availability and whether a site visit can be arranged at your convenience.")
      ..writeln("\nThank you.");

    final url = Uri.parse(
      "https://wa.me/$phone?text=${Uri.encodeComponent(message.toString())}",
    );

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint("Could not open WhatsApp");
    }
  }



  void _shareProperty() {
    final title = widget.property.title;
    final city = widget.property.city;
    final location = widget.property.location;
    final price = widget.property.price;

    final message = StringBuffer()
      ..writeln("You may be interested in this :")
      ..writeln(title ?? "Property");

    if (location != null && location.isNotEmpty) {
      message.writeln(location);
    }

    if (city != null && city.isNotEmpty) {
      message.writeln(city);
    }

    if (price != null) {
      message.writeln("Price: ₹${price.toStringAsFixed(0)}");
    }

    message.writeln("\nPlease check this property and let me know your thoughts.");

    Share.share(message.toString());
  }


  Future<void> _callOwner() async {
    if (widget.property.contactNumber == null) return;

    final url = Uri.parse("tel:${widget.property.contactNumber}");

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  void _toggleFavorite() {
    // TODO: save property to favorites
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
