import 'package:flutter/material.dart';
import 'package:ProFinDo/theme/app_colors.dart';

class PropertyFilterDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onApply;
  final Map<String, dynamic>? initialFilters;

  const PropertyFilterDialog({
    super.key,
    required this.onApply,
    this.initialFilters,
  });

  @override
  State<PropertyFilterDialog> createState() => _PropertyFilterDialogState();
}

class _PropertyFilterDialogState extends State<PropertyFilterDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  final cityController = TextEditingController();
  final locationController = TextEditingController();

  RangeValues priceRange = const RangeValues(1000.0, 100000000.0);
  RangeValues areaRange = const RangeValues(100.0, 10000.0);

  double bedrooms = 1.0;
  double bathrooms = 1.0;

  String? selectedType;
  String? selectedStatus;

  final List<String> types = ["Apartment", "Villa", "Plot", "Office"];
  final List<String> statusList = ["Ready", "Under Construction"];
  final List<String> amenities = [
    "Parking",
    "Lift",
    "Gym",
    "Garden",
    "Security",
    "Pool"
  ];
  final Set<String> selectedAmenities = {};

  // ================= SAFE CONVERTER =================
  double _toDouble(dynamic v, double fallback) {
    if (v == null) return fallback;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return fallback;
  }

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 250));
    _scale = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _controller.forward();

    if (widget.initialFilters != null) {
      final f = widget.initialFilters!;
      cityController.text = f["city"] ?? "";
      locationController.text = f["location"] ?? "";
      selectedType = f["type"];
      selectedStatus = f["constructionStatus"];

      priceRange = RangeValues(
        _toDouble(f["minPrice"], 1000.0),
        _toDouble(f["maxPrice"], 100000000.0),
      );

      areaRange = RangeValues(
        _toDouble(f["minArea"], 100.0),
        _toDouble(f["maxArea"], 10000.0),
      );

      bedrooms = _toDouble(f["bedrooms"], 1.0);
      bathrooms = _toDouble(f["bathrooms"], 1.0);

      if (f["amenity"] != null) {
        selectedAmenities.addAll(f["amenity"].split(","));
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    cityController.dispose();
    locationController.dispose();
    super.dispose();
  }

  // ================= FORMATTERS =================

  String formatIndianNumber(num value) {
    final str = value.toInt().toString();
    if (str.length <= 3) return str;
    final last3 = str.substring(str.length - 3);
    final rest = str.substring(0, str.length - 3);
    final reg = RegExp(r'\B(?=(\d{2})+(?!\d))');
    return rest.replaceAll(reg, ",") + "," + last3;
  }

  String formatPrice(num value) {
    if (value >= 10000000) {
      return "₹${(value / 10000000).toStringAsFixed(1)} Cr";
    } else if (value >= 100000) {
      return "₹${(value / 100000).toStringAsFixed(1)} Lakh";
    } else {
      return "₹${formatIndianNumber(value)}";
    }
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ScaleTransition(
        scale: _scale,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Filters",
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),

              _textField("City", cityController),
              _textField("Location", locationController),
              _dropdown("Type", types, selectedType,
                      (v) => setState(() => selectedType = v)),

              _section("Price Range"),
              Text(
                "${formatPrice(priceRange.start)} - ${formatPrice(priceRange.end)}",
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              RangeSlider(
                values: priceRange,
                min: 0.0,
                max: 100000000.0,
                divisions: 1000,
                activeColor: AppColors.primary,
                labels: RangeLabels(
                  formatPrice(priceRange.start),
                  formatPrice(priceRange.end),
                ),
                onChanged: (v) => setState(() => priceRange = v),
              ),

              _section("Area (sqft)"),
              Text(
                "${areaRange.start.toStringAsFixed(1)} - ${areaRange.end.toStringAsFixed(1)} sqft",
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              RangeSlider(
                values: areaRange,
                min: 0.0,
                max: 10000.0,
                divisions: 100,
                activeColor: AppColors.primary,
                labels: RangeLabels(
                  areaRange.start.toStringAsFixed(1),
                  areaRange.end.toStringAsFixed(1),
                ),
                onChanged: (v) => setState(() => areaRange = v),
              ),

              _section("Bedrooms: ${bedrooms.toInt()}"),
              Slider(
                value: bedrooms,
                min: 1.0,
                max: 10.0,
                divisions: 9,
                activeColor: AppColors.primary,
                label: bedrooms.toInt().toString(),
                onChanged: (v) => setState(() => bedrooms = v),
              ),

              _section("Bathrooms: ${bathrooms.toInt()}"),
              Slider(
                value: bathrooms,
                min: 1.0,
                max: 10.0,
                divisions: 9,
                activeColor: AppColors.primary,
                label: bathrooms.toInt().toString(),
                onChanged: (v) => setState(() => bathrooms = v),
              ),

              _section("Construction Status"),
              Wrap(
                spacing: 8,
                children: statusList.map((s) {
                  final selected = selectedStatus == s;
                  return ChoiceChip(
                    label: Text(s),
                    selected: selected,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(color: selected ? Colors.white : null),
                    onSelected: (_) => setState(() => selectedStatus = s),
                  );
                }).toList(),
              ),

              _section("Amenities"),
              Wrap(
                spacing: 8,
                children: amenities.map((a) {
                  final selected = selectedAmenities.contains(a);
                  return FilterChip(
                    label: Text(a),
                    selected: selected,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(color: selected ? Colors.white : null),
                    onSelected: (v) {
                      setState(() {
                        v ? selectedAmenities.add(a) : selectedAmenities.remove(a);
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _reset,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Reset"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _apply,
                    child: const Text("Search"),
                  ),
                ),
              ])
            ]),
          ),
        ),
      ),
    );
  }

  // ================= LOGIC =================

  void _reset() {
    cityController.clear();
    locationController.clear();
    priceRange = const RangeValues(1000.0, 100000000.0);
    areaRange = const RangeValues(100.0, 10000.0);
    bedrooms = 1.0;
    bathrooms = 1.0;
    selectedType = null;
    selectedStatus = null;
    selectedAmenities.clear();
    setState(() {});
  }

  void _apply() {
    widget.onApply({
      "city": cityController.text.trim(),
      "location": locationController.text.trim(),
      "type": selectedType,
      "constructionStatus": selectedStatus,
      "minPrice": priceRange.start,
      "maxPrice": priceRange.end,
      "minArea": areaRange.start,
      "maxArea": areaRange.end,
      "bedrooms": bedrooms.toInt(),
      "bathrooms": bathrooms.toInt(),
      "amenity": selectedAmenities.isNotEmpty ? selectedAmenities.join(",") : null,
    });

    Navigator.pop(context);
  }

  // ================= HELPERS =================

  Widget _section(String title) => Padding(
    padding: const EdgeInsets.only(top: 12, bottom: 6),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
    ),
  );

  Widget _textField(String hint, TextEditingController c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: TextField(
        controller: c,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _dropdown(String label, List items, value, ValueChanged onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: DropdownButtonFormField(
        value: value,
        decoration: InputDecoration(
          hintText: label,
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text("$e"))).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
