import 'package:flutter/material.dart';
import 'package:property/screens/profile_screen.dart';
import 'package:property/screens/home_screen.dart';
import 'package:property/screens/legalservice_providers.dart';
import 'package:property/screens/show_banks.dart';
import 'package:property/theme/app_colors.dart';
import 'package:property/screens/webviewhtml.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = const [
      HomeScreen(),
      BankPage(),
      HomeScreen(),
      LegalServicePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ TOP APP BAR
      appBar: AppBar(
        title: const Text("AdobeOne"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      // ✅ LEFT NAVIGATION DRAWER
      drawer: Drawer(
        child: Column(
          children: [
            /// 🔹 USER HEADER
            InkWell(
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProfileScreen(),
                  ),
                );
              },
              child: UserAccountsDrawerHeader(
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                ),
                accountName: const Text("Nikhil Aggarwal"),
                accountEmail: const Text("nikhil@email.com"),
                currentAccountPicture: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40),
                ),
              ),
            ),

            /// 🔹 MAIN NAVIGATION
            _drawerItem(Icons.home, "Home", 0),
            _drawerItem(Icons.account_balance, "Bank Loans", 1),
            _drawerItem(Icons.business, "Projects", 2),
            _drawerItem(Icons.document_scanner, "Legal Documents", 3),

            const Divider(),

            /// 📄 TERMS OF USE
            ListTile(
              leading: const Icon(Icons.description_outlined),
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

            /// ⚠️ DISCLAIMER
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

            /// 🚪 LOGOUT
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement logout logic
              },
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),

      // ✅ MAIN BODY
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),

      // ✅ BOTTOM NAVIGATION
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.secondary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,

        onTap: (index) {
          setState(() => _selectedIndex = index);
        },

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance),
            label: "Loans",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: "Projects",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.document_scanner),
            label: "Documents",
          ),
        ],
      ),
    );
  }

  /// 🔹 Drawer Item Builder
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
