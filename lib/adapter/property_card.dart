import 'package:flutter/material.dart';
import 'package:property/models/property_model.dart';
import 'package:cached_network_image/cached_network_image.dart';



class PropertyCard extends StatefulWidget {
  final PropertyModel property;

  const PropertyCard({super.key, required this.property});

  @override
  State<PropertyCard> createState() => _PropertyCardState();
}

class _PropertyCardState extends State<PropertyCard> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // IMAGE SLIDER
          Stack(
            children: [
              SizedBox(
                height: 220,
                child: PageView.builder(
                  itemCount: widget.property.images.length,
                  onPageChanged: (i) => setState(() => currentIndex = i),
                  itemBuilder: (_, i) => ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                    child: FadeInImage.assetNetwork(
                      placeholder: 'assets/images/house_placeholder.jpg',
                      image: widget.property.images[i],
                      fit: BoxFit.cover,
                      fadeInDuration: const Duration(milliseconds: 150),
                      imageCacheWidth: 800,
                      imageCacheHeight: 500,
                    ),
                  ),
                ),
              ),
              // TAGS
              Positioned(
                top: 12,
                left: 12,
                child: Row(
                  children: _tag("ZERO BROKERAGE"),
                ),
              ),

              Positioned(
                top: 12,
                right: 12,
                child: Icon(Icons.favorite_border, color: Colors.white),
              ),

              // DOT INDICATOR
              Positioned(
                bottom: 10,
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
                        color: currentIndex == i ? Colors.white : Colors.white54,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // DETAILS
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.property.title,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (widget.property.isNewBooking)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text("NEW BOOKING", style: TextStyle(color: Colors.blue)),
                      )
                  ],
                ),

                const SizedBox(height: 6),
                Text(widget.property.subtitle, style: TextStyle(color: Colors.grey.shade700)),
                const SizedBox(height: 4),
                Text(widget.property.type),
                const SizedBox(height: 8),

                Text(
                  widget.property.price,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                // NEARBY TAGS
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: widget.property.nearby
                      .map((e) => Chip(label: Text(e)))
                      .toList(),
                ),

                const SizedBox(height: 14),

                // BUTTONS
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.download),
                        label: const Text("Brochure"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        child: const Text("View Number"),
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

  List<Widget> _tag(String text) {
    return [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ),
    ];
  }
}
