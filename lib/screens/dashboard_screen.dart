import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

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
import 'admin_dashboard_screen.dart';
import 'subscription_screen.dart';
import 'user_profile_screen.dart';
import 'home_screen.dart';
import 'bank_apply_loan_dialog.dart';
import 'post_requirement_screen.dart';
import 'loan_eligibility_screen.dart';
import 'my_journeys_screen.dart';
import 'buyer_journey_screen.dart';

import '../network/api_client.dart';
import '../services/cache_manager.dart';
import '../services/feature_flags.dart';
import '../services/secure_token_service.dart';
import '../theme/app_colors.dart';
import '../commons/common_widget.dart';

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
  String _planName = '';
  bool _isAdmin = false;
  int? _postedByUserId;
  Widget? _currentPage;

  // Update badge — populated from SharedPreferences written by SplashScreen.
  bool _updateAvailable = false;
  String _latestVersionName = '';
  String _updateStoreUrl = '';

  // Maps each home action to the feature flag that gates it.
  // Actions not in this map are free for all plans.
  static const _actionFeatureMap = {
    HomeAction.buySell:      FeatureFlags.buySell,
    HomeAction.rentPg:       FeatureFlags.rentPg,
    HomeAction.banks:        FeatureFlags.bankLoans,
    HomeAction.homeLoan:     FeatureFlags.bankLoans,
    HomeAction.legalServices: FeatureFlags.documentation,
    HomeAction.rentAgreement: FeatureFlags.documentation,
    HomeAction.saleAgreement: FeatureFlags.documentation,
    HomeAction.myPostings:   FeatureFlags.postProperty,
    HomeAction.myJourneys:   FeatureFlags.journey,
  };

  bool _isActionLocked(HomeAction action) {
    final flag = _actionFeatureMap[action];
    return flag != null && !FeatureFlags.isEnabled(flag);
  }

  @override
  void initState() {
    super.initState();
    _currentPage = _buildHome();
    Future.wait([_loadAppVersion(), _loadUserInfo()]).then((_) {
      if (mounted && _selectedIndex == -1) {
        setState(() => _currentPage = _buildHome());
      }
    });
  }

  Future<void> _loadAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() => _appVersion = 'v${info.version} (${info.buildNumber})');
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final plan = await FeatureFlags.planName();
    if (!mounted) return;
    setState(() {
      _userName = prefs.getString('userName') ?? 'User';
      _userEmail = prefs.getString('userEmail') ?? '';
      _isAdmin = (prefs.getString('userRole') ?? '').toUpperCase() == 'ADMIN';
      _planName = plan;
      _updateAvailable    = prefs.getBool('updateAvailable') ?? false;
      _latestVersionName  = prefs.getString('latestVersionName') ?? '';
      _updateStoreUrl     = prefs.getString('updateStoreUrl') ?? '';
    });
  }

  Widget _buildHome() => HomeScreen(
        userId: widget.userId,
        userName: _userName,
        planName: _planName,
        onNavigate: _handleHomeAction,
        isLocked: _isActionLocked,
        onViewPlans: _openSubscriptionScreen,
      );

  // ── Feature flag helpers ──────────────────────────────────────────────────

  /// Maps a tab index to the canonical feature key the user's plan must
  /// enable to use that tab. Returns null for tabs with no gating.
  String? _tabFeature(int index) {
    switch (index) {
      case 0:
        return FeatureFlags.buySell;
      case 1:
        return FeatureFlags.rentPg;
      case 2:
        return FeatureFlags.bankLoans;
      case 3:
        return FeatureFlags.documentation;
    }
    return null;
  }

  void _openSubscriptionScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
    );
  }

  /// Shows a polite "upgrade your plan" snack with a direct link to the
  /// subscription screen when a gated feature is tapped.
  void _showUpgradeSnack(String featureLabel) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text('$featureLabel requires a higher plan to unlock.'),
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.slate,
        action: SnackBarAction(
          label: 'View Plans',
          textColor: AppColors.goldAccent,
          onPressed: _openSubscriptionScreen,
        ),
      ));
  }

  void _handleHomeAction(HomeAction action) {
    // Check action-level lock before navigating.
    if (_isActionLocked(action)) {
      const labels = {
        HomeAction.buySell:       'Buy / Sell',
        HomeAction.rentPg:        'Rent / PG',
        HomeAction.banks:         'Banks & Rates',
        HomeAction.homeLoan:      'Home Loan',
        HomeAction.legalServices: 'Legal Services',
        HomeAction.rentAgreement: 'Rent Agreement',
        HomeAction.saleAgreement: 'Sale Agreement',
        HomeAction.myPostings:    'My Postings',
        HomeAction.myJourneys:    'My Journeys',
      };
      _showUpgradeSnack(labels[action] ?? 'This feature');
      return;
    }

    switch (action) {
      case HomeAction.buySell:
        _selectTab(0);
      case HomeAction.rentPg:
        _selectTab(1);
      case HomeAction.homeLoan:
        LoanApplySheet.show(context);
      case HomeAction.banks:
        _selectTab(2);
      case HomeAction.postRequirement:
        _setPage(PostRequirementScreen(userId: widget.userId));
      case HomeAction.legalServices:
        _selectTab(3);
      case HomeAction.myFavourites:
        _setPage(FavouritePropertyListingScreen(userId: widget.userId));
      case HomeAction.myJourneys:
        _setPage(MyJourneysScreen(userId: widget.userId));
      case HomeAction.startJourney:
        _setPage(BuyerJourneyScreen(userId: widget.userId));
      case HomeAction.myPostings:
        setState(() {
          _postedByUserId = widget.userId;
          _selectedIndex = 0;
          _currentPage = _buildTabPage(0);
        });
      case HomeAction.myInquiries:
        _setPage(BrokerLeadsScreen(brokerId: widget.userId));
      case HomeAction.emiCalculator:
        _setPage(const EmiCalculatorScreen());
      case HomeAction.stampDuty:
        _setPage(const StampDutyScreen());
      case HomeAction.rentVsBuy:
        _setPage(const RentVsBuyScreen());
      case HomeAction.dueDiligence:
        _setPage(const DueDiligenceScreen());
      case HomeAction.loanEligibility:
        _setPage(const LoanEligibilityScreen());
      case HomeAction.rentAgreement:
        _setPage(const RentAgreementScreen());
      case HomeAction.saleAgreement:
        _setPage(const SaleAgreementScreen());
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
    final feat = _tabFeature(index);
    if (feat != null && !FeatureFlags.isEnabled(feat)) {
      const labels = ['Buy/Sell', 'Rent/PG', 'Bank Loans', 'Documentation'];
      _showUpgradeSnack(labels[index]);
      return;
    }
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
      appBar: _selectedIndex == -1 ? GradientAppBar(
        titleWidget: const Text(
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
      ) : null,

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
                    if (_isAdmin)
                      _drawerActionItem(
                        Icons.admin_panel_settings_rounded,
                        'Admin Dashboard',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AdminDashboardScreen()),
                        ),
                        color: AppColors.primary,
                      ),
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
                      Icons.workspace_premium_outlined,
                      'Subscription & Plans',
                      onTap: () {
                        Navigator.pop(context);
                        _openSubscriptionScreen();
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
                    _buildVersionRow(),
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
        heroTag: 'dashboardHomeFab',
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
        padding: EdgeInsets.zero,
        height: 64,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(Icons.sell_outlined, Icons.sell_rounded, 'Buy/Sell', 0),
            _navItem(Icons.apartment_outlined, Icons.apartment_rounded, 'Rent/PG', 1),
            const SizedBox(width: 60),
            _navItem(Icons.account_balance_wallet_outlined,
                Icons.account_balance_wallet_rounded, 'Loans', 2),
            _navItem(Icons.assignment_outlined, Icons.assignment_rounded, 'Documentation', 3),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, IconData activeIcon, String label, int index) {
    final active = _selectedIndex == index;
    final feat = _tabFeature(index);
    final enabled = feat == null || FeatureFlags.isEnabled(feat);
    final color = !enabled
        ? AppColors.textMuted.withOpacity(0.45)
        : (active ? AppColors.primary : AppColors.textMuted);
    return Expanded(
      child: InkWell(
        onTap: () => _selectTab(index),
        borderRadius: BorderRadius.circular(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(active ? activeIcon : icon, color: color, size: 22),
                if (!enabled)
                  const Positioned(
                    right: -6,
                    top: -2,
                    child: Icon(Icons.lock_outline,
                        size: 11, color: AppColors.textMuted),
                  ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                color: color,
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
      child: SizedBox(
        width: double.infinity,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/house2.jpg',
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.navy.withOpacity(0.88),
                      AppColors.slate.withOpacity(0.78),
                      AppColors.primaryDark.withOpacity(0.55),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 22, 16, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white.withOpacity(0.20),
                    child: Text(
                      _userName.isNotEmpty
                          ? _userName[0].toUpperCase()
                          : 'U',
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
                        style: const TextStyle(
                            fontSize: 12, color: Colors.white70),
                        overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  const Row(
                    children: [
                      Icon(Icons.open_in_new,
                          size: 11, color: Colors.white54),
                      SizedBox(width: 4),
                      Text('View Profile',
                          style:
                              TextStyle(fontSize: 11, color: Colors.white54)),
                    ],
                  ),
                ],
              ),
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

  /// Version label + optional amber "Update available" chip at the bottom
  /// of the drawer.  Tapping the chip opens the store.
  Widget _buildVersionRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _appVersion,
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
          if (_updateAvailable) ...[
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () async {
                if (_updateStoreUrl.isNotEmpty) {
                  try {
                    await launchUrl(
                      Uri.parse(_updateStoreUrl),
                      mode: LaunchMode.externalApplication,
                    );
                  } catch (_) {}
                }
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.goldAccent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                      color: AppColors.goldAccent.withOpacity(0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.system_update_rounded,
                        size: 12, color: AppColors.goldAccent),
                    const SizedBox(width: 5),
                    Text(
                      _latestVersionName.isNotEmpty
                          ? 'Update to v$_latestVersionName'
                          : 'Update available',
                      style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.goldAccent,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
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
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.logout_rounded,
                  color: AppColors.error, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('Logout'),
          ],
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              elevation: 0,
              minimumSize: const Size(88, 44),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
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
    ApiClient.setToken(null);
    await SecureTokenService.clearToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await FeatureFlags.save(null);
    AppCacheManager.instance.emptyCache();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }
}
