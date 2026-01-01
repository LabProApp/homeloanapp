import 'package:flutter/material.dart';
import 'package:property/theme/app_colors.dart';

class PostPropertyScreen extends StatefulWidget {
  const PostPropertyScreen({super.key});

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

  String rentOrSale = "Sale";
  String category = "Residential";
  String propertyType = "Apartment";

  final List<String> amenities = [];
  final List<String> images = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Post New Property",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _field("Title", titleController),
              _field("Subtitle", subtitleController),

              _dropdown(
                label: "Rent / Sale",
                value: rentOrSale,
                items: const ["Rent", "Sale"],
                onChanged: (v) => setState(() => rentOrSale = v),
              ),

              _field(
                "Price",
                priceController,
                keyboard: TextInputType.number,
                prefix: Icons.currency_rupee,
              ),

              _dropdown(
                label: "Category",
                value: category,
                items: const ["Residential", "Commercial", "Land"],
                onChanged: (v) => setState(() => category = v),
              ),

              _dropdown(
                label: "Property Type",
                value: propertyType,
                items: const ["Apartment", "Villa", "Plot", "Office"],
                onChanged: (v) => setState(() => propertyType = v),
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

              const SizedBox(height: 16),

              _sectionTitle("Amenities"),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _chip("Parking"),
                  _chip("Lift"),
                  _chip("Power Backup"),
                  _chip("Security"),
                  _chip("Gym"),
                  _chip("Swimming Pool"),
                ],
              ),

              const SizedBox(height: 20),

              _sectionTitle("Property Images"),
              OutlinedButton.icon(
                onPressed: () {
                  // TODO: Add image picker
                  setState(() {
                    images.add("image_placeholder");
                  });
                },
                icon: const Icon(Icons.upload),
                label: const Text("Upload Images"),
              ),

              const SizedBox(height: 30),

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
                  onPressed: _submit,
                  child: const Text(
                    "Post Property",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- SUBMIT ----------------

  void _submit() {
    if (_formKey.currentState!.validate()) {
      debugPrint({
        "title": titleController.text,
        "subtitle": subtitleController.text,
        "rentOrSale": rentOrSale,
        "price": priceController.text,
        "category": category,
        "type": propertyType,
        "superArea": superAreaController.text,
        "city": cityController.text,
        "state": stateController.text,
        "amenities": amenities,
        "images": images,
      }.toString());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Property posted successfully")),
      );

      Navigator.pop(context);
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
        v == null || v.isEmpty ? "Enter $label" : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: prefix != null ? Icon(prefix) : null,
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
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
          fillColor: Colors.grey[100],
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
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _chip(String label) {
    final selected = amenities.contains(label);
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (v) {
        setState(() {
          v ? amenities.add(label) : amenities.remove(label);
        });
      },
    );
  }
}
