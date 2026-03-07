import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../models/property_model.dart';
import '../services/property_api_service.dart';
import '../services/state_api_service.dart';
import '../theme/app_colors.dart';
import '../commons/common_widget.dart';
import '../screens/property_media_screen.dart';

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

  /// Controllers
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final securityDepositController = TextEditingController();
  final superAreaController = TextEditingController();
  final carpetAreaController = TextEditingController();
  final addressController = TextEditingController();
  final locationController = TextEditingController();
  final contactController = TextEditingController();

  /// Core
  String rentOrSale = "Sale";
  String category = "Residential";
  String propertyType = "APARTMENT";
  String postedByType = "Owner";
  String constructionStatus = "Ready to Move";

  int? bedrooms;
  int? bathrooms;
  int? floorNumber;
  int? totalFloors;

  /// Smart attributes
  String furnishing = "Unfurnished";
  String parking = "None";
  String facing = "North";
  String propertyAge = "0-1 Years";
  String availableFrom = "Immediate";

  /// Location
  MasterValue? selectedState;
  String? selectedCity;
  List<MasterValue> states = [];
  List<String> cities = [];

  /// Amenities
  final List<String> amenities = [];

  bool _loading = false;
  bool _loadingStates = true;
  bool _loadingCities = false;

  bool get isResidential => category == "Residential";
  bool get isRent => rentOrSale == "Rent";

  /// Options
  final rentSaleOptions = ["Rent", "Sale"];
  final categoryOptions = ["Residential", "Commercial"];

  final propertyTypesResidential = [
    "APARTMENT",
    "HOUSE",
    "BUILDER FLOOR",
    "PLOT"
  ];

  final propertyTypesCommercial = [
    "SHOP",
    "OFFICE",
    "SHOWROOM",
    "CO WORKING"
  ];

  final postedByOptions = [
    "Owner",
    "Broker",
    "Builder"
  ];

  final constructionStatusOptions = [
    "Ready to Move",
    "Under Construction",
    "New Launch"
  ];

  final furnishingOptions = [
    "Furnished",
    "Semi Furnished",
    "Unfurnished"
  ];

  final parkingOptions = [
    "None",
    "1",
    "2",
    "3+"
  ];

  final facingOptions = [
    "North",
    "South",
    "East",
    "West"
  ];

  final propertyAgeOptions = [
    "0-1 Years",
    "1-5 Years",
    "5-10 Years",
    "10+ Years"
  ];

  final availableFromOptions = [
    "Immediate",
    "Within 15 Days",
    "Within 30 Days"
  ];

  final amenityOptions = [
    "Club House",
    "Lift",
    "Power Backup",
    "Security",
    "Gym",
    "Swimming Pool",
    "Garden",
    "Parking",
    "CCTV"
  ];

  @override
  void initState() {
    super.initState();
    _loadStates();
  }

  /// Load States
  Future<void> _loadStates() async {
    try {
      states = await MasterService.getStates();
    } catch (_) {}

    setState(() {
      _loadingStates = false;
    });
  }

  /// Load Cities
  Future<void> _loadCities(int stateId) async {
    setState(() {
      _loadingCities = true;
      cities = [];
      selectedCity = null;
    });

    try {
      cities = await MasterService.getCities(stateId);
    } catch (_) {}

    setState(() {
      _loadingCities = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final propertyTypes =
    isResidential ? propertyTypesResidential : propertyTypesCommercial;

    if (!propertyTypes.contains(propertyType)) {
      propertyType = propertyTypes.first;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Post Property"),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// BASIC
              _sectionTitle("Basic Details"),

              _field("Title *", titleController),

              const SizedBox(height: 10),

              _field("Description *", descriptionController, maxLines: 3),

              const SizedBox(height: 20),

              /// TYPE
              _sectionTitle("Property Type"),

              _chipSelector(rentSaleOptions, rentOrSale,
                      (v) => setState(() => rentOrSale = v)),

              const SizedBox(height: 10),

              _chipSelector(categoryOptions, category, (v) {
                setState(() {
                  category = v;
                  propertyType = isResidential
                      ? propertyTypesResidential.first
                      : propertyTypesCommercial.first;
                });
              }),

              const SizedBox(height: 10),

              _dropdown(
                "Property Type *",
                propertyType,
                propertyTypes,
                    (v) => setState(() => propertyType = v),
              ),

              const SizedBox(height: 10),

              _dropdown(
                "Posted By *",
                postedByType,
                postedByOptions,
                    (v) => setState(() => postedByType = v),
              ),

              const SizedBox(height: 20),

              /// PRICE
              _sectionTitle("Price"),

              _field(
                isRent ? "Monthly Rent *" : "Price *",
                priceController,
                keyboard: TextInputType.number,
                prefix: Icons.currency_rupee,
                isPrice: true,
              ),
              _field(
                isRent ? "Security Deposit" : "Price *",
                securityDepositController,
                keyboard: TextInputType.number,
                prefix: Icons.currency_rupee,
                isPrice: true,
              ),
              const SizedBox(height: 20),

              /// AREA
              _sectionTitle("Area"),

              _field("Super Area (sqft) *", superAreaController,
                  keyboard: TextInputType.number),

              const SizedBox(height: 10),

              _field("Carpet Area", carpetAreaController,
                  keyboard: TextInputType.number),

              /// ROOMS
              if (isResidential) ...[
                const SizedBox(height: 20),
                _sectionTitle("Rooms"),

                _slider("Bedrooms", bedrooms,
                        (v) => setState(() => bedrooms = v)),

                _slider("Bathrooms", bathrooms,
                        (v) => setState(() => bathrooms = v)),
              ],

              /// FLOOR
              if (propertyType == "APARTMENT" ||
                  propertyType == "OFFICE") ...[
                const SizedBox(height: 20),
                _sectionTitle("Floor Details"),

                _slider("Floor Number", floorNumber,
                        (v) => setState(() => floorNumber = v)),

                _slider("Total Floors", totalFloors,
                        (v) => setState(() => totalFloors = v)),
              ],

              const SizedBox(height: 20),

              /// PROPERTY DETAILS
              _sectionTitle("Property Details"),

              _dropdown("Furnishing", furnishing, furnishingOptions,
                      (v) => setState(() => furnishing = v)),

              const SizedBox(height: 10),

              _dropdown("Parking", parking, parkingOptions,
                      (v) => setState(() => parking = v)),

              const SizedBox(height: 10),

              _dropdown("Facing", facing, facingOptions,
                      (v) => setState(() => facing = v)),

              const SizedBox(height: 10),

              _dropdown("Property Age", propertyAge, propertyAgeOptions,
                      (v) => setState(() => propertyAge = v)),

              const SizedBox(height: 10),

              _dropdown(
                "Construction Status *",
                constructionStatus,
                constructionStatusOptions,
                    (v) => setState(() => constructionStatus = v),
              ),

              if (isRent) ...[
                const SizedBox(height: 10),
                _dropdown("Available From", availableFrom,
                    availableFromOptions,
                        (v) => setState(() => availableFrom = v)),
              ],

              const SizedBox(height: 20),

              /// AMENITIES
              _sectionTitle("Amenities"),

              Wrap(
                spacing: 8,
                children: amenityOptions.map((a) {
                  final selected = amenities.contains(a);

                  return FilterChip(
                    label: Text(a),
                    selected: selected,
                    selectedColor: AppColors.primary,
                    onSelected: (v) {
                      setState(() {
                        v ? amenities.add(a) : amenities.remove(a);
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              /// LOCATION
              _sectionTitle("Location"),

              _field("Full Address *", addressController, maxLines: 2),

              const SizedBox(height: 10),

              _field("Locality / Area *", locationController),

              const SizedBox(height: 10),

              _loadingStates
                  ? const CircularProgressIndicator()
                  : _stateDropdown(),

              const SizedBox(height: 10),

              _loadingCities
                  ? const CircularProgressIndicator()
                  : _cityDropdown(),

              const SizedBox(height: 20),

              /// CONTACT
              _sectionTitle("Contact"),

              _field(
                "Phone *",
                contactController,
                keyboard: TextInputType.phone,
                prefix: Icons.phone,
              ),

              const SizedBox(height: 80)
            ],
          ),
        ),
      ),

      /// SAVE
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: AppButton(
          text: "Save Property",
          isLoading: _loading,
          onTap: _submit,
        ),
      ),
    );
  }

  /// ---------------- UI WIDGETS ----------------

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  Widget _field(
      String label,
      TextEditingController controller, {
        int maxLines = 1,
        TextInputType keyboard = TextInputType.text,
        IconData? prefix,
        bool isPrice = false,
      }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboard,
      validator: (v) {
        if (label.contains("*") && (v == null || v.isEmpty)) {
          return "Required";
        }
        return null;
      },
      onChanged: isPrice
          ? (v) {
        final clean = v.replaceAll(",", "");
        final num? value = num.tryParse(clean);
        if (value != null) {
          final formatted = NumberFormat("#,##,###").format(value);
          controller.value = TextEditingValue(
            text: formatted,
            selection:
            TextSelection.collapsed(offset: formatted.length),
          );
        }
      }
          : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: prefix != null ? Icon(prefix) : null,
        filled: true,
        fillColor: AppColors.textBoxbackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _chipSelector(
      List<String> options,
      String selected,
      Function(String) onSelected,
      ) {
    return Wrap(
      spacing: 8,
      children: options.map((e) {

        final isSelected = selected == e;

        return ChoiceChip(
          label: Text(
            e,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.primary,
            ),
          ),
          selected: isSelected,
          onSelected: (_) => onSelected(e),
          selectedColor: AppColors.primary,
          backgroundColor: AppColors.secondary.withOpacity(0.15),
        );
      }).toList(),
    );
  }

  Widget _dropdown(
      String label,
      String value,
      List<String> items,
      Function(String) onChanged,
      ) {
    return DropdownButtonFormField<String>(
      value: items.contains(value) ? value : null,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.textBoxbackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      items: items
          .map((e) =>
          DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }

  Widget _slider(String label, int? value, Function(int) onChanged) {

    final int currentValue = value ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(currentValue.toString()),
          ],
        ),

        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.primary.withAlpha(60),
            thumbColor: AppColors.primary,
          ),
          child: Slider(
            value: currentValue.toDouble(),
            min: 0,
            max: 10,
            divisions: 10,
            label: currentValue.toString(),
            onChanged: (v) => onChanged(v.toInt()),
          ),
        ),
      ],
    );
  }

  Widget _stateDropdown() {
    return DropdownButtonFormField<MasterValue>(
      hint: const Text("Select State"),
      value: selectedState,
      items: states
          .map((s) =>
          DropdownMenuItem(value: s, child: Text(s.value)))
          .toList(),
      onChanged: (v) {
        setState(() => selectedState = v);
        if (v != null) _loadCities(v.id);
      },
    );
  }

  Widget _cityDropdown() {
    return DropdownButtonFormField<String>(
      hint: const Text("Select City"),
      value: selectedCity,
      items: cities
          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
          .toList(),
      onChanged: (v) => setState(() => selectedCity = v),
    );
  }

  Future<void> _submit() async {

    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final price =
    double.tryParse(priceController.text.replaceAll(",", ""));
    final securityDeposit = double.tryParse(securityDepositController.text.replaceAll(",", ""));
    final property = PropertyModel(
      title: titleController.text,
      description: descriptionController.text,
      price: price,
      securityDeposit: securityDeposit,
      superArea: double.tryParse(superAreaController.text),
      carpetArea: double.tryParse(carpetAreaController.text),

      address: addressController.text,
      location: locationController.text,

      city: selectedCity,
      state: selectedState?.value,

      type: propertyType,
      category: category,
      rentOrSale: rentOrSale.toUpperCase(),

      postedBy: postedByType,
      constructionStatus: constructionStatus,

      bedrooms: bedrooms,
      bathrooms: bathrooms,

      floorNumber: floorNumber,
      totalFloors: totalFloors,

      furnishing: furnishing,
      facing: facing,
      propertyAge: propertyAge,

      parkingCount: parking ,

      amenities: amenities.join(","),

      contactNumber: contactController.text,

      currency: "INR",



      postDate: DateTime.now().toIso8601String(),

      // default flags
      verified: true,
      negotiable: true,
      loanAvailable: true,
    );

    try {

      final id = await PropertyApiService.addProperty(property);

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PropertyMediaScreen(propertyId: id,userId : widget.userId),
        ),
      );

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );

    } finally {

      setState(() => _loading = false);

    }
  }
}