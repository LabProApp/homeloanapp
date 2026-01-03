import 'package:flutter/material.dart';
import 'package:property/models/property_model.dart';
import 'package:property/theme/app_colors.dart';
import 'package:property/utility/amenity_icon.dart';
import 'package:readmore/readmore.dart';
import 'package:share_plus/share_plus.dart';
import 'package:property/commons/commonutil.dart';
import 'package:intl/intl.dart';

class PropertyDetailScreen extends StatefulWidget {
  final PropertyModel property;

  const PropertyDetailScreen({super.key, required this.property});

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  int currentIndex = 0;
  bool isFavourite = false;

  /// Extract images from documentList or fallback to assets
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

  /// Amenity list as strings
  List<String> get _amenities {
    if (widget.property.amenitiesAsList != null &&
        widget.property.amenitiesAsList!.isNotEmpty) {
      return widget.property.amenitiesAsList!.map((e) => e.toString()).toList();
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: CustomScrollView(
        slivers: [
          /// IMAGE SLIDER
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppColors.primary,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  PageView.builder(
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

                  /// TOP RIGHT ACTION ICONS
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 12,
                    right: 12,
                    child: Column(
                      children: [
                        _imageActionIcon(
                          icon: Icons.message,
                          onTap: _shareWhatsApp,
                        ),
                        const SizedBox(height: 10),
                        _imageActionIcon(
                          icon: Icons.share,
                          onTap: _shareProperty,
                        ),
                        const SizedBox(height: 10),
                        _imageActionIcon(
                          icon: isFavourite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          onTap: () =>
                              setState(() => isFavourite = !isFavourite),
                        ),
                      ],
                    ),
                  ),

                  /// DOT INDICATORS
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
                                : Colors.white54,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// CONTENT
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// PRICE & TITLE
                  Text(
                    widget.property.price != null
                        ? "₹ ${NumberFormat('#,##,###.##').format(widget.property.price)}"
                        : "-",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),

                  const SizedBox(height: 6),
                  Text(
                    widget.property.title ?? "-",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (widget.property.address != null)
                    Text(
                      widget.property.address!,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),

                  const SizedBox(height: 20),
                  _featureRow(),

                  const SizedBox(height: 24),
                  _sectionTitle("About This Property"),
                  const SizedBox(height: 6),
                  ReadMoreText(
                    widget.property.description ??
                        "Property details will be updated soon.",
                    trimLines: 3,
                    trimMode: TrimMode.Line,
                    trimCollapsedText: " Read More",
                    trimExpandedText: " Read Less",
                    moreStyle: TextStyle(color: AppColors.primary),
                    lessStyle: TextStyle(color: AppColors.primary),
                  ),

                  const SizedBox(height: 24),
                  if (_amenities.isNotEmpty) ...[
                    _sectionTitle("Amenities"),
                    const SizedBox(height: 10),
                    Wrap(
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
                                color: AppColors.primary,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                AmenityIcon.getAmenity(amenity).label,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  _sectionTitle("Property Details"),
                  const SizedBox(height: 10),
                  _detailsCard(),

                  const SizedBox(height: 80), // Space for bottom padding
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ---------------- ACTIONS ----------------
  void _shareProperty() {
    Share.share(
      "${widget.property.title}\n"
      "Price: ₹${widget.property.price?.toStringAsFixed(2) ?? "-"}\n"
      "Address: ${widget.property.address ?? "-"}",
    );
  }

  void _shareWhatsApp() {
    Share.share(
      "Check out this property:\n"
      "${widget.property.title}\n"
      "Price: ₹${widget.property.price?.toStringAsFixed(2) ?? "-"}",
    );
  }

  /// ---------------- UI HELPERS ----------------
  Widget _imageActionIcon({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.35),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }

  Widget _placeholderImage() {
    // Show 3 default images rotated by currentIndex
    final img = [
      'assets/images/house1.jpg',
      'assets/images/house2.jpg',
      'assets/images/house3.jpg',
    ][currentIndex % 3];

    return Image.asset(img, fit: BoxFit.cover, width: double.infinity);
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _featureRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _Feature(Icons.bed, "${widget.property.bedrooms ?? '-'} Beds"),
        _Feature(Icons.bathtub, "${widget.property.bathrooms ?? '-'} Baths"),
        _Feature(
          Icons.square_foot,
          "${widget.property.superArea?.toStringAsFixed(0) ?? '-'} Sqft",
        ),
      ],
    );
  }

  Widget _detailsCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _DetailRow("Type", widget.property.type ?? "-"),

          _DetailRow(
            "Construction Status",
            widget.property.constructionStatus ?? "-",
          ),
          _DetailRow(
            "Carpet Area",
            widget.property.carpetArea?.toString() ?? "-",
          ),
          _DetailRow(
            "Super Area",
            widget.property.superArea?.toString() ?? "-",
          ),
          _DetailRow("Posted By", widget.property.postedBy ?? "-"),
          _DetailRow("Contact", widget.property.contactNumber),
          _DetailRow("Posted On", widget.property.postDate ?? "-"),
        ],
      ),
    );
  }
}

/// ---------------- SMALL WIDGETS ----------------
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
