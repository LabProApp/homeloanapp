import 'package:flutter/material.dart';
import '../models/property_model.dart';
import '../theme/app_colors.dart';
import '../utility/amenity_icon.dart';
import 'package:readmore/readmore.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

class RentalPropertyDetailScreen extends StatefulWidget {
  final PropertyModel property;
  final int userId;

  const RentalPropertyDetailScreen({
    super.key,
    required this.property,
    required this.userId,
  });

  @override
  State<RentalPropertyDetailScreen> createState() =>
      _RentalPropertyDetailScreenState();
}

class _RentalPropertyDetailScreenState
    extends State<RentalPropertyDetailScreen> {
  int currentIndex = 0;

  List<String> get _images {
    if (widget.property.documentList != null &&
        widget.property.documentList!.isNotEmpty) {
      final urls = widget.property.documentList!
          .map((e) => e.docUrl)
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
    if (widget.property.amenitiesAsList != null &&
        widget.property.amenitiesAsList!.isNotEmpty) {
      return widget.property.amenitiesAsList!.map((e) => e.toString()).toList();
    }
    return [];
  }

  bool get _isCommercial {
    return widget.property.type?.toLowerCase() == "commercial";
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
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  PageView.builder(
                    itemCount: _images.length,
                    onPageChanged: (i) => setState(() => currentIndex = i),
                    itemBuilder: (_, i) {
                      final img = _images[i];
                      return img.startsWith('assets/')
                          ? Image.asset(img, fit: BoxFit.cover)
                          : Image.network(
                        img,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _placeholderImage(),
                      );
                    },
                  ),

                  /// DOTS
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
                  /// RENT PRICE
                  Text(
                    widget.property.price != null
                        ? "₹ ${NumberFormat('#,##,###').format(widget.property.price)} / month"
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

                  _sectionTitle("Rental Details"),
                  const SizedBox(height: 10),
                  _detailsCard(),

                  const SizedBox(height: 80),
                ],
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

  Widget _sectionTitle(String title) {
    return Text(title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
  }

  /// FEATURES ROW
  Widget _featureRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        if (!_isCommercial)
          _Feature(Icons.bed, "${widget.property.bedrooms ?? '-'} Beds"),
        if (!_isCommercial)
          _Feature(Icons.bathtub, "${widget.property.bathrooms ?? '-'} Baths"),
        _Feature(
          Icons.square_foot,
          "${widget.property.superArea?.toStringAsFixed(0) ?? '-'} Sqft",
        ),
       /* _Feature(
          Icons.event_available,
          widget.property.availableFrom ?? "Available",
        ),*/
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
          _DetailRow("Listing Type", "For Rent"),
          _DetailRow("Property Type", widget.property.type ?? "-"),
    //     _DetailRow("Deposit", widget.property.deposit?.toString() ?? "-"),
       //   _DetailRow(
        //      "Furnishing", widget.property.furnishingStatus ?? "-"),
       //   _DetailRow("Tenant Type", widget.property.tenantType ?? "-"),
          _DetailRow("Carpet Area",
              widget.property.carpetArea?.toString() ?? "-"),
          _DetailRow("Super Area",
              widget.property.superArea?.toString() ?? "-"),
          _DetailRow("Contact", widget.property.contactNumber ?? "-"),
        ],
      ),
    );
  }
}

/// SMALL WIDGETS
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