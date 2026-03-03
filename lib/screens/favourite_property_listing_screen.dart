import 'package:flutter/material.dart';
import '../models/property_model.dart';
import '../services/property_api_service.dart';
import '../theme/app_colors.dart';
import '../cards/property_card.dart';
import '../screens/propertyDetail_screen.dart';

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

  List<PropertyModel> _properties = [];
  bool _isLoading = true;
  String _error = "";

  @override
  void initState() {
    super.initState();
    _refreshFromApi();
  }

  Future<void> _loadProperties() async {
    try {
      setState(() {
        _isLoading = true;
        _error = "";
      });

      final service = PropertyApiService();

      final data = await service.fetchFavouriteProperties(widget.userId!);

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

  Future<void> _toggleFavourite(int propertyId) async {
    await PropertyApiService.toggleFavourite(
      userId: widget.userId,
      propertyId: propertyId,
    );
    _refreshFromApi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.listingbackground,
      appBar: AppBar(
        title: const Text("My Favourites"),
        foregroundColor: Colors.white,
        backgroundColor: AppColors.primary,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildList(),
        ],
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
                  hintText: "Search favourite properties",
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search),
                ),
              ),
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
            ? Center(child: Text(_error))
            : _properties.isEmpty
            ? const Center(
          child: Text(
            "No favourite properties yet",
            style: TextStyle(fontSize: 16),
          ),
        )
            : ListView.builder(
          padding: const EdgeInsets.symmetric(
              horizontal: 8, vertical: 4),
          itemCount: _properties.length,
          itemBuilder: (context, index) {
            final property = _properties[index];

            return Dismissible(
              key: ValueKey(property.id),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding:
                const EdgeInsets.symmetric(horizontal: 20),
                color: Colors.red,
                child: const Icon(Icons.delete,
                    color: Colors.white),
              ),
              confirmDismiss: (_) async {
                return await showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text(
                        "Remove from favourites?"),
                    content: const Text(
                        "Do you want to remove this property from favourites?"),
                    actions: [
                      TextButton(
                        onPressed: () =>
                            Navigator.pop(context, false),
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () =>
                            Navigator.pop(context, true),
                        child: const Text("Remove"),
                      ),
                    ],
                  ),
                );
              },
              onDismissed: (_) async {
                await _toggleFavourite(property.id!);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                    Text("Removed from favourites"),
                  ),
                );
              },
              child: Stack(
                children: [
                  InkWell(
                    onTap: () async {
                      final updated =
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              PropertyDetailScreen(
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

                  /// ❤️ HEART REMOVE BUTTON
                  Positioned(
                    top: 6,
                    right: 6,
                    child: GestureDetector(
                      onTap: () async {
                        await _toggleFavourite(
                            property.id!);

                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          const SnackBar(
                            content: Text(
                                "Removed from favourites"),
                          ),
                        );
                      },
                      child: const CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.favorite,
                          color: Colors.red,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}