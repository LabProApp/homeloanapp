import 'package:flutter/material.dart';
import 'package:property/screens/profile_screen.dart';
import 'package:property/screens/home_screen.dart';
import 'package:property/theme/app_colors.dart';

class DashboardScreen extends StatefulWidget {
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomeScreen(),//Center(child: Text("Home Page", style: TextStyle(fontSize: 22)),),
    Center(child: Text("Search Page", style: TextStyle(fontSize: 22))),
    Center(child: Text("Saved Page", style: TextStyle(fontSize: 22))),
    ProfileScreen(),
    //Center(child: Text("Account Page", style: TextStyle(fontSize: 22))),

    /*HomePage(),
    SearchPage(),
    SavedPage(),
    ProfilePage(),*/
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.secondary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,

        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: "Projects",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance),
            label: "Bank Loans",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.document_scanner),
            label: "Documents",
          ),
        ],
      ),
    );
  }
}
