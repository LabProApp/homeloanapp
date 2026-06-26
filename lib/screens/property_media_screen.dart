import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

import '../models/property_model.dart';
import '../theme/app_colors.dart';
import '../services/document_service.dart';
import '../commons/common_widget.dart';
import '../screens/dashboard_screen.dart';
import '../screens/property_poster_screen.dart';


class PropertyMediaScreen extends StatefulWidget {
  final int propertyId;
  final int userId;
  final PropertyModel? property;

  const PropertyMediaScreen({
    super.key,
    required this.propertyId,
    required this.userId,
    this.property,
  });

  @override
  State<PropertyMediaScreen> createState() => _PropertyMediaScreenState();
}

class _PropertyMediaScreenState extends State<PropertyMediaScreen> {
  final ImagePicker _picker = ImagePicker();

  bool _uploading = false;
  bool _picking   = false;
  int  _uploadCurrent = 0;
  int  _uploadTotal   = 0;

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
  }

  // ── Pick sheet ─────────────────────────────────────────────────────────────
  void _pickMedia() {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
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
  static const _maxImageBytes = 30 * 1024 * 1024;  // 30 MB
  static const _maxVideoBytes = 500 * 1024 * 1024; // 500 MB

  Future<void> _pickImages() async {
    final List<XFile> files;
    try {
      files = await _picker.pickMultiImage();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Photo library access denied. Please allow permission in Settings.'),
        ));
      }
      return;
    }
    if (files.isEmpty) return;

    setState(() => _picking = true);
    int skipped = 0;
    for (final f in files) {
      if (await f.length() > _maxImageBytes) {
        skipped++;
      } else {
        _mediaList.add(_MediaItem(file: File(f.path), caption: _captions.first, isVideo: false));
      }
    }
    if (skipped > 0 && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('$skipped photo${skipped > 1 ? 's' : ''} skipped (over 30 MB)'),
      ));
    }
    setState(() => _picking = false);
  }

  // ── Video pick ─────────────────────────────────────────────────────────────
  Future<void> _pickVideo() async {
    final XFile? file;
    try {
      file = await _picker.pickVideo(source: ImageSource.gallery);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Photo library access denied. Please allow permission in Settings.'),
        ));
      }
      return;
    }
    if (file == null) return;
    if (await file.length() > _maxVideoBytes) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Video is too large. Maximum allowed size is 500 MB.'),
        ));
      }
      return;
    }
    setState(() => _picking = true);
    _mediaList.add(_MediaItem(file: File(file.path), caption: _captions.first, isVideo: true));
    setState(() => _picking = false);
  }

  // ── Upload ─────────────────────────────────────────────────────────────────
  Future<void> _upload() async {
    if (_mediaList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least one photo or video')));
      return;
    }
    setState(() {
      _uploading = true;
      _uploadCurrent = 0;
      _uploadTotal = _mediaList.length;
    });
    try {
      for (int i = 0; i < _mediaList.length; i++) {
        setState(() => _uploadCurrent = i + 1);
        await DocumentApiService.uploadSingleDocument(
          objectType: 'PROPERTY',
          objectId: widget.propertyId,
          file: _mediaList[i].file,
          caption: _mediaList[i].caption,
        );
      }
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
      useSafeArea: true,
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
      appBar: GradientAppBar(
        titleWidget: Column(
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

  // ── Picking state ──────────────────────────────────────────────────────────
  Widget _buildProcessingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 64, height: 64,
              child: CircularProgressIndicator(
                strokeWidth: 5,
                backgroundColor: AppColors.border,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Preparing media...',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary),
            ),
            SizedBox(height: 6),
            Text('Adding to your listing',
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
                children: [
                  Text(
                    _uploadTotal > 0
                        ? 'Uploading $_uploadCurrent of $_uploadTotal...'
                        : 'Uploading...',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textMuted),
                  ),
                  Text(
                    '$_uploadTotal file${_uploadTotal != 1 ? 's' : ''}',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _uploadTotal > 0 ? _uploadCurrent / _uploadTotal : null,
                  minHeight: 4,
                ),
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
            if (hasMedia || widget.property != null) ...[
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (hasMedia)
                    TextButton(
                      onPressed: _uploading ? null : _goHome,
                      style: TextButton.styleFrom(
                          minimumSize: const Size(0, 32),
                          padding: EdgeInsets.zero),
                      child: const Text('Skip photos for now',
                          style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    )
                  else
                    const SizedBox.shrink(),
                  if (widget.property != null)
                    TextButton.icon(
                      onPressed: _uploading
                          ? null
                          : () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PropertyPosterScreen(property: widget.property!),
                                ),
                              ),
                      icon: const Icon(Icons.auto_awesome_outlined, size: 15),
                      label: const Text('Generate Poster',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          minimumSize: const Size(0, 32),
                          padding: const EdgeInsets.symmetric(horizontal: 4)),
                    ),
                ],
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
