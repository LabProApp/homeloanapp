import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/property_model.dart';
import '../services/property_api_service.dart';
import '../theme/app_colors.dart';
import '../commons/common_widget.dart';
import '../services/state_api_service.dart'; // MasterService
import '../screens/property_media_screen.dart';

class PostPropertyScreen extends StatefulWidget {
  final int? userId;
  final PropertyModel? propertyToEdit; // 👈 NEW

  const PostPropertyScreen({
    super.key,
    this.userId,
    this.propertyToEdit,
  });

  @override
  State<PostPropertyScreen> createState() => _PostPropertyScreenState();
}

class _PostPropertyScreenState extends State<PostPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  static const double vSpace = 10;

  final titleController = TextEditingController();
  final subtitleController = TextEditingController();
  final priceController = TextEditingController();
  final superAreaController = TextEditingController();
  final locationController = TextEditingController();
  final contactController = TextEditingController();

  int? bedrooms;
  int? bathrooms;
  int? _createdPropertyId;
  bool _alreadyCreated = false;
  String rentOrSale = "Sale";
  String category = "Residential";
  String propertyType = "APARTMENT";
  String constructionStatus = "Ready to Move";
  String postedByType = "Owner";

  MasterValue? selectedState;
  String? selectedCity;
  List<MasterValue> states = [];
  List<String> cities = [];

  final List<String> amenities = [];
  bool _loading = false;
  bool _loadingStates = true;
  bool _loadingCities = false;

  final List<String> rentSaleOptions = ["Rent", "Sale"];
  final List<String> categoryOptions = ["Residential", "Commercial"];
  final List<String> postedByOptions = ["Owner", "Broker", "Builder"];
  final List<String> constructionStatusOptions = [
    "Ready to Move",
    "Under Construction",
    "New Launch",
    "ReSale"
  ];
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

  bool get isEditMode => widget.propertyToEdit != null;

  @override
  void initState() {
    super.initState();
    _loadStates();
    _prefillIfEdit();

    if(isEditMode)
      {
        _alreadyCreated = true;
        _createdPropertyId = widget.propertyToEdit!.id;
      }

  }

  void _prefillIfEdit() {
    final p = widget.propertyToEdit;
    if (p == null) return;

    titleController.text = p.title ?? "";
    subtitleController.text = p.description ?? "";
    priceController.text = p.price != null
        ? NumberFormat("#,##,###").format(p.price)
        : "";
    superAreaController.text = p.superArea?.toString() ?? "";
    locationController.text = p.location ?? "";
    contactController.text = p.contactNumber ?? "";

    bedrooms = p.bedrooms;
    bathrooms = p.bathrooms;

    rentOrSale = (p.rentOrSale ?? "SALE").toUpperCase() == "RENT"
        ? "Rent"
        : "Sale";
    category = p.category ?? category;
    propertyType = p.type ?? propertyType;
    constructionStatus = p.constructionStatus ?? constructionStatus;
    postedByType = p.postedBy ?? postedByType;

    if (p.state != null) {
      selectedState = MasterValue(id: -1, value: p.state!);
    }
    selectedCity = p.city;
  }

  Future<void> _loadStates() async {
    setState(() => _loadingStates = true);
    try {
      states = await MasterService.getStates();

      if (isEditMode && widget.propertyToEdit?.state != null) {
        selectedState = states.firstWhere(
              (s) => s.value == widget.propertyToEdit!.state,
          orElse: () => states.first,
        );
        await _loadCities(selectedState!.id);
        selectedCity = widget.propertyToEdit!.city;
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to load states: $e')));
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
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to load cities: $e')));
    } finally {
      if (mounted) setState(() => _loadingCities = false);
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    subtitleController.dispose();
    priceController.dispose();
    superAreaController.dispose();
    locationController.dispose();
    contactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? "Modify Property" : "Post New Property"),
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.secondary,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _field("Title", titleController),
              _space(),
              _field("Subtitle / Description", subtitleController),
              _space(),

              _sectionTitle("Rent / Sale"),
              _chipSelector(
                options: rentSaleOptions,
                selected: rentOrSale,
                onSelected: (v) => setState(() => rentOrSale = v),
              ),
              _space(),

              _field(
                "Price",
                priceController,
                keyboard: TextInputType.number,
                prefix: Icons.currency_rupee,
                isPrice: true,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
              ),
              _space(),

              _sectionTitle("Category"),
              _chipSelector(
                options: categoryOptions,
                selected: category,
                onSelected: (v) => setState(() => category = v),
              ),
              _space(),

              _dropdown(
                label: "Property Type",
                value: propertyType,
                items: propertyTypes,
                onChanged: (v) => setState(() => propertyType = v),
              ),
              _space(),

              _sectionTitle("Construction Status"),
              _chipSelector(
                options: constructionStatusOptions,
                selected: constructionStatus,
                onSelected: (v) => setState(() => constructionStatus = v),
              ),
              _space(),

              _field("Super Area (sqft)", superAreaController,
                  keyboard: TextInputType.number),
              _space(),

              _sectionTitle("Bedrooms"),
              _sliderRow(
                value: bedrooms,
                onChanged: (v) => setState(() => bedrooms = v),
              ),
              _space(),

              _sectionTitle("Bathrooms"),
              _sliderRow(
                value: bathrooms,
                onChanged: (v) => setState(() => bathrooms = v),
              ),
              _space(),

              _field("Location", locationController),
              _space(),

              _sectionTitle("State"),
              _loadingStates
                  ? const Center(child: CircularProgressIndicator())
                  : _fancyDropdown<MasterValue>(
                items: states,
                value: selectedState,
                hint: "Select State",
                itemLabel: (s) => s.value,
                onChanged: (v) {
                  setState(() => selectedState = v);
                  if (v != null) _loadCities(v.id);
                },
              ),
              _space(),

              _sectionTitle("City"),
              _loadingCities
                  ? const Center(child: CircularProgressIndicator())
                  : _fancyDropdown<String>(
                items: cities,
                value: selectedCity,
                hint: "Select City",
                itemLabel: (c) => c,
                onChanged: (v) => setState(() => selectedCity = v),
              ),
              _space(),

              _field(
                "Contact Number",
                contactController,
                keyboard: TextInputType.phone,
                prefix: Icons.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(12),
                ],
              ),
              _space(),

              _sectionTitle("Posted By"),
              _chipSelector(
                options: postedByOptions,
                selected: postedByType,
                onSelected: (v) => setState(() => postedByType = v),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: AppButton(
            isLoading: _loading,
            text: isEditMode ? "Update Property" : "Post Property",
            onTap: _submit,
          ),
        ),
      ),
    );
  }

  Widget _space() => const SizedBox(height: vSpace);

  Widget _sectionTitle(String text) =>
      Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14));

  Widget _fancyDropdown<T>({
    required List<T> items,
    required T? value,
    required String hint,
    required String Function(T) itemLabel,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.textBoxbackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          isExpanded: true,
          value: value,
          hint: Text(hint),
          items: items.map((e) {
            return DropdownMenuItem<T>(
              value: e,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(itemLabel(e)),
              ),
            );
          }).toList(),
          onChanged: onChanged,
          menuMaxHeight: 48.0 * 5,
          itemHeight: 48,
        ),
      ),
    );
  }

  Widget _sliderRow({int? value, required Function(int) onChanged}) {
    return Row(
      children: [
        Expanded(
          flex: 8,
          child: Slider(
            value: (value ?? 0).toDouble(),
            min: 0,
            max: 12,
            divisions: 12,
            label: value?.toString() ?? "0",
            onChanged: (v) => onChanged(v.toInt()),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(width: 40, child: Text(value?.toString() ?? "")),
      ],
    );
  }

  Widget _field(String label, TextEditingController controller,
      {TextInputType keyboard = TextInputType.text,
        IconData? prefix,
        bool isPrice = false,
        List<TextInputFormatter>? inputFormatters}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      inputFormatters: inputFormatters,
      validator: (v) => v == null || v.trim().isEmpty ? "Enter $label" : null,
      onChanged: isPrice
          ? (v) {
        final clean = v.replaceAll(",", "");
        final num? value = num.tryParse(clean);
        if (value != null) {
          final formatted = NumberFormat("#,##,###").format(value);
          controller.value = TextEditingValue(
            text: formatted,
            selection: TextSelection.collapsed(offset: formatted.length),
          );
        }
      }
          : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: prefix != null ? Icon(prefix, size: 18) : null,
        isDense: true,
        contentPadding:
        const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        filled: true,
        fillColor: AppColors.textBoxbackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _chipSelector({
    required List<String> options,
    required String selected,
    required Function(String) onSelected,
  }) =>
      Wrap(
        spacing: 6,
        runSpacing: 4,
        children: options
            .map(
              (o) => ChoiceChip(
            label: Text(o, style: const TextStyle(fontSize: 12)),
            selected: selected == o,
            selectedColor: AppColors.primary.withAlpha(50),
            onSelected: (_) => onSelected(o),
          ),
        )
            .toList(),
      );

  Widget _dropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String) onChanged,
  }) =>
      DropdownButtonFormField<String>(
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          contentPadding:
          const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          filled: true,
          fillColor: AppColors.textBoxbackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        items:
        items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: (v) => onChanged(v!),
      );

  Future<void> _submit() async {
    if(_loading) return;
    if (!_formKey.currentState!.validate()) return;
    if (selectedState == null || selectedCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select state and city")),
      );
      return;
    }

    setState(() => _loading = true);

    final price = double.tryParse(priceController.text.replaceAll(",", ""));

    final property = PropertyModel(
      id: _createdPropertyId ?? widget.propertyToEdit?.id,
      title: _cap(titleController.text),
      description: _cap(subtitleController.text),
      projectName: _cap(titleController.text),
      address:
      "${_cap(locationController.text)}, $selectedCity, ${selectedState!.value}",
      location: _cap(locationController.text),
      city: selectedCity!,
      state: selectedState!.value,
      type: propertyType,
      category: category,
      rentOrSale: rentOrSale.toUpperCase(),
      propertyStatus: "ACTIVE",
      constructionStatus: constructionStatus,
      price: price,
      superArea: double.tryParse(superAreaController.text),
      carpetArea: double.tryParse(superAreaController.text),
      bedrooms: bedrooms == 0 ? null : bedrooms,
      bathrooms: bathrooms == 0 ? null : bathrooms,
      amenities: amenities.join(","),
      postedByUser: widget.userId,
      postedBy: postedByType,
      verified: false,
      postDate: DateTime.now().toIso8601String(),
      contactNumber: contactController.text.trim(),
    );

    try {
      int propertyId;

      if (_alreadyCreated || isEditMode) {
        await PropertyApiService.updateProperty(property);
        propertyId = property.id!;
      } else {
        propertyId = await PropertyApiService.addProperty(property);

        // ✅ Mark as created
        _createdPropertyId = propertyId;
        _alreadyCreated = true;
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Property saved. Add images now")),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PropertyMediaScreen(propertyId: propertyId),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save property: $e")),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _cap(String text) =>
      text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);
}
