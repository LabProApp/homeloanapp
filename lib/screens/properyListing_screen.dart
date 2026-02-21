import 'package:flutter/material.dart';
import '../models/property_model.dart';
import '../services/property_api_service.dart';
import '../theme/app_colors.dart';
import '../cards/property_card.dart';
import '../screens/propertyDetail_screen.dart';
import '../screens/propertyAdd_screen.dart';
import '../screens/property_filter_dialog.dart';

class PropertyListingScreen extends StatefulWidget {
  final String userId;
  final String? postedbyuserId;
  const PropertyListingScreen({super.key, required this.userId, this.postedbyuserId});

  @override
  State<PropertyListingScreen> createState() => _PropertyListingScreenState();
}

class _PropertyListingScreenState extends State<PropertyListingScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<PropertyModel> _properties = [];
  bool _isLoading = true;
  String _error = "";

  bool isResidential = true;
  bool isBuy = true;

  Map<String, dynamic> _filters = {};
  String _sortBy = "latest";

  @override
  void initState() {
    super.initState();
    debugPrint("✅ PropertyListing received userId: ${widget.userId}");
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
        postedByUser: (widget.postedbyuserId != null && widget.postedbyuserId!.isNotEmpty)
            ? widget.postedbyuserId
            : null,
        city: searchText.isEmpty ? _filters["city"] : searchText,
        location: searchText.isEmpty ? null : searchText,
        category: isResidential ? "Residential" : "Commercial",
        rentOrSale: isBuy ? "SALE" : "RENT",
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
        foregroundColor: AppColors.white,
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                onSubmitted: (_) => _refreshFromApi(),
                decoration: const InputDecoration(
                  hintText: "Search by title or city",
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _iconBtn(Icons.sort, _openSortSheet),
          const SizedBox(width: 8),
          _iconBtn(Icons.filter_alt, _openFilterDialog),
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
          const SizedBox(width: 50),
          Expanded(
            child: _toggle(["Buy", "Rent"], isBuy, (val) {
              setState(() => isBuy = val);
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
        child: ScrollConfiguration(
          behavior: const _NoGlowScrollBehavior(),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error.isNotEmpty
              ? Center(child: Text(_error))
              : _properties.isEmpty
              ? const Center(
            child: Text("No properties found", style: TextStyle(fontSize: 16)),
          )
              : ListView.builder(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            itemCount: _properties.length,
            itemBuilder: (context, index) {
              final property = _properties[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: InkWell(
                  onTap: () async {
                    final updated = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PropertyDetailScreen(
                          property: property,
                          userId: widget.userId,
                        ),
                      ),
                    );

                    if (updated == true) {
                      _refreshFromApi();
                    }
                  },
                  child: PropertyCard(property: property),
                ),
              );
            },
          ),
        ),
      ),
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
          _sortTile("Price: Low to High", "price_low"),
          _sortTile("Price: High to Low", "price_high"),
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

  Widget _toggle(List<String> labels, bool firstSelected, Function(bool) onTap) {
    return ToggleButtons(
      isSelected: [firstSelected, !firstSelected],
      borderRadius: BorderRadius.circular(12),
      constraints: const BoxConstraints(minHeight: 35, minWidth: 70),
      selectedColor: Colors.white,
      fillColor: AppColors.primary,
      onPressed: (i) => onTap(i == 0),
      children: labels.map((e) => Text(e, style: const TextStyle(fontSize: 12))).toList(),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) {
    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(icon: Icon(icon), onPressed: onTap),
    );
  }
}

/// Removes Android glow + improves scroll feel
class _NoGlowScrollBehavior extends ScrollBehavior {
  const _NoGlowScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}