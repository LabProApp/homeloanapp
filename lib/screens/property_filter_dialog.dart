import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../services/state_api_service.dart';
import '../commons/common_widget.dart';
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

class _PropertyFilterBottomSheetState
    extends State<PropertyFilterDialog> {
  static const double vGap = 6;

  final locationController = TextEditingController();

  RangeValues priceRange =
  const RangeValues(1000.0, 100000000.0);
  RangeValues areaRange =
  const RangeValues(100.0, 10000.0);

  double bedrooms = 1.0;
  double bathrooms = 1.0;

  String? selectedType;
  String? selectedStatus;

  String? selectedCategory;
  String? selectedListingType;

  MasterValue? selectedState;
  MasterValue? selectedCity;

  List<MasterValue> states = [];
  List<MasterValue> cities = [];

  final List<String> residentialTypes = [
    "HOUSE",
    "PLOT",
    "APARTMENT",
    "BUILDER FLOOR",
    "PG",
  ];

  final List<String> commercialTypes = [
    "SHOP",
    "OFFICE",
    "SHOWROOM",
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

  List<String> get filteredTypes {
    if (selectedCategory == "Residential") return residentialTypes;
    if (selectedCategory == "Commercial") return commercialTypes;
    return [...residentialTypes, ...commercialTypes];
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
      selectedCategory = f["category"];
      selectedListingType = f["rentOrSale"];

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

      if (f["amenity"] != null && f["amenity"] is String) {
        selectedAmenities.addAll(
            (f["amenity"] as String).split(","));
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
      locationController.clear();
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
      inactiveTrackColor:
      AppColors.primary,
      overlayColor: Colors.orange,
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
          decoration:  BoxDecoration(
            color: AppColors.primary.withOpacity(0.05),
            borderRadius:
            BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),

              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [

                      _section("Category"),
                      Wrap(
                        spacing: 6,
                        children: ["Residential", "Commercial"]
                            .map((e) {
                          return ChoiceChip(
                            label: Text(e),
                            selected: selectedCategory == e,
                            onSelected: (_) {
                              setState(() {
                                selectedCategory = e;
                                final list =
                                e == "Residential"
                                    ? residentialTypes
                                    : commercialTypes;
                                selectedType = list.first;
                              });
                            },
                          );
                        }).toList(),
                      ),

                      _section("Listing Type"),
                      Wrap(
                        spacing: 6,
                        children: ["Sale", "Rent"].map((e) {
                          return ChoiceChip(
                            label: Text(e),
                            selected:
                            selectedListingType == e,
                            onSelected: (_) => setState(
                                    () => selectedListingType = e),
                          );
                        }).toList(),
                      ),

                      _loadingStates
                          ? const CircularProgressIndicator()
                          : _fancyDropdown<MasterValue>(
                        items: states,
                        value: selectedState,
                        hint: "State",
                        itemLabel: (s) => s.value,
                        onChanged: (v) {
                          setState(() {
                            selectedState = v;
                            selectedCity = null;
                            cities = [];
                            locationController.clear();
                          });
                          if (v != null) {
                            _loadCities(v.id);
                          }
                        },
                      ),

                      _loadingCities
                          ? const CircularProgressIndicator()
                          : _fancyDropdown<MasterValue>(
                        items: cities,
                        value: selectedCity,
                        hint: "City",
                        itemLabel: (c) => c.value,
                        onChanged: (v) {
                          setState(() {
                            selectedCity = v;
                            locationController.clear();
                          });
                        },
                      ),

                      _textField("Location", locationController),

                      _fancyDropdown<String>(
                        items: filteredTypes,
                        value: selectedType,
                        hint: "Type",
                        itemLabel: (t) => t,
                        onChanged: selectedCategory == null
                            ? null
                            : (v) => setState(
                                () => selectedType = v),
                      ),

                      _section("Price"),
                      _buildRangeSlider(
                        values: priceRange,
                        min: 0,
                        max: 100000000,
                        divisions: 1000,
                        labelFormatter: _fmtCurrency,
                        onChanged: (v) =>
                            setState(() => priceRange = v),
                      ),

                      _section("Area"),
                      _buildRangeSlider(
                        values: areaRange,
                        min: 0,
                        max: 10000,
                        divisions: 100,
                        labelFormatter: (v) =>
                            v.toInt().toString(),
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
                            label: Text(s),
                            selected: selectedStatus == s,
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
                            label: Text(a),
                            selected:
                            selectedAmenities.contains(a),
                            onSelected: (v) {
                              setState(() {
                                v
                                    ? selectedAmenities.add(a)
                                    : selectedAmenities
                                    .remove(a);
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
                child: AppButton(
                  text: "Search",
                  onTap: _apply,
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
      "city": selectedCity?.value,
      "location": locationController.text.trim(),
      "type": selectedType,
      "category": selectedCategory,
      "rentOrSale": selectedListingType,
      "constructionStatus": selectedStatus,
      "minPrice": priceRange.start,
      "maxPrice": priceRange.end,
      "minArea": areaRange.start,
      "maxArea": areaRange.end,
      "bedrooms": bedrooms.toInt(),
      "bathrooms": bathrooms.toInt(),
      "amenity":
      selectedAmenities.isNotEmpty
          ? selectedAmenities.join(",")
          : null,
    });

    Navigator.pop(context);
  }

  Widget _section(String title) => Padding(
    padding: const EdgeInsets.symmetric(vertical: vGap),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Text(title),
    ),
  );

  Widget _textField(String hint, TextEditingController c) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: vGap),
      child: TextField(
        controller: c,
        decoration: InputDecoration(hintText: hint),
      ),
    );
  }

  Widget _fancyDropdown<T>({
    required List<T> items,
    required T? value,
    required String hint,
    required String Function(T) itemLabel,
    required ValueChanged<T?>? onChanged,
  }) {
    return DropdownButton2<T>(
      isExpanded: true,
      value: value,
      hint: Text(hint),
      items: items
          .map((e) => DropdownMenuItem<T>(
        value: e,
        child: Text(itemLabel(e)),
      ))
          .toList(),
      onChanged: onChanged,
    );
  }
}