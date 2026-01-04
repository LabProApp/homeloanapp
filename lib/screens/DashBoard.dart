import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:property/screens/userProfile_screen.dart';
import 'package:property/screens/properyListing_screen.dart';
import 'package:property/screens/legalServiceProviders_listing.dart';
import 'package:property/screens/banksListing_screen.dart';
import 'package:property/screens/webviewhtml.dart';
import 'package:property/screens/emi_calculator_screen.dart';
import 'package:property/theme/app_colors.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  String _appVersion = "";

  @override
  void initState() {
    super.initState();
    _pages = const [
      HomeScreen(),           // 0
      BankPage(),             // 1
      HomeScreen(),           // 2 Projects
      LegalServicePage(),     // 3 Documents
      EmiCalculatorScreen(),  // 4 EMI Calculator (drawer only)
    ];
    _loadAppVersion();
  }

  /// 🔹 Load app version from pubspec.yaml
  Future<void> _loadAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = "v${info.version} (${info.buildNumber})";
    });
  }

  /// ✅ Bottom nav index mapping
  int? get _bottomNavIndex {
    if (_selectedIndex >= 4) return null;
    return _selectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,

      /// 🔷 APP BAR
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primary,
        title: const Text(
          "ABODE ONE",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 1,
          ),
        ),
        foregroundColor: Colors.white,
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
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
              child: UserAccountsDrawerHeader(
                decoration: const BoxDecoration(color: AppColors.primary),
                accountName: const Text(
                  "Nikhil Aggarwal",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                accountEmail: const Text("nikhil@email.com"),
                currentAccountPicture: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: AppColors.primary),
                ),
              ),
            ),

            _drawerItem(Icons.home_rounded, "Home", 0),
            _drawerItem(Icons.account_balance_rounded, "Bank Loans", 1),
            _drawerItem(Icons.business_rounded, "Projects", 2),
            _drawerItem(Icons.document_scanner_rounded, "Legal Documents", 3),

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

            /// 🔹 APP VERSION (BOTTOM LEFT)
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _appVersion,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),

            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),

      /// 📄 PAGE STACK
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

  /// 🔹 Drawer item builder
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
}
