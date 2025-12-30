import 'package:flutter/material.dart';
import 'package:property/screens/profile_screen.dart';
import 'package:property/screens/home_screen.dart';
import 'package:property/screens/show_banks.dart';
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
      HomeScreen(),
      BankPage(),
      Center(child: Text("Projects", style: TextStyle(fontSize: 22))),
      Center(child: Text("documents", style: TextStyle(fontSize: 22))),
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
      ),

      // ✅ LEFT NAVIGATION BAR (DRAWER)
      drawer: Drawer(
        child: Column(
          children: [
            // Drawer Header
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: AppColors.primary,
              ),
              accountName: const Text("Nikhil Aggarwal"),
              accountEmail: const Text("nikhil@email.com"),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40),
              ),
            ),

            // Drawer Items
            _drawerItem(
              icon: Icons.home,
              title: "Home",
              index: 0,
            ),
            _drawerItem(
              icon: Icons.account_balance,
              title: "Bank Loans",
              index: 1,
            ),
            _drawerItem(
              icon: Icons.business,
              title: "Projects",
              index: 2,
            ),
            _drawerItem(
              icon: Icons.document_scanner,
              title: "Legal Documents",
              index: 3,
            ),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: () {
                Navigator.pop(context);
                // TODO: logout logic
              },
            ),
          ],
        ),
      ),

      // ✅ PAGE BODY
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

  // 🔹 Drawer Item Builder
  Widget _drawerItem({
    required IconData icon,
    required String title,
    required int index,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      selected: _selectedIndex == index,
      selectedColor: AppColors.secondary,
      onTap: () {
        setState(() => _selectedIndex = index);
        Navigator.pop(context); // close drawer
      },
    );
  }
}
