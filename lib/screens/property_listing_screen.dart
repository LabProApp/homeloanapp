import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/property_model.dart';
import '../services/property_api_service.dart';
import '../theme/app_colors.dart';
import '../cards/property_card.dart';
import '../screens/property_detail_screen.dart';
import '../screens/property_add_screen.dart';
import '../screens/property_filter_dialog.dart';
import '../commons/common_widget.dart';

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
  static final _fmt = NumberFormat('#,##,###');

  final TextEditingController _searchController = TextEditingController();

  List<PropertyModel> _properties = [];
  bool _isLoading = true;
  String _error = "";

  bool isResidential = true;
  Map<String, dynamic> _filters = {};
  String _sortBy = "latest";

  List<Map<String, dynamic>> _savedSearches = [];
  bool _savedSearchesExpanded = false;

  // ---------- sort label map ----------
  static const Map<String, String> _sortLabels = {
    'latest': 'Default (Latest)',
    'date_new': 'Newest Posted',
    'date_old': 'Oldest Posted',
    'price_low': 'Price: Low → High',
    'price_high': 'Price: High → Low',
  };

  static const Map<String, String> _sortChipLabels = {
    'date_new': 'Newest',
    'date_old': 'Oldest',
    'price_low': 'Price ↑',
    'price_high': 'Price ↓',
  };

  @override
  void initState() {
    super.initState();
    _loadSavedSearches();
    _refreshFromApi();
  }

  // ============================================================
  // STORAGE
  // ============================================================

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

  // ============================================================
  // SAVE / APPLY
  // ============================================================

  void _saveCurrentSearch() {
    final search = {
      "searchText": _searchController.text.trim(),
      "filters": Map<String, dynamic>.from(_filters),
      "isResidential": isResidential,
      "sortBy": _sortBy,
      "usage": 1,
      "pinned": false,
      "time": DateTime.now().millisecondsSinceEpoch,
    };

    int index = _savedSearches.indexWhere((e) =>
        e["searchText"] == search["searchText"] &&
        jsonEncode(e["filters"]) == jsonEncode(search["filters"]));

    if (index != -1) {
      _savedSearches[index]["usage"] =
          (_savedSearches[index]["usage"] ?? 0) + 1;
      _savedSearches[index]["time"] = DateTime.now().millisecondsSinceEpoch;
    } else {
      _savedSearches.add(search);
    }

    _sortSavedSearches();

    if (_savedSearches.length > 6) {
      _savedSearches = _savedSearches.take(6).toList();
    }

    _persistSavedSearches();
    if (mounted) setState(() {});
  }

  void _applySavedSearch(Map<String, dynamic> search) {
    setState(() {
      _searchController.text = search["searchText"] ?? "";
      _filters = Map<String, dynamic>.from(search["filters"] ?? {});
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

  // ============================================================
  // SUMMARY
  // ============================================================

  String _summarizeSearch(Map<String, dynamic> search) {
    final f = search["filters"] ?? {};
    List<String> parts = [];

    if ((search["searchText"] ?? "").isNotEmpty) parts.add(search["searchText"]);
    if (f["city"] != null) parts.add(f["city"]);
    if (f["type"] != null) parts.add(f["type"]);
    if (f["bedrooms"] != null) parts.add("${f["bedrooms"]}BHK");
    if (f["minPrice"] != null) parts.add("₹${f["minPrice"]}+");

    return parts.join(" • ");
  }

  // ============================================================
  // ACTIVE FILTER COUNT
  // ============================================================

  int get _activeFilterCount {
    const keys = [
      'state', 'city', 'type', 'bedrooms', 'bathrooms',
      'minPrice', 'maxPrice', 'minArea', 'maxArea',
      'furnishing', 'constructionStatus', 'preferredTenants',
    ];
    return keys.where((k) {
      final v = _filters[k];
      return v != null && v.toString().isNotEmpty;
    }).length;
  }

  // ============================================================
  // API
  // ============================================================

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

      String? city;
      String? location;

      if (searchText.isNotEmpty) {
        location = searchText;
        city = _filters["city"];
      } else {
        city = _filters["city"];
        location = null;
      }

      final data = await service.fetchProperties(
        postedByUserId: widget.postedbyuserId,
        city: city,
        location: location,
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

      _sortResults();
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

  // ============================================================
  // SORT
  // ============================================================

  void _sortResults() {
    switch (_sortBy) {
      case 'price_low':
        _properties.sort((a, b) =>
            (a.price ?? double.maxFinite).compareTo(b.price ?? double.maxFinite));
      case 'price_high':
        _properties.sort((a, b) =>
            (b.price ?? 0).compareTo(a.price ?? 0));
      case 'date_new':
        _properties.sort((a, b) =>
            (b.postDate ?? '').compareTo(a.postDate ?? ''));
      case 'date_old':
        _properties.sort((a, b) =>
            (a.postDate ?? '').compareTo(b.postDate ?? ''));
      default:
        break;
    }
    if (mounted) setState(() {});
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.listingbackground,
      appBar: AppBar(
        title: const Text("Sale : Residential & Commercial"),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildActiveFilterChips(),
          _buildSavedSearchPanel(),
          _buildToggles(),
          _buildResultsBar(),
          _buildList(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
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

  // ============================================================
  // SEARCH BAR
  // ============================================================

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
      child: Row(
        children: [
          Expanded(
            child: AppSearchField(
              controller: _searchController,
              hintText: "Search by locality, city, state",
              onSubmitted: (_) => _refreshFromApi(),
            ),
          ),
          const SizedBox(width: 8),
          // Sort button — highlighted when not "latest"
          _sortIconBtn(),
          const SizedBox(width: 8),
          // Filter button — badge when filters active
          _filterIconBtn(),
        ],
      ),
    );
  }

  // ============================================================
  // ACTIVE FILTER CHIPS
  // ============================================================

  Widget _buildActiveFilterChips() {
    final fmt = _fmt;
    final chips = <Widget>[];

    // Sort chip at the START (if sort is not default)
    if (_sortBy != 'latest') {
      final sortLabel = _sortChipLabels[_sortBy] ?? _sortBy;
      chips.add(
        Padding(
          padding: const EdgeInsets.only(right: 6),
          child: InputChip(
            avatar: const Icon(Icons.sort_rounded, size: 14),
            label: Text(sortLabel),
            labelStyle: const TextStyle(fontSize: 12, color: AppColors.primary),
            backgroundColor: AppColors.primary.withOpacity(0.1),
            side: const BorderSide(color: AppColors.primary, width: 1),
            deleteIcon: const Icon(Icons.close, size: 14),
            onDeleted: () {
              setState(() => _sortBy = 'latest');
              _refreshFromApi();
            },
          ),
        ),
      );
    }

    // Filter chips
    void addChip(String key, String label) {
      chips.add(
        Padding(
          padding: const EdgeInsets.only(right: 6),
          child: InputChip(
            label: Text(label),
            labelStyle: const TextStyle(fontSize: 12, color: AppColors.primary),
            backgroundColor: AppColors.primary.withOpacity(0.1),
            side: const BorderSide(color: AppColors.primary, width: 1),
            deleteIcon: const Icon(Icons.close, size: 14),
            onDeleted: () {
              setState(() => _filters.remove(key));
              _refreshFromApi();
            },
          ),
        ),
      );
    }

    final f = _filters;
    if (f['city'] != null && f['city'].toString().isNotEmpty)
      addChip('city', 'City: ${f['city']}');
    if (f['type'] != null && f['type'].toString().isNotEmpty)
      addChip('type', '${f['type']}');
    if (f['bedrooms'] != null && f['bedrooms'].toString().isNotEmpty)
      addChip('bedrooms', '${f['bedrooms']}+ BHK');
    if (f['bathrooms'] != null && f['bathrooms'].toString().isNotEmpty)
      addChip('bathrooms', '${f['bathrooms']}+ Bath');

    // Price range: show combined chip if either min or max present
    final hasMinPrice = f['minPrice'] != null && f['minPrice'].toString().isNotEmpty;
    final hasMaxPrice = f['maxPrice'] != null && f['maxPrice'].toString().isNotEmpty;
    if (hasMinPrice || hasMaxPrice) {
      final min = hasMinPrice ? fmt.format(num.tryParse(f['minPrice'].toString()) ?? 0) : '0';
      final max = hasMaxPrice ? fmt.format(num.tryParse(f['maxPrice'].toString()) ?? 0) : '∞';
      chips.add(
        Padding(
          padding: const EdgeInsets.only(right: 6),
          child: InputChip(
            label: Text('₹$min–₹$max'),
            labelStyle: const TextStyle(fontSize: 12, color: AppColors.primary),
            backgroundColor: AppColors.primary.withOpacity(0.1),
            side: const BorderSide(color: AppColors.primary, width: 1),
            deleteIcon: const Icon(Icons.close, size: 14),
            onDeleted: () {
              setState(() {
                _filters.remove('minPrice');
                _filters.remove('maxPrice');
              });
              _refreshFromApi();
            },
          ),
        ),
      );
    }

    // Area range
    final hasMinArea = f['minArea'] != null && f['minArea'].toString().isNotEmpty;
    final hasMaxArea = f['maxArea'] != null && f['maxArea'].toString().isNotEmpty;
    if (hasMinArea || hasMaxArea) {
      final min = f['minArea']?.toString() ?? '0';
      final max = f['maxArea']?.toString() ?? '∞';
      chips.add(
        Padding(
          padding: const EdgeInsets.only(right: 6),
          child: InputChip(
            label: Text('$min–$max sqft'),
            labelStyle: const TextStyle(fontSize: 12, color: AppColors.primary),
            backgroundColor: AppColors.primary.withOpacity(0.1),
            side: const BorderSide(color: AppColors.primary, width: 1),
            deleteIcon: const Icon(Icons.close, size: 14),
            onDeleted: () {
              setState(() {
                _filters.remove('minArea');
                _filters.remove('maxArea');
              });
              _refreshFromApi();
            },
          ),
        ),
      );
    }

    if (f['furnishing'] != null && f['furnishing'].toString().isNotEmpty)
      addChip('furnishing', '${f['furnishing']}');
    if (f['constructionStatus'] != null && f['constructionStatus'].toString().isNotEmpty)
      addChip('constructionStatus', '${f['constructionStatus']}');
    if (f['state'] != null && f['state'].toString().isNotEmpty)
      addChip('state', '${f['state']}');

    final hasAny = chips.isNotEmpty;
    if (!hasAny) return const SizedBox();

    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          ...chips,
          // Clear all button at the end
          Center(
            child: TextButton(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.error,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () {
                setState(() {
                  _filters.clear();
                  _sortBy = 'latest';
                });
                _refreshFromApi();
              },
              child: const Text("Clear all", style: TextStyle(fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SAVED SEARCH PANEL — expandable list
  // ============================================================

  Widget _buildSavedSearchPanel() {
    if (_savedSearches.isEmpty) return const SizedBox();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Tappable header ──────────────────────────────────────
        Material(
          color: Colors.white,
          child: InkWell(
            onTap: () => setState(
                () => _savedSearchesExpanded = !_savedSearchesExpanded),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
              child: Row(
                children: [
                  const Icon(Icons.history_rounded,
                      size: 15, color: AppColors.textMuted),
                  const SizedBox(width: 6),
                  const Text(
                    "Saved Filters",
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "${_savedSearches.length}",
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  AnimatedRotation(
                    turns: _savedSearchesExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    child: const Icon(Icons.keyboard_arrow_down_rounded,
                        size: 20, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ),
        ),

        // ── Animated expandable list ─────────────────────────────
        AnimatedSize(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: _savedSearchesExpanded
              ? Material(
                  color: Colors.white,
                  elevation: 3,
                  shadowColor: Colors.black.withOpacity(0.08),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Divider(height: 1, thickness: 0.5),
                      ...List.generate(_savedSearches.length, (i) {
                        final s = _savedSearches[i];
                        final summary = _summarizeSearch(s);

                        return InkWell(
                          onTap: () {
                            setState(() => _savedSearchesExpanded = false);
                            _applySavedSearch(s);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 11),
                            child: Row(
                              children: [
                                const Icon(Icons.history_rounded,
                                    size: 16,
                                    color: AppColors.textMuted),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        summary.isEmpty
                                            ? "All properties"
                                            : summary,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textPrimary,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if ((s["sortBy"] ?? "latest") !=
                                          "latest")
                                        Text(
                                          "Sort: ${_sortLabels[s['sortBy']] ?? s['sortBy']}",
                                          style: const TextStyle(
                                              fontSize: 11,
                                              color: AppColors.textMuted),
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () => _deleteSearch(i),
                                  child: const Padding(
                                    padding: EdgeInsets.all(4),
                                    child: Icon(Icons.close_rounded,
                                        size: 16,
                                        color: AppColors.textMuted),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 4),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  // ============================================================
  // TOGGLES / RESULTS BAR / LIST / ERROR / EMPTY
  // ============================================================

  Widget _buildToggles() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: _toggle(["Residential", "Commercial"], isResidential, (val) {
        setState(() => isResidential = val);
        _refreshFromApi();
      }),
    );
  }

  Widget _buildResultsBar() {
    if (_isLoading || _error.isNotEmpty) return const SizedBox();
    final count = _properties.length;
    if (count == 0) return const SizedBox();
    final hasFilters = _activeFilterCount > 0 || _searchController.text.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 2),
      child: Row(
        children: [
          Text(
            hasFilters
                ? '$count ${count == 1 ? "property" : "properties"} found'
                : '$count ${isResidential ? "residential" : "commercial"} ${count == 1 ? "property" : "properties"}',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
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
                        physics: const BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics()),
                        cacheExtent: 800,
                        addAutomaticKeepAlives: false,
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
                            child: PropertyCard(
                                property: p, userId: widget.userId),
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
              const Icon(Icons.wifi_off_rounded,
                  size: 64, color: AppColors.textMuted),
              const SizedBox(height: 16),
              const Text(
                "Couldn't load properties",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary),
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
              Icon(Icons.home_work_outlined,
                  size: 72, color: AppColors.textMuted),
              SizedBox(height: 16),
              Text(
                "No properties found",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary),
              ),
              SizedBox(height: 8),
              Text(
                "Try adjusting your filters or search term.",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // DIALOGS
  // ============================================================

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
      builder: (sheetCtx) {
        return StatefulBuilder(builder: (sheetCtx, setSheetState) {
          Widget sortTile(IconData icon, String label, String value) {
            final isSelected = _sortBy == value;
            return ListTile(
              leading: Icon(icon,
                  color: isSelected ? AppColors.primary : AppColors.textMuted),
              title: Text(
                label,
                style: TextStyle(
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textPrimary,
                ),
              ),
              trailing: isSelected
                  ? const Icon(Icons.check_rounded, color: AppColors.primary)
                  : null,
              onTap: () {
                setState(() => _sortBy = value);
                Navigator.pop(sheetCtx);
                _sortResults();
              },
            );
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Title row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Text(
                      "Sort By",
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    if (_sortBy != 'latest')
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppColors.primary, width: 1),
                        ),
                        child: Text(
                          _sortLabels[_sortBy] ?? _sortBy,
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              sortTile(Icons.access_time_rounded, "Default (Latest)", "latest"),
              sortTile(Icons.calendar_today_rounded, "Newest Posted", "date_new"),
              sortTile(Icons.history_rounded, "Oldest Posted", "date_old"),
              sortTile(Icons.trending_up_rounded, "Price: Low → High", "price_low"),
              sortTile(Icons.trending_down_rounded, "Price: High → Low", "price_high"),
              const SizedBox(height: 16),
            ],
          );
        });
      },
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  Widget _toggle(List<String> labels, bool first, Function(bool) onTap) {
    return ToggleButtons(
      isSelected: [first, !first],
      borderRadius: BorderRadius.circular(12),
      constraints: const BoxConstraints(minHeight: 36, minWidth: 100),
      selectedColor: Colors.white,
      color: AppColors.textSecondary,
      fillColor: AppColors.primary,
      borderColor: AppColors.border,
      selectedBorderColor: AppColors.primary,
      onPressed: (i) => onTap(i == 0),
      children: labels
          .map((e) => Text(e,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w500)))
          .toList(),
    );
  }

  /// Standard icon button (used for sort, highlighted when sort != latest)
  Widget _sortIconBtn() {
    final isActive = _sortBy != 'latest';
    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.primary.withOpacity(0.1)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isActive
            ? Border.all(color: AppColors.primary, width: 1)
            : null,
      ),
      child: IconButton(
        icon: Icon(
          Icons.sort,
          color: isActive ? AppColors.primary : null,
        ),
        onPressed: _openSortSheet,
      ),
    );
  }

  /// Filter icon button with amber badge when filters are active
  Widget _filterIconBtn() {
    final count = _activeFilterCount;
    final isActive = count > 0;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primary.withOpacity(0.1)
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: isActive
                ? Border.all(color: AppColors.primary, width: 1)
                : null,
          ),
          child: IconButton(
            icon: Icon(
              Icons.filter_alt_outlined,
              color: isActive ? AppColors.primary : null,
            ),
            onPressed: _openFilterDialog,
          ),
        ),
        if (isActive)
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Plain icon button (kept for potential reuse)
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
