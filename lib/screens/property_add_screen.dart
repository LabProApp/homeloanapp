import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/property_model.dart';
import '../services/property_api_service.dart';
import '../services/state_api_service.dart';
import '../theme/app_colors.dart';
import '../commons/common_widget.dart';
import 'property_media_screen.dart';

class PostPropertyScreen extends StatefulWidget {
  final int userId;
  final PropertyModel? propertyToEdit;

  const PostPropertyScreen({
    super.key,
    required this.userId,
    this.propertyToEdit,
  });

  @override
  State<PostPropertyScreen> createState() => _PostPropertyScreenState();
}

class _PostPropertyScreenState extends State<PostPropertyScreen> {
  final _formKey = GlobalKey<FormState>();

  // ── Controllers ──────────────────────────────────────────────────────────────
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _depositCtrl = TextEditingController();
  final _superAreaCtrl = TextEditingController();
  final _carpetAreaCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();

  Key _localityKey = UniqueKey();

  // ── Property fields ───────────────────────────────────────────────────────────
  String rentOrSale = 'Sale';
  String category = 'Residential';
  String propertyType = 'APARTMENT';
  String postedByType = 'Owner';
  String constructionStatus = 'Ready to Move';
  String furnishing = 'Unfurnished';
  String parking = 'None';
  String facing = 'North';
  String propertyAge = '0-1 Years';
  String availableFrom = 'Immediate';

  int bedrooms = 2;
  int bathrooms = 2;
  int floorNumber = 0;
  int totalFloors = 1;

  // ── Location ──────────────────────────────────────────────────────────────────
  MasterValue? selectedState;
  MasterValue? selectedCity;
  List<MasterValue> states = [];
  List<MasterValue> cities = [];
  List<MasterValue> localities = [];
  final Map<int, List<MasterValue>> _cityCache = {};
  final Map<int, List<MasterValue>> _localityCache = {};

  // ── Loading / state ───────────────────────────────────────────────────────────
  bool _submitting = false;
  bool _loadingStates = true;
  bool _loadingCities = false;
  bool _loadingLocalities = false;

  final List<String> _selectedAmenities = [];

  String _userName = '';
  String _userEmail = '';

  bool get _isResidential => category == 'Residential';
  bool get _isRent => rentOrSale == 'Rent';

  // ── Static option lists ───────────────────────────────────────────────────────
  static const _rentSaleOptions = ['Sale', 'Rent'];
  static const _categoryOptions = ['Residential', 'Commercial'];
  static const _residentialTypes = ['APARTMENT', 'HOUSE', 'BUILDER FLOOR', 'PLOT'];
  static const _commercialTypes = ['SHOP', 'OFFICE', 'SHOWROOM', 'CO WORKING'];
  static const _postedByOptions = ['Owner', 'Broker', 'Builder'];
  static const _constructionOptions = ['Ready to Move', 'Under Construction', 'New Launch'];
  static const _furnishingOptions = ['Furnished', 'Semi Furnished', 'Unfurnished'];
  static const _parkingOptions = ['None', '1', '2', '3+'];
  static const _facingOptions = ['North', 'South', 'East', 'West'];
  static const _ageOptions = ['0-1 Years', '1-5 Years', '5-10 Years', '10+ Years'];
  static const _availableFromOptions = ['Immediate', 'Within 15 Days', 'Within 30 Days'];
  static const _amenityOptions = [
    'Club House', 'Lift', 'Power Backup', 'Security',
    'Gym', 'Swimming Pool', 'Garden', 'Parking', 'CCTV',
  ];

  // ── Lifecycle ─────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _prefillFromEdit();
    _loadStates();
    _loadUserData();
    if (widget.propertyToEdit == null) {
      _titleCtrl.addListener(_refreshDescIfEmpty);
      _carpetAreaCtrl.addListener(_refreshDescIfEmpty);
      WidgetsBinding.instance.addPostFrameCallback((_) => _refreshDescIfEmpty());
    }
  }

  @override
  void dispose() {
    _titleCtrl.removeListener(_refreshDescIfEmpty);
    _carpetAreaCtrl.removeListener(_refreshDescIfEmpty);
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _depositCtrl.dispose();
    _superAreaCtrl.dispose();
    _carpetAreaCtrl.dispose();
    _addressCtrl.dispose();
    _locationCtrl.dispose();
    _contactCtrl.dispose();
    super.dispose();
  }

  // ── Pre-fill for edit mode ─────────────────────────────────────────────────

  void _prefillFromEdit() {
    final p = widget.propertyToEdit;
    if (p == null) return;

    final isEditRent = p.rentOrSale?.toUpperCase() == 'RENT';
    _titleCtrl.text = p.title ?? '';
    _descCtrl.text = p.description ?? '';
    _priceCtrl.text = (isEditRent ? p.monthlyRent : p.price)?.toString() ?? '';
    _depositCtrl.text = p.securityDeposit?.toString() ?? '';
    _superAreaCtrl.text = p.superArea?.toString() ?? '';
    _carpetAreaCtrl.text = p.carpetArea?.toString() ?? '';
    _addressCtrl.text = p.address ?? '';
    _locationCtrl.text = p.location ?? '';
    _contactCtrl.text = p.contactNumber;

    rentOrSale = isEditRent ? 'Rent' : 'Sale';
    category = p.category ?? 'Residential';
    propertyType = p.type ?? 'APARTMENT';
    postedByType = p.postedBy ?? 'Owner';
    constructionStatus = p.constructionStatus ?? 'Ready to Move';
    bedrooms = p.bedrooms ?? 2;
    bathrooms = p.bathrooms ?? 2;
    floorNumber = p.floorNumber ?? 0;
    totalFloors = p.totalFloors ?? 1;
    furnishing = p.furnishing ?? 'Unfurnished';
    parking = p.parkingCount ?? 'None';
    facing = p.facing ?? 'North';
    propertyAge = p.propertyAge ?? '0-1 Years';

    if (p.amenities != null && p.amenities!.isNotEmpty) {
      _selectedAmenities.addAll(
        p.amenities!.split(',').map((e) => e.trim()).where(_amenityOptions.contains),
      );
    }
  }

  // ── User data & description helpers ──────────────────────────────────────────

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final name = prefs.getString('userName') ?? '';
    final email = prefs.getString('userEmail') ?? '';
    final mobile = prefs.getString('userMobile') ?? '';
    setState(() {
      _userName = name;
      _userEmail = email;
      if (_contactCtrl.text.isEmpty) _contactCtrl.text = mobile;
    });
  }

  void _refreshDescIfEmpty() {
    if (!mounted || _descCtrl.text.isNotEmpty) return;
    final d = _generateDescription();
    if (d.isNotEmpty) _descCtrl.text = d;
  }

  String _generateDescription() {
    final carpet = double.tryParse(_carpetAreaCtrl.text.trim());
    final superAreaVal = double.tryParse(_superAreaCtrl.text.trim());
    final parts = <String>[];
    if (_isResidential) {
      final adj = bedrooms >= 4 ? 'Spacious' : bedrooms == 1 ? 'Cozy' : 'Well-designed';
      parts.add('$adj $bedrooms BHK ${_toTitleCase(propertyType)}');
    } else {
      parts.add('Premium ${_toTitleCase(propertyType)}');
    }
    parts.add('$facing-facing');
    if (_isResidential && bathrooms > 0) {
      parts.add('with $bathrooms bathroom${bathrooms > 1 ? 's' : ''}');
    }
    var desc = '${parts.join(', ')}.';
    if (carpet != null && carpet > 0) {
      desc += ' Carpet area: ${carpet.toStringAsFixed(0)} sq.ft.';
    } else if (superAreaVal != null && superAreaVal > 0) {
      desc += ' Built-up area: ${superAreaVal.toStringAsFixed(0)} sq.ft.';
    }
    desc += ' Available for ${_isRent ? 'rent' : 'sale'}.';
    if (_selectedAmenities.isNotEmpty) {
      desc += ' Amenities include ${_selectedAmenities.take(3).join(', ')}.';
    }
    return desc;
  }

  String _toTitleCase(String s) => s
      .split(' ')
      .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1).toLowerCase())
      .join(' ');

  // ── Location loaders ──────────────────────────────────────────────────────────

  Future<void> _loadStates() async {
    try {
      final data = await MasterService.getStates();
      if (!mounted) return;
      setState(() {
        states = data;
        _loadingStates = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingStates = false);
      _showError('Failed to load states. Please check your connection.');
      return;
    }

    final editState = widget.propertyToEdit?.state;
    if (editState == null) return;
    final match = states.where((s) => s.value == editState).firstOrNull;
    if (match != null && mounted) {
      setState(() => selectedState = match);
      await _loadCities(match.id);
    }
  }

  Future<void> _loadCities(int stateId) async {
    if (_cityCache.containsKey(stateId)) {
      setState(() => cities = _cityCache[stateId]!);
      _prefillCity();
      return;
    }

    setState(() {
      _loadingCities = true;
      cities = [];
      selectedCity = null;
      localities = [];
      _locationCtrl.clear();
      _localityKey = UniqueKey();
    });

    try {
      final data = await MasterService.getCities(stateId);
      _cityCache[stateId] = data;
      if (!mounted) return;
      setState(() {
        cities = data;
        _loadingCities = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingCities = false);
      _showError('Failed to load cities. Please try again.');
      return;
    }

    FocusScope.of(context).unfocus();
    _prefillCity();
  }

  void _prefillCity() {
    final editCity = widget.propertyToEdit?.city;
    if (editCity == null || !mounted) return;
    final match = cities.where((c) => c.value == editCity).firstOrNull;
    if (match != null) {
      setState(() => selectedCity = match);
      _loadLocalities(match.id);
    }
  }

  Future<void> _loadLocalities(int cityId) async {
    if (_localityCache.containsKey(cityId)) {
      if (!mounted) return;
      setState(() {
        localities = _localityCache[cityId]!;
        _loadingLocalities = false;
      });
      return;
    }

    setState(() {
      _loadingLocalities = true;
      localities = [];
      _locationCtrl.clear();
      _localityKey = UniqueKey();
    });

    try {
      final data = await MasterService.getLocalities(cityId);
      _localityCache[cityId] = data;
      if (!mounted) return;
      setState(() => localities = data);
    } catch (_) {
      if (!mounted) return;
      _showError('Failed to load localities. You can still type the area name.');
    } finally {
      if (mounted) setState(() => _loadingLocalities = false);
    }
  }

  // ── Submit ────────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);

    final price = double.tryParse(_priceCtrl.text.trim());

    final property = PropertyModel(
      id: widget.propertyToEdit?.id,
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      price: _isRent ? null : price,
      monthlyRent: _isRent ? price : null,
      securityDeposit: _isRent ? double.tryParse(_depositCtrl.text.trim()) : null,
      superArea: double.tryParse(_superAreaCtrl.text.trim()),
      carpetArea: double.tryParse(_carpetAreaCtrl.text.trim()),
      address: _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
      location: _locationCtrl.text.trim(),
      city: selectedCity?.value,
      state: selectedState?.value,
      type: propertyType,
      category: category,
      rentOrSale: rentOrSale.toUpperCase(),
      postedBy: postedByType,
      postedByUser: widget.userId,
      constructionStatus: constructionStatus,
      bedrooms: _isResidential ? bedrooms : null,
      bathrooms: _isResidential ? bathrooms : null,
      floorNumber: floorNumber,
      totalFloors: totalFloors,
      furnishing: furnishing,
      facing: facing,
      propertyAge: propertyAge,
      parkingCount: parking,
      amenities: _selectedAmenities.isEmpty ? null : _selectedAmenities.join(','),
      contactNumber: _contactCtrl.text.trim(),
      currency: 'INR',
      postDate: widget.propertyToEdit?.postDate ?? DateTime.now().toIso8601String(),
      verified: widget.propertyToEdit?.verified,
    );

    try {
      int id;
      if (widget.propertyToEdit != null) {
        await PropertyApiService.updateProperty(property);
        id = widget.propertyToEdit!.id!;
      } else {
        id = await PropertyApiService.addProperty(property);
      }

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PropertyMediaScreen(propertyId: id, userId: widget.userId),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final isNetwork = e.toString().contains('SocketException') ||
          e.toString().contains('TimeoutException') ||
          e.toString().contains('Connection refused');
      _showError(isNetwork
          ? 'Network error. Please check your connection and try again.'
          : 'Could not save the property. Please try again.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── UI Helpers ────────────────────────────────────────────────────────────────

  InputDecoration _inputDeco(String label, {bool required = false, String? hint, Widget? suffixIcon}) {
    return InputDecoration(
      labelText: required ? '$label *' : label,
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
      filled: true,
      fillColor: AppColors.white,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
      labelStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
      suffixIcon: suffixIcon,
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      errorStyle: const TextStyle(fontSize: 11, color: AppColors.error),
    );
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 16,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    bool required = false,
    int maxLines = 1,
    TextInputType keyboard = TextInputType.text,
    String? hint,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboard,
        style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
        decoration: _inputDeco(label, required: required, hint: hint),
        validator: validator,
      ),
    );
  }

  Widget _dropdownField<T>({
    required String label,
    required T value,
    required List<T> items,
    required ValueChanged<T> onChanged,
    bool required = false,
    String? Function(T?)? validator,
  }) {
    final safeValue = items.contains(value) ? value : null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DropdownButtonFormField<T>(
        value: safeValue,
        isDense: true,
        itemHeight: 48,
        decoration: _inputDeco(label, required: required),
        items: items.map((e) => DropdownMenuItem<T>(
          value: e,
          child: Text(e.toString(), style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
        )).toList(),
        onChanged: (v) { if (v != null) onChanged(v); },
        validator: validator,
      ),
    );
  }

  Widget _chipSelector(
    List<String> options,
    String selected,
    ValueChanged<String> onSelected,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
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
            side: BorderSide(color: isSelected ? AppColors.primary : AppColors.border),
            labelStyle: TextStyle(
              fontSize: 13,
              color: isSelected ? AppColors.white : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
            onSelected: (_) => onSelected(e),
          );
        }).toList(),
      ),
    );
  }

  // Stepper replaces sliders — more conventional for property forms.
  Widget _stepper(
    String label,
    int value,
    ValueChanged<int> onChanged, {
    int min = 0,
    int max = 10,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
          Row(
            children: [
              _stepButton(Icons.remove_rounded,
                  value <= min ? null : () => setState(() => onChanged(value - 1))),
              SizedBox(
                width: 40,
                child: Text(
                  value.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              _stepButton(Icons.add_rounded,
                  value >= max ? null : () => setState(() => onChanged(value + 1))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stepButton(IconData icon, VoidCallback? onTap) {
    final active = onTap != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: active ? AppColors.primary : AppColors.border),
          color: active ? AppColors.primary.withOpacity(0.08) : AppColors.surfaceSubtle,
        ),
        child: Icon(icon, size: 16, color: active ? AppColors.primary : AppColors.textMuted),
      ),
    );
  }

  Widget _loadingIndicator() => const SizedBox(
        width: 20,
        height: 20,
        child: Padding(
          padding: EdgeInsets.all(12),
          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
        ),
      );

  // ── Location Widgets ──────────────────────────────────────────────────────────

  Widget _stateDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DropdownButtonFormField<MasterValue>(
        hint: const Text('Select State', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
        value: states.contains(selectedState) ? selectedState : null,
        isDense: true,
        itemHeight: 48,
        decoration: _inputDeco('State', required: true,
            suffixIcon: _loadingStates ? _loadingIndicator() : null),
        items: states.map((s) => DropdownMenuItem(
          value: s,
          child: Text(s.value, style: const TextStyle(fontSize: 14)),
        )).toList(),
        validator: (v) => v == null ? 'Please select a state' : null,
        onChanged: _loadingStates
            ? null
            : (v) {
                setState(() {
                  selectedState = v;
                  selectedCity = null;
                  cities = [];
                  localities = [];
                  _locationCtrl.clear();
                  _localityKey = UniqueKey();
                });
                if (v != null) _loadCities(v.id);
              },
      ),
    );
  }

  Widget _cityDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DropdownButtonFormField<MasterValue>(
        hint: Text(
          selectedState == null ? 'Select state first' : 'Select City',
          style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
        ),
        value: cities.contains(selectedCity) ? selectedCity : null,
        isDense: true,
        itemHeight: 48,
        decoration: _inputDeco('City', required: true,
            suffixIcon: _loadingCities ? _loadingIndicator() : null),
        items: cities.map((c) => DropdownMenuItem(
          value: c,
          child: Text(c.value, style: const TextStyle(fontSize: 14)),
        )).toList(),
        validator: (v) => v == null ? 'Please select a city' : null,
        onChanged: (selectedState == null || _loadingCities)
            ? null
            : (v) {
                setState(() {
                  selectedCity = v;
                  localities = [];
                  _locationCtrl.clear();
                  _localityKey = UniqueKey();
                });
                if (v != null) _loadLocalities(v.id);
              },
      ),
    );
  }

  Widget _localityField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: IgnorePointer(
        ignoring: _loadingLocalities,
        child: Autocomplete<String>(
          key: _localityKey,
          initialValue: TextEditingValue(text: _locationCtrl.text),
          optionsBuilder: (v) {
            final all = localities.map((e) => e.value);
            if (v.text.isEmpty) return all;
            return all.where((l) => l.toLowerCase().contains(v.text.toLowerCase()));
          },
          onSelected: (v) => _locationCtrl.text = v,
          fieldViewBuilder: (ctx, ctrl, focusNode, _) {
            return TextFormField(
              controller: ctrl,
              focusNode: focusNode,
              style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
              // Use onChanged instead of addListener to avoid listener leaks on rebuild
              onChanged: (v) => _locationCtrl.text = v,
              decoration: _inputDeco(
                'Locality / Area',
                required: true,
                hint: 'Type to search…',
                suffixIcon: _loadingLocalities ? _loadingIndicator() : null,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Locality is required';
                return null;
              },
            );
          },
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final propertyTypes = _isResidential ? _residentialTypes : _commercialTypes;
    final safePropertyType =
        propertyTypes.contains(propertyType) ? propertyType : propertyTypes.first;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.propertyToEdit != null ? 'Edit Property' : 'Post Property'),
      ),
      body: Form(
        key: _formKey,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
              sliver: SliverList(
                delegate: SliverChildListDelegate([

                  // ── 1. Basic Details ────────────────────────────────────────
                  _section('Basic Details'),
                  _textField(
                    controller: _titleCtrl,
                    label: 'Property Title',
                    required: true,
                    hint: 'e.g. 2BHK Apartment near Metro',
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Title is required';
                      if (v.trim().length < 5) return 'Title must be at least 5 characters';
                      return null;
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _descCtrl,
                          maxLines: 4,
                          style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                          decoration: _inputDeco('Description', hint: 'Describe key features, nearby landmarks…'),
                        ),
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: () => setState(() => _descCtrl.text = _generateDescription()),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.auto_fix_high_outlined, size: 13, color: AppColors.primary),
                                SizedBox(width: 4),
                                Text('Auto-fill from details', style: TextStyle(fontSize: 12, color: AppColors.primary)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── 2. Listing Type ─────────────────────────────────────────
                  _section('Listing Type'),
                  _chipSelector(_rentSaleOptions, rentOrSale, (v) => setState(() {
                    rentOrSale = v;
                    _refreshDescIfEmpty();
                  })),

                  // ── 3. Category & Property Type ─────────────────────────────
                  _section('Category'),
                  _chipSelector(_categoryOptions, category, (v) {
                    setState(() {
                      category = v;
                      propertyType = (_isResidential ? _residentialTypes : _commercialTypes).first;
                    });
                  }),

                  _dropdownField<String>(
                    label: 'Property Type',
                    value: safePropertyType,
                    items: propertyTypes,
                    required: true,
                    onChanged: (v) => setState(() => propertyType = v),
                    validator: (v) => v == null ? 'Please select a property type' : null,
                  ),

                  _dropdownField<String>(
                    label: 'Posted By',
                    value: postedByType,
                    items: _postedByOptions,
                    onChanged: (v) => setState(() => postedByType = v),
                  ),

                  // ── 4. Location ─────────────────────────────────────────────
                  _section('Location'),
                  _stateDropdown(),
                  _cityDropdown(),
                  _localityField(),
                  _textField(
                    controller: _addressCtrl,
                    label: 'Full Address',
                    maxLines: 3,
                    hint: 'Street, colony, landmark…',
                  ),

                  // ── 5. Pricing ──────────────────────────────────────────────
                  _section(_isRent ? 'Rent Details' : 'Pricing'),
                  _textField(
                    controller: _priceCtrl,
                    label: _isRent ? 'Monthly Rent (₹)' : 'Price (₹)',
                    required: true,
                    keyboard: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return _isRent ? 'Monthly rent is required' : 'Price is required';
                      }
                      final n = double.tryParse(v.trim());
                      if (n == null) return 'Enter a valid amount';
                      if (n <= 0) return 'Amount must be greater than zero';
                      return null;
                    },
                  ),
                  if (_isRent) ...[
                    _textField(
                      controller: _depositCtrl,
                      label: 'Security Deposit (₹)',
                      keyboard: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return null;
                        final n = double.tryParse(v.trim());
                        if (n == null) return 'Enter a valid amount';
                        if (n < 0) return 'Amount cannot be negative';
                        return null;
                      },
                    ),
                    _dropdownField<String>(
                      label: 'Available From',
                      value: availableFrom,
                      items: _availableFromOptions,
                      onChanged: (v) => setState(() => availableFrom = v),
                    ),
                  ],

                  // ── 6. Area ─────────────────────────────────────────────────
                  _section('Area'),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _textField(
                          controller: _superAreaCtrl,
                          label: 'Super Area (sq.ft)',
                          keyboard: TextInputType.number,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return null;
                            final n = double.tryParse(v.trim());
                            if (n == null) return 'Invalid number';
                            if (n <= 0) return 'Must be > 0';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _textField(
                          controller: _carpetAreaCtrl,
                          label: 'Carpet Area (sq.ft)',
                          keyboard: TextInputType.number,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return null;
                            final n = double.tryParse(v.trim());
                            if (n == null) return 'Invalid number';
                            if (n <= 0) return 'Must be > 0';
                            final sa = double.tryParse(_superAreaCtrl.text.trim());
                            if (sa != null && n > sa) return 'Cannot exceed super area';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),

                  // ── 7. Rooms (Residential only) ─────────────────────────────
                  if (_isResidential) ...[
                    _section('Rooms'),
                    _stepper('Bedrooms', bedrooms, (v) {
                      bedrooms = v;
                      _refreshDescIfEmpty();
                    }, min: 1),
                    _stepper('Bathrooms', bathrooms, (v) {
                      bathrooms = v;
                      _refreshDescIfEmpty();
                    }, min: 1),
                  ],

                  // ── 8. Floor Info ───────────────────────────────────────────
                  _section('Floor Info'),
                  _stepper('Floor Number', floorNumber, (v) => floorNumber = v, max: totalFloors),
                  _stepper('Total Floors', totalFloors, (v) {
                    totalFloors = v;
                    if (floorNumber > totalFloors) floorNumber = totalFloors;
                  }, min: 1, max: 60),

                  // ── 9. Property Details ─────────────────────────────────────
                  _section('Property Details'),
                  _dropdownField<String>(
                    label: 'Furnishing',
                    value: furnishing,
                    items: _furnishingOptions,
                    onChanged: (v) => setState(() => furnishing = v),
                  ),
                  _dropdownField<String>(
                    label: 'Parking',
                    value: parking,
                    items: _parkingOptions,
                    onChanged: (v) => setState(() => parking = v),
                  ),
                  _dropdownField<String>(
                    label: 'Facing',
                    value: facing,
                    items: _facingOptions,
                    onChanged: (v) => setState(() {
                      facing = v;
                      _refreshDescIfEmpty();
                    }),
                  ),
                  _dropdownField<String>(
                    label: 'Property Age',
                    value: propertyAge,
                    items: _ageOptions,
                    onChanged: (v) => setState(() => propertyAge = v),
                  ),
                  _dropdownField<String>(
                    label: 'Construction Status',
                    value: constructionStatus,
                    items: _constructionOptions,
                    onChanged: (v) => setState(() => constructionStatus = v),
                  ),

                  // ── 10. Amenities ───────────────────────────────────────────
                  _section('Amenities'),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: _amenityOptions.map((a) {
                        final selected = _selectedAmenities.contains(a);
                        return FilterChip(
                          label: Text(a),
                          selected: selected,
                          selectedColor: AppColors.primary.withOpacity(0.15),
                          backgroundColor: AppColors.white,
                          checkmarkColor: AppColors.primary,
                          showCheckmark: true,
                          side: BorderSide(
                            color: selected ? AppColors.primary : AppColors.border,
                          ),
                          labelStyle: TextStyle(
                            fontSize: 12,
                            color: selected ? AppColors.primary : AppColors.textSecondary,
                            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                          ),
                          onSelected: (v) => setState(() {
                            v ? _selectedAmenities.add(a) : _selectedAmenities.remove(a);
                          }),
                        );
                      }).toList(),
                    ),
                  ),

                  // ── 11. Contact ─────────────────────────────────────────────
                  _section('Contact'),
                  if (_userName.isNotEmpty || _userEmail.isNotEmpty) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSubtle,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          if (_userName.isNotEmpty)
                            Row(children: [
                              const Icon(Icons.person_outline_rounded, size: 16, color: AppColors.textMuted),
                              const SizedBox(width: 8),
                              const Text('Name', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                              const Spacer(),
                              Text(_userName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                            ]),
                          if (_userName.isNotEmpty && _userEmail.isNotEmpty)
                            const Divider(height: 12, thickness: 0.5),
                          if (_userEmail.isNotEmpty)
                            Row(children: [
                              const Icon(Icons.email_outlined, size: 16, color: AppColors.textMuted),
                              const SizedBox(width: 8),
                              const Text('Email', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                              const Spacer(),
                              Flexible(child: Text(_userEmail, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary))),
                            ]),
                        ],
                      ),
                    ),
                  ],
                  _textField(
                    controller: _contactCtrl,
                    label: 'Mobile Number',
                    required: true,
                    keyboard: TextInputType.phone,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Phone number is required';
                      final digits = v.replaceAll(RegExp(r'\D'), '');
                      final valid = digits.length == 10 ||
                          (digits.length == 12 && digits.startsWith('91'));
                      return valid ? null : 'Enter a valid 10-digit mobile number';
                    },
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),

      // ── Sticky Submit ─────────────────────────────────────────────────────────
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          decoration: BoxDecoration(
            color: AppColors.white,
            boxShadow: [
              BoxShadow(
                blurRadius: 12,
                color: Colors.black.withOpacity(0.06),
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: AppButton(
            text: widget.propertyToEdit != null ? 'Update Property' : 'Save & Continue',
            isLoading: _submitting,
            onTap: _submitting ? null : _submit,
          ),
        ),
      ),
    );
  }
}
