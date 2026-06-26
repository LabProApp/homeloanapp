import 'dart:io';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/property_model.dart';
import '../services/cache_manager.dart';
import '../theme/app_colors.dart';
import '../commons/common_widget.dart';

// ── Color themes ──────────────────────────────────────────────────────────────

class _PosterTheme {
  final String name;
  final Color primary;
  final Color accent;
  final Color bg;
  const _PosterTheme({required this.name, required this.primary, required this.accent, required this.bg});
}

const _kThemes = [
  _PosterTheme(name: 'Amber',   primary: Color(0xFF78350F), accent: Color(0xFFD97706), bg: Color(0xFFFFFBEB)),
  _PosterTheme(name: 'Navy',    primary: Color(0xFF1E3A5F), accent: Color(0xFF2563EB), bg: Color(0xFFEFF6FF)),
  _PosterTheme(name: 'Emerald', primary: Color(0xFF064E3B), accent: Color(0xFF059669), bg: Color(0xFFECFDF5)),
  _PosterTheme(name: 'Crimson', primary: Color(0xFF7F1D1D), accent: Color(0xFFDC2626), bg: Color(0xFFFFF1F2)),
  _PosterTheme(name: 'Violet',  primary: Color(0xFF3B0764), accent: Color(0xFF7C3AED), bg: Color(0xFFF5F3FF)),
  _PosterTheme(name: 'Slate',   primary: Color(0xFF0F172A), accent: Color(0xFF475569), bg: Color(0xFFF8FAFC)),
];

// ── Template enum ─────────────────────────────────────────────────────────────

enum _Tpl { classic, overlay, modern, grid, luxury, minimal, split }

extension _TplX on _Tpl {
  String get label => ['Classic', 'Overlay', 'Modern', 'Grid', 'Luxury', 'Minimal', 'Split'][index];
  IconData get icon => [
    Icons.view_agenda_outlined,
    Icons.layers_outlined,
    Icons.dashboard_outlined,
    Icons.grid_view_outlined,
    Icons.diamond_outlined,
    Icons.article_outlined,
    Icons.view_column,
  ][index];
}

// ── Screen ────────────────────────────────────────────────────────────────────

class PropertyPosterScreen extends StatefulWidget {
  final PropertyModel property;
  const PropertyPosterScreen({super.key, required this.property});

  @override
  State<PropertyPosterScreen> createState() => _PropertyPosterScreenState();
}

class _PropertyPosterScreenState extends State<PropertyPosterScreen> {
  _Tpl _tpl = _Tpl.classic;
  int _themeIdx = 0;
  File? _localImage;
  bool _sharing = false;
  final _posterKey = GlobalKey();
  static final _fmt = NumberFormat('#,##,###');

  _PosterTheme get _theme => _kThemes[_themeIdx];

  String? get _networkUrl {
    final docs = widget.property.documentList;
    if (docs == null || docs.isEmpty) return null;
    return docs.where((d) => d.docUrl != null && d.docUrl!.isNotEmpty).map((d) => d.docUrl!).firstOrNull;
  }

  Future<void> _pickPhoto() async {
    final f = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 90);
    if (f != null && mounted) setState(() => _localImage = File(f.path));
  }

  Future<void> _share() async {
    setState(() => _sharing = true);
    try {
      final boundary = _posterKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final img = await boundary.toImage(pixelRatio: 3.0);
      final data = await img.toByteData(format: ui.ImageByteFormat.png);
      final bytes = data!.buffer.asUint8List();
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/poster_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(bytes);
      if (!mounted) return;
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: widget.property.title ?? 'Property Listing',
        text: '${widget.property.title ?? ''} — ${widget.property.city ?? ''}',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not generate poster: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: GradientAppBar(title: 'Generate Poster'),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionLabel('Template Style'),
                  const SizedBox(height: 10),
                  _templateRow(),
                  const SizedBox(height: 18),
                  _sectionLabel('Color Theme'),
                  const SizedBox(height: 10),
                  _colorRow(),
                  const SizedBox(height: 20),
                  _sectionLabel('Preview'),
                  const SizedBox(height: 10),
                  _posterPreview(),
                  const SizedBox(height: 10),
                  Center(
                    child: TextButton.icon(
                      onPressed: _pickPhoto,
                      icon: const Icon(Icons.add_photo_alternate_outlined, size: 16),
                      label: Text(_localImage == null && _networkUrl == null
                          ? 'Add Photo for Poster'
                          : 'Change Poster Photo'),
                      style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _bottomBar(),
        ],
      ),
    );
  }

  Widget _sectionLabel(String s) => Text(
    s,
    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
        color: AppColors.textPrimary, letterSpacing: 0.2),
  );

  Widget _templateRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _Tpl.values.map((t) {
          final sel = t == _tpl;
          return GestureDetector(
            onTap: () => setState(() => _tpl = t),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(right: 12),
              width: 82,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: sel ? _theme.primary : AppColors.border,
                    width: sel ? 2 : 1.5),
                boxShadow: sel
                    ? [BoxShadow(color: _theme.primary.withOpacity(0.28), blurRadius: 10, offset: const Offset(0, 3))]
                    : [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 4, offset: const Offset(0, 2))],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.5),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 110,
                      child: _TemplateThumbnail(tpl: t, theme: _theme),
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      color: sel ? _theme.primary : AppColors.white,
                      child: Text(
                        t.label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: sel ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _colorRow() {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _kThemes.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final t = _kThemes[i];
          final sel = i == _themeIdx;
          return GestureDetector(
            onTap: () => setState(() => _themeIdx = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 42, height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [t.primary, t.accent],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                border: Border.all(color: sel ? t.accent : Colors.transparent, width: sel ? 3 : 0),
                boxShadow: sel
                    ? [BoxShadow(color: t.accent.withOpacity(0.45), blurRadius: 10, spreadRadius: 1)]
                    : null,
              ),
              child: sel ? const Icon(Icons.check_rounded, color: Colors.white, size: 18) : null,
            ),
          );
        },
      ),
    );
  }

  Widget _posterPreview() {
    const pw = 600.0;
    const ph = 848.0;
    return LayoutBuilder(builder: (ctx, bc) {
      final scale = bc.maxWidth / pw;
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.20), blurRadius: 24, offset: const Offset(0, 8))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            width: bc.maxWidth,
            height: ph * scale,
            child: FittedBox(
              fit: BoxFit.contain,
              alignment: Alignment.topCenter,
              child: RepaintBoundary(
                key: _posterKey,
                child: SizedBox(
                  width: pw, height: ph,
                  child: _buildPoster(),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildPoster() {
    final args = _Args(
      property: widget.property,
      theme: _theme,
      localImage: _localImage,
      networkUrl: _networkUrl,
      fmt: _fmt,
    );
    return switch (_tpl) {
      _Tpl.classic => _ClassicPoster(args: args),
      _Tpl.overlay => _OverlayPoster(args: args),
      _Tpl.modern  => _ModernPoster(args: args),
      _Tpl.grid    => _GridPoster(args: args),
      _Tpl.luxury  => _LuxuryPoster(args: args),
      _Tpl.minimal => _MinimalPoster(args: args),
      _Tpl.split   => _SplitPoster(args: args),
    };
  }

  Widget _bottomBar() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: const Border(top: BorderSide(color: AppColors.border)),
          boxShadow: [BoxShadow(color: AppColors.shadowMedium, blurRadius: 8, offset: const Offset(0, -2))],
        ),
        child: AppButton(
          text: 'Share Poster',
          isLoading: _sharing,
          onTap: _sharing ? null : _share,
        ),
      ),
    );
  }
}

// ── Shared data + helpers ─────────────────────────────────────────────────────

class _Args {
  final PropertyModel property;
  final _PosterTheme theme;
  final File? localImage;
  final String? networkUrl;
  final NumberFormat fmt;
  const _Args({required this.property, required this.theme, required this.localImage,
    required this.networkUrl, required this.fmt});

  bool get isRent => property.rentOrSale?.toUpperCase() == 'RENT';

  String get actionLabel => isRent ? 'FOR RENT' : 'FOR SALE';

  String get priceLabel {
    if (isRent) {
      final r = property.monthlyRent ?? property.price;
      return r != null ? '₹ ${fmt.format(r)} / month' : '–';
    }
    return property.price != null ? '₹ ${fmt.format(property.price)}' : '–';
  }

  String get typeLabel {
    final t = property.type ?? '';
    if (t.isEmpty) return 'Property';
    return t[0].toUpperCase() + t.substring(1).toLowerCase();
  }

  List<String> get amenities {
    final a = property.amenities;
    if (a == null || a.isEmpty) return [];
    return a.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
  }
}

Widget _img(_Args a, {required double w, required double h, BorderRadius? radius}) {
  Widget inner;
  if (a.localImage != null) {
    inner = Image.file(a.localImage!, width: w, height: h, fit: BoxFit.cover);
  } else if (a.networkUrl != null) {
    inner = CachedNetworkImage(
      cacheManager: AppCacheManager.instance,
      imageUrl: a.networkUrl!,
      width: w, height: h, fit: BoxFit.cover,
      placeholder: (_, __) => _placeholder(w, h, a),
      errorWidget: (_, __, ___) => _placeholder(w, h, a),
    );
  } else {
    inner = _placeholder(w, h, a);
  }
  final box = SizedBox(width: w, height: h, child: inner);
  if (radius != null) return ClipRRect(borderRadius: radius, child: box);
  return box;
}

Widget _placeholder(double w, double h, _Args a) => Container(
  width: w, height: h,
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [a.theme.primary.withOpacity(0.07), a.theme.accent.withOpacity(0.13)],
      begin: Alignment.topLeft, end: Alignment.bottomRight,
    ),
  ),
  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Icon(Icons.home_work_outlined, size: 44, color: a.theme.primary.withOpacity(0.30)),
    const SizedBox(height: 8),
    Text('Tap "Change Photo"\nto add a property image',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 12, color: a.theme.primary.withOpacity(0.45), height: 1.4)),
  ]),
);

Widget _brandTag(Color c) => Row(mainAxisSize: MainAxisSize.min, children: [
  Icon(Icons.home_rounded, size: 14, color: c),
  const SizedBox(width: 4),
  Text('KeyBricks', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: c, letterSpacing: 0.5)),
]);

Widget _featureRow(_Args a, Color iconColor, Color textColor) {
  final p = a.property;
  final chips = <Widget>[];
  if (p.bedrooms != null)
    chips.add(_feat(Icons.bed_rounded, '${p.bedrooms} BHK', iconColor, textColor));
  if (p.bathrooms != null)
    chips.add(_feat(Icons.bathtub_rounded, '${p.bathrooms} Bath', iconColor, textColor));
  if (p.superArea != null)
    chips.add(_feat(Icons.square_foot_rounded, '${p.superArea!.toInt()} sqft', iconColor, textColor));
  if (chips.isEmpty) return const SizedBox.shrink();
  return Row(mainAxisAlignment: MainAxisAlignment.start,
      children: chips.expand((w) => [w, const SizedBox(width: 18)]).toList()..removeLast());
}

Widget _feat(IconData icon, String text, Color iconColor, Color textColor) => Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    Icon(icon, size: 15, color: iconColor),
    const SizedBox(width: 4),
    Text(text, style: TextStyle(fontSize: 13, color: textColor, fontWeight: FontWeight.w600)),
  ],
);

// ── Template Thumbnails ───────────────────────────────────────────────────────

class _TemplateThumbnail extends StatelessWidget {
  final _Tpl tpl;
  final _PosterTheme theme;
  const _TemplateThumbnail({required this.tpl, required this.theme});

  @override
  Widget build(BuildContext context) => switch (tpl) {
    _Tpl.classic => _classic(),
    _Tpl.overlay => _overlay(),
    _Tpl.modern  => _modern(),
    _Tpl.grid    => _grid(),
    _Tpl.luxury  => _luxury(),
    _Tpl.minimal => _minimal(),
    _Tpl.split   => _split(),
  };

  Widget _line(double w, double h, Color c) => Container(
    width: w, height: h,
    decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(1.5)),
  );

  Widget _imgBox({double? w, double? h}) => Container(
    width: w, height: h,
    color: theme.accent.withOpacity(0.20),
    child: Center(child: Icon(Icons.image_outlined, size: 12, color: theme.accent.withOpacity(0.40))),
  );

  Widget _statPill() => Container(
    width: 16, height: 9,
    decoration: BoxDecoration(color: theme.bg, borderRadius: BorderRadius.circular(2)),
  );

  Widget _classic() => Container(
    color: Colors.white,
    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Container(
        height: 17, color: theme.primary,
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Row(children: [
          _line(18, 4, Colors.white70),
          const Spacer(),
          Container(width: 14, height: 7,
              decoration: BoxDecoration(color: theme.accent, borderRadius: BorderRadius.circular(2))),
        ]),
      ),
      _imgBox(h: 38),
      Container(height: 2, color: theme.accent),
      Expanded(child: Padding(
        padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _line(34, 4, theme.accent.withOpacity(0.45)),
          const SizedBox(height: 4),
          _line(54, 5, theme.primary),
          const SizedBox(height: 3),
          _line(42, 3, Colors.grey.shade400),
          const Spacer(),
          Row(children: [
            _line(26, 5, theme.primary),
            const Spacer(),
            Container(width: 22, height: 10,
                decoration: BoxDecoration(color: theme.primary, borderRadius: BorderRadius.circular(2))),
          ]),
        ]),
      )),
      Container(height: 8, color: theme.accent),
    ]),
  );

  Widget _overlay() => Stack(fit: StackFit.expand, children: [
    _imgBox(),
    Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [theme.primary.withOpacity(0.06), theme.primary.withOpacity(0.94)],
        ),
      ),
    ),
    Positioned(
      top: 7, left: 5, right: 5,
      child: Row(children: [
        _line(20, 4, Colors.white70),
        const Spacer(),
        Container(width: 16, height: 7,
            decoration: BoxDecoration(color: theme.accent, borderRadius: BorderRadius.circular(2))),
      ]),
    ),
    Positioned(
      left: 5, right: 5, bottom: 7,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        _line(24, 3, theme.accent),
        const SizedBox(height: 3),
        _line(50, 5, Colors.white),
        const SizedBox(height: 3),
        _line(36, 3, Colors.white60),
        const SizedBox(height: 6),
        Row(children: [
          _line(26, 5, Colors.white),
          const Spacer(),
          _line(18, 3, Colors.white54),
        ]),
      ]),
    ),
  ]);

  Widget _modern() => Stack(fit: StackFit.expand, children: [
    Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.primary, Color.lerp(theme.primary, theme.accent, 0.38)!],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
      ),
    ),
    Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(5, 8, 5, 0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _line(30, 5, Colors.white),
          const SizedBox(height: 3),
          _line(20, 3, Colors.white54),
        ]),
      ),
      Expanded(
        child: Container(
          margin: const EdgeInsets.fromLTRB(5, 6, 5, 6),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
          clipBehavior: Clip.antiAlias,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Expanded(flex: 3, child: _imgBox()),
            Expanded(flex: 2, child: Padding(
              padding: const EdgeInsets.all(4),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                  _line(12, 3, theme.primary),
                  _line(12, 3, theme.primary),
                  _line(12, 3, theme.primary),
                ]),
                const SizedBox(height: 5),
                Row(children: [
                  _line(26, 5, theme.primary),
                  const Spacer(),
                  Container(width: 18, height: 9,
                      decoration: BoxDecoration(color: theme.accent, borderRadius: BorderRadius.circular(2))),
                ]),
              ]),
            )),
          ]),
        ),
      ),
    ]),
  ]);

  Widget _grid() => Container(
    color: Colors.white,
    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Container(
        height: 24,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.primary, Color.lerp(theme.primary, theme.accent, 0.40)!],
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _line(15, 3, theme.accent),
          const SizedBox(height: 2),
          _line(40, 4, Colors.white),
        ]),
      ),
      SizedBox(
        height: 36,
        child: Row(children: [
          Expanded(flex: 3, child: _imgBox()),
          const SizedBox(width: 2),
          Expanded(flex: 2, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Expanded(child: Container(color: theme.bg)),
            const SizedBox(height: 2),
            Expanded(child: Container(color: theme.bg)),
          ])),
        ]),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 6),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _statPill(), _statPill(), _statPill(),
        ]),
      ),
      const Spacer(),
      Padding(
        padding: const EdgeInsets.fromLTRB(5, 0, 5, 4),
        child: Row(children: [
          _line(26, 5, theme.primary),
          const Spacer(),
          Container(width: 20, height: 10,
              decoration: BoxDecoration(color: theme.primary, borderRadius: BorderRadius.circular(2))),
        ]),
      ),
      Container(height: 8, color: theme.accent),
    ]),
  );

  Widget _luxury() {
    final dark = Color.lerp(theme.primary, Colors.black, 0.72)!;
    return Container(
      color: dark,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(height: 1.5, color: theme.accent.withOpacity(0.75)),
        Padding(
          padding: const EdgeInsets.fromLTRB(5, 6, 5, 3),
          child: Row(children: [
            _line(18, 4, theme.accent),
            const Spacer(),
            Container(width: 18, height: 7,
              decoration: BoxDecoration(
                border: Border.all(color: theme.accent.withOpacity(0.7)),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _line(42, 5, Colors.white),
            const SizedBox(height: 3),
            _line(28, 3, Colors.white38),
          ]),
        ),
        const SizedBox(height: 5),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 5),
          height: 38,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: theme.accent.withOpacity(0.50)),
          ),
          clipBehavior: Clip.antiAlias,
          child: _imgBox(),
        ),
        const Spacer(),
        Container(margin: const EdgeInsets.symmetric(horizontal: 5), height: 1, color: Colors.white12),
        Padding(
          padding: const EdgeInsets.fromLTRB(5, 4, 5, 5),
          child: Row(children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _line(12, 2, theme.accent.withOpacity(0.7)),
              const SizedBox(height: 2),
              _line(26, 5, Colors.white),
            ]),
            const Spacer(),
            Container(width: 20, height: 10,
              decoration: BoxDecoration(
                border: Border.all(color: theme.accent.withOpacity(0.75)),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ]),
        ),
        Container(height: 1.5, color: theme.accent.withOpacity(0.75)),
      ]),
    );
  }

  Widget _minimal() => Container(
    color: Colors.white,
    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _imgBox(h: 44),
      Container(height: 2, color: theme.accent),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(5, 6, 5, 5),
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Container(width: 2.5, color: theme.accent, decoration: BoxDecoration(borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 5),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  _line(16, 3, Colors.black45),
                  const Spacer(),
                  Container(width: 14, height: 6,
                    decoration: BoxDecoration(color: theme.accent, borderRadius: BorderRadius.circular(1))),
                ]),
                const SizedBox(height: 4),
                _line(40, 5, Colors.black87),
                const SizedBox(height: 3),
                _line(30, 3, Colors.black38),
                const Spacer(),
                Row(children: [
                  _line(24, 5, Colors.black87),
                  const Spacer(),
                  Container(width: 16, height: 8,
                      decoration: BoxDecoration(color: theme.primary, borderRadius: BorderRadius.circular(2))),
                ]),
              ]),
            ),
          ]),
        ),
      ),
    ]),
  );

  Widget _split() => Row(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Expanded(
        flex: 5,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [theme.primary, Color.lerp(theme.primary, theme.accent, 0.28)!],
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
            ),
          ),
          padding: const EdgeInsets.all(5),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _line(14, 3, theme.accent),
            const SizedBox(height: 4),
            _line(26, 5, Colors.white),
            const SizedBox(height: 2),
            _line(20, 3, Colors.white54),
            const SizedBox(height: 8),
            _line(16, 2, Colors.white24),
            const SizedBox(height: 3),
            _line(18, 2, Colors.white24),
            const Spacer(),
            _line(22, 5, Colors.white),
            const SizedBox(height: 4),
            Container(width: 24, height: 10,
              decoration: BoxDecoration(
                border: Border.all(color: theme.accent.withOpacity(0.75)),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ]),
        ),
      ),
      Expanded(flex: 7, child: _imgBox()),
    ],
  );
}

// ── Template 1 — Classic ──────────────────────────────────────────────────────
// Dark header · image · white body · accent footer

class _ClassicPoster extends StatelessWidget {
  final _Args args;
  const _ClassicPoster({required this.args});

  @override
  Widget build(BuildContext context) {
    final p = args.property;
    final t = args.theme;
    final am = args.amenities.take(4).toList();

    return Container(
      color: Colors.white,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // ── Header ──────────────────────────────────────────────────────────
        Container(
          height: 80,
          color: t.primary,
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Row(children: [
            _brandTag(Colors.white),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(color: t.accent, borderRadius: BorderRadius.circular(6)),
              child: Text(args.actionLabel,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800,
                      color: Colors.white, letterSpacing: 1.0)),
            ),
          ]),
        ),

        // ── Image ────────────────────────────────────────────────────────────
        _img(args, w: 600, h: 252),
        Container(height: 5, color: t.accent),

        // ── Body ─────────────────────────────────────────────────────────────
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 20, 28, 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Type chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: t.accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: t.accent.withOpacity(0.30)),
                ),
                child: Text(args.typeLabel.toUpperCase(),
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: t.accent, letterSpacing: 0.8)),
              ),
              const SizedBox(height: 10),

              // Title
              Text(p.title ?? 'Property Listing',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: t.primary, height: 1.25),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 8),

              // Location
              Row(children: [
                Icon(Icons.location_on_rounded, size: 14, color: t.accent),
                const SizedBox(width: 4),
                Expanded(child: Text(
                  [p.location, p.city, p.state].where((s) => s != null && s.isNotEmpty).join(', '),
                  style: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                )),
              ]),
              const SizedBox(height: 14),

              // Stats bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: _featureRow(args, t.accent, t.primary),
              ),
              const SizedBox(height: 12),

              // Tags
              Wrap(spacing: 7, runSpacing: 5, children: [
                if (p.furnishing != null) _tag(p.furnishing!, t),
                if (p.facing != null) _tag('${p.facing} Facing', t),
                ...am.map((a) => _tag(a, t)),
              ]),

              const Spacer(),
              Container(height: 1, color: const Color(0xFFE2E8F0)),
              const SizedBox(height: 12),

              // Price + Contact
              Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('PRICE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: t.accent, letterSpacing: 1.2)),
                  Text(args.priceLabel,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: t.primary)),
                ]),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(color: t.primary, borderRadius: BorderRadius.circular(10)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.call_rounded, size: 14, color: Colors.white),
                    const SizedBox(width: 6),
                    Text(p.contactNumber,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                  ]),
                ),
              ]),
            ]),
          ),
        ),

        // ── Footer ───────────────────────────────────────────────────────────
        Container(
          height: 34, color: t.accent,
          alignment: Alignment.center,
          child: const Text('Listed on KeyBricks • Your Property Partner',
              style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w500, letterSpacing: 0.2)),
        ),
      ]),
    );
  }

  Widget _tag(String label, _PosterTheme t) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: t.accent.withOpacity(0.08),
      borderRadius: BorderRadius.circular(5),
      border: Border.all(color: t.accent.withOpacity(0.20)),
    ),
    child: Text(label, style: TextStyle(fontSize: 11, color: t.accent, fontWeight: FontWeight.w600)),
  );
}

// ── Template 2 — Overlay ──────────────────────────────────────────────────────
// Full-bleed image · gradient scrim · frosted info panel at bottom

class _OverlayPoster extends StatelessWidget {
  final _Args args;
  const _OverlayPoster({required this.args});

  @override
  Widget build(BuildContext context) {
    final p = args.property;
    final t = args.theme;

    return Stack(fit: StackFit.expand, children: [
      _img(args, w: 600, h: 848),

      // Gradient scrim
      Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [
              t.primary.withOpacity(0.10),
              t.primary.withOpacity(0.25),
              t.primary.withOpacity(0.75),
              t.primary.withOpacity(0.97),
            ],
            stops: const [0.0, 0.30, 0.58, 1.0],
          ),
        ),
      ),

      // Top bar
      Positioned(
        top: 0, left: 0, right: 0,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 28, 28, 20),
          child: Row(children: [
            _brandTag(Colors.white),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: t.accent,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [BoxShadow(color: t.accent.withOpacity(0.45), blurRadius: 10)],
              ),
              child: Text(args.actionLabel,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800,
                      color: Colors.white, letterSpacing: 1.0)),
            ),
          ]),
        ),
      ),

      // Bottom panel
      Positioned(
        left: 0, right: 0, bottom: 0,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 0, 28, 32),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(args.typeLabel.toUpperCase(),
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: t.accent, letterSpacing: 1.4)),
            const SizedBox(height: 6),
            Text(p.title ?? 'Property Listing',
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white, height: 1.2),
                maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.location_on_rounded, size: 14, color: Color(0xCCFFFFFF)),
              const SizedBox(width: 4),
              Expanded(child: Text(
                [p.location, p.city].where((s) => s != null && s.isNotEmpty).join(', '),
                style: const TextStyle(fontSize: 13, color: Color(0xCCFFFFFF)),
                maxLines: 1, overflow: TextOverflow.ellipsis,
              )),
            ]),
            const SizedBox(height: 16),

            // Feature chips
            Row(children: [
              if (p.bedrooms != null) ...[_oChip(Icons.bed_rounded, '${p.bedrooms} BHK', t), const SizedBox(width: 10)],
              if (p.bathrooms != null) ...[_oChip(Icons.bathtub_rounded, '${p.bathrooms}', t), const SizedBox(width: 10)],
              if (p.superArea != null) _oChip(Icons.square_foot_rounded, '${p.superArea!.toInt()} sqft', t),
            ]),
            const SizedBox(height: 18),

            Container(height: 1, color: Colors.white24),
            const SizedBox(height: 16),

            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('PRICE', style: TextStyle(fontSize: 9, color: t.accent, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
                Text(args.priceLabel,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
              ]),
              const Spacer(),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                const Text('Contact Now', style: TextStyle(fontSize: 11, color: Color(0xAAFFFFFF))),
                const SizedBox(height: 3),
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.call_rounded, size: 14, color: t.accent),
                  const SizedBox(width: 5),
                  Text(p.contactNumber,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                ]),
              ]),
            ]),
          ]),
        ),
      ),
    ]);
  }

  Widget _oChip(IconData icon, String text, _PosterTheme t) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.white12,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.white24),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 13, color: Colors.white70),
      const SizedBox(width: 5),
      Text(text, style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600)),
    ]),
  );
}

// ── Template 3 — Modern ───────────────────────────────────────────────────────
// Solid gradient bg · geometric accent circles · white rounded card

class _ModernPoster extends StatelessWidget {
  final _Args args;
  const _ModernPoster({required this.args});

  @override
  Widget build(BuildContext context) {
    final p = args.property;
    final t = args.theme;
    final am = args.amenities.take(3).toList();

    return Stack(children: [
      // Background gradient
      Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [t.primary, Color.lerp(t.primary, t.accent, 0.38)!],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
        ),
      ),

      // Decorative circles
      Positioned(top: -70, right: -70, child: _circle(230, t.accent.withOpacity(0.13))),
      Positioned(top: 90, right: 50,   child: _circle(80,  t.accent.withOpacity(0.09))),
      Positioned(bottom: -50, left: -50, child: _circle(190, t.accent.withOpacity(0.11))),

      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // Header row
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 36, 28, 0),
          child: Row(children: [
            _brandTag(Colors.white),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.16),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.white30),
              ),
              child: Text(args.actionLabel,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800,
                      color: Colors.white, letterSpacing: 1.0)),
            ),
          ]),
        ),
        const SizedBox(height: 20),

        // Title block on coloured bg
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(args.typeLabel.toUpperCase(),
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: t.accent, letterSpacing: 1.5)),
            const SizedBox(height: 8),
            Text(p.title ?? 'Property Listing',
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white, height: 1.2),
                maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            Row(children: [
              Icon(Icons.location_on_rounded, size: 14, color: t.accent),
              const SizedBox(width: 4),
              Expanded(child: Text(
                [p.location, p.city].where((s) => s != null && s.isNotEmpty).join(', '),
                style: const TextStyle(fontSize: 13, color: Colors.white70),
                maxLines: 1, overflow: TextOverflow.ellipsis,
              )),
            ]),
          ]),
        ),
        const SizedBox(height: 22),

        // White card
        Expanded(
          child: Container(
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.22), blurRadius: 28, offset: const Offset(0, 10))],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              _img(args, w: 560, h: 210),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    // Stat boxes
                    Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                      if (p.bedrooms != null)  _statBox('${p.bedrooms}',           'BHK',   t),
                      if (p.bathrooms != null) _statBox('${p.bathrooms}',          'Bath',  t),
                      if (p.superArea != null) _statBox('${p.superArea!.toInt()}', 'sqft',  t),
                      if (p.floorNumber != null) _statBox('${p.floorNumber}',      'Floor', t),
                    ]),
                    const SizedBox(height: 12),

                    if (am.isNotEmpty)
                      Wrap(spacing: 6, runSpacing: 4,
                          children: am.map((a) => _mTag(a, t)).toList()),

                    const Spacer(),
                    Container(height: 1, color: const Color(0xFFE2E8F0)),
                    const SizedBox(height: 10),

                    Row(children: [
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('ASKING PRICE',
                            style: TextStyle(fontSize: 9, color: t.accent, fontWeight: FontWeight.w700, letterSpacing: 1)),
                        Text(args.priceLabel,
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: t.primary)),
                      ])),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                        decoration: BoxDecoration(color: t.accent, borderRadius: BorderRadius.circular(10)),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.call_rounded, size: 14, color: Colors.white),
                          const SizedBox(width: 5),
                          Text(p.contactNumber,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                        ]),
                      ),
                    ]),
                  ]),
                ),
              ),
            ]),
          ),
        ),
      ]),
    ]);
  }

  Widget _circle(double size, Color color) =>
      Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, color: color));

  Widget _statBox(String value, String label, _PosterTheme t) => Column(mainAxisSize: MainAxisSize.min, children: [
    Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: t.primary)),
    Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
  ]);

  Widget _mTag(String label, _PosterTheme t) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: t.bg,
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: t.accent.withOpacity(0.25)),
    ),
    child: Text(label, style: TextStyle(fontSize: 11, color: t.primary, fontWeight: FontWeight.w500)),
  );
}

// ── Template 4 — Grid ─────────────────────────────────────────────────────────
// Accent header · image + decorative tiles · stats · price footer

class _GridPoster extends StatelessWidget {
  final _Args args;
  const _GridPoster({required this.args});

  @override
  Widget build(BuildContext context) {
    final p = args.property;
    final t = args.theme;
    final am = args.amenities.take(4).toList();

    return Container(
      color: Colors.white,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // ── Accent header ─────────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.fromLTRB(24, 22, 24, 22),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [t.primary, Color.lerp(t.primary, t.accent, 0.40)!],
              begin: Alignment.centerLeft, end: Alignment.centerRight,
            ),
          ),
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(args.actionLabel,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: t.accent, letterSpacing: 1.5)),
              const SizedBox(height: 4),
              Text(p.title ?? 'Property Listing',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white, height: 1.2),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
            ])),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              _brandTag(Colors.white70),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: t.accent.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: t.accent.withOpacity(0.40)),
                ),
                child: Text(args.typeLabel,
                    style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ]),
          ]),
        ),

        // ── Image + 2 decorative tiles ────────────────────────────────────────
        SizedBox(
          height: 270,
          child: Row(children: [
            Expanded(flex: 3, child: _img(args, w: 360, h: 270)),
            const SizedBox(width: 3),
            Expanded(flex: 2, child: Column(children: [
              Expanded(child: _deco('Spacious Layout', Icons.space_dashboard_outlined, t)),
              const SizedBox(height: 3),
              Expanded(child: _deco('Prime Location', Icons.location_city_outlined, t)),
            ])),
          ]),
        ),

        // ── Location strip ────────────────────────────────────────────────────
        Container(
          color: t.bg,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Row(children: [
            Icon(Icons.location_on_rounded, size: 14, color: t.accent),
            const SizedBox(width: 5),
            Expanded(child: Text(
              [p.location, p.city, p.state].where((s) => s != null && s.isNotEmpty).join(', '),
              style: TextStyle(fontSize: 13, color: t.primary, fontWeight: FontWeight.w500),
              maxLines: 1, overflow: TextOverflow.ellipsis,
            )),
          ]),
        ),

        // ── Stats ─────────────────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: const BoxDecoration(
              color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFE2E8F0)))),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            if (p.bedrooms != null)  _gStat(Icons.bed_rounded,         '${p.bedrooms} BHK', t),
            if (p.bathrooms != null) _gStat(Icons.bathtub_rounded,     '${p.bathrooms} Bath', t),
            if (p.superArea != null) _gStat(Icons.square_foot_rounded, '${p.superArea!.toInt()} sqft', t),
            if (p.furnishing != null) _gStat(Icons.chair_outlined,     p.furnishing!, t),
          ]),
        ),

        // ── Amenity chips ─────────────────────────────────────────────────────
        if (am.isNotEmpty || p.facing != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
            child: Wrap(spacing: 8, runSpacing: 5, children: [
              ...am.map((a) => _gTag(a, t)),
              if (p.facing != null) _gTag('${p.facing} Facing', t),
            ]),
          ),

        const Spacer(),

        // ── Price + Contact ───────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
          decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFFE2E8F0)))),
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('PRICE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: t.accent, letterSpacing: 1.2)),
              Text(args.priceLabel, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: t.primary)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
              decoration: BoxDecoration(color: t.primary, borderRadius: BorderRadius.circular(10)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.call_rounded, size: 15, color: Colors.white),
                const SizedBox(width: 6),
                Text(p.contactNumber,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
              ]),
            ),
          ]),
        ),

        Container(
          height: 34, margin: const EdgeInsets.only(top: 14),
          color: t.accent,
          alignment: Alignment.center,
          child: const Text('KeyBricks • Your Property Partner',
              style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w500, letterSpacing: 0.3)),
        ),
      ]),
    );
  }

  Widget _deco(String text, IconData icon, _PosterTheme t) => Container(
    color: t.bg,
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(icon, size: 26, color: t.primary.withOpacity(0.22)),
      const SizedBox(height: 5),
      Text(text, textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11, color: t.primary.withOpacity(0.45), fontWeight: FontWeight.w500)),
    ]),
  );

  Widget _gStat(IconData icon, String label, _PosterTheme t) => Column(mainAxisSize: MainAxisSize.min, children: [
    Container(
      width: 36, height: 36,
      decoration: BoxDecoration(shape: BoxShape.circle, color: t.accent.withOpacity(0.10)),
      child: Icon(icon, size: 16, color: t.accent),
    ),
    const SizedBox(height: 4),
    Text(label, style: TextStyle(fontSize: 11, color: t.primary, fontWeight: FontWeight.w600)),
  ]);

  Widget _gTag(String label, _PosterTheme t) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: t.accent.withOpacity(0.09),
      borderRadius: BorderRadius.circular(5),
      border: Border.all(color: t.accent.withOpacity(0.20)),
    ),
    child: Text(label, style: TextStyle(fontSize: 11, color: t.accent, fontWeight: FontWeight.w600)),
  );
}

// ── Template 5 — Luxury ───────────────────────────────────────────────────────
// Dark bg · accent border frame · centered image · ornamental divider · price

class _LuxuryPoster extends StatelessWidget {
  final _Args args;
  const _LuxuryPoster({required this.args});

  @override
  Widget build(BuildContext context) {
    final p = args.property;
    final t = args.theme;
    final dark = Color.lerp(t.primary, Colors.black, 0.72)!;
    final am = args.amenities.take(4).toList();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [dark, Color.lerp(dark, t.primary, 0.30)!],
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(children: [
        Positioned(top: 0,    left: 0, right: 0, child: Container(height: 3, color: t.accent)),
        Positioned(bottom: 0, left: 0, right: 0, child: Container(height: 3, color: t.accent)),

        Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const SizedBox(height: 3),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 22, 32, 6),
            child: Row(children: [
              _brandTag(t.accent),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: t.accent.withOpacity(0.70), width: 1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(args.actionLabel,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800,
                        color: t.accent, letterSpacing: 1.2)),
              ),
            ]),
          ),

          // Title + location
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 6, 32, 22),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(args.typeLabel.toUpperCase(),
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500,
                      color: t.accent.withOpacity(0.80), letterSpacing: 2.2)),
              const SizedBox(height: 7),
              Text(p.title ?? 'Luxury Property',
                  style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w700,
                      color: Colors.white, height: 1.2),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 7),
              Row(children: [
                Icon(Icons.location_on_rounded, size: 13, color: t.accent.withOpacity(0.70)),
                const SizedBox(width: 4),
                Expanded(child: Text(
                  [p.location, p.city, p.state].where((s) => s != null && s.isNotEmpty).join(', '),
                  style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.62), letterSpacing: 0.2),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                )),
              ]),
            ]),
          ),

          // Framed image
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: t.accent.withOpacity(0.42), width: 1.5),
            ),
            clipBehavior: Clip.antiAlias,
            child: _img(args, w: 536, h: 290, radius: BorderRadius.circular(3)),
          ),

          const SizedBox(height: 24),

          // Stats row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              if (p.bedrooms != null)    _lStat('${p.bedrooms} BHK',           Icons.bed_rounded, t),
              if (p.bathrooms != null)   _lStat('${p.bathrooms} Bath',          Icons.bathtub_rounded, t),
              if (p.superArea != null)   _lStat('${p.superArea!.toInt()} sqft', Icons.square_foot_rounded, t),
              if (p.floorNumber != null) _lStat('Floor ${p.floorNumber}',       Icons.layers_rounded, t),
            ]),
          ),

          if (am.isNotEmpty) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Wrap(spacing: 8, runSpacing: 6, children: am.map((a) => _lTag(a, t)).toList()),
            ),
          ],

          const Spacer(),

          // Ornamental divider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Row(children: [
              Expanded(child: Container(height: 1, color: t.accent.withOpacity(0.28))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Icon(Icons.diamond_outlined, size: 12, color: t.accent.withOpacity(0.48)),
              ),
              Expanded(child: Container(height: 1, color: t.accent.withOpacity(0.28))),
            ]),
          ),
          const SizedBox(height: 18),

          // Price + contact
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 0, 32, 26),
            child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('ASKING PRICE',
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700,
                        color: t.accent.withOpacity(0.72), letterSpacing: 1.5)),
                const SizedBox(height: 4),
                Text(args.priceLabel,
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: Colors.white)),
              ]),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: t.accent, width: 1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.call_rounded, size: 14, color: t.accent),
                  const SizedBox(width: 8),
                  Text(p.contactNumber,
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: t.accent)),
                ]),
              ),
            ]),
          ),

          const SizedBox(height: 3),
        ]),
      ]),
    );
  }

  Widget _lStat(String text, IconData icon, _PosterTheme t) => Column(mainAxisSize: MainAxisSize.min, children: [
    Container(
      width: 48, height: 48,
      decoration: BoxDecoration(
        border: Border.all(color: t.accent.withOpacity(0.32), width: 1),
        borderRadius: BorderRadius.circular(4),
        color: Colors.white.withOpacity(0.06),
      ),
      child: Icon(icon, size: 20, color: t.accent.withOpacity(0.78)),
    ),
    const SizedBox(height: 5),
    Text(text, style: const TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w600)),
  ]);

  Widget _lTag(String label, _PosterTheme t) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.07),
      borderRadius: BorderRadius.circular(3),
      border: Border.all(color: t.accent.withOpacity(0.22)),
    ),
    child: Text(label,
        style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.72), fontWeight: FontWeight.w500)),
  );
}

// ── Template 6 — Minimal ──────────────────────────────────────────────────────
// Full-width image · thin accent bar · left accent line · clean typography

class _MinimalPoster extends StatelessWidget {
  final _Args args;
  const _MinimalPoster({required this.args});

  @override
  Widget build(BuildContext context) {
    final p = args.property;
    final t = args.theme;
    final am = args.amenities.take(5).toList();

    return Container(
      color: Colors.white,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // Full-width image (no header bar)
        Stack(children: [
          _img(args, w: 600, h: 315),
          Positioned(
            top: 20, right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: t.accent,
                borderRadius: BorderRadius.circular(6),
                boxShadow: [BoxShadow(color: t.accent.withOpacity(0.40), blurRadius: 10)],
              ),
              child: Text(args.actionLabel,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800,
                      color: Colors.white, letterSpacing: 1.0)),
            ),
          ),
        ]),
        Container(height: 3, color: t.accent),

        // Content with left accent line
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 22, 28, 20),
            child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Container(
                width: 4,
                decoration: BoxDecoration(color: t.accent, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // Brand + type row
                  Row(children: [
                    _brandTag(t.primary),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: t.bg,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: t.accent.withOpacity(0.25)),
                      ),
                      child: Text(args.typeLabel.toUpperCase(),
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                              color: t.accent, letterSpacing: 0.8)),
                    ),
                  ]),
                  const SizedBox(height: 14),

                  Text(p.title ?? 'Property Listing',
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: t.primary, height: 1.2),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),

                  Row(children: [
                    Icon(Icons.location_on_rounded, size: 13, color: t.accent),
                    const SizedBox(width: 4),
                    Expanded(child: Text(
                      [p.location, p.city, p.state].where((s) => s != null && s.isNotEmpty).join(', '),
                      style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    )),
                  ]),
                  const SizedBox(height: 16),

                  _featureRow(args, t.accent, t.primary),

                  if (am.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(spacing: 7, runSpacing: 5,
                        children: am.map((a) => _mnTag(a, t)).toList()),
                  ],

                  const Spacer(),
                  Container(height: 1, color: const Color(0xFFE2E8F0)),
                  const SizedBox(height: 14),

                  Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('PRICE',
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700,
                              color: t.accent, letterSpacing: 1.2)),
                      Text(args.priceLabel,
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: t.primary)),
                    ]),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(color: t.primary, borderRadius: BorderRadius.circular(8)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.call_rounded, size: 14, color: Colors.white),
                        const SizedBox(width: 6),
                        Text(p.contactNumber,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                      ]),
                    ),
                  ]),
                ]),
              ),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _mnTag(String label, _PosterTheme t) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: t.bg,
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: t.accent.withOpacity(0.22)),
    ),
    child: Text(label, style: TextStyle(fontSize: 11, color: t.primary, fontWeight: FontWeight.w500)),
  );
}

// ── Template 7 — Split ────────────────────────────────────────────────────────
// Coloured info panel left · full-height image right

class _SplitPoster extends StatelessWidget {
  final _Args args;
  const _SplitPoster({required this.args});

  @override
  Widget build(BuildContext context) {
    final p = args.property;
    final t = args.theme;
    final am = args.amenities.take(4).toList();

    return Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      // Left panel — details
      Container(
        width: 242,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [t.primary, Color.lerp(t.primary, t.accent, 0.28)!],
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.fromLTRB(24, 40, 20, 32),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _brandTag(t.accent),
          const SizedBox(height: 26),

          // Accent underline accent
          Container(width: 32, height: 3, color: t.accent, margin: const EdgeInsets.only(bottom: 10)),

          Text(args.actionLabel,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: t.accent, letterSpacing: 2.0)),
          const SizedBox(height: 6),
          Text(args.typeLabel.toUpperCase(),
              style: const TextStyle(fontSize: 10, color: Colors.white54, letterSpacing: 0.8)),
          const SizedBox(height: 10),

          Text(p.title ?? 'Property Listing',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white, height: 1.25),
              maxLines: 4, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 12),

          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.location_on_rounded, size: 12, color: t.accent),
            const SizedBox(width: 4),
            Expanded(child: Text(
              [p.location, p.city, p.state].where((s) => s != null && s.isNotEmpty).join(', '),
              style: const TextStyle(fontSize: 12, color: Colors.white60, height: 1.4),
              maxLines: 2, overflow: TextOverflow.ellipsis,
            )),
          ]),
          const SizedBox(height: 20),

          if (p.bedrooms != null)    _spFeature(Icons.bed_rounded,         '${p.bedrooms} BHK', t),
          if (p.bathrooms != null) ...[const SizedBox(height: 8), _spFeature(Icons.bathtub_rounded, '${p.bathrooms} Bathrooms', t)],
          if (p.superArea != null) ...[const SizedBox(height: 8), _spFeature(Icons.square_foot_rounded, '${p.superArea!.toInt()} sqft', t)],
          if (p.furnishing != null) ...[const SizedBox(height: 8), _spFeature(Icons.chair_outlined, p.furnishing!, t)],

          if (am.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(spacing: 5, runSpacing: 5,
                children: am.take(3).map((a) => _spTag(a, t)).toList()),
          ],

          const Spacer(),

          Container(height: 1, color: AppColors.white15),
          const SizedBox(height: 14),

          Text('PRICE',
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: t.accent, letterSpacing: 1.5)),
          const SizedBox(height: 4),
          Text(args.priceLabel,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: t.accent.withOpacity(0.65)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.call_rounded, size: 14, color: t.accent),
              const SizedBox(width: 6),
              Expanded(child: Text(p.contactNumber,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: t.accent),
                  overflow: TextOverflow.ellipsis)),
            ]),
          ),
        ]),
      ),

      // Right panel — image
      Expanded(
        child: Stack(fit: StackFit.expand, children: [
          _img(args, w: 358, h: 848),
          Positioned(
            top: 28, right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: t.accent,
                borderRadius: BorderRadius.circular(6),
                boxShadow: [BoxShadow(color: t.accent.withOpacity(0.40), blurRadius: 10)],
              ),
              child: Column(children: [
                const Text('FOR',
                    style: TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w600, letterSpacing: 1.0)),
                Text(args.isRent ? 'RENT' : 'SALE',
                    style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
              ]),
            ),
          ),
        ]),
      ),
    ]);
  }

  Widget _spFeature(IconData icon, String text, _PosterTheme t) => Row(
    mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 13, color: t.accent.withOpacity(0.72)),
      const SizedBox(width: 6),
      Text(text, style: const TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w500)),
    ],
  );

  Widget _spTag(String label, _PosterTheme t) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.10),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(label,
        style: const TextStyle(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.w500)),
  );
}
