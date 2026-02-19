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

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    debugPrint("✅ DashboardScreen received userId: ${widget.userId}");
    _pages = [
      PropertyListingScreen(userId: widget.userId), // Home ✅
      BankPage(userId: widget.userId),              // Loans
      PropertyListingScreen(userId: widget.userId), // Projects ✅
      LegalServicePage(userId: widget.userId),      // Legal
      const EmiCalculatorScreen(),                  // Drawer only
    ];


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

  int? get _bottomNavIndex {
    if (_selectedIndex >= 4) return null;
    return _selectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.listingbackground,

      /// 🔷 APP BAR
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.listingbackground,
        foregroundColor: AppColors.primary,
        title: const Text(
          "KeyBricks",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 1,
          ),
        ),
      ),

      /// 📂 DRAWER
      drawer: Drawer(
        child: Column(
          children: [
            InkWell(
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfileScreen(userId: widget.userId),
                  ),
                );
              },
              child: UserAccountsDrawerHeader(
                decoration: const BoxDecoration(color: AppColors.primary),
                accountName: Text(
                  _userName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                accountEmail: Text(_userEmail),
                currentAccountPicture: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),

            _drawerItem(Icons.home_rounded, "Home", 0),
            _drawerItem(Icons.account_balance_rounded, "Bank Loans", 1),
            _drawerItem(Icons.business_rounded, "Projects", 2),
            _drawerItem(Icons.document_scanner_rounded, "Documentation", 3),

            /// ⭐ MY PROPERTY POSTINGS
            ListTile(
              leading: const Icon(Icons.home_work_outlined),
              title: const Text("My Property Postings"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PropertyListingScreen(
                      userId: widget.userId,
                    ),
                  ),
                );
              },
            ),

            const Divider(),

            /// 🔧 TOOLS
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

            const Divider(),

            ListTile(
              leading: const Icon(Icons.language),
              title: const Text("Website"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const WebViewPage(
                      title: "Website",
                      url: "http://15.206.9.70",
                    ),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.warning_amber_outlined),
              title: const Text("Terms of Use"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const WebViewPage(
                      title: "Terms of Use",
                      url: "http://15.206.9.70/terms-of-use.html",
                    ),
                  ),
                );
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

            /// 🔐 LOGOUT
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: () => _showLogoutDialog(),
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),

      /// 📄 BODY
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),

      /// 🔻 BOTTOM NAV
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _bottomNavIndex ?? 0,
        selectedItemColor: AppColors.secondary,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() => _selectedIndex = index);
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
        setState(() => _selectedIndex = index);
        Navigator.pop(context);
      },
    );
  }

  /// 🔐 LOGOUT CONFIRMATION
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
