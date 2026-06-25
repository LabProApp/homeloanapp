import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../services/state_api_service.dart';
import '../commons/common_widget.dart';

/// Filter bottom-sheet shared by both Buy/Sell and Rent/PG listing screens.
///
/// Sections are grouped by logical concern and adapt based on listing type:
///   1  Listing      — Category + Property Type
///   2  Location     — State → City → Locality
///   3  Budget       — Price range
///   4  Size & Rooms — Area range + Bedrooms + Bathrooms (Residential only)
///   5  Property Details — Construction Status + Furnishing + Ownership
///   6  Rental Terms — Preferred Tenants + Available From  (Rent only)
///   7  Amenities    — multi-select chips (same options as Add Property screen)
///
/// Listing type (SALE / RENT) is NOT shown as a user-editable option — the
/// calling screen owns that choice.  It is still forwarded in the filter map
/// so the listing screen can include it in the API call unchanged.
class PropertyFilterDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onApply;
  final Map<String, dynamic>? initialFilters;

  const PropertyFilterDialog({
    super.key,
    required this.onApply,
    this.initialFilters,
  });

  static void show(
    BuildContext context, {
    required Function(Map<String, dynamic>) onApply,
    Map<String, dynamic>? initialFilters,
  }) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
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
  State<PropertyFilterDialog> createState() => _PropertyFilterDialogState();
}

class _PropertyFilterDialogState extends State<PropertyFilterDialog> {
  final _locationCtrl = TextEditingController();

  RangeValues _priceRange = const RangeValues(1000.0, 100000000.0);
  RangeValues _areaRange  = const RangeValues(100.0,  10000.0);
  bool _priceChanged = false;
  bool _areaChanged  = false;

  int _bedrooms  = 0;
  int _bathrooms = 0;

  // Listing type is read-only from the caller; not shown to the user.
  String? _listingType;

  String? _category;
  String? _type;
  String? _status;        // constructionStatus
  String? _furnishing;
  String? _ownership;     // ownershipType
  String? _preferredTenants;
  String? _availability;  // noticePeriod

  MasterValue? _selectedState;
  MasterValue? _selectedCity;
  List<MasterValue> _states = [];
  List<MasterValue> _cities = [];
  bool _loadingStates = true;
  bool _loadingCities = false;

  final Set<String> _amenities = {};

  // ── Derived ─────────────────────────────────────────────────────────────────
  bool get _isRent => _listingType?.toUpperCase() == 'RENT';

  // ── Option lists — kept in sync with property_add_screen.dart ───────────────
  static const _residentialTypes = [
    'APARTMENT', 'HOUSE', 'BUILDER FLOOR', 'PLOT', 'PG',
  ];
  static const _commercialTypes = [
    'SHOP', 'OFFICE', 'SHOWROOM', 'CO WORKING', 'AGRICULTURAL',
  ];
  static const _statusList = [
    'Ready to Move', 'Under Construction', 'New Launch', 'Resale',
  ];
  // Matches property_add_screen._furnishingOptions exactly (no hyphen in "Semi Furnished").
  static const _furnishingList = ['Furnished', 'Semi Furnished', 'Unfurnished'];
  static const _ownershipList  = ['Freehold', 'Leasehold'];
  static const _tenantList     = ['Family', 'Bachelors', 'Anyone'];
  // Matches property_add_screen._availableFromOptions exactly.
  static const _availabilityList = ['Immediate', 'Within 15 Days', 'Within 30 Days'];
  // Matches property_add_screen._amenityOptions exactly.
  static const _amenityList = [
    'Club House', 'Lift', 'Power Backup', 'Security',
    'Gym', 'Swimming Pool', 'Garden', 'Parking', 'CCTV',
  ];

  static final _currencyFmt = NumberFormat.currency(
    locale: 'en_IN', symbol: '₹', decimalDigits: 0,
  );

  String _fmtCurrency(double v) => _currencyFmt.format(v);

  double _toDouble(dynamic v, double fallback) {
    if (v == null) return fallback;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return fallback;
  }

  List<String> get _filteredTypes {
    if (_category == 'Residential') return _residentialTypes;
    if (_category == 'Commercial')  return _commercialTypes;
    return [..._residentialTypes, ..._commercialTypes];
  }

  // ── Lifecycle ────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _loadStates();
    final f = widget.initialFilters;
    if (f != null) {
      _listingType      = f['rentOrSale'] as String?;
      _locationCtrl.text = f['location'] as String? ?? '';
      _type             = f['type'] as String?;
      _status           = f['constructionStatus'] as String?;
      _category         = f['category'] as String?;
      _furnishing       = f['furnishing'] as String?;
      _ownership        = f['ownershipType'] as String?;
      _preferredTenants = f['preferredTenants'] as String?;
      _availability     = f['availability'] as String?;
      _priceRange = RangeValues(
        _toDouble(f['minPrice'], 1000.0),
        _toDouble(f['maxPrice'], 100000000.0),
      );
      _areaRange = RangeValues(
        _toDouble(f['minArea'], 100.0),
        _toDouble(f['maxArea'], 10000.0),
      );
      _priceChanged = f['minPrice'] != null || f['maxPrice'] != null;
      _areaChanged  = f['minArea']  != null || f['maxArea']  != null;
      _bedrooms  = (f['bedrooms']  as int?) ?? 0;
      _bathrooms = (f['bathrooms'] as int?) ?? 0;
      if (f['amenity'] is String) {
        _amenities.addAll((f['amenity'] as String).split(',').map((e) => e.trim()));
      }
    }
  }

  @override
  void dispose() {
    _locationCtrl.dispose();
    super.dispose();
  }

  // ── API helpers ──────────────────────────────────────────────────────────────

  Future<void> _loadStates() async {
    setState(() => _loadingStates = true);
    try {
      _states = await MasterService.getStates();
      final f = widget.initialFilters;
      if (f != null && f['state'] != null) {
        _selectedState = _states.firstWhere(
          (s) => s.value == f['state'],
          orElse: () => _states.first,
        );
        await _loadCities(_selectedState!.id, applyInitial: true);
      }
    } finally {
      if (mounted) setState(() => _loadingStates = false);
    }
  }

  Future<void> _loadCities(int stateId, {bool applyInitial = false}) async {
    setState(() { _loadingCities = true; _cities = []; _selectedCity = null; });
    try {
      _cities = await MasterService.getCities(stateId);
      if (applyInitial && widget.initialFilters != null) {
        final cityVal = widget.initialFilters!['city']?.toString().toLowerCase().trim();
        if (cityVal != null) {
          final match = _cities.where((c) => c.value.toLowerCase().trim() == cityVal);
          _selectedCity = match.isNotEmpty ? match.first : null;
        }
      }
    } finally {
      if (mounted) setState(() => _loadingCities = false);
    }
  }

  // ── Actions ──────────────────────────────────────────────────────────────────

  void _clearAll() {
    setState(() {
      _locationCtrl.clear();
      _category         = null;
      _type             = null;
      _status           = null;
      _furnishing       = null;
      _ownership        = null;
      _preferredTenants = null;
      _availability     = null;
      _selectedState    = null;
      _selectedCity     = null;
      _cities           = [];
      _priceRange = const RangeValues(1000.0, 100000000.0);
      _areaRange  = const RangeValues(100.0,  10000.0);
      _priceChanged = false;
      _areaChanged  = false;
      _bedrooms  = 0;
      _bathrooms = 0;
      _amenities.clear();
    });
  }

  void _apply() {
    final raw = <String, dynamic>{
      'rentOrSale':        _listingType,
      'state':             _selectedState?.value,
      'city':              _selectedCity?.value,
      'location':          _locationCtrl.text.trim().isEmpty ? null : _locationCtrl.text.trim(),
      'type':              _type,
      'category':          _category,
      'constructionStatus': _status,
      'furnishing':        _furnishing,
      'ownershipType':     _ownership,
      'preferredTenants':  _preferredTenants,
      'availability':      _availability,
      'minPrice':          _priceChanged ? _priceRange.start : null,
      'maxPrice':          _priceChanged ? _priceRange.end   : null,
      'minArea':           _areaChanged  ? _areaRange.start  : null,
      'maxArea':           _areaChanged  ? _areaRange.end    : null,
      'bedrooms':          _bedrooms  == 0 ? null : _bedrooms,
      'bathrooms':         _bathrooms == 0 ? null : _bathrooms,
      'amenity':           _amenities.isNotEmpty ? _amenities.join(',') : null,
    };
    raw.removeWhere((_, v) => v == null);
    widget.onApply(raw);
    Navigator.pop(context);
  }

  // ── UI helpers ───────────────────────────────────────────────────────────────

  InputDecoration _inputDeco(String label) => InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
        filled: true,
        fillColor: AppColors.white,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      );

  Widget _sectionHeader(String title) => Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 10),
        child: Row(
          children: [
            Container(
              width: 3, height: 16,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      );

  /// Single-select choice chips.  Tapping the selected chip deselects it.
  Widget _chipRow(
    List<String> options,
    String? selected,
    ValueChanged<String?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        children: options.map((e) {
          final isSelected = selected == e;
          return ChoiceChip(
            label: Text(e),
            selected: isSelected,
            selectedColor: AppColors.primary,
            backgroundColor: AppColors.white,
            side: BorderSide(
              color: isSelected ? AppColors.primary : AppColors.border,
            ),
            labelStyle: TextStyle(
              fontSize: 13,
              color: isSelected ? AppColors.white : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
            onSelected: (_) => onChanged(isSelected ? null : e),
          );
        }).toList(),
      ),
    );
  }

  Widget _dropdown<T>({
    required String label,
    required List<T> items,
    required T? value,
    required ValueChanged<T?>? onChanged,
    required String Function(T) itemLabel,
    Widget? suffixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: DropdownButtonFormField<T>(
        value: items.contains(value) ? value : null,
        isDense: true,
        itemHeight: 48,
        decoration: suffixIcon != null
            ? _inputDeco(label).copyWith(suffixIcon: suffixIcon)
            : _inputDeco(label),
        hint: Text(label,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
        items: items
            .map((e) => DropdownMenuItem<T>(
                  value: e,
                  child: Text(itemLabel(e),
                      style: const TextStyle(
                          fontSize: 14, color: AppColors.textPrimary)),
                ))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _stepper(
    String label,
    int value,
    ValueChanged<int> onChanged, {
    int max = 10,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textPrimary)),
              Text(
                value == 0 ? 'Any' : value.toString(),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: value == 0 ? AppColors.textMuted : AppColors.primary,
                ),
              ),
            ],
          ),
          Row(
            children: [
              _stepBtn(Icons.remove_rounded,
                  value <= 0 ? null : () => setState(() => onChanged(value - 1))),
              const SizedBox(width: 12),
              _stepBtn(Icons.add_rounded,
                  value >= max ? null : () => setState(() => onChanged(value + 1))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stepBtn(IconData icon, VoidCallback? onTap) {
    final active = onTap != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 34, height: 34,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: active ? AppColors.primary : AppColors.border),
          color: active
              ? AppColors.primary.withOpacity(0.08)
              : AppColors.surfaceSubtle,
        ),
        child: Icon(icon,
            size: 16,
            color: active ? AppColors.primary : AppColors.textMuted),
      ),
    );
  }

  Widget _loadingIndicator() => const SizedBox(
        width: 20, height: 20,
        child: Padding(
          padding: EdgeInsets.all(12),
          child: CircularProgressIndicator(
              strokeWidth: 2, color: AppColors.primary),
        ),
      );

  Widget _rangeSlider({
    required RangeValues values,
    required double min,
    required double max,
    required int divisions,
    required String Function(double) labelFmt,
    required ValueChanged<RangeValues> onChanged,
  }) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        thumbColor: AppColors.primary,
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: AppColors.border,
        overlayColor: AppColors.primary.withOpacity(0.18),
      ),
      child: RangeSlider(
        values: values,
        min: min, max: max,
        divisions: divisions,
        labels: RangeLabels(labelFmt(values.start), labelFmt(values.end)),
        onChanged: onChanged,
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // ── Drag handle ──────────────────────────────────────────────
              const SizedBox(height: 8),
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 8),

              // ── Header ───────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Text(
                      'Filters',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: _clearAll,
                      child: const Text('Clear All',
                          style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // ── Scrollable body ──────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // ── 1. LISTING ─────────────────────────────────────
                      _sectionHeader('Listing'),
                      const Text('Category',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.textMuted)),
                      const SizedBox(height: 6),
                      _chipRow(
                        ['Residential', 'Commercial'],
                        _category,
                        (v) => setState(() {
                          _category = v;
                          _type = null;
                        }),
                      ),
                      const SizedBox(height: 4),
                      _dropdown<String>(
                        label: 'Property Type',
                        items: _filteredTypes,
                        value: _type,
                        itemLabel: (e) => e,
                        onChanged: (v) => setState(() => _type = v),
                      ),

                      // ── 2. LOCATION ────────────────────────────────────
                      _sectionHeader('Location'),
                      _dropdown<MasterValue>(
                        label: 'State',
                        items: _states,
                        value: _selectedState,
                        itemLabel: (s) => s.value,
                        suffixIcon: _loadingStates
                            ? _loadingIndicator()
                            : null,
                        onChanged: _loadingStates
                            ? null
                            : (v) {
                                setState(() {
                                  _selectedState = v;
                                  _selectedCity  = null;
                                  _cities        = [];
                                  _locationCtrl.clear();
                                });
                                if (v != null) _loadCities(v.id);
                              },
                      ),
                      _dropdown<MasterValue>(
                        label: 'City',
                        items: _cities,
                        value: _selectedCity,
                        itemLabel: (c) => c.value,
                        suffixIcon: _loadingCities
                            ? _loadingIndicator()
                            : null,
                        onChanged: (_selectedState == null || _loadingCities)
                            ? null
                            : (v) => setState(() => _selectedCity = v),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: TextField(
                          controller: _locationCtrl,
                          style: const TextStyle(
                              fontSize: 14, color: AppColors.textPrimary),
                          decoration: _inputDeco('Locality / Area'),
                        ),
                      ),

                      // ── 3. BUDGET ──────────────────────────────────────
                      _sectionHeader(
                        _priceChanged
                            ? 'Budget: ${_fmtCurrency(_priceRange.start)} – ${_fmtCurrency(_priceRange.end)}'
                            : 'Budget: Any',
                      ),
                      _rangeSlider(
                        values: _priceRange,
                        min: 0, max: 100000000, divisions: 1000,
                        labelFmt: _fmtCurrency,
                        onChanged: (v) => setState(() {
                          _priceRange   = v;
                          _priceChanged = true;
                        }),
                      ),

                      // ── 4. SIZE & ROOMS ────────────────────────────────
                      _sectionHeader(
                        _areaChanged
                            ? 'Size & Rooms: ${_areaRange.start.toInt()}–${_areaRange.end.toInt()} sqft'
                            : 'Size & Rooms',
                      ),
                      _rangeSlider(
                        values: _areaRange,
                        min: 0, max: 10000, divisions: 100,
                        labelFmt: (v) => '${v.toInt()} sqft',
                        onChanged: (v) => setState(() {
                          _areaRange   = v;
                          _areaChanged = true;
                        }),
                      ),
                      if (_category == null || _category == 'Residential') ...[
                        _stepper('Bedrooms',  _bedrooms,  (v) => setState(() => _bedrooms  = v)),
                        _stepper('Bathrooms', _bathrooms, (v) => setState(() => _bathrooms = v)),
                      ],

                      // ── 5. PROPERTY DETAILS ────────────────────────────
                      _sectionHeader('Property Details'),
                      const Text('Construction Status',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.textMuted)),
                      const SizedBox(height: 6),
                      _chipRow(
                        _statusList, _status,
                        (v) => setState(() => _status = v),
                      ),
                      const SizedBox(height: 8),
                      if (_category == null || _category == 'Residential') ...[
                        const Text('Furnishing',
                            style: TextStyle(
                                fontSize: 12, color: AppColors.textMuted)),
                        const SizedBox(height: 6),
                        _chipRow(
                          _furnishingList, _furnishing,
                          (v) => setState(() => _furnishing = v),
                        ),
                        const SizedBox(height: 8),
                      ],
                      const Text('Ownership',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.textMuted)),
                      const SizedBox(height: 6),
                      _chipRow(
                        _ownershipList, _ownership,
                        (v) => setState(() => _ownership = v),
                      ),

                      // ── 6. RENTAL TERMS (Rent listings only) ───────────
                      if (_isRent) ...[
                        _sectionHeader('Rental Terms'),
                        const Text('Preferred Tenants',
                            style: TextStyle(
                                fontSize: 12, color: AppColors.textMuted)),
                        const SizedBox(height: 6),
                        _chipRow(
                          _tenantList, _preferredTenants,
                          (v) => setState(() => _preferredTenants = v),
                        ),
                        const SizedBox(height: 8),
                        const Text('Available From',
                            style: TextStyle(
                                fontSize: 12, color: AppColors.textMuted)),
                        const SizedBox(height: 6),
                        _chipRow(
                          _availabilityList, _availability,
                          (v) => setState(() => _availability = v),
                        ),
                      ],

                      // ── 7. AMENITIES ───────────────────────────────────
                      _sectionHeader('Amenities'),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: _amenityList.map((a) {
                          final selected = _amenities.contains(a);
                          return FilterChip(
                            label: Text(a),
                            selected: selected,
                            selectedColor: AppColors.primary.withOpacity(0.15),
                            backgroundColor: AppColors.white,
                            checkmarkColor: AppColors.primary,
                            side: BorderSide(
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.border,
                            ),
                            labelStyle: TextStyle(
                              fontSize: 12,
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                              fontWeight: selected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                            onSelected: (v) => setState(() {
                              v ? _amenities.add(a) : _amenities.remove(a);
                            }),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),

              // ── Apply button ──────────────────────────────────────────────
              Container(
                padding: EdgeInsets.fromLTRB(
                    16, 10, 16,
                    MediaQuery.of(context).padding.bottom + 10),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 8,
                      color: Colors.black.withOpacity(0.06),
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: AppButton(text: 'Search', onTap: _apply),
              ),
            ],
          ),
        );
      },
    );
  }
}
