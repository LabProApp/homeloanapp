import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/property_model.dart';
import '../services/cache_manager.dart';
import '../models/client_lead_model.dart';
import '../models/user_model.dart';
import '../services/leads_service.dart';
import '../services/user_service.dart';
import '../theme/app_colors.dart';
import 'package:intl/intl.dart';
import '../services/property_api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../commons/common_util.dart';
import '../commons/property_share_sheet.dart';
import '../services/property_share_service.dart';
import '../utility/amenity_icon.dart';

class RentPropertyCard extends StatefulWidget {
  final PropertyModel property;
  final bool showWhatsAppIcon;
  final bool showAmenitiesExpandable;
  final int? userId;

  const RentPropertyCard({
    super.key,
    required this.property,
    this.userId,
    this.showWhatsAppIcon = true,
    this.showAmenitiesExpandable = true,
  });

  @override
  State<RentPropertyCard> createState() => _RentPropertyCardState();
}

class _RentPropertyCardState extends State<RentPropertyCard> {
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
    if (widget.property.documentList != null &&
        widget.property.documentList!.isNotEmpty) {
      final urls = widget.property.documentList!
          .map((doc) => doc.docUrl)
          .whereType<String>()
          .where((url) => url.isNotEmpty)
          .toList();
      if (urls.isNotEmpty) return urls;
    }
    return [];
  }

  Widget _typePlaceholder() {
    final type = widget.property.type?.toUpperCase() ?? '';
    final category = widget.property.category?.toUpperCase() ?? '';
    final isCommercial = ['SHOP', 'OFFICE', 'SHOWROOM', 'CO WORKING'].contains(type) || category == 'COMMERCIAL';
    final isPlot = type == 'PLOT';

    final IconData icon;
    final Color bg;
    final Color iconColor;
    final String label;

    if (isCommercial) {
      icon = Icons.business_outlined;
      bg = const Color(0xFFE0F7FA);
      iconColor = const Color(0xFF00695C);
      label = widget.property.type ?? 'Commercial';
    } else if (isPlot) {
      icon = Icons.landscape_outlined;
      bg = const Color(0xFFFBE9E7);
      iconColor = const Color(0xFF6D4C41);
      label = 'Plot';
    } else {
      icon = Icons.apartment_outlined;
      bg = const Color(0xFFE8EAF6);
      iconColor = const Color(0xFF283593);
      label = widget.property.type ?? 'Rental';
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            bg,
            Color.alphaBlend(iconColor.withOpacity(0.18), bg),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: iconColor),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                color: iconColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              'No pictures available',
              style: TextStyle(color: iconColor.withOpacity(0.65), fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  String get rent {
    if (widget.property.monthlyRent != null) {
      return "₹ ${_fmt.format(widget.property.monthlyRent)} / month";
    }
    if (widget.property.price != null) {
      return "₹ ${_fmt.format(widget.property.price)} / month";
    }
    return "-";
  }

  @override
  Widget build(BuildContext context) {
    final status =
        widget.property.constructionStatus ?? widget.property.propertyStatus ?? "-";

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: 355,
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
                      widget.property.title ?? "-",
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
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
                      "${widget.property.location ?? ""}, ${widget.property.city ?? ""}",
                      style: const TextStyle(fontSize: 12, color: AppColors.white70),
                    ),

                    const SizedBox(height: 6),

                    /// META + RENT
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              _metaIcon(Icons.bed, "${widget.property.bedrooms ?? '-'}"),
                              _metaIcon(Icons.bathtub, "${widget.property.bathrooms ?? '-'}"),
                              _metaIcon(
                                Icons.square_foot,
                                widget.property.superArea != null
                                    ? "${widget.property.superArea!.toInt()} sqft"
                                    : "-",
                              ),
                              if (widget.property.floorNumber != null)
                                _metaIcon(Icons.layers, "Fl ${widget.property.floorNumber}"),
                            ],
                          ),
                        ),
                        Text(
                          rent,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.goldAccent,
                            shadows: [Shadow(offset: Offset(0, 1), blurRadius: 4, color: Colors.black45)],
                          ),
                        ),
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
        _smallIconBtn(Icons.call, AppColors.primary, _callOwner),
        if (widget.showWhatsAppIcon) ...[
          const SizedBox(width: 8),
          _smallIconBtn(Icons.chat, AppColors.whatsAppGreen, _openWhatsApp),
        ],
        const Spacer(),
        _interestedBtn(),
      ],
    );
  }

  Widget _smallIconBtn(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withOpacity(0.22),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.55)),
        ),
        child: Icon(icon, size: 18, color: Colors.white),
      ),
    );
  }

  Widget _interestedBtn() {
    return InkWell(
      onTap: _sendingLead ? null : _createLead,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: _sendingLead
            ? const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : const Text(
                'Interested',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
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

  Widget _metaIcon(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Row(
        children: [
          Icon(icon, size: 12, color: AppColors.white70),
          const SizedBox(width: 3),
          Text(text,
              style:
                  const TextStyle(fontSize: 11, color: Colors.white)),
        ],
      ),
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
      color: AppColors.surfaceSubtle,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: AppColors.border,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.image_outlined, size: 28, color: AppColors.textMuted),
            ),
            const SizedBox(height: 8),
            const Text('Loading...', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
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
      clientName: prefs.getString("userName") ?? "",
      email: prefs.getString("userEmail") ?? "",
      mobile: prefs.getString("userMobile") ?? "",
      propertyTitle: widget.property.title,
      propertyCity: widget.property.city,
      propertyPrice: widget.property.price,
      preferredPropertyType: widget.property.type,
      preferredBudget: widget.property.price,
      inquiryDate: DateTime.now().toIso8601String(),
      status: "NEW",
      contacted: false,
      leadSource: "Rental Property Interest",
      remark:
      "User interested in rental property ${widget.property.title ?? ""}",
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
                : 'Owner will contact you soon'),
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
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 18,
        backgroundColor: AppColors.imageOverlay,
        child: _sendingLead && icon == Icons.star
            ? const SizedBox(
          height: 12,
          width: 12,
          child: CircularProgressIndicator(
              strokeWidth: 2, color: Colors.white),
        )
            : Icon(icon, size: 18, color: Colors.white),
      ),
    );
  }
}