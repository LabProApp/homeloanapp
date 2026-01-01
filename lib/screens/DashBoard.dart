import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _pages = const [
      HomeScreen(),           // 0
      BankPage(),             // 1
      HomeScreen(),           // 2 Projects placeholder
      LegalServicePage(),     // 3 Legal & Documents
      EmiCalculatorScreen(),  // 4 EMI Calculator (drawer only)
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "ABODE ONE",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
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
                accountName: const Text("Nikhil Aggarwal"),
                accountEmail: const Text("nikhil@email.com"),
                currentAccountPicture: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40),
                ),
              ),
            ),

            // MAIN NAVIGATION
            _drawerItem(Icons.home, "Home", 0),
            _drawerItem(Icons.account_balance, "Bank Loans", 1),
            _drawerItem(Icons.business, "Projects", 2),
            _drawerItem(Icons.document_scanner, "Legal Documents", 3),

            const Divider(),

            // TOOLS SECTION
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "TOOLS",
                  style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                ),
              ),
            ),

            ListTile(
              leading: const Icon(Icons.calculate),
              title: const Text("EMI Calculator"),
              selected: _selectedIndex == 4,
              selectedColor: AppColors.secondary,
              onTap: () {
                setState(() => _selectedIndex = 4); // jump to last page
                Navigator.pop(context); // close drawer
              },
            ),

            const Divider(),

            // WEBSITE
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

            // TERMS
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

            // LOGOUT
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex >= 4 ? 3 : _selectedIndex, // cap at 3 for bottom nav
        selectedItemColor: AppColors.secondary,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _selectedIndex = index; // directly map to first 4 pages
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance), label: "Loans"),
          BottomNavigationBarItem(icon: Icon(Icons.business), label: "Projects"),
          BottomNavigationBarItem(icon: Icon(Icons.document_scanner), label: "Documents"),
        ],
      ),
    );
  }

  // Drawer item builder
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
