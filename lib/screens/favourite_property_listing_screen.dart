import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;
import '../models/property_model.dart';
import '../services/property_api_service.dart';
import '../theme/app_colors.dart';
import '../cards/property_card.dart';
import '../screens/property_detail_screen.dart';
import '../commons/common_widget.dart';

class FavouritePropertyListingScreen extends StatefulWidget {
  final int userId;

  const FavouritePropertyListingScreen({
    super.key,
    required this.userId,
  });

  @override
  State<FavouritePropertyListingScreen> createState() =>
      _FavouritePropertyListingScreenState();
}

class _FavouritePropertyListingScreenState
    extends State<FavouritePropertyListingScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<PropertyModel> _allProperties = [];
  List<PropertyModel> _properties = [];
  bool _isLoading = true;
  String _error = "";
  bool _headerCollapsed = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadProperties();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final pixels = _scrollController.position.pixels;
    final direction = _scrollController.position.userScrollDirection;
    if (pixels <= 0 && _headerCollapsed) {
      setState(() => _headerCollapsed = false);
    } else if (direction == ScrollDirection.reverse && !_headerCollapsed) {
      setState(() => _headerCollapsed = true);
    } else if (direction == ScrollDirection.forward && _headerCollapsed) {
      setState(() => _headerCollapsed = false);
    }
  }

  Future<void> _loadProperties() async {
    setState(() { _isLoading = true; _error = ""; });
    try {
      final data =
          await PropertyApiService().fetchFavouriteProperties(widget.userId);
      if (!mounted) return;
      setState(() {
        _allProperties = data;
        _isLoading = false;
      });
      _applySearch();
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  void _applySearch() {
    if (!mounted) return;
    final q = _searchController.text.trim().toLowerCase();
    setState(() {
      _properties = q.isEmpty
          ? List.from(_allProperties)
          : _allProperties.where((p) =>
              (p.title?.toLowerCase().contains(q) ?? false) ||
              (p.city?.toLowerCase().contains(q) ?? false) ||
              (p.location?.toLowerCase().contains(q) ?? false) ||
              (p.address?.toLowerCase().contains(q) ?? false) ||
              (p.type?.toLowerCase().contains(q) ?? false),
            ).toList();
    });
  }

  Future<void> _toggleFavourite(int propertyId) async {
    await PropertyApiService.toggleFavourite(
      userId: widget.userId,
      propertyId: propertyId,
    );
    _loadProperties();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.listingbackground,
      appBar: GradientAppBar(
        title: 'My Favourites',
      ),
      body: Column(
        children: [
          CollapsibleHeader(
            collapsed: _headerCollapsed,
            child: _buildSearchBar(),
          ),
          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
      child: AppSearchField(
        controller: _searchController,
        hintText: "Search by title, city or type",
        onChanged: (_) => _applySearch(),
        onSubmitted: (_) => _applySearch(),
      ),
    );
  }

  Widget _buildList() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error.isNotEmpty) return AppErrorState(message: _error, onRetry: _loadProperties);
    if (_properties.isEmpty) {
      final isFiltered = _searchController.text.trim().isNotEmpty;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.favorite_border_rounded,
                    size: 40, color: AppColors.primary),
              ),
              const SizedBox(height: 16),
              Text(
                isFiltered ? 'No favourites match your search' : 'No favourites yet',
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                isFiltered
                    ? 'Try a different search term'
                    : 'Tap the heart icon on any property to save it here',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: AppColors.textMuted, height: 1.5),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadProperties,
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.fromLTRB(8, 4, 8, 80 + MediaQuery.viewPaddingOf(context).bottom),
        itemCount: _properties.length,
        itemBuilder: (context, index) {
          final property = _properties[index];

          return Dismissible(
            key: ValueKey(property.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              color: Colors.red,
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            confirmDismiss: (_) async {
              return await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Remove from favourites?"),
                  content: const Text(
                      "Do you want to remove this property from favourites?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text("Remove"),
                    ),
                  ],
                ),
              );
            },
            onDismissed: (_) async {
              await _toggleFavourite(property.id!);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Removed from favourites")),
                );
              }
            },
            // Pass userId so the card's heart icon toggles favourite via API
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
                if (updated == true) _loadProperties();
              },
              child: PropertyCard(
                property: property,
                userId: widget.userId,
                initialIsFavourite: true,
              ),
            ),
          );
        },
      ),
    );
  }
}
