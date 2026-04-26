import 'package:flutter/material.dart';
import '../models/property_model.dart';
import '../services/property_api_service.dart';
import '../theme/app_colors.dart';
import '../cards/rent_property_card.dart';
import '../screens/rent_property_detail_screen.dart';
import '../screens/property_add_screen.dart';
import '../screens/property_filter_dialog.dart';

class RentalListingScreen extends StatefulWidget {
  final int userId;
  final int? postedbyuserId;

  const RentalListingScreen({
    super.key,
    required this.userId,
    this.postedbyuserId,
  });

  @override
  State<RentalListingScreen> createState() => _RentalListingScreenState();
}

class _RentalListingScreenState extends State<RentalListingScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<PropertyModel> _properties = [];
  bool _isLoading = true;
  String _error = "";

  bool isResidential = true; // Residential / Commercial only
  Map<String, dynamic> _filters = {};
  String _sortBy = "latest";

  @override
  void initState() {
    super.initState();
    debugPrint("✅ RentalListing userId: ${widget.userId}");
    _refreshFromApi();
  }

  int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return null;
  }

  double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return null;
  }

  Future<void> _loadProperties() async {
    try {
      setState(() {
        _isLoading = true;
        _error = "";
      });

      final service = PropertyApiService();
      final searchText = _searchController.text.trim();

      final data = await service.fetchProperties(
        postedByUserId: widget.postedbyuserId,
        city: searchText.isEmpty ? _filters["city"] : searchText,
        location: searchText.isEmpty ? null : searchText,

        /// 🔒 Always RENT
        rentOrSale: "RENT",

        /// Residential / Commercial
        category: isResidential ? "Residential" : "Commercial",

        /// Filters
        type: _filters["type"],
        minBedrooms: _toInt(_filters["bedrooms"]),
        minBathrooms: _toInt(_filters["bathrooms"]),
        minPrice: _toDouble(_filters["minPrice"]),
        maxPrice: _toDouble(_filters["maxPrice"]),
        minArea: _toDouble(_filters["minArea"]),
        maxArea: _toDouble(_filters["maxArea"]),
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

  void _refreshFromApi() => _loadProperties();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.listingbackground,
      appBar: AppBar(
        title: const Text("Leasing : Commercial, Rental & PG"),
        foregroundColor: Colors.white,
        elevation: 1,
        backgroundColor: Colors.transparent, // important
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildToggles(),
          _buildList(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () async {
          final added = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PostPropertyScreen(userId: widget.userId),
            ),
          );

          if (added == true) {
            _refreshFromApi();
          }
        },
        child: const Icon(Icons.add),
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: TextField(
                controller: _searchController,
                onSubmitted: (_) => _refreshFromApi(),
                decoration: const InputDecoration(
                  hintText: "Search city, area, PG, flat...",
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _iconBtn(Icons.sort, _openSortSheet),
          const SizedBox(width: 8),
          _iconBtn(Icons.filter_alt_outlined, _openFilterDialog),
        ],
      ),
    );
  }

  Widget _buildToggles() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: _toggle(["Residential", "Commercial"], isResidential, (val) {
              setState(() => isResidential = val);
              _refreshFromApi();
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return Expanded(
      child: RefreshIndicator(
        onRefresh: () async => _refreshFromApi(),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error.isNotEmpty
                ? _buildErrorState()
                : _properties.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        itemCount: _properties.length,
                        itemBuilder: (context, index) {
                          final property = _properties[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: InkWell(
                              onTap: () async {
                                final updated = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => RentalPropertyDetailScreen(
                                      property: property,
                                      userId: widget.userId,
                                    ),
                                  ),
                                );
                                if (updated == true) _refreshFromApi();
                              },
                              child: RentPropertyCard(
                                property: property,
                                userId: widget.userId,
                              ),
                            ),
                          );
                        },
                      ),
      ),
    );
  }

  Widget _buildErrorState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_rounded, size: 64, color: AppColors.textMuted),
              const SizedBox(height: 16),
              const Text(
                "Couldn't load rentals",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              const Text(
                "Check your connection and try again.",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                icon: const Icon(Icons.refresh_rounded),
                label: const Text("Retry"),
                onPressed: _refreshFromApi,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        const Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.apartment_outlined, size: 72, color: AppColors.textMuted),
              SizedBox(height: 16),
              Text(
                "No rental properties found",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              SizedBox(height: 8),
              Text(
                "Try adjusting your filters or search for a different area.",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _openFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => PropertyFilterDialog(
        initialFilters: _filters,
        onApply: (filters) {
          setState(() => _filters = filters);
          _refreshFromApi();
        },
      ),
    );
  }

  void _openSortSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _sortTile("Latest", "latest"),
          _sortTile("Rent: Low to High", "price_low"),
          _sortTile("Rent: High to Low", "price_high"),
        ],
      ),
    );
  }

  Widget _sortTile(String label, String value) {
    return ListTile(
      title: Text(label),
      trailing: _sortBy == value ? const Icon(Icons.check) : null,
      onTap: () {
        setState(() => _sortBy = value);
        Navigator.pop(context);
        _refreshFromApi();
      },
    );
  }

  Widget _toggle(
      List<String> labels, bool firstSelected, Function(bool) onTap) {
    return ToggleButtons(
      isSelected: [firstSelected, !firstSelected],
      borderRadius: BorderRadius.circular(12),
      constraints: const BoxConstraints(minHeight: 36, minWidth: 110),
      selectedColor: Colors.white,
      fillColor: AppColors.primary,
      onPressed: (i) => onTap(i == 0),
      children: labels
          .map((e) => Text(e, style: const TextStyle(fontSize: 13)))
          .toList(),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) {
    return Container(
      height: 42,
      width: 42,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: IconButton(icon: Icon(icon), onPressed: onTap),
    );
  }
}

