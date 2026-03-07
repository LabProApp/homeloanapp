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
      final urls =
      widget.property.documentList!.map((e) => e.fileUrl).toList();
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
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,

      /// BOTTOM ACTIONS
      bottomNavigationBar: _bottomButtons(),

      body: CustomScrollView(
        slivers: [

          /// IMAGE SLIDER
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppColors.primary,
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  Share.share(
                      "${widget.property.title}\nRent: $rent\n${widget.property.address}");
                },
              )
            ],
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
                    bottom: 14,
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

          /// BODY
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// RENT
                  Text(
                    rent,
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary),
                  ),

                  const SizedBox(height: 6),

                  /// TITLE
                  Text(
                    widget.property.title ?? "-",
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 4),

                  /// ADDRESS
                  if (widget.property.address != null)
                    Text(
                      widget.property.address!,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),

                  if (widget.property.landmark != null)
                    Text(
                      "Near ${widget.property.landmark}",
                      style: TextStyle(color: AppColors.textSecondary),
                    ),

                  const SizedBox(height: 10),

                  /// STATS
                  Row(
                    children: [
                      Icon(Icons.visibility,
                          size: 18, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text("${widget.property.viewsCount ?? 0} views"),
                      const SizedBox(width: 16),
                      Icon(Icons.favorite,
                          size: 18, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text("${widget.property.shortListCount ?? 0} saved"),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// FEATURES
                  _featureRow(),

                  const SizedBox(height: 24),

                  /// DESCRIPTION
                  _sectionTitle("About Property"),
                  const SizedBox(height: 8),

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

                  /// AMENITIES
                  if (_amenities.isNotEmpty) ...[
                    _sectionTitle("Amenities"),
                    const SizedBox(height: 12),
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

                  /// HIGHLIGHTS
                  _sectionTitle("Property Highlights"),
                  const SizedBox(height: 10),
                  _highlightCard(),

                  const SizedBox(height: 24),

                  /// RENT DETAILS
                  _sectionTitle("Rental Details"),
                  const SizedBox(height: 10),
                  _rentalCard(),

                  const SizedBox(height: 24),

                  /// OWNER
                  _sectionTitle("Owner Details"),
                  const SizedBox(height: 10),
                  _ownerCard(),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _featureRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _Feature(Icons.bed, "${widget.property.bedrooms ?? '-'} Beds"),
        _Feature(Icons.bathtub, "${widget.property.bathrooms ?? '-'} Baths"),
        _Feature(Icons.square_foot,
            "${widget.property.superArea?.toStringAsFixed(0) ?? '-'} sqft"),
      ],
    );
  }

  Widget _highlightCard() {
    return _card([
      _DetailRow("Floor",
          "${widget.property.floorNumber ?? "-"} / ${widget.property.totalFloors ?? "-"}"),
      _DetailRow("Facing", widget.property.facing ?? "-"),
      _DetailRow("Property Age",
          widget.property.propertyAge != null
              ? "${widget.property.propertyAge} Years"
              : "-"),
      _DetailRow("Parking",
          widget.property.parkingCount != null
              ? "${widget.property.parkingCount}"
              : "-"),
      _DetailRow("Parking Type", widget.property.parkingType ?? "-"),
    ]);
  }

  Widget _rentalCard() {
    return _card([
      _DetailRow("Monthly Rent", rent),
      _DetailRow(
          "Security Deposit",
          widget.property.securityDeposit != null
              ? "₹ ${NumberFormat('#,##,###').format(widget.property.securityDeposit)}"
              : "-"),
      _DetailRow(
          "Brokerage",
          widget.property.brokerage != null
              ? "₹ ${NumberFormat('#,##,###').format(widget.property.brokerage)}"
              : "No Brokerage"),
      _DetailRow(
        "Furnishing",
        widget.property.furnishing ?? "-",
      ),
      _DetailRow("Lease Duration", widget.property.leaseDuration ?? "-"),
      _DetailRow("Notice Period", widget.property.noticePeriod ?? "-"),
      _DetailRow("Preferred Tenants",
          widget.property.preferredTenants ?? "Any"),

      _DetailRow(
          "Maintenance Included",
          widget.property.maintenanceIncluded == true ? "Yes" : "No"),
    ]);
  }

  Widget _ownerCard() {
    return _card([
      _DetailRow("Posted By", widget.property.postedBy ?? "-"),
      _DetailRow("Builder", widget.property.builderName ?? "-"),
      _DetailRow("Verified", widget.property.verified == true ? "Yes" : "No"),
      _DetailRow("RERA Approved",
          widget.property.reraApproved == true ? "Yes" : "No"),
      if (widget.property.reraNumber != null)
        _DetailRow("RERA Number", widget.property.reraNumber!),
      _DetailRow("Contact", widget.property.contactNumber),
    ]);
  }

  Widget _card(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: children),
    );
  }

  Widget _bottomButtons() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.call),
              label: const Text("Call Owner"),
              onPressed: () {},
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.chat),
              label: const Text("WhatsApp"),
              onPressed: () {},
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
}

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