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
    if (widget.property.documentList?.isNotEmpty == true) {
      return widget.property.documentList!
          .map((e) => e.docUrl)
          .whereType<String>()
          .toList();
    }
    return [
      'assets/images/house1.jpg',
      'assets/images/house2.jpg',
      'assets/images/house3.jpg',
    ];
  }

  List<String> get _amenities =>
      widget.property.amenitiesAsList?.map((e) => e.toString()).toList() ?? [];

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          /// IMAGE CAROUSEL
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

          /// IMAGE GRADIENT (iOS STYLE)
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black54,
                  ],
                ),
              ),
            ),
          ),

          /// PAGE INDICATORS
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

          /// ACTION ICONS
          Positioned(
            top: 12,
            right: 12,
            child: Column(
              children: [
                _iconCircle(Icons.favorite_border, _openWhatsApp),
                const SizedBox(height: 10),
                _iconCircle(Icons.message, _openWhatsApp),
                const SizedBox(height: 10),
                _iconCircle(Icons.phone, _callOwner),
                const SizedBox(height: 10),
                _iconCircle(Icons.share, _shareProperty),
              ],
            ),
          ),

          /// DETAILS PANEL (NO BLUR)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: _detailsSection(),
            ),
          ),
        ],
      ),
    );
  }

  /// DETAILS
  Widget _detailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                widget.property.title ?? "-",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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

        Text(
          "${widget.property.city ?? "-"} | ${widget.property.state ?? "-"}",
          style: const TextStyle(color: Colors.white70),
        ),

        const SizedBox(height: 6),

        Text(
          widget.property.price != null
              ? "₹ ${NumberFormat('#,##,###').format(widget.property.price)}"
              : "-",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),

        if (widget.showAmenitiesExpandable && _amenities.isNotEmpty)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () =>
                  setState(() => _amenitiesExpanded = !_amenitiesExpanded),
              child: Text(
                _amenitiesExpanded ? "Hide Amenities" : "Show Amenities",
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }

  Widget _placeholderImage() {
    return Image.asset(
      'assets/images/house1.jpg',
      fit: BoxFit.cover,
    );
  }

  Future<void> _openWhatsApp() async {
    final url =
    Uri.parse("https://wa.me/${widget.property.contactNumber}");
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  void _shareProperty() {
    Share.share(widget.property.title ?? "-");
  }

  Future<void> _callOwner() async {
    await launchUrl(Uri.parse("tel:${widget.property.contactNumber}"));
  }

  Widget _iconCircle(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 18,
        backgroundColor: Colors.black26,
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
