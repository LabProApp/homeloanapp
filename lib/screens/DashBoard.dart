import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'userLogin_screen.dart';
import 'userProfile_screen.dart';
import 'properyListing_screen.dart';
import 'legalServiceProviders_listing.dart';
import 'banksListing_screen.dart';
import 'emi_calculator_screen.dart';
import 'favourite_property_listing_screen.dart';
import 'interested_users_screen.dart';

import '../theme/app_colors.dart';

class DashboardScreen extends StatefulWidget {
  final int userId;

  const DashboardScreen({
    super.key,
    required this.userId,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  String _appVersion = "";

  String _userName = "User";
  String _userEmail = "";

  int? _postedByUserId;
  Widget? _currentPage;

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
    _loadUserInfo();
    _currentPage = _buildPage();
  }

  Future<void> _loadAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = "v${info.version} (${info.buildNumber})";
    });
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString("userName") ?? "User";
      _userEmail = prefs.getString("userEmail") ?? "";
    });
  }

  Widget _buildPage() {
    switch (_selectedIndex) {
      case 0:
        return PropertyListingScreen(
          key: UniqueKey(),
          userId: widget.userId,
          postedbyuserId: _postedByUserId,
        );
      case 1:
        return BankPage(userId: widget.userId);
      case 2:
        return PropertyListingScreen(
          key: UniqueKey(),
          userId: widget.userId,
        );
      case 3:
        return LegalServicePage(userId: widget.userId);
      case 4:
        return const EmiCalculatorScreen();
      default:
        return PropertyListingScreen(userId: widget.userId);
    }
  }

  void _setPage(Widget page) {
    setState(() {
      _currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.listingbackground,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.listingbackground,
        foregroundColor: AppColors.primary,
        title: const Text(
          "KeyBricks",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 22,
            letterSpacing: 1.2,
            color: AppColors.primary,
          ),
        ),
      ),

      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewPadding.bottom + 12,
            ),
            children: [
              const SizedBox(height: 12),

              /// USER HEADER
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: const Icon(Icons.account_circle_rounded,
                          color: AppColors.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _userName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            _userEmail,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              _drawerItem(Icons.dashboard_rounded, "Home", 0),
              _drawerItem(Icons.account_balance_wallet_rounded, "Bank Loans", 1),
              _drawerItem(Icons.apartment_rounded, "Rentals / PG", 2),
              _drawerItem(Icons.assignment_rounded, "Documentation", 3),

              ListTile(
                dense: true,
                leading: const Icon(Icons.business_center_rounded),
                title: const Text("My Property Postings"),
                onTap: () {
                  setState(() {
                    _postedByUserId = widget.userId;
                    _selectedIndex = 0;
                    _currentPage = _buildPage();
                  });
                  Navigator.pop(context);
                },
              ),

              const Divider(),

              ListTile(
                dense: true,
                leading: const Icon(Icons.favorite_rounded),
                title: const Text("My Favourite Properties"),
                onTap: () {
                  Navigator.pop(context);
                  _setPage(FavouritePropertyListingScreen(
                    userId: widget.userId,
                  ));
                },
              ),

              ListTile(
                dense: true,
                leading: const Icon(Icons.groups_rounded),
                title: const Text("Customer Inquiries"),
                onTap: () {
                  Navigator.pop(context);
                  _setPage(BrokerLeadsScreen(
                    brokerId: widget.userId,
                  ));
                },
              ),

              const Divider(),

              Padding(
                padding: const EdgeInsets.only(left: 16, top: 8),
                child: Text(
                  _appVersion,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ),

              const SizedBox(height: 8),

              ListTile(
                dense: true,
                leading: const Icon(Icons.logout_rounded, color: Colors.red),
                title: const Text(
                  "Logout",
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () => _showLogoutDialog(),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),

      body: _currentPage ?? _buildPage(),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.secondary,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _postedByUserId = null;
            _selectedIndex = index;
            _currentPage = _buildPage();
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard_rounded),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet_rounded),
            label: "Loans",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.apartment_outlined),
            activeIcon: Icon(Icons.apartment_rounded),
            label: "Rentals/PG",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment_rounded),
            label: "Documents",
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, int index) {
    return ListTile(
      dense: true,
      leading: Icon(icon),
      title: Text(title),
      selected: _selectedIndex == index,
      selectedColor: AppColors.secondary,
      onTap: () {
        setState(() {
          _postedByUserId = null;
          _selectedIndex = index;
          _currentPage = _buildPage();
        });
        Navigator.pop(context);
      },
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              await _logout();
            },
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }
}