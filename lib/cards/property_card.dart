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
    final type = widget.property.type?.toUpperCase() ?? '';
    final category = widget.property.category?.toUpperCase() ?? '';
    final isCommercial = ['SHOP', 'OFFICE', 'SHOWROOM', 'CO WORKING'].contains(type) || category == 'COMMERCIAL';
    final isPlot = type == 'PLOT';

    final IconData icon;
    final Color bg;
    final Color iconColor;
    final String label;

    if (isCommercial) {
      icon = Icons.storefront_outlined;
      bg = const Color(0xFFE8F5E9);
      iconColor = const Color(0xFF2E7D32);
      label = widget.property.type ?? 'Commercial';
    } else if (isPlot) {
      icon = Icons.landscape_outlined;
      bg = const Color(0xFFFBE9E7);
      iconColor = const Color(0xFF6D4C41);
      label = 'Plot';
    } else {
      icon = Icons.home_outlined;
      bg = const Color(0xFFFFF3E0);
      iconColor = const Color(0xFFE65100);
      label = widget.property.type ?? 'Property';
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
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
              'Pictures will be available soon',
              style: TextStyle(color: iconColor.withOpacity(0.55), fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final property = widget.property;

    final status =
        property.constructionStatus ?? property.propertyStatus ?? "-";

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// IMAGE SECTION
          SizedBox(
            height: 220,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
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

                /// IMAGE COUNT
                if (_images.length > 1)
                  Positioned(
                    bottom: 8,
                    right: 12,
                    child: Container(
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
                  ),

                /// STATUS
                Positioned(
                  top: 12,
                  left: 12,
                  child: _pill(status),
                ),

                /// TOP ICONS (favorite + share only)
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

          /// DETAILS SECTION
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// TITLE
                Text(
                  property.title ?? "-",
                  style: const TextStyle(
                      fontSize: 17,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 2),

                /// LOCATION
                Text(
                  property.location ?? "-",
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12),
                ),

                const SizedBox(height: 2),

                /// CITY + PRICE
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "${property.city ?? "-"} | ${property.state ?? "-"}",
                        style: const TextStyle(
                            color: AppColors.textMuted, fontSize: 11),
                      ),
                    ),
                    Text(
                      property.price != null
                          ? "₹ ${_fmt.format(property.price)}"
                          : "-",
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ),

                const SizedBox(height: 2),

                /// DATE
                Text(
                  "Posted: ${AppUtils.formatDate(property.postDate)}",
                  style: const TextStyle(
                      fontSize: 10, color: AppColors.textMuted),
                ),

                const SizedBox(height: 6),

                /// FEATURES
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _feature(Icons.bed,
                        "${property.bedrooms ?? '-'} Beds"),
                    _feature(Icons.bathtub,
                        "${property.bathrooms ?? '-'} Bath"),
                    _feature(Icons.square_foot,
                        "${property.superArea ?? '-'} sqft"),
                  ],
                ),

                if (widget.showAmenitiesExpandable &&
                    widget.property.amenitiesAsList != null &&
                    widget.property.amenitiesAsList!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  _amenitiesRow(),
                ],

                const SizedBox(height: 10),
                const Divider(height: 1, color: AppColors.border),
                const SizedBox(height: 8),
                _actionRow(),
              ],
            ),
          ),
        ],
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
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }

  Widget _interestedBtn() {
    return InkWell(
      onTap: _sendingLead ? null : _createLead,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(20),
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
                  fontWeight: FontWeight.w600,
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
                Icon(a.icon, size: 12, color: AppColors.textMuted),
                const SizedBox(width: 3),
                Text(a.label,
                    style:
                    const TextStyle(fontSize: 10, color: AppColors.textMuted)),
              ],
            ),
          );
        }),
        if (amenities.length > 4)
          Text("+${amenities.length - 4} more",
              style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
      ],
    );
  }

  Widget _feature(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 12, color: AppColors.textMuted),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
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