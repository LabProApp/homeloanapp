import 'package:flutter/material.dart';

class PropertyFilterDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onApply;

  const PropertyFilterDialog({super.key, required this.onApply});

  @override
  State<PropertyFilterDialog> createState() => _PropertyFilterDialogState();
}

class _PropertyFilterDialogState extends State<PropertyFilterDialog> {
  final TextEditingController cityController = TextEditingController();
  final TextEditingController minPriceController = TextEditingController();
  final TextEditingController maxPriceController = TextEditingController();

  String? selectedCategory;
  String? selectedBedrooms;
  String? selectedBathrooms;

  final List<String> categories = ["Apartment", "Villa", "Plot", "Office"];
  final List<String> numbers = ["1", "2", "3", "4", "5+"];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// TITLE
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Filter Properties",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),

              const SizedBox(height: 12),

              /// CITY
              _textField("City", cityController),

              /// CATEGORY
              _dropdown("Category", categories, selectedCategory,
                      (val) => setState(() => selectedCategory = val)),

              /// BEDROOMS
              _dropdown("Bedrooms", numbers, selectedBedrooms,
                      (val) => setState(() => selectedBedrooms = val)),

              /// BATHROOMS
              _dropdown("Bathrooms", numbers, selectedBathrooms,
                      (val) => setState(() => selectedBathrooms = val)),

              /// PRICE RANGE
              Row(
                children: [
                  Expanded(
                      child:
                      _textField("Min Price", minPriceController, isNumber: true)),
                  const SizedBox(width: 10),
                  Expanded(
                      child:
                      _textField("Max Price", maxPriceController, isNumber: true)),
                ],
              ),

              const SizedBox(height: 20),

              /// BUTTONS
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _clearFilters,
                      child: const Text("Reset"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _applyFilters,
                      child: const Text("Apply"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _clearFilters() {
    cityController.clear();
    minPriceController.clear();
    maxPriceController.clear();
    setState(() {
      selectedCategory = null;
      selectedBedrooms = null;
      selectedBathrooms = null;
    });
  }

  void _applyFilters() {
    final filters = {
      "city": cityController.text.isNotEmpty ? cityController.text : null,
      "category": selectedCategory,
      "minBedrooms":
      selectedBedrooms != null ? int.tryParse(selectedBedrooms!) : null,
      "minBathrooms":
      selectedBathrooms != null ? int.tryParse(selectedBathrooms!) : null,
      "minPrice":
      minPriceController.text.isNotEmpty ? double.tryParse(minPriceController.text) : null,
      "maxPrice":
      maxPriceController.text.isNotEmpty ? double.tryParse(maxPriceController.text) : null,
    };

    widget.onApply(filters);
    Navigator.pop(context);
  }

  // ================= UI HELPERS =================

  Widget _textField(String hint, TextEditingController controller,
      {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType:
        isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _dropdown(String label, List<String> items, String? value,
      ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          hintText: label,
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        items: items
            .map((e) =>
            DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
