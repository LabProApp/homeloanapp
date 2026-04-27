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

  const DashboardScreen({super.key, required this.userId});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  String _appVersion = '';
  String _userName = 'User';
  String _userEmail = '';
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
    setState(() => _appVersion = 'v${info.version} (${info.buildNumber})');
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _userName = prefs.getString('userName') ?? 'User';
      _userEmail = prefs.getString('userEmail') ?? '';
    });
  }

  Widget _buildPage() {
    switch (_selectedIndex) {
      case 0:
        return PropertyListingScreen(
          key: const PageStorageKey('home'),
          userId: widget.userId,
          postedbyuserId: _postedByUserId,
        );
      case 1:
        return RentalListingScreen(
          key: const PageStorageKey('rentals'),
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

  void _setPage(Widget page) => setState(() => _currentPage = page);

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.listingbackground,

      // ── AppBar ────────────────────────────────────────────────────────────
      appBar: AppBar(
        elevation: 0,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          'KeyBricks',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 1.0,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ProfileScreen(userId: widget.userId)),
              ),
              child: CircleAvatar(
                radius: 17,
                backgroundColor: Colors.white.withOpacity(0.25),
                child: Text(
                  _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),

      // ── Drawer ────────────────────────────────────────────────────────────
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              // Header — tappable → profile
              _drawerHeader(),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(top: 8, bottom: 12),
                  children: [
                    _sectionLabel('MAIN'),
                    _drawerNavItem(Icons.home_rounded, 'Home', 0),
                    _drawerNavItem(Icons.apartment_rounded, 'Rentals / PG', 1),
                    _drawerNavItem(
                        Icons.account_balance_wallet_rounded, 'Bank Loans', 2),
                    _drawerNavItem(
                        Icons.assignment_rounded, 'Documentation', 3),

                    const Divider(height: 20),
                    _sectionLabel('MY ACCOUNT'),
                    _drawerActionItem(
                      Icons.person_outline_rounded,
                      'My Profile',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  ProfileScreen(userId: widget.userId)),
                        );
                      },
                    ),
                    _drawerActionItem(
                      Icons.business_center_rounded,
                      'My Property Postings',
                      onTap: () {
                        setState(() {
                          _postedByUserId = widget.userId;
                          _selectedIndex = 0;
                          _currentPage = _buildPage();
                        });
                        Navigator.pop(context);
                      },
                    ),
                    _drawerActionItem(
                      Icons.favorite_rounded,
                      'My Favourite Properties',
                      onTap: () {
                        Navigator.pop(context);
                        _setPage(FavouritePropertyListingScreen(
                            userId: widget.userId));
                      },
                    ),
                    _drawerActionItem(
                      Icons.groups_rounded,
                      'Customer Inquiries',
                      onTap: () {
                        Navigator.pop(context);
                        _setPage(
                            BrokerLeadsScreen(brokerId: widget.userId));
                      },
                    ),

                    const Divider(height: 20),
                    _sectionLabel('TOOLS'),
                    _drawerActionItem(
                      Icons.calculate_outlined,
                      'EMI Calculator',
                      onTap: () {
                        Navigator.pop(context);
                        _setPage(const EmiCalculatorScreen());
                      },
                    ),

                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        _appVersion,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textMuted),
                      ),
                    ),
                    const SizedBox(height: 8),

                    _drawerActionItem(
                      Icons.logout_rounded,
                      'Logout',
                      onTap: _showLogoutDialog,
                      color: AppColors.error,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // ── Body ──────────────────────────────────────────────────────────────
      body: _currentPage ?? _buildPage(),

      // ── Bottom Navigation (Material 3 NavigationBar) ──────────────────────
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.primary.withOpacity(0.12),
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.08),
        height: 65,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (index) {
          setState(() {
            _postedByUserId = null;
            _selectedIndex = index;
            _currentPage = _buildPage();
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded, color: AppColors.primary),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.apartment_outlined),
            selectedIcon:
                Icon(Icons.apartment_rounded, color: AppColors.primary),
            label: 'Rentals/PG',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet_rounded,
                color: AppColors.primary),
            label: 'Loans',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon:
                Icon(Icons.assignment_rounded, color: AppColors.primary),
            label: 'Docs',
          ),
        ],
      ),
    );
  }

  // ── Drawer helpers ────────────────────────────────────────────────────────

  Widget _drawerHeader() {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => ProfileScreen(userId: widget.userId)),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 22, 16, 18),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.white.withOpacity(0.25),
              child: Text(
                _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _userName,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white),
            ),
            if (_userEmail.isNotEmpty)
              Text(
                _userEmail,
                style: const TextStyle(fontSize: 12, color: Colors.white70),
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 6),
            const Row(
              children: [
                Icon(Icons.open_in_new, size: 11, color: Colors.white54),
                SizedBox(width: 4),
                Text('View Profile',
                    style: TextStyle(fontSize: 11, color: Colors.white54)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        child: Text(
          text,
          style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
              letterSpacing: 0.8),
        ),
      );

  Widget _drawerNavItem(IconData icon, String title, int index) {
    final selected = _selectedIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
      decoration: BoxDecoration(
        color: selected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        dense: true,
        leading: Icon(icon,
            size: 22,
            color: selected ? AppColors.primary : AppColors.textPrimary),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: selected ? AppColors.primary : AppColors.textPrimary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
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

  Widget _drawerActionItem(
    IconData icon,
    String title, {
    required VoidCallback onTap,
    Color? color,
  }) {
    final c = color ?? AppColors.textPrimary;
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: Icon(icon, size: 22, color: c),
      title: Text(title,
          style: TextStyle(fontSize: 14, color: c)),
      onTap: onTap,
    );
  }

  // ── Logout ────────────────────────────────────────────────────────────────

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              minimumSize: const Size(80, 40),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              minimumSize: const Size(88, 40),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
