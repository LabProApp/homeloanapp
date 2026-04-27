import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'user_login_screen.dart';
import 'property_listing_screen.dart';
import 'rental_listing_screen.dart';
import 'legal_service_providers_listing.dart';
import 'banks_listing_screen.dart';
import 'emi_calculator_screen.dart';
import 'favourite_property_listing_screen.dart';
import 'interested_users_screen.dart';
import 'user_profile_screen.dart';

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

    if (!mounted) return;

    setState(() {
      _appVersion = "v${info.version} (${info.buildNumber})";
    });
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      _userName = prefs.getString("userName") ?? "User";
      _userEmail = prefs.getString("userEmail") ?? "";
    });
  }

  Widget _buildPage() {
    switch (_selectedIndex) {
      case 0:
        return PropertyListingScreen(
          key: const PageStorageKey("home"),
          userId: widget.userId,
          postedbyuserId: _postedByUserId,
        );

      case 1:
        return RentalListingScreen(
          key: const PageStorageKey("rentals"),
          userId: widget.userId,
        );

      case 2:
        return BankPage(userId: widget.userId);

      case 3:
        return LegalServicePage(userId: widget.userId);

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

      /// APP BAR
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.listingbackground,
        foregroundColor: AppColors.primary,
        title: Text(
          'KeyBricks',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            letterSpacing: 1.2,
            color: AppColors.primary,
          ),
        ),
      ),

      /// DRAWER
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [

              /// HEADER (ENHANCED)
              Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.primary,
                      child: const Icon(Icons.person, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _userName,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            _userEmail,
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: AppColors.textMuted,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 12),
                  children: [

                    _drawerItem(Icons.dashboard_rounded, "Home", 0),
                    _drawerItem(Icons.apartment_rounded, "Rentals / PG", 1),
                    _drawerItem(Icons.account_balance_wallet_rounded, "Bank Loans", 2),
                    _drawerItem(Icons.assignment_rounded, "Documentation", 3),

                    /// 🔥 PROFILE ADDED
                    ListTile(
                      leading: const Icon(Icons.person_outline),
                      title: const Text("My Profile"),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProfileScreen(
                              userId: widget.userId,
                            ),
                          ),
                        );
                      },
                    ),

                    ListTile(
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
                      leading: const Icon(Icons.favorite_rounded),
                      title: const Text("My Favourite Properties"),
                      onTap: () {
                        Navigator.pop(context);
                        _setPage(
                          FavouritePropertyListingScreen(
                            userId: widget.userId,
                          ),
                        );
                      },
                    ),

                    ListTile(
                      leading: const Icon(Icons.groups_rounded),
                      title: const Text("Customer Inquiries"),
                      onTap: () {
                        Navigator.pop(context);
                        _setPage(
                          BrokerLeadsScreen(
                            brokerId: widget.userId,
                          ),
                        );
                      },
                    ),

                    const Divider(),

                    ListTile(
                      leading: const Icon(Icons.calculate),
                      title: const Text("EMI Calculator"),
                      onTap: () {
                        Navigator.pop(context);
                        _setPage(const EmiCalculatorScreen());
                      },
                    ),

                    const SizedBox(height: 10),

                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Text(
                        _appVersion,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    ListTile(
                      leading: const Icon(Icons.logout_rounded, color: Colors.red),
                      title: const Text(
                        "Logout",
                        style: TextStyle(color: Colors.red),
                      ),
                      onTap: () => _showLogoutDialog(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      /// BODY
      body: _currentPage ?? _buildPage(),

      /// BOTTOM NAVIGATION
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMuted,
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
            icon: Icon(Icons.apartment_outlined),
            activeIcon: Icon(Icons.apartment_rounded),
            label: "Rentals/PG",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet_rounded),
            label: "Loans",
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
    final isSelected = _selectedIndex == index;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(icon,
            color: isSelected ? AppColors.primary : AppColors.textPrimary),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? AppColors.primary : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        onTap: () {
          setState(() {
            _postedByUserId = null;
            _selectedIndex = index;
            _currentPage = _buildPage();
          });

          Navigator.pop(context);
        },
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(context);
              await _logout();
            },
            child: const Text('Logout'),
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