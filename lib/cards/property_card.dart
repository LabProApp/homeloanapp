import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/cache_manager.dart';

import '../models/property_model.dart';
import '../models/client_lead_model.dart';
import '../models/user_model.dart';
import '../services/leads_service.dart';
import '../services/property_api_service.dart';
import '../services/user_service.dart';
import '../theme/app_colors.dart';
import '../commons/common_util.dart';
import '../commons/property_share_sheet.dart';
import '../services/property_share_service.dart';
import '../utility/amenity_icon.dart';

class PropertyCard extends StatefulWidget {
  final PropertyModel property;
  final bool showWhatsAppIcon;
  final int? userId;
  final bool showAmenitiesExpandable;

  const PropertyCard({
    super.key,
    required this.property,
    this.userId,
    this.showWhatsAppIcon = true,
    this.showAmenitiesExpandable = true,
  });

  @override
  State<PropertyCard> createState() => _PropertyCardState();
}

class _PropertyCardState extends State<PropertyCard> {
  static final _fmt = NumberFormat('#,##,###');

  int currentIndex = 0;
  bool _isFavourite = false;
  bool _sendingLead = false;
  UserModel? _owner;

  final PageController _imageCtrl = PageController();
  Timer? _slideTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startSlideshow());
  }

  void _startSlideshow() {
    _slideTimer?.cancel();
    if (_images.length < 2) return;
    _slideTimer = Timer.periodic(const Duration(milliseconds: 1500), (_) {
      if (!mounted || !_imageCtrl.hasClients) return;
      final next = (currentIndex + 1) % _images.length;
      _imageCtrl.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _slideTimer?.cancel();
    _imageCtrl.dispose();
    super.dispose();
  }

  Future<String> _resolveOwnerPhone() async {
    if (_owner != null && _owner!.mobile.isNotEmpty) return _owner!.mobile;
    final id = widget.property.postedByUser;
    if (id == null || id == 0) return widget.property.contactNumber;
    try {
      final u = await UserApiService.getProfile(id);
      if (mounted) setState(() => _owner = u);
      return u.mobile.isNotEmpty ? u.mobile : widget.property.contactNumber;
    } catch (_) {
      return widget.property.contactNumber;
    }
  }

  List<String> get _images {
    final docs = widget.property.documentList;
    if (docs != null && docs.isNotEmpty) {
      final urls = docs
          .map((e) => e.docUrl)
          .where((url) => url != null && url.isNotEmpty)
          .cast<String>()
          .toList();
      if (urls.isNotEmpty) return urls;
    }
    return [];
  }

  Widget _typePlaceholder() {
    final property = widget.property;
    final type = property.type?.toUpperCase() ?? '';
    final category = property.category?.toUpperCase() ?? '';
    final isCommercial = ['SHOP', 'OFFICE', 'SHOWROOM', 'CO WORKING'].contains(type) || category == 'COMMERCIAL';
    final isPlot = type == 'PLOT';

    final IconData icon = isCommercial
        ? Icons.business_outlined
        : isPlot
            ? Icons.landscape_outlined
            : Icons.home_work_outlined;
    final String label = isCommercial
        ? (property.type ?? 'Commercial')
        : isPlot
            ? 'Plot'
            : (property.type ?? 'Property');

    const neutralIcon = Color(0xFF78909C);
    final area = property.superArea ?? property.carpetArea;
    final cityParts = [property.city, property.state].where((s) => s != null && s.isNotEmpty);
    final cityStr = cityParts.join(', ');
    final isVerified = property.verified == true;
    final message = isVerified
        ? 'Verified listing. Photos will be uploaded shortly.'
        : 'Property images will be available soon.';

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFFFF), Color(0xFFF8F9FB), Color(0xFFEFF1F5)],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isVerified)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32).withOpacity(0.10),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF2E7D32).withOpacity(0.35)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.verified_rounded, size: 11, color: Color(0xFF2E7D32)),
                        SizedBox(width: 4),
                        Text('Verified Listing',
                          style: TextStyle(fontSize: 9, color: Color(0xFF2E7D32),
                              fontWeight: FontWeight.w700, letterSpacing: 0.2)),
                      ],
                    ),
                  )
                else
                  const SizedBox(height: 18),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: neutralIcon.withOpacity(0.10),
                shape: BoxShape.circle,
                border: Border.all(color: neutralIcon.withOpacity(0.20)),
              ),
              child: Icon(icon, size: 30, color: neutralIcon.withOpacity(0.75)),
            ),
            const SizedBox(height: 8),
            Text(label,
              style: const TextStyle(
                color: Color(0xFF546E7A), fontSize: 13,
                fontWeight: FontWeight.w600, letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 10),
            if (cityStr.isNotEmpty || area != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFDDE1E7)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (cityStr.isNotEmpty)
                      _placeholderAttr(Icons.location_on_outlined, cityStr),
                    if (cityStr.isNotEmpty && area != null) const SizedBox(height: 3),
                    if (area != null)
                      _placeholderAttr(Icons.square_foot, '${area.toStringAsFixed(0)} sqft'),
                  ],
                ),
              ),
            const SizedBox(height: 10),
            Text(message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF90A4AE), fontSize: 9, fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderAttr(IconData icon, String text) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 11, color: const Color(0xFF78909C)),
      const SizedBox(width: 4),
      Text(text, style: const TextStyle(fontSize: 10, color: Color(0xFF546E7A))),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final property = widget.property;
    final status = property.constructionStatus ?? property.propertyStatus ?? "-";

    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: 370,
        child: Stack(
          fit: StackFit.expand,
          children: [

            // ── Full-height image / placeholder ───────────────────────
            _images.isEmpty
                ? _typePlaceholder()
                : PageView.builder(
                    controller: _imageCtrl,
                    itemCount: _images.length,
                    onPageChanged: (i) => setState(() => currentIndex = i),
                    itemBuilder: (_, i) => CachedNetworkImage(
                      cacheManager: AppCacheManager.instance,
                      imageUrl: _images[i],
                      fit: BoxFit.cover,
                      fadeInDuration: const Duration(milliseconds: 250),
                      placeholder: (_, __) => _loadingPlaceholder(),
                      errorWidget: (_, __, ___) => _typePlaceholder(),
                    ),
                  ),

            // ── Translucent gradient details overlay at the bottom ─────
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.18),
                      Colors.black.withOpacity(0.62),
                      Colors.black.withOpacity(0.88),
                    ],
                    stops: const [0.0, 0.18, 0.55, 1.0],
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(14, 30, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    /// TITLE
                    Text(
                      property.title ?? "-",
                      style: const TextStyle(
                        fontSize: 19,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                        shadows: [
                          Shadow(offset: Offset(0, 1), blurRadius: 6, color: Colors.black54),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    /// LOCATION
                    Text(
                      property.location ?? "-",
                      style: const TextStyle(color: AppColors.white70, fontSize: 12),
                    ),

                    const SizedBox(height: 5),

                    /// CITY + PRICE
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "${property.city ?? "-"} | ${property.state ?? "-"}",
                            style: const TextStyle(color: AppColors.white60, fontSize: 11),
                          ),
                        ),
                        Text(
                          property.price != null
                              ? "₹ ${_fmt.format(property.price)}"
                              : "-",
                          style: const TextStyle(
                            color: AppColors.goldAccent,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            shadows: [Shadow(offset: Offset(0, 1), blurRadius: 4, color: Colors.black45)],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 7),

                    /// FEATURES
                    Row(
                      children: [
                        _feature(Icons.bed, "${property.bedrooms ?? '-'} Beds"),
                        const SizedBox(width: 16),
                        _feature(Icons.bathtub, "${property.bathrooms ?? '-'} Bath"),
                        const SizedBox(width: 16),
                        _feature(Icons.square_foot, "${property.superArea ?? '-'} sqft"),
                      ],
                    ),

                    if (widget.showAmenitiesExpandable &&
                        widget.property.amenitiesAsList != null &&
                        widget.property.amenitiesAsList!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      _amenitiesRow(),
                    ],

                    const SizedBox(height: 10),
                    Container(height: 0.5, color: const Color(0x55FFFFFF)),
                    const SizedBox(height: 9),
                    _actionRow(),
                  ],
                ),
              ),
            ),

            // ── Status pill + image counter (top-left) ────────────────
            Positioned(
              top: 12,
              left: 12,
              child: Row(
                children: [
                  _pill(status),
                  if (_images.length > 1) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.imageOverlay,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "${currentIndex + 1}/${_images.length}",
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // ── Fav + Share icons (top-right) ─────────────────────────
            Positioned(
              top: 8,
              right: 8,
              child: Column(
                children: [
                  _iconCircle(
                    _isFavourite ? Icons.favorite : Icons.favorite_border,
                    _toggleFavorite,
                  ),
                  const SizedBox(height: 6),
                  _iconCircle(Icons.share, _shareProperty),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }

  /// BOTTOM ACTION ROW: Call, WhatsApp, Interested
  Widget _actionRow() {
    return Row(
      children: [
        _smallIconBtn(Icons.call_rounded, 'Call', _callOwner),
        if (widget.showWhatsAppIcon) ...[
          const SizedBox(width: 8),
          _smallIconBtn(Icons.chat_rounded, 'Chat', _openWhatsApp),
        ],
        const Spacer(),
        _interestedBtn(),
      ],
    );
  }

  Widget _smallIconBtn(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.18),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: Colors.white),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _interestedBtn() {
    return GestureDetector(
      onTap: _sendingLead ? null : _createLead,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2)),
          ],
        ),
        child: _sendingLead
            ? const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.star_rounded, size: 14, color: AppColors.primary),
                  SizedBox(width: 5),
                  Text(
                    'Interested',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  /// AMENITIES
  Widget _amenitiesRow() {
    final amenities = widget.property.amenitiesAsList!;
    final visible = amenities.take(4);

    return Row(
      children: [
        ...visible.map((e) {
          final a = AmenityIcon.getAmenity(e.toString());
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Row(
              children: [
                Icon(a.icon, size: 12, color: AppColors.white70),
                const SizedBox(width: 3),
                Text(a.label,
                    style: const TextStyle(
                        fontSize: 10, color: AppColors.white70)),
              ],
            ),
          );
        }),
        if (amenities.length > 4)
          Text("+${amenities.length - 4} more",
              style: const TextStyle(
                  fontSize: 10, color: AppColors.white70)),
      ],
    );
  }

  Widget _feature(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 12, color: AppColors.white70),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
              fontSize: 10,
              color: Colors.white,
              fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _pill(String text, {Color color = AppColors.textPrimary}) {
    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style:
        const TextStyle(fontSize: 10, color: Colors.white),
      ),
    );
  }

  Widget _loadingPlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFFFF), Color(0xFFF8F9FB), Color(0xFFEFF1F5)],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF90A4AE)),
            ),
            SizedBox(height: 10),
            Text('Loading...', style: TextStyle(fontSize: 10, color: Color(0xFF90A4AE))),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleFavorite() async {
    await PropertyApiService.toggleFavourite(
      userId: widget.userId!,
      propertyId: widget.property.id!,
    );
    setState(() => _isFavourite = !_isFavourite);
  }

  Future<void> _createLead() async {
    if (widget.userId == null || widget.property.id == null) return;

    setState(() => _sendingLead = true);

    final prefs = await SharedPreferences.getInstance();

    final lead = ClientLeadModel(
      brokerId: widget.property.postedByUser,
      userId: widget.userId!,
      propertyId: widget.property.id!,
      leadType: 'PROPERTY_INQUIRY',
      clientName: prefs.getString("userName"),
      email: prefs.getString("userEmail"),
      mobile: prefs.getString("userMobile"),
      propertyTitle: widget.property.title,
      propertyCity: widget.property.city,
      propertyPrice: widget.property.price,
      preferredPropertyType: widget.property.type,
      preferredBudget: widget.property.price,
      inquiryDate: DateTime.now().toIso8601String(),
      status: "NEW",
      contacted: false,
      leadSource: "Property Interest",
      remark:
      "User showed interest from property ${widget.property.title}",
    );

    try {
      final res = await LeadApiService.createLead(lead);
      if (!mounted) return;
      final alreadySent = res['inquiryAlreadySent'] == true;
      final serverMsg = (res['responseMessage'] as String?)?.trim();
      _showSnack(
        alreadySent
            ? (serverMsg?.isNotEmpty == true
                ? serverMsg!
                : 'Inquiry already sent')
            : (serverMsg?.isNotEmpty == true
                ? serverMsg!
                : 'Interest sent successfully'),
      );
    } catch (e) {
      if (!mounted) return;
      _showSnack('Could not send interest. Please try again.', isError: true);
    } finally {
      if (mounted) setState(() => _sendingLead = false);
    }
  }

  void _showSnack(String text, {bool isError = false}) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(text),
        duration: const Duration(seconds: 2),
        backgroundColor: isError ? AppColors.error : null,
      ),
    );
  }

  void _shareProperty() {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => PropertyShareSheet(property: widget.property),
    );
  }

  Future<void> _callOwner() async {
    final phone = await _resolveOwnerPhone();
    if (phone.isEmpty) return;
    AppUtils.call(phone);
  }

  Future<void> _openWhatsApp() async {
    final phone = await _resolveOwnerPhone();
    if (phone.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final msg = PropertyShareService.inquiryWhatsAppText(
      widget.property,
      buyerName: prefs.getString('userName'),
      buyerPhone: prefs.getString('userMobile'),
      buyerEmail: prefs.getString('userEmail'),
    );
    try {
      await AppUtils.whatsapp(phone, msg);
    } catch (e) {
      if (!mounted) return;
      _showSnack(e.toString(), isError: true);
    }
  }

  Widget _iconCircle(IconData icon, VoidCallback? onTap) {
    final isFav = icon == Icons.favorite;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isFav ? Colors.red.shade400 : Colors.black.withOpacity(0.45),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 1)),
          ],
        ),
        child: Icon(icon, size: 19, color: Colors.white),
      ),
    );
  }
}