import 'package:flutter/material.dart';
import '../models/property_model.dart';
import '../services/property_api_service.dart';
import '../theme/app_colors.dart';

class PostPropertyScreen extends StatefulWidget {
  final String? userId;
  const PostPropertyScreen({
    super.key,
    this.userId,
  });

  @override
  State<PostPropertyScreen> createState() => _PostPropertyScreenState();
}

class _PostPropertyScreenState extends State<PostPropertyScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final titleController = TextEditingController();
  final subtitleController = TextEditingController();
  final priceController = TextEditingController();
  final superAreaController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final contactController = TextEditingController();

  // 🔹 Chip / Dropdown values
  String rentOrSale = "Sale";
  String category = "Residential";
  String propertyType = "APARTMENT";
  String constructionStatus = "READY";

  final List<String> amenities = [];

  bool _loading = false;

  // 🔹 Options
  final List<String> rentSaleOptions = ["Rent", "Sale"];
  final List<String> categoryOptions = ["Residential", "Commercial"];
  final List<String> constructionStatusOptions = [
    "READY_TO_MOVE",
    "UNDER_CONSTRUCTION",
    "NEW_LAUNCH",
    "RESALE"
  ];

  final List<String> propertyTypes = [
    "HOUSE",
    "PLOT",
    "APARTMENT",
    "BUILDER_FLOOR",
    "SHOP",
    "OFFICE",
    "SHOWROOM",
    "PG",
    "CO_WORKING",
    "AGRICULTURAL",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Post New Property"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _field("Title", titleController),
              _field("Subtitle / Description", subtitleController),

              /// 🔹 RENT / SALE
              _sectionTitle("Rent / Sale"),
              _chipSelector(
                options: rentSaleOptions,
                selected: rentOrSale,
                onSelected: (v) => setState(() => rentOrSale = v),
              ),

              _field(
                "Price",
                priceController,
                keyboard: TextInputType.number,
                prefix: Icons.currency_rupee,
              ),

              /// 🔹 CATEGORY
              _sectionTitle("Category"),
              _chipSelector(
                options: categoryOptions,
                selected: category,
                onSelected: (v) => setState(() => category = v),
              ),

              /// 🔹 PROPERTY TYPE (DROPDOWN)
              _dropdown(
                label: "Property Type",
                value: propertyType,
                items: propertyTypes,
                onChanged: (v) => setState(() => propertyType = v),
              ),

              /// 🔹 CONSTRUCTION STATUS (CHIPS)
              _sectionTitle("Construction Status"),
              _chipSelector(
                options: constructionStatusOptions,
                selected: constructionStatus,
                onSelected: (v) =>
                    setState(() => constructionStatus = v),
              ),

              _field(
                "Super Area (sqft)",
                superAreaController,
                keyboard: TextInputType.number,
              ),

              Row(
                children: [
                  Expanded(child: _field("City", cityController)),
                  const SizedBox(width: 12),
                  Expanded(child: _field("State", stateController)),
                ],
              ),

              _field(
                "Contact Number",
                contactController,
                keyboard: TextInputType.phone,
                prefix: Icons.phone,
              ),

              const SizedBox(height: 16),

              /// 🔹 AMENITIES
              _sectionTitle("Amenities"),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _amenityChip("Parking"),
                  _amenityChip("Lift"),
                  _amenityChip("Power Backup"),
                  _amenityChip("Security"),
                  _amenityChip("Gym"),
                  _amenityChip("Swimming Pool"),
                ],
              ),

              const SizedBox(height: 24),

              /// 🔹 SUBMIT
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    "Post Property",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- SUBMIT ----------------

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final property = PropertyModel(
      title: titleController.text.trim(),
      description: subtitleController.text.trim(),
      projectName: titleController.text.trim(),

      address:
      "${cityController.text.trim()}, ${stateController.text.trim()}",
      city: cityController.text.trim(),
      state: stateController.text.trim(),
      location: cityController.text.trim(),

      type: propertyType,
      category: category,
      rentOrSale: rentOrSale,
      propertyStatus: "ACTIVE",
      constructionStatus: constructionStatus,

      price: double.tryParse(priceController.text),
      superArea: double.tryParse(superAreaController.text),
      carpetArea: double.tryParse(superAreaController.text),

      amenities: amenities.join(","),

      postedBy: "APP",
      postedByUser: 1,
      planPackage: "FREE",
      verified: false,
      postDate: DateTime.now().toIso8601String(),

      contactNumber: contactController.text.trim(),
    );

    try {
      await PropertyApiService.addProperty(property);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Property posted successfully")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to post property: $e")),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ---------------- HELPERS ----------------

  Widget _field(
      String label,
      TextEditingController controller, {
        TextInputType keyboard = TextInputType.text,
        IconData? prefix,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        validator: (v) =>
        v == null || v.trim().isEmpty ? "Enter $label" : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: prefix != null ? Icon(prefix) : null,
          filled: true,
          fillColor: AppColors.textBoxbackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _dropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: AppColors.textBoxbackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        items: items
            .map(
              (e) => DropdownMenuItem(
            value: e,
            child: Text(e.replaceAll("_", " ")),
          ),
        )
            .toList(),
        onChanged: (v) => onChanged(v!),
      ),
    );
  }

  Widget _chipSelector({
    required List<String> options,
    required String selected,
    required Function(String) onSelected,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: options.map((o) {
        return ChoiceChip(
          label: Text(o.replaceAll("_", " ")),
          selected: selected == o,
          selectedColor: AppColors.primary.withOpacity(0.2),
          onSelected: (_) => onSelected(o),
        );
      }).toList(),
    );
  }

  Widget _amenityChip(String label) {
    final selected = amenities.contains(label);

    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: selected ? AppColors.primary : Colors.black87,
        ),
      ),
      selected: selected,
      selectedColor: AppColors.primary.withOpacity(0.2),
      onSelected: (v) {
        setState(() {
          v ? amenities.add(label) : amenities.remove(label);
        });
      },
    );
  }


  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 6),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }
}
