import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
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

  static const double vSpace = 10; // ✅ single source of truth for spacing

  final titleController = TextEditingController();
  final subtitleController = TextEditingController();
  final priceController = TextEditingController();
  final superAreaController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final locationController = TextEditingController();
  final contactController = TextEditingController();

  int? bedrooms;
  int? bathrooms;

  String rentOrSale = "Sale";
  String category = "Residential";
  String propertyType = "APARTMENT";
  String constructionStatus = "Ready to Move";
  String postedByType = "Owner";

  final List<String> amenities = [];
  bool _loading = false;

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

  @override
  void dispose() {
    titleController.dispose();
    subtitleController.dispose();
    priceController.dispose();
    superAreaController.dispose();
    cityController.dispose();
    stateController.dispose();
    locationController.dispose();
    contactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Post New Property"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
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
                onSelected: (v) =>
                    setState(() => constructionStatus = v),
              ),
              _space(),

              _field(
                "Super Area (sqft)",
                superAreaController,
                keyboard: TextInputType.number,
              ),
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

              Row(
                children: [
                  Expanded(child: _field("City", cityController)),
                  const SizedBox(width: 12),
                  Expanded(child: _field("State", stateController)),
                ],
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
          child: SizedBox(
            width: double.infinity,
            height: 48,
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
                  fontSize: 15,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _space() => const SizedBox(height: vSpace);

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final price =
    double.tryParse(priceController.text.replaceAll(",", ""));

    final property = PropertyModel(
      title: _cap(titleController.text),
      description: _cap(subtitleController.text),
      projectName: _cap(titleController.text),
      address:
      "${_cap(locationController.text)}, ${_cap(cityController.text)}, ${_cap(stateController.text)}",
      location: _cap(locationController.text),
      city: _cap(cityController.text),
      state: _cap(stateController.text),
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
      postedByUser: int.tryParse(widget.userId ?? "0"),
      postedBy: postedByType,
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

  String _cap(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  Widget _sliderRow({int? value, required Function(int) onChanged}) {
    return Row(
      children: [
        Expanded(
          flex: 8,
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.orange,
              inactiveTrackColor: Colors.orange.withOpacity(0.3),
              thumbColor: Colors.orange,
              overlayColor: Colors.orange.withOpacity(0.2),
              valueIndicatorColor: Colors.orange,
            ),
            child: Slider(
              value: (value ?? 0).toDouble(),
              min: 0,
              max: 12,
              divisions: 11,
              label: value?.toString() ?? "0",
              onChanged: (v) => onChanged(v.toInt()),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 50,
          child: Text(
            value == null || value == 0 ? " " : "$value",
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _field(
      String label,
      TextEditingController controller, {
        TextInputType keyboard = TextInputType.text,
        IconData? prefix,
        bool isPrice = false,
        List<TextInputFormatter>? inputFormatters,
      }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      textCapitalization: TextCapitalization.sentences,
      inputFormatters: inputFormatters,
      validator: (v) =>
      v == null || v.trim().isEmpty ? "Enter $label" : null,
      onChanged: isPrice
          ? (v) {
        final clean = v.replaceAll(",", "");
        final num? value = num.tryParse(clean);
        if (value != null) {
          final formatted =
          NumberFormat("#,##,###").format(value);
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
        prefixIcon: prefix != null ? Icon(prefix, size: 18) : null,
        isDense: true,
        contentPadding:
        const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        filled: true,
        fillColor: AppColors.textBoxbackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
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
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        contentPadding:
        const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
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
          child: Text(e),
        ),
      )
          .toList(),
      onChanged: (v) => onChanged(v!),
    );
  }

  Widget _chipSelector({
    required List<String> options,
    required String selected,
    required Function(String) onSelected,
  }) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: options.map((o) {
        return ChoiceChip(
          label: Text(o, style: const TextStyle(fontSize: 12)),
          selected: selected == o,
          selectedColor: AppColors.primary.withOpacity(0.2),
          visualDensity: VisualDensity.compact,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          labelPadding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          onSelected: (_) => onSelected(o),
        );
      }).toList(),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
    );
  }
}
