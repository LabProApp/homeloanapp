import 'package:flutter/material.dart';
import 'package:property/models/property_model.dart';
import 'package:property/theme/app_colors.dart';
import 'package:property/utility/amenity_icon.dart';
import 'package:readmore/readmore.dart';

class PropertyDetailScreen extends StatefulWidget {
  final PropertyModel property;

  const PropertyDetailScreen({super.key, required this.property});

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: CustomScrollView(
        slivers: [
          /// IMAGE SLIDER
          SliverAppBar(
            /*expandedHeight: 280,
            pinned: true,
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
            */
            backgroundColor: Colors.white,
            elevation: 1,
            pinned: true,
            expandedHeight: 260,

            /// Title appears ONLY after scroll
            title: const Text(
              "Property Details",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),

            /// Hide title initially
            centerTitle: false,
            foregroundColor: Colors.black,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  PageView.builder(
                    itemCount: widget.property.images.length,
                    onPageChanged: (i) {
                      setState(() => currentIndex = i);
                    },
                    itemBuilder: (_, i) {
                      return Image.network(
                        widget.property.images[i],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                        const Center(child: Icon(Icons.broken_image, size: 40)),
                      );
                    },
                  ),

                  /// DOT INDICATOR
                  Positioned(
                    bottom: 14,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        widget.property.images.length,
                            (i) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: currentIndex == i ? 8 : 6,
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
                  /// PRICE
                  Text(
                    widget.property.price,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  /// ADDRESS
                  Text(
                    widget.property.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    widget.property.subtitle,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),

                  const SizedBox(height: 16),

                  /// FEATURES
                  _featureRow(),

                  const SizedBox(height: 24),

                  /// ABOUT
                  _sectionTitle("About This Home"),
                  const SizedBox(height: 6),
                  /*Text(
                    'widget.property.description' ??
                        "Beautiful modern home with premium amenities and spacious interiors.",
                    style: TextStyle(color: Colors.grey.shade700),
                  ),*/
                  ReadMoreText(
                    "Beautiful modern home with premium amenities and spacious interiors. "
                        "This stunning property offers a perfect blend of luxury and comfort. "
                        "Featuring high-end finishes, open living spaces, natural lighting, "
                        "and a thoughtfully designed layout ideal for family living."
                        "Beautiful modern home with premium amenities and spacious interiors. "
                        "This stunning property offers a perfect blend of luxury and comfort. "
                        "Featuring high-end finishes, open living spaces, natural lighting, "
                        "and a thoughtfully designed layout ideal for family living.",
                    trimLines: 3,
                    trimMode: TrimMode.Line,
                    trimCollapsedText: " Read More",
                    trimExpandedText: " Read Less",
                    style: const TextStyle(fontSize: 14),
                    moreStyle: const TextStyle(color: Colors.blue),
                    lessStyle: const TextStyle(color: Colors.blue),
                  ),

                  const SizedBox(height: 24),

                  /// AMENITIES
                  _sectionTitle("Amenities"),
                  const SizedBox(height: 10),
                  /*Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.property.amenities
                        .map((e) => Chip(label: Text(e)))
                        .toList(),
                  ),*/
                  Wrap(
                    spacing: 20,
                    runSpacing: 16,
                    alignment: WrapAlignment.start,
                    children: widget.property.amenities.map((amenity) {
                      return SizedBox(
                        width: 70,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              AmenityIcon.getIcon(amenity),
                              size: 26,
                              color: Colors.grey.shade700,
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

                  const SizedBox(height: 24),

                  /// PROPERTY DETAILS
                  _sectionTitle("Property Details"),
                  const SizedBox(height: 10),
                  _detailsCard(),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ---------------- UI HELPERS ----------------

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _featureRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: const [
        _Feature(Icons.bed, "4 Beds"),
        _Feature(Icons.bathtub, "3.5 Baths"),
        _Feature(Icons.square_foot, "3,250 Sqft"),
        _Feature(Icons.garage, "2 Garage"),
      ],
    );
  }

  Widget _detailsCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        children: [
          _DetailRow("Property Type", "Single Family"),
          _DetailRow("Year Built", "2018"),
          _DetailRow("Lot Size", "0.35 acres"),
          _DetailRow("HOA Fees", "\$250/month"),
          _DetailRow("Property Tax", "\$28,500/year"),
          _DetailRow("MLS #", "ML81923456"),
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
        Icon(icon, color:AppColors.accent),
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
          Text(title, style: TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}


