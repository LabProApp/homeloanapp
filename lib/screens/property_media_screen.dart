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

class PropertyMediaScreen extends StatefulWidget {
  final int propertyId;

  const PropertyMediaScreen({
    super.key,
    required this.propertyId,
  });

  @override
  State<PropertyMediaScreen> createState() => _PropertyMediaScreenState();
}

class _PropertyMediaScreenState extends State<PropertyMediaScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _uploading = false;
  double _progress = 0;
  bool _picking = false;
  double _pickProgress = 0;
  String _appName = "App";

  final List<_MediaItem> _mediaList = [];

  final captions = [
    "Kitchen",
    "Bedroom",
    "Bathroom",
    "Balcony",
    "Living Room",
    "Drawing Room",
    "Pooja Room",
    "Front",
    "Elevation",
    "Plot",
    "Showroom",
  ];

  @override
  void initState() {
    super.initState();
    _loadAppName();
  }

  Future<void> _loadAppName() async {
    final info = await PackageInfo.fromPlatform();
    setState(() => _appName = info.appName);
  }

  /// -------- MEDIA PICKER (IMAGE OR VIDEO) ----------
  void _pickMedia() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text("Pick Images"),
              onTap: () {
                Navigator.pop(context);
                _pickImages();
              },
            ),
            ListTile(
              leading: const Icon(Icons.video_library),
              title: const Text("Pick Video"),
              onTap: () {
                Navigator.pop(context);
                _pickVideo();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImages() async {
    final files = await _picker.pickMultiImage(imageQuality: 95);
    if (files.isEmpty) return;

    setState(() {
      _picking = true;
      _pickProgress = 0;
    });

    for (int i = 0; i < files.length; i++) {
      File imgFile = await _compressImage(File(files[i].path));
      imgFile = await _addWatermark(imgFile);

      _mediaList.add(
        _MediaItem(file: imgFile, caption: captions.first, isVideo: false),
      );

      setState(() {
        _pickProgress = (i + 1) / files.length;
      });
    }

    setState(() {
      _picking = false;
    });
  }

  Future<void> _pickVideo() async {
    final file = await _picker.pickVideo(source: ImageSource.gallery);
    if (file == null) return;
    final compressed = await _compressVideo(File(file.path));
    _mediaList.add(
      _MediaItem(file: compressed, caption: captions.first, isVideo: true),
    );
    setState(() {});
  }

  Future<File> _compressImage(File file) async {
    final bytes = await file.readAsBytes();
    final original = img.decodeImage(bytes);
    if (original == null) return file;

    final resized =
    original.width > 1920 ? img.copyResize(original, width: 1920) : original;

    final compressedBytes = img.encodeJpg(resized, quality: 90);
    final newFile = File(file.path)..writeAsBytesSync(compressedBytes);
    return newFile;
  }

  Future<File> _compressVideo(File file) async {
    final info = await VideoCompress.compressVideo(
      file.path,
      quality: VideoQuality.MediumQuality,
    );
    return File(info!.path!);
  }

  Future<File> _addWatermark(File file) async {
    final bytes = await file.readAsBytes();
    final original = img.decodeImage(bytes);
    if (original == null) return file;

    final font = img.arial24;

    img.drawString(
      original,
      _appName,
      font: font,
      x: original.width - (_appName.length * 14),
      y: original.height - 40,
      color: img.ColorUint8.rgb(255, 255, 255),
    );

    final watermarked = File(file.path)
      ..writeAsBytesSync(img.encodeJpg(original, quality: 90));

    return watermarked;
  }

  Future<void> _upload() async {
    if (_mediaList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please add at least one image or video")),
      );
      return;
    }

    setState(() => _uploading = true);

    try {
      await DocumentApiService.uploadDocuments(
        objectType: "PROPERTY",
        objectId: widget.propertyId,
        files: _mediaList.map((e) => e.file).toList(),
        captions: _mediaList.map((e) => e.caption).toList(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Upload completed")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Upload failed: $e")),
      );
    }

    setState(() => _uploading = false);
  }

  void _openPreview(_MediaItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FullscreenPreview(item: item)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Upload Photos / Videos"),
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.secondary,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),

      /// -------- BOTTOM BUTTONS ----------
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_uploading) LinearProgressIndicator(value: _progress),
              const SizedBox(height: 8),

              AppButton(
                text: "Add Photos / Videos",

                onTap: _pickMedia,
              ),
              const SizedBox(height: 8),

              AppButton(
                isLoading: _uploading,
                text: "Finalize Property",
                onTap: () {
                  if (_mediaList.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please add at least one image or video"),
                      ),
                    );
                    return;
                  }
                  _upload();
                },
              ),
            ],
          ),
        ),
      ),

      /// -------- GRID ----------
      body: _mediaList.isEmpty
          ? const Center(child: Text("No media selected"))
          : GridView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _mediaList.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemBuilder: (_, i) {
          final item = _mediaList[i];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: () => _openPreview(item),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          color: Colors.black12,
                          width: double.infinity,
                          child: item.isVideo
                              ? const Icon(Icons.play_circle_fill, size: 50)
                              : Image.file(item.file, fit: BoxFit.cover),
                        ),
                      ),
                    ),

                    // ❌ DELETE BUTTON
                    Positioned(
                      top: 6,
                      right: 6,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _mediaList.removeAt(i);
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),

              // Caption BELOW media
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  color: AppColors.textBoxbackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: item.caption,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    items: captions
                        .map((e) => DropdownMenuItem(
                      value: e,
                      child: Text(e, style: const TextStyle(fontSize: 12)),
                    ))
                        .toList(),
                    onChanged: (v) => setState(() => item.caption = v!),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MediaItem {
  File file;
  String caption;
  bool isVideo;

  _MediaItem({
    required this.file,
    required this.caption,
    required this.isVideo,
  });
}

/// ---------- FULLSCREEN PREVIEW ----------
class FullscreenPreview extends StatefulWidget {
  final _MediaItem item;
  const FullscreenPreview({super.key, required this.item});

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
      appBar: AppBar(backgroundColor: Colors.black),
      body: Center(
        child: widget.item.isVideo
            ? (_controller != null && _controller!.value.isInitialized
            ? AspectRatio(
          aspectRatio: _controller!.value.aspectRatio,
          child: VideoPlayer(_controller!),
        )
            : const CircularProgressIndicator())
            : Image.file(widget.item.file),
      ),
    );
  }
}