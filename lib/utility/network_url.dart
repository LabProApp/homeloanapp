/*
import 'package:flutter/material.dart';
import 'package:property/models/property_model.dart';
import 'package:property/services/property_api_service.dart';
import 'package:property/widgets/property_card.dart';
import 'package:property/screens/propertyDetail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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

  Future<void> _loadProperties() async {
    try {
      final data = await PropertyApiService().fetchProperties();
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

  void _search(String query) {
    final result = _allProperties.where((p) {
      return p.title.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      _filteredProperties = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          "Property Hub",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          /// SEARCH BAR
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 45,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _search,
                      decoration: const InputDecoration(
                        hintText: "Search properties",
                        border: InputBorder.none,
                        icon: Icon(Icons.search),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// PROPERTY LIST
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error.isNotEmpty
                ? Center(child: Text(_error))
                : _filteredProperties.isEmpty
                ? const Center(child: Text("No properties found"))
                : ListView.builder(
              itemCount: _filteredProperties.length,
              itemBuilder: (context, index) {
                final property = _filteredProperties[index];
                return InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PropertyDetailScreen(
                          property: property,
                        ),
                      ),
                    );
                  },
                  child: PropertyCard(property: property),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
*/
