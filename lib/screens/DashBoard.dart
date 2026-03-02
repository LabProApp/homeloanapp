import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'userLogin_screen.dart';
import 'userProfile_screen.dart';
import 'properyListing_screen.dart';
import 'legalServiceProviders_listing.dart';
import 'banksListing_screen.dart';
import 'emi_calculator_screen.dart';
import 'webviewhtml.dart';
import 'favourite_property_listing_screen.dart';
import 'interested_users_screen.dart';

import '../theme/app_colors.dart';

class DashboardScreen extends StatefulWidget {
  final String userId;

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

  String? _postedByUserId;

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
    _loadUserInfo();
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
          ),
        ),
      ),

      drawer: Drawer(
        child: Column(
          children: [
            const SizedBox(height: 40),

            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Profile"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfileScreen(userId: widget.userId),
                  ),
                );
              },
            ),

            const Divider(),

            _drawerItem(Icons.home_rounded, "Home", 0),
            _drawerItem(Icons.account_balance_rounded, "Bank Loans", 1),
            _drawerItem(Icons.business_rounded, "Projects", 2),
            _drawerItem(Icons.document_scanner_rounded, "Documentation", 3),

            ListTile(
              leading: const Icon(Icons.home_work_outlined),
              title: const Text("My Property Postings"),
              onTap: () {
                setState(() {
                  _postedByUserId = widget.userId;
                  _selectedIndex = 0;
                });
                Navigator.pop(context);
              },
            ),

            const Divider(),

            /// ⭐ NEW OPTIONS
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text("My Favourite Properties"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FavouritePropertyListingScreen(
                      userId: widget.userId,
                    ),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.people_alt),
              title: const Text("Users Interested"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BrokerLeadsScreen(
                      userId: widget.userId,
                    ),
                  ),
                );
              },
            ),

            const Divider(),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "TOOLS",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),

            ListTile(
              leading: const Icon(Icons.calculate),
              title: const Text("EMI Calculator"),
              selected: _selectedIndex == 4,
              selectedColor: AppColors.secondary,
              onTap: () {
                setState(() => _selectedIndex = 4);
                Navigator.pop(context);
              },
            ),

            const Spacer(),

            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _appVersion,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ),

            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: () => _showLogoutDialog(),
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),

      body: _buildPage(),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.secondary,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _postedByUserId = null;
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_outlined),
            activeIcon: Icon(Icons.account_balance),
            label: "Loans",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business_outlined),
            activeIcon: Icon(Icons.business),
            label: "Projects",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.document_scanner_outlined),
            activeIcon: Icon(Icons.document_scanner),
            label: "Documents",
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      selected: _selectedIndex == index,
      selectedColor: AppColors.secondary,
      onTap: () {
        setState(() {
          _postedByUserId = null;
          _selectedIndex = index;
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