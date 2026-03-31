import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/property_model.dart';
import '../services/property_api_service.dart';
import '../theme/app_colors.dart';
import '../cards/property_card.dart';
import '../screens/propertyDetail_screen.dart';
import '../screens/propertyAdd_screen.dart';
import '../screens/property_filter_dialog.dart';

class PropertyListingScreen extends StatefulWidget {
  final int userId;
  final int? postedbyuserId;

  const PropertyListingScreen({
    super.key,
    required this.userId,
    this.postedbyuserId,
  });

  @override
  State<PropertyListingScreen> createState() => _PropertyListingScreenState();
}

class _PropertyListingScreenState extends State<PropertyListingScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<PropertyModel> _properties = [];
  bool _isLoading = true;
  String _error = "";

  bool isResidential = true;
  Map<String, dynamic> _filters = {};
  String _sortBy = "latest";

  List<Map<String, dynamic>> _savedSearches = [];

  @override
  void initState() {
    super.initState();
    _loadSavedSearches();
    _refreshFromApi();
  }

  /// ---------------- STORAGE ----------------

  Future<void> _loadSavedSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString("saved_searches");

    if (data != null) {
      final decoded = jsonDecode(data) as List;
      _savedSearches =
          decoded.map((e) => Map<String, dynamic>.from(e)).toList();
      _sortSavedSearches();
      if (mounted) setState(() {});
    }
  }

  Future<void> _persistSavedSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("saved_searches", jsonEncode(_savedSearches));
  }

  /// ---------------- SAVE / APPLY ----------------

  void _saveCurrentSearch() {
    final search = {
      "searchText": _searchController.text.trim(),
      "filters": Map<String, dynamic>.from(_filters), // ✅ FIXED
      "isResidential": isResidential,
      "sortBy": _sortBy,
      "usage": 1,
      "pinned": false,
      "time": DateTime.now().millisecondsSinceEpoch,
    };

    int index = _savedSearches.indexWhere((e) =>
    e["searchText"] == search["searchText"] &&
        jsonEncode(e["filters"]) == jsonEncode(search["filters"])); // ✅ FIXED

    if (index != -1) {
      _savedSearches[index]["usage"] =
          (_savedSearches[index]["usage"] ?? 0) + 1;
      _savedSearches[index]["time"] =
          DateTime.now().millisecondsSinceEpoch;
    } else {
      _savedSearches.add(search);
    }

    _sortSavedSearches();

    if (_savedSearches.length > 5) {
      _savedSearches = _savedSearches.take(5).toList();
    }

    _persistSavedSearches();
    if (mounted) setState(() {});
  }

  void _applySavedSearch(Map<String, dynamic> search) {
    setState(() {
      _searchController.text = search["searchText"] ?? "";
      _filters =
      Map<String, dynamic>.from(search["filters"] ?? {}); // ✅ SAFE
      isResidential = search["isResidential"] ?? true;
      _sortBy = search["sortBy"] ?? "latest";
    });

    search["usage"] = (search["usage"] ?? 0) + 1;
    search["time"] = DateTime.now().millisecondsSinceEpoch;

    _sortSavedSearches();
    _persistSavedSearches();

    _refreshFromApi();
  }

  void _deleteSearch(int index) {
    _savedSearches.removeAt(index);
    _persistSavedSearches();
    setState(() {});
  }

  void _togglePin(int index) {
    _savedSearches[index]["pinned"] =
    !(_savedSearches[index]["pinned"] ?? false);
    _sortSavedSearches();
    _persistSavedSearches();
    setState(() {});
  }

  void _sortSavedSearches() {
    _savedSearches.sort((a, b) {
      if ((b["pinned"] ?? false) != (a["pinned"] ?? false)) {
        return (b["pinned"] ?? false) ? 1 : -1;
      }
      return (b["usage"] ?? 0).compareTo(a["usage"] ?? 0);
    });
  }

  /// ---------------- SUMMARY ----------------

  String _summarizeSearch(Map<String, dynamic> search) {
    final f = search["filters"] ?? {};
    List<String> parts = [];

    if ((search["searchText"] ?? "").isNotEmpty) {
      parts.add(search["searchText"]);
    }
    if (f["city"] != null) parts.add(f["city"]);
    if (f["type"] != null) parts.add(f["type"]);
    if (f["bedrooms"] != null) parts.add("${f["bedrooms"]}BHK");
    if (f["minPrice"] != null) parts.add("₹${f["minPrice"]}+");

    parts.add(search["isResidential"] ? "Res" : "Com");

    return parts.join(" • ");
  }

  /// ---------------- API ----------------

  int? _toInt(dynamic v) =>
      v is int ? v : v is double ? v.toInt() : null;

  double? _toDouble(dynamic v) =>
      v is double ? v : v is int ? v.toDouble() : null;

  Future<void> _loadProperties() async {
    try {
      setState(() {
        _isLoading = true;
        _error = "";
      });

      final service = PropertyApiService();
      final searchText = _searchController.text.trim();

      /// ✅ FIXED LOGIC (IMPORTANT)
      String? city;
      String? location;

      if (searchText.isNotEmpty) {
        location = searchText; // search everything
        city = _filters["city"];
      } else {
        city = _filters["city"];
        location = null;
      }

      final data = await service.fetchProperties(
        postedByUserId: widget.postedbyuserId,
        city: city,
        location: location, // ✅ RESTORED
        rentOrSale: "SALE",
        category: isResidential ? "Residential" : "Commercial",
        type: _filters["type"],
        minBedrooms: _toInt(_filters["bedrooms"]),
        minBathrooms: _toInt(_filters["bathrooms"]),
        minPrice: _toDouble(_filters["minPrice"]),
        maxPrice: _toDouble(_filters["maxPrice"]),
        minArea: _toDouble(_filters["minArea"]),
        maxArea: _toDouble(_filters["maxArea"]),
      );

      if (!mounted) return;

      setState(() {
        _properties = data;
        _isLoading = false;
      });

      _saveCurrentSearch();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _refreshFromApi() => _loadProperties();

  /// ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.listingbackground,
      appBar: AppBar(
        title: const Text("Sale : Residential & Commercial"),
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildSavedSearchChips(),
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
          if (added == true) _refreshFromApi();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSavedSearchChips() {
    if (_savedSearches.isEmpty) return const SizedBox();

    return SizedBox(
      height: 55,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _savedSearches.length,
        itemBuilder: (context, i) {
          final s = _savedSearches[i];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: GestureDetector(
              onLongPress: () => _deleteSearch(i),
              child: InputChip(
                label: Text(
                  _summarizeSearch(s),
                  style: const TextStyle(fontSize: 12),
                ),
                avatar: s["pinned"] == true
                    ? const Icon(Icons.push_pin, size: 16)
                    : null,
                onPressed: () => _applySavedSearch(s),
                onDeleted: () => _togglePin(i),
              ),
            ),
          );
        },
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
                  hintText: "Search by locality, city, state",
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search),
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
      child: _toggle(["Residential", "Commercial"], isResidential, (val) {
        setState(() => isResidential = val);
        _refreshFromApi();
      }),
    );
  }

  Widget _buildList() {
    return Expanded(
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
          ? Center(child: Text(_error))
          : _properties.isEmpty
          ? const Center(child: Text("No properties found"))
          : ListView.builder(
        itemCount: _properties.length,
        itemBuilder: (_, i) {
          final p = _properties[i];
          return InkWell(
            onTap: () async {
              final updated = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PropertyDetailScreen(
                    property: p,
                    userId: widget.userId,
                  ),
                ),
              );
              if (updated == true) _refreshFromApi();
            },
            child: PropertyCard(property: p, userId: widget.userId),
          );
        },
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

  Widget _toggle(List<String> labels, bool first, Function(bool) onTap) {
    return ToggleButtons(
      isSelected: [first, !first],
      borderRadius: BorderRadius.circular(12),
      constraints: const BoxConstraints(minHeight: 35, minWidth: 90),
      selectedColor: Colors.white,
      fillColor: AppColors.primary,
      onPressed: (i) => onTap(i == 0),
      children: labels.map((e) => Text(e)).toList(),
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

/// Removes Android glow
class _NoGlowScrollBehavior extends ScrollBehavior {
  const _NoGlowScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}