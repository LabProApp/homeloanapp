import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_compress/video_compress.dart';
import 'package:image/image.dart' as img;
import 'package:video_player/video_player.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../theme/app_colors.dart';
import '../services/document_service.dart';
import '../commons/common_widget.dart';
import '../screens/dashboard_screen.dart';

class PropertyMediaScreen extends StatefulWidget {
  final int propertyId;
  final int userId;

  const PropertyMediaScreen({
    super.key,
    required this.propertyId,
    required this.userId,
  });

  @override
  State<PropertyMediaScreen> createState() => _PropertyMediaScreenState();
}

class _PropertyMediaScreenState extends State<PropertyMediaScreen> {
  final ImagePicker _picker = ImagePicker();

  bool _uploading = false;
  bool _picking   = false;
  int  _pickCurrent = 0;
  int  _pickTotal   = 0;

  String _appName = 'App';

  final List<_MediaItem> _mediaList = [];

  static const _captions = [
    'Living Room', 'Bedroom',    'Kitchen',   'Bathroom',
    'Balcony',     'Drawing Room','Pooja Room','Front',
    'Elevation',   'Plot',        'Showroom',  'Other',
  ];

  int get _photoCount => _mediaList.where((m) => !m.isVideo).length;
  int get _videoCount => _mediaList.where((m) =>  m.isVideo).length;

  @override
  void initState() {
    super.initState();
    _loadAppName();
  }

  Future<void> _loadAppName() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) setState(() => _appName = info.appName);
  }

  // ── Pick sheet ─────────────────────────────────────────────────────────────
  void _pickMedia() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 14),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Add Media',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                ),
              ),
              const SizedBox(height: 4),
              _MediaOption(
                icon: Icons.photo_library_outlined,
                title: 'Photos from Gallery',
                subtitle: 'Select one or multiple images',
                onTap: () { Navigator.pop(context); _pickImages(); },
              ),
              _MediaOption(
                icon: Icons.videocam_outlined,
                title: 'Property Tour Video',
                subtitle: 'Add a walkthrough video',
                onTap: () { Navigator.pop(context); _pickVideo(); },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // ── Image pick + process ───────────────────────────────────────────────────
  Future<void> _pickImages() async {
    final files = await _picker.pickMultiImage(imageQuality: 95);
    if (files.isEmpty) return;
    setState(() { _picking = true; _pickCurrent = 0; _pickTotal = files.length; });
    for (int i = 0; i < files.length; i++) {
      File f = await _compressImage(File(files[i].path));
      f = await _addWatermark(f);
      _mediaList.add(_MediaItem(file: f, caption: _captions.first, isVideo: false));
      setState(() => _pickCurrent = i + 1);
    }
    setState(() => _picking = false);
  }

  // ── Video pick + process ───────────────────────────────────────────────────
  Future<void> _pickVideo() async {
    final file = await _picker.pickVideo(source: ImageSource.gallery);
    if (file == null) return;
    setState(() { _picking = true; _pickCurrent = 0; _pickTotal = 1; });
    final compressed = await _compressVideo(File(file.path));
    _mediaList.add(_MediaItem(file: compressed, caption: _captions.first, isVideo: true));
    setState(() => _picking = false);
  }

  Future<File> _compressImage(File file) async {
    final bytes    = await file.readAsBytes();
    final original = img.decodeImage(bytes);
    if (original == null) return file;
    final resized  = original.width > 1920
        ? img.copyResize(original, width: 1920)
        : original;
    final jpg      = img.encodeJpg(resized, quality: 90);
    return File('${file.path}_compressed.jpg')..writeAsBytesSync(jpg);
  }

  Future<File> _compressVideo(File file) async {
    final info = await VideoCompress.compressVideo(
        file.path, quality: VideoQuality.MediumQuality);
    if (info == null || info.path == null) return file;
    await VideoCompress.deleteAllCache();
    return File(info.path!);
  }

  Future<File> _addWatermark(File file) async {
    final bytes    = await file.readAsBytes();
    final original = img.decodeImage(bytes);
    if (original == null) return file;
    img.drawString(
      original, _appName, font: img.arial24,
      x: original.width - (_appName.length * 14),
      y: original.height - 40,
      color: img.ColorUint8.rgb(255, 255, 255),
    );
    return File(file.path)
      ..writeAsBytesSync(img.encodeJpg(original, quality: 90));
  }

  // ── Upload ─────────────────────────────────────────────────────────────────
  Future<void> _upload() async {
    if (_mediaList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least one photo or video')));
      return;
    }
    setState(() => _uploading = true);
    try {
      await DocumentApiService.uploadDocuments(
        objectType: 'PROPERTY',
        objectId:    widget.propertyId,
        files:    _mediaList.map((e) => e.file).toList(),
        captions: _mediaList.map((e) => e.caption).toList(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: AppColors.success,
          content: Text('Property listed successfully!')));
      await Future.delayed(const Duration(milliseconds: 800));
      _goHome();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Upload failed: $e')));
      }
    }
    if (mounted) setState(() => _uploading = false);
  }

  void _goHome() => Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => DashboardScreen(userId: widget.userId)),
    (route) => false,
  );

  // ── Caption picker sheet ───────────────────────────────────────────────────
  void _showCaptionPicker(int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 14),
              const Text('Label this photo',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _captions.map((c) {
                  final sel = _mediaList[index].caption == c;
                  return ChoiceChip(
                    label: Text(c),
                    selected: sel,
                    onSelected: (_) {
                      setState(() => _mediaList[index].caption = c);
                      Navigator.pop(context);
                    },
                    selectedColor: AppColors.primary.withOpacity(0.15),
                    labelStyle: TextStyle(
                      fontSize: 13,
                      color: sel ? AppColors.primary : AppColors.textSecondary,
                      fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                    ),
                    side: BorderSide(
                        color: sel ? AppColors.primary : AppColors.border),
                    backgroundColor: AppColors.white,
                    showCheckmark: false,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openPreview(int index) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => FullscreenPreview(
          item: _mediaList[index],
          index: index,
          total: _mediaList.length),
    ));
  }

  // ── Scaffold ──────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final hasMedia = _mediaList.isNotEmpty;
    return Scaffold(
      backgroundColor: AppColors.listingbackground,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Property Photos'),
            if (hasMedia)
              Text(
                '$_photoCount photo${_photoCount != 1 ? 's' : ''}'
                '${_videoCount > 0 ? ', $_videoCount video${_videoCount != 1 ? 's' : ''}' : ''}',
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.white70),
              ),
          ],
        ),
      ),
      body: _picking
          ? _buildProcessingState()
          : hasMedia
              ? _buildGrid()
              : _buildEmptyState(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  // ── Empty state ────────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88, height: 88,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add_photo_alternate_outlined,
                  size: 40, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            const Text('Add Property Photos',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            const Text(
              'Properties with photos get 5× more inquiries. '
              'Add at least 5 photos for best results.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13, color: AppColors.textMuted, height: 1.5),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: AppButton(
                  text: 'Add Photos / Videos', onTap: _pickMedia),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: _goHome,
              child: const Text('Skip for now',
                  style: TextStyle(
                      fontSize: 13, color: AppColors.textMuted)),
            ),
          ],
        ),
      ),
    );
  }

  // ── Processing state ───────────────────────────────────────────────────────
  Widget _buildProcessingState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 64, height: 64,
              child: CircularProgressIndicator(
                value: _pickTotal > 0 ? _pickCurrent / _pickTotal : null,
                strokeWidth: 5,
                backgroundColor: AppColors.border,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _pickTotal > 1
                  ? 'Processing $_pickCurrent of $_pickTotal...'
                  : 'Processing media...',
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            const Text('Compressing & watermarking',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }

  // ── Media grid ─────────────────────────────────────────────────────────────
  Widget _buildGrid() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
      itemCount: _mediaList.length + 1,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.76,
      ),
      itemBuilder: (_, i) {
        if (i == _mediaList.length) return _buildAddTile();
        return _buildGridItem(i);
      },
    );
  }

  Widget _buildAddTile() {
    return GestureDetector(
      onTap: _pickMedia,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: AppColors.primary.withOpacity(0.3), width: 1.5),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate_outlined,
                size: 28, color: AppColors.primary),
            SizedBox(height: 6),
            Text('Add More',
                style: TextStyle(
                    fontSize: 11,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildGridItem(int i) {
    final item    = _mediaList[i];
    final isCover = i == 0 && !item.isVideo;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Thumbnail
              GestureDetector(
                onTap: () => _openPreview(i),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: item.isVideo
                      ? Container(
                          color: AppColors.textPrimary,
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.play_circle_fill,
                                  size: 32, color: AppColors.white70),
                              SizedBox(height: 4),
                              Text('Video',
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: AppColors.white70)),
                            ],
                          ),
                        )
                      : Image.file(item.file, fit: BoxFit.cover),
                ),
              ),
              // Cover badge
              if (isCover)
                Positioned(
                  top: 6, left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('Cover',
                        style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white)),
                  ),
                ),
              // Delete
              Positioned(
                top: 4, right: 4,
                child: GestureDetector(
                  onTap: () => setState(() => _mediaList.removeAt(i)),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.imageOverlay,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close,
                        size: 12, color: AppColors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Caption tap-to-change
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () => _showCaptionPicker(i),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    item.caption,
                    style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down,
                    size: 12, color: AppColors.textMuted),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Bottom action bar ──────────────────────────────────────────────────────
  Widget _buildBottomBar() {
    final hasMedia = _mediaList.isNotEmpty;
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: const Border(top: BorderSide(color: AppColors.border)),
          boxShadow: [
            BoxShadow(
                color: AppColors.shadowMedium,
                blurRadius: 8,
                offset: const Offset(0, -2)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_uploading) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Uploading photos...',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textMuted)),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: const LinearProgressIndicator(minHeight: 4),
              ),
              const SizedBox(height: 10),
            ],
            Row(
              children: [
                if (hasMedia) ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _uploading ? null : _pickMedia,
                      icon: const Icon(
                          Icons.add_photo_alternate_outlined, size: 16),
                      label: const Text('Add More'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 48),
                        padding:
                            const EdgeInsets.symmetric(horizontal: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  flex: 2,
                  child: AppButton(
                    text: hasMedia ? 'Upload & Finish' : 'Add Photos / Videos',
                    isLoading: _uploading,
                    onTap: _uploading ? null : (hasMedia ? _upload : _pickMedia),
                  ),
                ),
              ],
            ),
            if (hasMedia) ...[
              const SizedBox(height: 6),
              TextButton(
                onPressed: _uploading ? null : _goHome,
                style: TextButton.styleFrom(
                    minimumSize: const Size(0, 32),
                    padding: EdgeInsets.zero),
                child: const Text('Skip photos for now',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textMuted)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Data class ─────────────────────────────────────────────────────────────────

class _MediaItem {
  File   file;
  String caption;
  bool   isVideo;

  _MediaItem({required this.file, required this.caption, required this.isVideo});
}

// ── Media option row (pick sheet) ─────────────────────────────────────────────

class _MediaOption extends StatelessWidget {
  final IconData  icon;
  final String    title;
  final String    subtitle;
  final VoidCallback onTap;

  const _MediaOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary)),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textMuted)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

// ── Full-screen preview ────────────────────────────────────────────────────────

class FullscreenPreview extends StatefulWidget {
  final _MediaItem item;
  final int        index;
  final int        total;

  const FullscreenPreview({
    super.key,
    required this.item,
    required this.index,
    required this.total,
  });

  @override
  State<FullscreenPreview> createState() => _FullscreenPreviewState();
}

class _FullscreenPreviewState extends State<FullscreenPreview> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    if (widget.item.isVideo) {
      _controller = VideoPlayerController.file(widget.item.file)
        ..initialize().then((_) {
          setState(() {});
          _controller!.play();
        });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: AppColors.white,
        title: Text(
          '${widget.index + 1} / ${widget.total}',
          style: const TextStyle(
              color: AppColors.white70, fontSize: 14),
        ),
        actions: [
          if (!widget.item.isVideo)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(widget.item.caption,
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.white,
                          fontWeight: FontWeight.w500)),
                ),
              ),
            ),
        ],
      ),
      body: Center(
        child: widget.item.isVideo
            ? (_controller != null && _controller!.value.isInitialized
                ? GestureDetector(
                    onTap: () => setState(() {
                      _controller!.value.isPlaying
                          ? _controller!.pause()
                          : _controller!.play();
                    }),
                    child: AspectRatio(
                      aspectRatio: _controller!.value.aspectRatio,
                      child: VideoPlayer(_controller!),
                    ),
                  )
                : const CircularProgressIndicator(
                    color: AppColors.white))
            : InteractiveViewer(
                child: Image.file(widget.item.file)),
      ),
    );
  }
}
