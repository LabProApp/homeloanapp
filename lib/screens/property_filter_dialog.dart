import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../services/state_api_service.dart';

class PropertyFilterDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onApply;
  final Map<String, dynamic>? initialFilters;

  const PropertyFilterDialog({
    super.key,
    required this.onApply,
    this.initialFilters,
  });

  static void show(BuildContext context,
      {required Function(Map<String, dynamic>) onApply,
        Map<String, dynamic>? initialFilters}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      builder: (_) => PropertyFilterDialog(
        onApply: onApply,
        initialFilters: initialFilters,
      ),
    );
  }

  @override
  State<PropertyFilterDialog> createState() =>
      _PropertyFilterBottomSheetState();
}

class _PropertyFilterBottomSheetState extends State<PropertyFilterDialog> {
  static const double vGap = 6;

  final locationController = TextEditingController();

  RangeValues priceRange = const RangeValues(1000.0, 100000000.0);
  RangeValues areaRange = const RangeValues(100.0, 10000.0);

  double bedrooms = 1.0;
  double bathrooms = 1.0;

  String? selectedType;
  String? selectedStatus;

  MasterValue? selectedState;
  String? selectedCity;

  List<MasterValue> states = [];
  List<String> cities = [];

  final List<String> propertyTypes = [
    "HOUSE",
    "PLOT",
    "APARTMENT",
    "BUILDER FLOOR",
    "SHOP",
    "OFFICE",
    "SHOWROOM",
    "PG",
    "CO WORKING",
    "AGRICULTURAL",
  ];

  final List<String> statusList = [
    "Ready to Move",
    "Under Construction",
    "New Launch",
    "ReSale"
  ];

  final List<String> amenities = [
    "Parking",
    "Lift",
    "Gym",
    "Garden",
    "Security",
    "Pool"
  ];

  final Set<String> selectedAmenities = {};

  bool _loadingStates = true;
  bool _loadingCities = false;

  final NumberFormat _currencyFmt = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  String _fmtCurrency(double v) => _currencyFmt.format(v);

  double _toDouble(dynamic v, double fallback) {
    if (v == null) return fallback;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return fallback;
  }

  @override
  void initState() {
    super.initState();
    _loadStates();

    if (widget.initialFilters != null) {
      final f = widget.initialFilters!;
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

  Future<void> _loadStates() async {
    setState(() => _loadingStates = true);
    try {
      states = await MasterService.getStates();
    } finally {
      if (mounted) setState(() => _loadingStates = false);
    }
  }

  Future<void> _loadCities(int stateId) async {
    setState(() {
      _loadingCities = true;
      cities = [];
      selectedCity = null;
    });
    try {
      cities = await MasterService.getCities(stateId);
    } finally {
      if (mounted) setState(() => _loadingCities = false);
    }
  }

  @override
  void dispose() {
    locationController.dispose();
    super.dispose();
  }

  SliderThemeData _sliderTheme(BuildContext context) {
    return SliderTheme.of(context).copyWith(
      thumbColor: Colors.orange,
      activeTrackColor: AppColors.primary,
      inactiveTrackColor: AppColors.primary.withOpacity(0.3),
      tickMarkShape: const RoundSliderTickMarkShape(tickMarkRadius: 3),
      activeTickMarkColor: Colors.orange,
      inactiveTickMarkColor: Colors.grey.shade300,
      overlayColor: Colors.orange.withOpacity(0.15),
    );
  }

  Widget _buildRangeSlider({
    required RangeValues values,
    required double min,
    required double max,
    required int divisions,
    required String Function(double) labelFormatter,
    required ValueChanged<RangeValues> onChanged,
  }) {
    return SliderTheme(
      data: _sliderTheme(context),
      child: RangeSlider(
        values: values,
        min: min,
        max: max,
        divisions: divisions,
        labels: RangeLabels(
          labelFormatter(values.start),
          labelFormatter(values.end),
        ),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildSlider({
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    return SliderTheme(
      data: _sliderTheme(context),
      child: Slider(
        value: value,
        min: min,
        max: max,
        divisions: divisions,
        onChanged: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 8),

              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      _loadingStates
                          ? const CircularProgressIndicator()
                          : _fancyDropdown<MasterValue>(
                        items: states,
                        value: selectedState,
                        hint: "State",
                        itemLabel: (s) => s.value,
                        onChanged: (v) {
                          setState(() => selectedState = v);
                          if (v != null) _loadCities(v.id);
                        },
                      ),

                      _loadingCities
                          ? const CircularProgressIndicator()
                          : _fancyDropdown<String>(
                        items: cities,
                        value: selectedCity,
                        hint: "City",
                        itemLabel: (c) => c,
                        onChanged: (v) =>
                            setState(() => selectedCity = v),
                      ),

                      _textField("Location", locationController),

                      _fancyDropdown<String>(
                        items: propertyTypes,
                        value: selectedType,
                        hint: "Type",
                        itemLabel: (t) => t,
                        onChanged: (v) => setState(() => selectedType = v),
                      ),

                      _section("Price"),
                      _buildRangeSlider(
                        values: priceRange,
                        min: 0,
                        max: 100000000,
                        divisions: 1000,
                        labelFormatter: (v) => _fmtCurrency(v),
                        onChanged: (v) =>
                            setState(() => priceRange = v),
                      ),

                      _section("Area"),
                      _buildRangeSlider(
                        values: areaRange,
                        min: 0,
                        max: 10000,
                        divisions: 100,
                        labelFormatter: (v) => v.toInt().toString(),
                        onChanged: (v) =>
                            setState(() => areaRange = v),
                      ),

                      _section("Bedrooms: ${bedrooms.toInt()}"),
                      _buildSlider(
                        value: bedrooms,
                        min: 0,
                        max: 12,
                        divisions: 12,
                        onChanged: (v) =>
                            setState(() => bedrooms = v),
                      ),

                      _section("Bathrooms: ${bathrooms.toInt()}"),
                      _buildSlider(
                        value: bathrooms,
                        min: 0,
                        max: 12,
                        divisions: 12,
                        onChanged: (v) =>
                            setState(() => bathrooms = v),
                      ),

                      _section("Status"),
                      Wrap(
                        spacing: 6,
                        children: statusList.map((s) {
                          return ChoiceChip(
                            label:
                            Text(s, style: const TextStyle(fontSize: 11)),
                            selected: selectedStatus == s,
                            selectedColor:
                            AppColors.primary.withOpacity(0.2),
                            onSelected: (_) =>
                                setState(() => selectedStatus = s),
                          );
                        }).toList(),
                      ),

                      _section("Amenities"),
                      Wrap(
                        spacing: 6,
                        children: amenities.map((a) {
                          return FilterChip(
                            label: Text(a,
                                style: const TextStyle(fontSize: 11)),
                            selected: selectedAmenities.contains(a),
                            selectedColor:
                            AppColors.primary.withOpacity(0.2),
                            onSelected: (v) {
                              setState(() {
                                v
                                    ? selectedAmenities.add(a)
                                    : selectedAmenities.remove(a);
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide.none,
                        ),
                        child: const Text("Close"),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        onPressed: _apply,
                        child: const Text("Search"),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  void _apply() {
    widget.onApply({
      "state": selectedState?.value,
      "city": selectedCity,
      "location": locationController.text.trim(),
      "type": selectedType,
      "constructionStatus": selectedStatus,
      "minPrice": priceRange.start,
      "maxPrice": priceRange.end,
      "minArea": areaRange.start,
      "maxArea": areaRange.end,
      "bedrooms": bedrooms.toInt(),
      "bathrooms": bathrooms.toInt(),
      "amenity":
      selectedAmenities.isNotEmpty ? selectedAmenities.join(",") : null,
    });
    Navigator.pop(context);
  }

  Widget _section(String title) => Padding(
    padding: const EdgeInsets.symmetric(vertical: vGap),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Text(title,
          style:
          const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
    ),
  );

  Widget _textField(String hint, TextEditingController c) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: vGap),
      child: TextField(
        controller: c,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          hintText: hint,
          isDense: true,
          contentPadding:
          const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          filled: true,
          fillColor: AppColors.primary.withOpacity(0.06),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _fancyDropdown<T>({
    required List<T> items,
    required T? value,
    required String hint,
    required String Function(T) itemLabel,
    required ValueChanged<T?> onChanged,
  }) {
    const double itemH = 38;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: vGap),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<T>(
          isExpanded: true,
          value: value,
          hint: Text(hint, style: const TextStyle(fontSize: 13)),
          items: items
              .map((e) => DropdownMenuItem<T>(
            value: e,
            child: Text(itemLabel(e),
                style: const TextStyle(fontSize: 13)),
          ))
              .toList(),
          onChanged: onChanged,
          buttonStyleData: ButtonStyleData(
            height: itemH,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppColors.primary.withOpacity(0.06),
            ),
          ),
          dropdownStyleData: DropdownStyleData(
            maxHeight: itemH * 5,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
          ),
          menuItemStyleData: const MenuItemStyleData(height: itemH),
          iconStyleData: const IconStyleData(
            icon: Icon(Icons.keyboard_arrow_down),
            iconSize: 20,
          ),
        ),
      ),
    );
  }
}
