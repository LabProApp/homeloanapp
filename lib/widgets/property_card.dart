import 'package:flutter/material.dart';
import 'package:property/models/property_model.dart';
import 'package:property/theme/app_colors.dart';
import 'package:property/utility/amenity_icon.dart';

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
  bool amenitiesExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // IMAGE CAROUSEL
          Stack(
            children: [
              SizedBox(
                height: 380, // bigger height
                width: double.infinity,
                child: PageView.builder(
                  itemCount: widget.property.images.length,
                  onPageChanged: (i) => setState(() => currentIndex = i),
                  itemBuilder: (_, i) => ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.asset(
                      widget.property.images[i],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                ),
              ),

              // PAGE INDICATORS
              Positioned(
                bottom: 8,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    widget.property.images.length,
                        (i) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: currentIndex == i ? 10 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: currentIndex == i ? Colors.white : Colors.white54,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
              ),

              // TAGS
              Positioned(
                top: 12,
                left: 12,
                child: Row(
                  children: [
                    _tag(widget.property.postedBy),
                    const SizedBox(width: 8),
                    if (widget.property.verified) _verifiedTag(),
                  ],
                ),
              ),

              // FAVORITE ICON
              Positioned(
                top: 12,
                right: 12,
                child: const Icon(Icons.favorite_border, color: Colors.white),
              ),

              // WHATSAPP, BROCHURE, PHONE ICONS
              Positioned(
                bottom: 12,
                right: 12,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.showWhatsAppIcon)
                      _iconCircle(Icons.message, Colors.green, () {}),
                    const SizedBox(width: 8),
                    _iconCircle(Icons.download, AppColors.secondary, () {}),
                    const SizedBox(width: 8),
                    _iconCircle(Icons.phone, AppColors.secondary, () {}),
                  ],
                ),
              ),
            ],
          ),

          // DETAILS WITH GRADIENT BACKGROUND
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFF5F7FA), // light greyish
                  Color(0xFFE4E8F0), // slightly darker grey
                ],
              ),
            ),
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TITLE + RENT/SALE
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.property.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        widget.property.rentOrSale,
                        style: TextStyle(color: AppColors.cardBg),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // SUBTITLE
                Text(
                  widget.property.subtitle,
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                const SizedBox(height: 6),

                // CITY | STATE + AREA
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        "${widget.property.city} | ${widget.property.state}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.square_foot, size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 2),
                        Text(
                          widget.property.superArea,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // CATEGORY | TYPE + PRICE
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        "${widget.property.category} | ${widget.property.type}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.currency_rupee, size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 2),
                        Text(
                          widget.property.price,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // AMENITIES EXPANDABLE
                if (widget.showAmenitiesExpandable)
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => amenitiesExpanded = !amenitiesExpanded),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              amenitiesExpanded ? "Hide Amenities" : "Show Amenities",
                              style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w600),
                            ),
                            Icon(
                              amenitiesExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                              color: AppColors.secondary,
                            ),
                          ],
                        ),
                      ),
                      if (amenitiesExpanded)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Wrap(
                            spacing: 20,
                            runSpacing: 16,
                            alignment: WrapAlignment.start,
                            children: widget.property.amenities.map((amenity) {
                              return SizedBox(
                                width: 70,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(AmenityIcon.getIcon(amenity), size: 26, color: Colors.grey.shade700),
                                    const SizedBox(height: 6),
                                    Text(
                                      amenity,
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 12),
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
        ],
      ),
    );
  }

  // TAG WIDGET
  Widget _tag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  // VERIFIED TAG WIDGET
  Widget _verifiedTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.shade600,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: const [
          Icon(Icons.verified, color: Colors.white, size: 14),
          SizedBox(width: 4),
          Text(
            "VERIFIED",
            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // CIRCLE ICON WIDGET
  Widget _iconCircle(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 18,
        backgroundColor: Colors.black38,
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}
