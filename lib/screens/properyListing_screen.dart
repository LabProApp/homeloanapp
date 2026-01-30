import 'package:flutter/material.dart';
import '../models/property_model.dart';
import '../services/property_api_service.dart';
import '../theme/app_colors.dart';
import '../cards/property_card.dart';
import '../screens/propertyDetail_screen.dart';
import '../screens/propertyAdd_screen.dart';
import '../screens/property_filter_dialog.dart';

class PropertyListingScreen extends StatefulWidget {
  final String? userId;

  const PropertyListingScreen({
    super.key,
    this.userId,
  });

  @override
  State<PropertyListingScreen> createState() => _PropertyListingScreenState();
}

class _PropertyListingScreenState extends State<PropertyListingScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<PropertyModel> _properties = [];

  bool _isLoading = true;
  String _error = "";

  /// 🔁 TOGGLES
  bool isResidential = true;
  bool isBuy = true;

  /// 🔎 ADVANCED FILTERS
  String? city;
  String? category;
  int? minBedrooms;
  int? minBathrooms;
  double? minPrice;
  double? maxPrice;

  @override
  void initState() {
    super.initState();
    _refreshFromApi();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// 🔄 LOAD PROPERTIES FROM API USING FILTERS
  Future<void> _loadProperties({
    String? search,
    String? type,
    String? listingType,
    String? city,
    String? category,
    int? minBedrooms,
    int? minBathrooms,
    double? minPrice,
    double? maxPrice,
  }) async {
    try {
      setState(() {
        _isLoading = true;
        _error = "";
      });

      final service = PropertyApiService();

      final data = await service.fetchProperties(
        title: search,
        type: type,
        rentOrSale: listingType,
        city: city,
        category: category,
        minBedrooms: minBedrooms,
        minBathrooms: minBathrooms,
        minPrice: minPrice,
        maxPrice: maxPrice,
        postedByUser: widget.userId,
      );

      setState(() {
        _properties = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  /// 📡 CALL API WITH CURRENT FILTER VALUES
  void _refreshFromApi() {
    _loadProperties(
      search: _searchController.text.trim().isEmpty
          ? null
          : _searchController.text.trim(),
      type: isResidential ? "residential" : "commercial",
      listingType: isBuy ? "buy" : "rent",
      city: city,
      category: category,
      minBedrooms: minBedrooms,
      minBathrooms: minBathrooms,
      minPrice: minPrice,
      maxPrice: maxPrice,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Column(
        children: [
          /// 🔍 SEARCH BAR
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onSubmitted: (_) => _refreshFromApi(),
                      decoration: const InputDecoration(
                        hintText: "Search properties...",
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.search, size: 20),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _actionButton(icon: Icons.favorite_border, onTap: () {}),
                const SizedBox(width: 8),
                _actionButton(
                  icon: Icons.filter_list,
                  onTap: _openFilterDialog,
                ),
              ],
            ),
          ),

          /// 🔁 TOGGLES
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _propertyTypeToggle(),
                _buyRentToggle(),
              ],
            ),
          ),

          /// 🏠 PROPERTY LIST
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error.isNotEmpty
                ? Center(
              child: Text(
                _error,
                style: const TextStyle(color: Colors.red),
              ),
            )
                : _properties.isEmpty
                ? const Center(
              child: Text(
                "No properties found",
                style: TextStyle(fontSize: 16),
              ),
            )
                : ListView.builder(
              padding:
              const EdgeInsets.symmetric(vertical: 6),
              physics: const BouncingScrollPhysics(),
              itemCount: _properties.length,
              itemBuilder: (context, index) {
                final property = _properties[index];

                return Padding(
                  padding:
                  const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              PropertyDetailScreen(
                                property: property,
                              ),
                        ),
                      );
                    },
                    child: SizedBox(
                      height: 600,
                      child: PropertyCard(
                        property: property,
                        showWhatsAppIcon: true,
                        showAmenitiesExpandable: true,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),

      /// ➕ ADD PROPERTY
      floatingActionButton: SizedBox(
        width: 70,
        height: 70,
        child: FloatingActionButton(
          backgroundColor: AppColors.accent,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PostPropertyScreen(
                  userId: widget.userId,
                ),
              ),
            );
          },
          child: const Icon(Icons.add, size: 36),
        ),
      ),
    );
  }

  // ================= TOGGLES =================

  Widget _propertyTypeToggle() {
    return ToggleButtons(
      isSelected: [isResidential, !isResidential],
      borderRadius: BorderRadius.circular(12),
      constraints: const BoxConstraints(minHeight: 34, minWidth: 90),
      selectedColor: Colors.white,
      fillColor: AppColors.secondary,
      color: Colors.black87,
      onPressed: (index) {
        setState(() {
          isResidential = index == 0;
        });
        _refreshFromApi();
      },
      children: const [
        Text("Residential", style: TextStyle(fontSize: 12)),
        Text("Commercial", style: TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buyRentToggle() {
    return ToggleButtons(
      isSelected: [isBuy, !isBuy],
      borderRadius: BorderRadius.circular(12),
      constraints: const BoxConstraints(minHeight: 34, minWidth: 70),
      selectedColor: Colors.white,
      fillColor: AppColors.secondary,
      color: Colors.black87,
      onPressed: (index) {
        setState(() {
          isBuy = index == 0;
        });
        _refreshFromApi();
      },
      children: const [
        Text("Buy", style: TextStyle(fontSize: 12)),
        Text("Rent", style: TextStyle(fontSize: 12)),
      ],
    );
  }

  // ================= FILTER DIALOG =================

  void _openFilterDialog() {
    showDialog(
      context: context,
      builder: (_) => PropertyFilterDialog(
        onApply: (Map<String, dynamic> filters) {
          city = filters["city"] as String?;
          category = filters["category"] as String?;
          minBedrooms = filters["minBedrooms"] as int?;
          minBathrooms = filters["minBathrooms"] as int?;
          minPrice = filters["minPrice"] as double?;
          maxPrice = filters["maxPrice"] as double?;

          _refreshFromApi();
        },
      ),
    );
  }
}

/// 🔘 COMMON ACTION BUTTON
Widget _actionButton({
  required IconData icon,
  required VoidCallback onTap,
}) {
  return Container(
    height: 40,
    width: 40,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
    ),
    child: IconButton(
      icon: Icon(icon, size: 20),
      onPressed: onTap,
    ),
  );
}
