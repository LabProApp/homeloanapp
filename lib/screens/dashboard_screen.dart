import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'user_login_screen.dart';
import 'property_listing_screen.dart';
import 'rental_listing_screen.dart';
import 'legal_service_providers_listing.dart';
import 'banks_listing_screen.dart';
import 'emi_calculator_screen.dart';
import 'stamp_duty_screen.dart';
import 'rent_vs_buy_screen.dart';
import 'due_diligence_screen.dart';
import 'rent_agreement_screen.dart';
import 'sale_agreement_screen.dart';
import 'favourite_property_listing_screen.dart';
import 'interested_users_screen.dart';
import 'user_profile_screen.dart';
import 'home_screen.dart';

import '../theme/app_colors.dart';

class DashboardScreen extends StatefulWidget {
  final int userId;

  const DashboardScreen({super.key, required this.userId});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // -1 = Home services page (center FAB)
  // 0 = Buy/Sell, 1 = Rent/PG, 2 = Loans, 3 = Docs
  int _selectedIndex = -1;
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
    _currentPage = _buildHome();
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

  Widget _buildHome() => HomeScreen(
        userId: widget.userId,
        userName: _userName,
        onNavigate: _handleHomeAction,
      );

  void _handleHomeAction(dynamic action) {
    switch (action.toString()) {
      case '_HomeAction.buySell':
        _selectTab(0);
        break;
      case '_HomeAction.rentPg':
        _selectTab(1);
        break;
      case '_HomeAction.homeLoan':
      case '_HomeAction.banks':
        _selectTab(2);
        break;
      case '_HomeAction.legalServices':
        _selectTab(3);
        break;
      case '_HomeAction.myFavourites':
        _setPage(FavouritePropertyListingScreen(userId: widget.userId));
        break;
      case '_HomeAction.myPostings':
        setState(() {
          _postedByUserId = widget.userId;
          _selectedIndex = 0;
          _currentPage = _buildTabPage(0);
        });
        break;
      case '_HomeAction.myInquiries':
        _setPage(BrokerLeadsScreen(brokerId: widget.userId));
        break;
      case '_HomeAction.emiCalculator':
        _setPage(const EmiCalculatorScreen());
        break;
      case '_HomeAction.stampDuty':
        _setPage(const StampDutyScreen());
        break;
      case '_HomeAction.rentVsBuy':
        _setPage(const RentVsBuyScreen());
        break;
      case '_HomeAction.dueDiligence':
        _setPage(const DueDiligenceScreen());
        break;
      case '_HomeAction.loanEligibility':
        _selectTab(2);
        break;
      case '_HomeAction.rentAgreement':
        _setPage(const RentAgreementScreen());
        break;
      case '_HomeAction.saleAgreement':
        _setPage(const SaleAgreementScreen());
        break;
    }
  }

  Widget _buildTabPage(int index) {
    switch (index) {
      case 0:
        return PropertyListingScreen(
          key: const PageStorageKey('buySell'),
          userId: widget.userId,
          postedbyuserId: _postedByUserId,
        );
      case 1:
        return RentalListingScreen(
          key: const PageStorageKey('rentals'),
          userId: widget.userId,
        );
      case 2:
        return BankPage(
          userId: widget.userId,
          onNavigateToEmi: () => _setPage(const EmiCalculatorScreen()),
        );
      case 3:
        return LegalServicePage(userId: widget.userId);
      default:
        return PropertyListingScreen(userId: widget.userId);
    }
  }

  void _selectTab(int index) {
    setState(() {
      _postedByUserId = null;
      _selectedIndex = index;
      _currentPage = _buildTabPage(index);
    });
  }

  void _goHome() {
    setState(() {
      _selectedIndex = -1;
      _currentPage = _buildHome();
    });
  }

  void _setPage(Widget page) {
    setState(() {
      _selectedIndex = -2; // custom page, no tab selected
      _currentPage = page;
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.listingbackground,

      // ── AppBar ────────────────────────────────────────────────────────────
      appBar: AppBar(
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
              _drawerHeader(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(top: 8, bottom: 12),
                  children: [
                    _sectionLabel('MAIN'),
                    _drawerActionItem(Icons.home_rounded, 'Home', onTap: _goHome),
                    _drawerNavItem(Icons.sell_outlined, 'Buy / Sell', 0),
                    _drawerNavItem(Icons.apartment_rounded, 'Rent / PG', 1),
                    _drawerNavItem(Icons.account_balance_wallet_rounded, 'Bank Loans', 2),
                    _drawerNavItem(Icons.assignment_rounded, 'Documentation', 3),

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
                        Navigator.pop(context);
                        setState(() {
                          _postedByUserId = widget.userId;
                          _selectedIndex = 0;
                          _currentPage = _buildTabPage(0);
                        });
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
                        _setPage(BrokerLeadsScreen(brokerId: widget.userId));
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
                    _drawerActionItem(
                      Icons.receipt_long_outlined,
                      'Stamp Duty Calculator',
                      onTap: () => _setPage(const StampDutyScreen()),
                    ),
                    _drawerActionItem(
                      Icons.balance_outlined,
                      'Rent vs Buy',
                      onTap: () => _setPage(const RentVsBuyScreen()),
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
      body: _currentPage ?? _buildHome(),

      // ── Center raised Home FAB ────────────────────────────────────────────
      floatingActionButton: FloatingActionButton(
        onPressed: _goHome,
        backgroundColor: _selectedIndex == -1
            ? AppColors.primary
            : AppColors.primary.withOpacity(0.85),
        elevation: _selectedIndex == -1 ? 6 : 4,
        shape: const CircleBorder(),
        tooltip: 'Home',
        child: Icon(
          _selectedIndex == -1 ? Icons.home_rounded : Icons.home_outlined,
          color: Colors.white,
          size: 28,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // ── Bottom App Bar with 4 items (2 + 2 around FAB notch) ─────────────
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: Colors.white,
        elevation: 8,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(Icons.sell_outlined, Icons.sell_rounded, 'Buy/Sell', 0),
              _navItem(Icons.apartment_outlined, Icons.apartment_rounded, 'Rent/PG', 1),
              const SizedBox(width: 60), // space for FAB
              _navItem(Icons.account_balance_wallet_outlined,
                  Icons.account_balance_wallet_rounded, 'Loans', 2),
              _navItem(Icons.assignment_outlined, Icons.assignment_rounded, 'Docs', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, IconData activeIcon, String label, int index) {
    final active = _selectedIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => _selectTab(index),
        borderRadius: BorderRadius.circular(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              active ? activeIcon : icon,
              color: active ? AppColors.primary : AppColors.textMuted,
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: active ? AppColors.primary : AppColors.textMuted,
                fontWeight: active ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
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
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
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
            Text(_userName,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
            if (_userEmail.isNotEmpty)
              Text(_userEmail,
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                  overflow: TextOverflow.ellipsis),
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
        color: selected
            ? AppColors.primary.withOpacity(0.1)
            : Colors.transparent,
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
          Navigator.pop(context);
          _selectTab(index);
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
      title: Text(title, style: TextStyle(fontSize: 14, color: c)),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              minimumSize: const Size(88, 40),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
