import 'package:flutter/material.dart';
import '../models/property_model.dart';
import '../services/property_api_service.dart';
import '../theme/app_colors.dart';
import '../cards/property_card.dart';
import '../screens/propertyDetail_screen.dart';
import '../screens/propertyAdd_screen.dart';

class PropertyListingScreen extends StatefulWidget {
  final String? userId; // ✅ OPTIONAL userId

  const PropertyListingScreen({
    super.key,
    this.userId,
  });

  @override
  State<PropertyListingScreen> createState() => _PropertyListingScreenState();
}

class _PropertyListingScreenState extends State<PropertyListingScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<PropertyModel> _allProperties = [];
  List<PropertyModel> _filteredProperties = [];

  bool _isLoading = true;
  String _error = "";

  @override
  void initState() {
    super.initState();
    _loadProperties();
  }

  /// 🔄 LOAD PROPERTIES (ALL or USER-SPECIFIC)
  Future<void> _loadProperties() async {
    try {
      final service = PropertyApiService();

      final data = widget.userId != null
          ? await service.fetchProperties( userId: widget.userId,)
          : await service.fetchProperties();

      setState(() {
        _allProperties = data;
        _filteredProperties = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  /// 🔍 SEARCH FILTER
  void _search(String query) {
    setState(() {
      _filteredProperties = _allProperties.where((p) {
        return (p.title ?? '')
            .toLowerCase()
            .contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,

      /// 🔶 BODY
      body: Column(
        children: [
          /// 🔍 SEARCH BAR + ACTIONS
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
            child: Row(
              children: [
                /// 🔍 SEARCH
                Expanded(
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _search,
                      textAlignVertical: TextAlignVertical.center,
                      decoration: const InputDecoration(
                        hintText: "Search properties...",
                        border: InputBorder.none,
                        isDense: true,
                        prefixIcon: Icon(Icons.search, size: 20),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                _actionButton(
                  icon: Icons.favorite_border,
                  onTap: () {},
                ),

                const SizedBox(width: 8),

                _actionButton(
                  icon: Icons.filter_list,
                  onTap: () {},
                ),
              ],
            ),
          ),

          /// 🔶 PROPERTY LIST
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
                : _filteredProperties.isEmpty
                ? const Center(
              child: Text(
                "No properties found",
                style: TextStyle(fontSize: 16),
              ),
            )
                : ListView.builder(
              padding:
              const EdgeInsets.symmetric(vertical: 6),
              physics:
              const BouncingScrollPhysics(),
              itemCount: _filteredProperties.length,
              itemBuilder: (context, index) {
                final property =
                _filteredProperties[index];

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
                      width: double.infinity,
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

      /// ➕ ADD PROPERTY BUTTON
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
                  userId: widget.userId, // ✅ pass userId
                ),
              ),
            );
          },
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 36,
          ),
        ),
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
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 6,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: IconButton(
      padding: EdgeInsets.zero,
      icon: Icon(icon, size: 20, color: Colors.black),
      onPressed: onTap,
    ),
  );
}
