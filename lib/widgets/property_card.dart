import 'package:flutter/material.dart';
import 'package:property/models/property_model.dart';
import 'package:property/theme/app_colors.dart';
import 'package:property/utility/amenity_icon.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

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

  /// ================= GET IMAGES =================
  List<String> get _images {
    if (widget.property.documentList != null &&
        widget.property.documentList!.isNotEmpty) {
      final urls = widget.property.documentList!
          .map((doc) => doc.docUrl)
          .whereType<String>()
          .toList();
      if (urls.isNotEmpty) return urls;
    }
    // Fallback asset images
    return [
      'assets/images/house1.jpg',
      'assets/images/house2.jpg',
      'assets/images/house3.jpg',
    ];
  }

  /// ================= GET AMENITIES =================
  List<String> get _amenities {
    return widget.property.amenitiesAsList
        ?.map((e) => e.toString())
        .toList() ??
        [];
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ================= IMAGE CAROUSEL =================
          Stack(
            children: [
              SizedBox(
                height: 380,
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

              // ================= INDICATORS =================
              Positioned(
                bottom: 10,
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
                        color:
                        currentIndex == i ? Colors.white : Colors.white54,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
              ),

              // ================= TAGS =================
              Positioned(
                top: 12,
                left: 12,
                child: Row(
                  children: [
                    _tag(widget.property.postedBy ?? "-"),
                    const SizedBox(width: 8),
                    if (widget.property.verified ?? false) _verifiedTag(),
                  ],
                ),
              ),

              // ================= FAVORITE =================
              const Positioned(
                top: 12,
                right: 12,
                child: Icon(Icons.favorite_border, color: Colors.white, size: 26),
              ),

              // ================= ACTION ICONS =================
              Positioned(
                bottom: 16,
                right: 12,
                child: Column(
                  children: [
                    if (widget.showWhatsAppIcon)
                      _iconCircle(Icons.message, _openWhatsApp),
                    const SizedBox(height: 12),
                    _iconCircle(Icons.share, _shareProperty),
                    const SizedBox(height: 12),
                    _iconCircle(Icons.phone, _callOwner),
                  ],
                ),
              ),
            ],
          ),

          // ================= DETAILS =================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFF7F8FA),
                  Color(0xFFE6EBF3),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title & Rent/Sale
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.property.title ?? "-",
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
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

                // City | State & Super Area
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "${widget.property.city ?? "-"} | ${widget.property.state ?? "-"}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                    const Icon(Icons.square_foot, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      widget.property.superArea != null
                          ? "${widget.property.superArea!.toStringAsFixed(0)} Sqft"
                          : "-",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Category | Type & Price
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "${widget.property.category ?? "-"} | ${widget.property.type ?? "-"}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                    const Icon(Icons.currency_rupee, size: 14),
                    Text(
                      widget.property.price != null
                          ? "₹ ${widget.property.price!.toStringAsFixed(2)}"
                          : "-",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Amenities
                if (widget.showAmenitiesExpandable && _amenities.isNotEmpty)
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () =>
                            setState(() => amenitiesExpanded = !amenitiesExpanded),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              amenitiesExpanded ? "Hide Amenities" : "Show Amenities",
                              style: const TextStyle(
                                  color: AppColors.secondary,
                                  fontWeight: FontWeight.w600),
                            ),
                            Icon(
                              amenitiesExpanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
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
                            children: _amenities.map((amenity) {
                              return SizedBox(
                                width: 70,
                                child: Column(
                                  children: [
                                    Icon(
                                      AmenityIcon.getIcon(amenity),
                                      size: 26,
                                      color: AppColors.primary,
                                    ),
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

  /// ================= PLACEHOLDER =================
  Widget _placeholderImage() {
    // List of local placeholder images
    final placeholders = [
      'assets/images/house1.jpg',
      'assets/images/house2.jpg',
      'assets/images/house3.jpg',
    ];

    // Pick one based on current index so it rotates with PageView
    final img = placeholders[currentIndex % placeholders.length];

    return Image.asset(
      img,
      fit: BoxFit.cover,
      width: double.infinity,
    );
  }


  // ================= ACTION METHODS =================
  Future<void> _openWhatsApp() async {
    final message =
        "Hi, I'm interested in this property:\n${widget.property.title ?? "-"}\nPrice: ₹${widget.property.price?.toStringAsFixed(2) ?? "-"}";
    final url = Uri.parse(
        "https://wa.me/${widget.property.contactNumber}?text=${Uri.encodeComponent(message)}");
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

  // ================= SMALL WIDGETS =================
  Widget _tag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text.toUpperCase(),
          style: const TextStyle(
              color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  Widget _verifiedTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        children: [
          Icon(Icons.verified, color: Colors.white, size: 14),
          SizedBox(width: 4),
          Text("VERIFIED",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
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
