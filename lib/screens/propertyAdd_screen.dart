import 'package:flutter/material.dart';
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
  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    securityDepositController.dispose();
    superAreaController.dispose();
    carpetAreaController.dispose();
    addressController.dispose();
    locationController.dispose();
    contactController.dispose();
    super.dispose();
  }


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
  Key localityKey = UniqueKey();
  /// Property Info
  String rentOrSale = "Sale";
  String category = "Residential";
  String propertyType = "APARTMENT";
  String postedByType = "Owner";
  String constructionStatus = "Ready to Move";

  int? bedrooms;
  int? bathrooms;
  int? floorNumber;
  int? totalFloors;

  String furnishing = "Unfurnished";
  String parking = "None";
  String facing = "North";
  String propertyAge = "0-1 Years";
  String availableFrom = "Immediate";

  /// Location
  MasterValue? selectedState;
  MasterValue? selectedCity;

  List<MasterValue> states = [];
  List<MasterValue> cities = [];
  List<MasterValue> localities = [];

  /// Local Cache (speed optimization)
  final Map<int, List<MasterValue>> cityCache = {};
  final Map<int, List<MasterValue>> localityCache = {};

  bool _loading = false;
  bool _loadingStates = true;
  bool _loadingCities = false;
  bool _loadingLocalities = false;

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

  final postedByOptions = ["Owner", "Broker", "Builder"];

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

  final parkingOptions = ["None", "1", "2", "3+"];

  final facingOptions = ["North", "South", "East", "West"];

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

  final List<String> amenities = [];

  @override
  void initState() {
    super.initState();
    _loadStates();
  }

  /// LOAD STATES
  Future<void> _loadStates() async {
    try {
      states = await MasterService.getStates();
    } catch (_) {}

    setState(() => _loadingStates = false);
  }

  /// LOAD CITIES
  Future<void> _loadCities(int stateId) async {

    if (cityCache.containsKey(stateId)) {
      setState(() {
        cities = cityCache[stateId]!;
      });
      return;
    }

    setState(() {
      _loadingCities = true;
      cities = [];
      selectedCity = null;
      localities = [];
      locationController.clear();
    });

    try {

      final data = await MasterService.getCities(stateId);

      cityCache[stateId] = data;

      cities = data;

    } catch (_) {}

    setState(() => _loadingCities = false);
    FocusScope.of(context).requestFocus(FocusNode());
  }

  /// LOAD LOCALITIES
  /// LOAD LOCALITIES
  Future<void> _loadLocalities(int cityId) async {

    /// If cached, use instantly (fast UX)
    if (localityCache.containsKey(cityId)) {

      if (!mounted) return;

      setState(() {
        localities = localityCache[cityId]!;
        _loadingLocalities = false;
      });

      return;
    }

    if (!mounted) return;

    setState(() {
      _loadingLocalities = true;
      localities = [];
      locationController.clear();
    });

    try {

      final data = await MasterService.getLocalities(cityId);

      /// Save to cache
      localityCache[cityId] = data;

      if (!mounted) return;

      setState(() {
        localities = data;
      });

    } catch (e) {

      debugPrint("Locality loading error: $e");

    } finally {

      if (!mounted) return;

      setState(() {
        _loadingLocalities = false;
      });

    }
  }

  @override
  Widget build(BuildContext context) {

    final propertyTypes =
    isResidential ? propertyTypesResidential : propertyTypesCommercial;

    return Scaffold(

      appBar: AppBar(
        title: const Text("Post Property"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),

      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                _section("Basic Details"),
                _field("Title *", titleController),
                _field("Description *", descriptionController, maxLines: 5),

                _section("Location"),

                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: IgnorePointer(
                    ignoring: _loadingStates,
                    child: _stateDropdown(),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: IgnorePointer(
                    ignoring: _loadingCities,
                    child: _cityDropdown(),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: IgnorePointer(
                    ignoring: _loadingLocalities,
                    child: _localityAutocomplete(),
                  ),
                ),

                _field("Full Address", addressController, maxLines: 4),



                _section("Property Type"),

                _chipSelector(rentSaleOptions, rentOrSale,
                        (v) => setState(() => rentOrSale = v)),

                _chipSelector(categoryOptions, category, (v) {
                  setState(() {
                    category = v;
                    propertyType = propertyTypes.first;
                  });
                }),

                _dropdown(
                    "Property Type",
                    propertyType,
                    propertyTypes,
                        (v) => setState(() => propertyType = v)),

                _dropdown(
                    "Posted By",
                    postedByType,
                    postedByOptions,
                        (v) => setState(() => postedByType = v)),

                _section("Price"),

                _field(isRent ? "Monthly Rent *" : "Price *",
                    priceController,
                    keyboard: TextInputType.number),

                if (isRent)
                  _field("Security Deposit",
                      securityDepositController,
                      keyboard: TextInputType.number),

                _section("Area"),

                Row(
                  children: [
                    Expanded(child: _field("Super Area", superAreaController)),
                    const SizedBox(width: 10),
                    Expanded(child: _field("Carpet Area", carpetAreaController)),
                  ],
                ),

                if (isResidential) ...[
                  _section("Rooms"),
                  _slider("Bedrooms", bedrooms, (v) => setState(() => bedrooms = v)),
                  _slider("Bathrooms", bathrooms, (v) => setState(() => bathrooms = v)),
                ],

                _section("Property Details"),

                _dropdown("Furnishing", furnishing, furnishingOptions,
                        (v) => setState(() => furnishing = v)),

                _dropdown("Parking", parking, parkingOptions,
                        (v) => setState(() => parking = v)),

                _dropdown("Facing", facing, facingOptions,
                        (v) => setState(() => facing = v)),

                _dropdown("Property Age", propertyAge, propertyAgeOptions,
                        (v) => setState(() => propertyAge = v)),

                _dropdown("Construction Status", constructionStatus,
                    constructionStatusOptions,
                        (v) => setState(() => constructionStatus = v)),

                if (isRent)
                  _dropdown("Available From", availableFrom,
                      availableFromOptions,
                          (v) => setState(() => availableFrom = v)),

                _section("Amenities"),

                Wrap(
                  spacing: 6,
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


                _section("Contact"),

                _field("Phone *", contactController,
                    keyboard: TextInputType.phone),

              ]),
            ),
          )
        ],
      ),

      /// Sticky Save Button
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 8,
              color: Colors.black12,
              offset: Offset(0, -2),
            )
          ],
        ),
        child: AppButton(
          text: "Save Property",
          isLoading: _loading,
          onTap: _submit,
        ),
      ),
    );
  }

  /// UI Widgets

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 6),
      child: Text(
        title,
        style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold),
      ),
    );
  }
  Widget _field(String label, TextEditingController controller,
      {int maxLines = 1, TextInputType keyboard = TextInputType.text}) {

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboard,
        style: const TextStyle(fontSize: 14),
        validator: (v) {
          if (label.contains("*") && (v == null || v.isEmpty)) {
            return "Required";
          }
          return null;
        },
        decoration: InputDecoration(
          hintText: label,
          hintStyle: const TextStyle(fontSize: 13),

          filled: true,
          fillColor: AppColors.white,

          isDense: true,

          /// ✅ THIS is what actually reduces height
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),

          /// ✅ EXTRA COMPACT CONTROL (important)
          visualDensity: const VisualDensity(
            horizontal: 0,
            vertical: -1, // 🔥 key line
          ),

          /// ✅ optional hard limit (safe)
          constraints: const BoxConstraints(
            minHeight: 40,
          ),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _chipSelector(
      List<String> options,
      String selected,
      Function(String) onSelected) {

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Wrap(
        spacing: 6,
        children: options.map((e) {

          final isSelected = selected == e;

          return ChoiceChip(
            label: Text(e),
            selected: isSelected,
            selectedColor: AppColors.primary,
            backgroundColor: AppColors.white.withOpacity(.15),
            labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.primary),
            onSelected: (_) => onSelected(e),
          );
        }).toList(),
      ),
    );
  }

  Widget _dropdown(
      String label,
      String value,
      List<String> items,
      Function(String) onChanged) {

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: DropdownButtonFormField<String>(
        value: items.contains(value) ? value : null,
        isDense: true,
        itemHeight: 48,
        items: items
            .map((e) => DropdownMenuItem(
          value: e,
          child: Text(e, style: const TextStyle(fontSize: 14)),
        ))
            .toList(),
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
        decoration: InputDecoration(
          hintText: label,
          filled: true,
          fillColor: AppColors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6, // reduce height here
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _slider(String label, int? value, Function(int) onChanged) {

    final v = value ?? 0;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(v.toString()),
          ],
        ),
        Slider(
          value: v.toDouble(),
          min: 0,
          max: 10,
          divisions: 10,
          activeColor: AppColors.primary,
          onChanged: (x) => onChanged(x.toInt()),
        )
      ],
    );
  }

  Widget _localityAutocomplete() {
    return Autocomplete<String>(
      key: localityKey,
      initialValue: TextEditingValue(text: locationController.text),

      optionsBuilder: (TextEditingValue text) {

        if (text.text.isEmpty) {
          return localities.map((e) => e.value);
        }

        return localities
            .map((e) => e.value)
            .where((l) =>
            l.toLowerCase().contains(text.text.toLowerCase()));
      },

      onSelected: (value) {
        locationController.text = value;
      },

      fieldViewBuilder: (context, controller, focusNode, onSubmit) {

        /// IMPORTANT → sync only once
        controller.addListener(() {
          locationController.text = controller.text;
        });

        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            hintText: "Locality / Area *",
            filled: true,
            fillColor: AppColors.white,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
          validator: (v) {
            if (v == null || v.isEmpty) {
              return "Required";
            }
            return null;
          },
        );
      },
    );
  }

  Widget _stateDropdown() {
    return DropdownButtonFormField<MasterValue>(
      hint: const Text("Select State"),
      value: states.contains(selectedState) ? selectedState : null,
      isDense: true, // ✅ reduces height
      itemHeight: 48, // ✅ compact dropdown list
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6, // ✅ reduced from default
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
      items: states
          .map((s) => DropdownMenuItem(
        value: s,
        child: Text(
          s.value,
          style: const TextStyle(fontSize: 14), // optional tighter text
        ),
      ))
          .toList(),
      onChanged: (v) {
        setState(() {
          selectedState = v;

          selectedCity = null;
          cities = [];
          localities = [];

          locationController.clear();

          /// force rebuild locality field
          localityKey = UniqueKey();
        });

        if (v != null) {
          _loadCities(v.id);
        }
      },
    );
  }

  Widget _cityDropdown() {
    return DropdownButtonFormField<MasterValue>(
      hint: const Text("Select City"),
      value: cities.contains(selectedCity) ? selectedCity : null,
      isDense: true, // ✅ reduces height
      itemHeight: 48, // ✅ compact dropdown list
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6, // ✅ reduced
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
      items: cities
          .map((c) => DropdownMenuItem(
        value: c,
        child: Text(
          c.value,
          style: const TextStyle(fontSize: 14),
        ),
      ))
          .toList(),
      onChanged: selectedState == null
          ? null
          : (v) async {
        setState(() {
          selectedCity = v;

          localities = [];
          locationController.clear();

          /// force rebuild autocomplete
          localityKey = UniqueKey();
        });

        if (v != null) {
          await _loadLocalities(v.id);
        }
      },
    );
  }

















  Future<void> _submit() async {

    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final property = PropertyModel(
      title: titleController.text,
      description: descriptionController.text,
      price: double.tryParse(priceController.text),
      superArea: double.tryParse(superAreaController.text),
      carpetArea: double.tryParse(carpetAreaController.text),
      address: addressController.text,
      location: locationController.text,
      city: selectedCity?.value,
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
      parkingCount: parking,
      amenities: amenities.join(","),
      contactNumber: contactController.text,
      currency: "INR",
      postDate: DateTime.now().toIso8601String(),
      verified: true,
    );

    try {

      final id = await PropertyApiService.addProperty(property);

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PropertyMediaScreen(
              propertyId: id,
              userId: widget.userId),
        ),
      );

    } catch (e) {

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));

    }

    setState(() => _loading = false);
  }
}