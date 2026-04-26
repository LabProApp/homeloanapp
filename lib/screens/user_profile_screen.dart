import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';
import '../theme/app_colors.dart';
import '../commons/common_widget.dart';
import '../services/document_service.dart';

class ProfileScreen extends StatefulWidget {
  final int userId;

  const ProfileScreen({
    super.key,
    required this.userId,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<UserModel> _futureUser;

  File? _selectedImage;
  bool _loading = false;

  TextEditingController? _nameCtrl;
  TextEditingController? _addressCtrl;

  String? _profileImageUrl;

  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    debugPrint("📌 ProfileScreen INIT | userId: ${widget.userId}");

    _futureUser = _loadUser();
  }

  Future<UserModel> _loadUser() async {
    try {
      debugPrint("🔄 Fetching user profile...");

      final user = await UserApiService.getProfile(widget.userId);

      debugPrint("✅ User loaded: ${user.name}");

      return user;
    } catch (e) {
      debugPrint("❌ Error loading user: $e");
      rethrow;
    }
  }

  /// PROFILE IMAGE
  Future<void> _loadProfileImage(int userId) async {
    try {
      debugPrint("🔄 Loading profile image...");

      final docs = await DocumentApiService.getDocuments(
        objectType: "USER",
        objectId: userId,
      );

      if (docs.isNotEmpty) {
        debugPrint("✅ Profile image loaded");

        setState(() {
          _profileImageUrl = docs.first.docUrl;
        });
      } else {
        debugPrint("⚠️ No profile image found");
      }
    } catch (e) {
      debugPrint("❌ Image load error: $e");
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    debugPrint("📷 Picking image from $source");

    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 70);

    if (picked != null) {
      debugPrint("✅ Image selected: ${picked.path}");

      setState(() {
        _selectedImage = File(picked.path);
      });
    } else {
      debugPrint("⚠️ Image not selected");
    }
  }

  /// SAVE PROFILE
  Future<void> _saveProfile(UserModel user) async {
    try {
      debugPrint("💾 Saving profile...");

      setState(() => _loading = true);

      await UserApiService.updateProfile(
        userId: user.id,
        name: _nameCtrl!.text.trim(),
        address: _addressCtrl!.text.trim(),
      );
      debugPrint("✅ Profile updated");

      if (_selectedImage != null) {
        debugPrint("📤 Uploading profile image...");

        await DocumentApiService.uploadDocuments(
          objectType: "USER",
          objectId: user.id,
          files: [_selectedImage!],
        );

        await _loadProfileImage(user.id);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.success,
          content: Text("Profile updated successfully"),
        ),
      );

      setState(() {
        _futureUser = _loadUser();
      });
    } catch (e) {
      debugPrint("❌ Save failed: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.error,
          content: Text("Update failed: $e"),
        ),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showImagePickerSheet() {
    debugPrint("📂 Opening image picker sheet");

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Take Photo"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Choose from Gallery"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.listingbackground,
      body: FutureBuilder<UserModel>(
        future: _futureUser,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _errorView(snapshot.error.toString());
          }

          if (!snapshot.hasData) {
            return _errorView("No profile data found.");
          }

          final user = snapshot.data!;

          if (!_initialized) {
            _nameCtrl = TextEditingController(text: user.name);
            _addressCtrl = TextEditingController(text: user.address);
            _initialized = true;
          }

          if (_profileImageUrl == null) {
            _loadProfileImage(user.id);
          }

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 180,
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(20),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  centerTitle: true,
                  title: const Text("My Profile"),

                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _profileHeader(user),

                      const SizedBox(height: 24),

                      _sectionCard(
                        title: "Personal Information",
                        icon: Icons.person,
                        child: Column(
                          children: [
                            _InfoField(
                              label: "Full Name",
                              controller: _nameCtrl,
                              readOnly: false,
                            ),
                            const SizedBox(height: 12),
                            _InfoField(
                              label: "Email",
                              value: user.email,
                            ),
                            const SizedBox(height: 12),
                            _InfoField(
                              label: "Mobile",
                              value: user.mobile,
                            ),
                            const SizedBox(height: 12),
                            _InfoField(
                              label: "Address",
                              controller: _addressCtrl,
                              readOnly: false,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      AppButton(
                        text: "Save Profile",
                        isLoading: _loading,
                        onTap: () => _saveProfile(user),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _profileHeader(UserModel user) {
    ImageProvider imageProvider;

    if (_selectedImage != null) {
      imageProvider = FileImage(_selectedImage!);
    } else if (_profileImageUrl != null && _profileImageUrl!.isNotEmpty) {
      imageProvider = NetworkImage(_profileImageUrl!);
    } else {
      imageProvider = const AssetImage("assets/images/ic_launcher.png");
    }

    return Column(
      children: [
        GestureDetector(
          onTap: _showImagePickerSheet,
          child: CircleAvatar(radius: 54, backgroundImage: imageProvider),
        ),
        const SizedBox(height: 12),
        Text(
          user.name,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
      ],
    );
  }

  Widget _errorView(String msg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person_off_outlined, size: 64, color: AppColors.textMuted),
            const SizedBox(height: 16),
            const Text(
              "Couldn't load profile",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            const Text(
              "Check your connection and try again.",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              icon: const Icon(Icons.refresh_rounded),
              label: const Text("Retry"),
              onPressed: () {
                setState(() {
                  _initialized = false;
                  _futureUser = _loadUser();
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _InfoField extends StatelessWidget {
  final String label;
  final String? value;
  final TextEditingController? controller;
  final bool readOnly;

  const _InfoField({
    required this.label,
    this.value,
    this.controller,
    this.readOnly = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller ?? TextEditingController(text: value),
      readOnly: readOnly,
      decoration: InputDecoration(labelText: label),
    );
  }
}