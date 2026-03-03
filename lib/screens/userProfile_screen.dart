import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';
import '../theme/app_colors.dart';
import '../commons/common_widget.dart';
import '../services/document_service.dart';

class ProfileScreen extends StatefulWidget {
  final int userId; // email or mobile

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

  late TextEditingController _nameCtrl;
  late TextEditingController _addressCtrl;

  String? _profileImageUrl; // 👈 from documents API

  @override
  void initState() {
    super.initState();
    _futureUser = UserApiService.getProfile(widget.userId);
  }

  /// 🔽 Fetch user documents and get image
  Future<void> _loadProfileImage(int userId) async {
    try {
      final docs = await DocumentApiService.getDocuments(
        objectType: "USER",
        objectId: userId,
      );

      if (docs.isNotEmpty) {
        setState(() {
          _profileImageUrl = docs.first.fileUrl; // assuming backend sends fileUrl
        });
      }
    } catch (e) {
      debugPrint("Failed to load profile image: $e");
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 70);

    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  Future<void> _saveProfile(UserModel user) async {
    try {
      setState(() => _loading = true);

      await UserApiService.updateProfile(
        userId: user.id,
        name: _nameCtrl.text,
        address: _addressCtrl.text,
      );

      if (_selectedImage != null) {
        await DocumentApiService.uploadDocuments(
          objectType: "USER",
          objectId: user.id,
          files: [_selectedImage!],
        );

        // reload image
        await _loadProfileImage(user.id);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully")),
      );

      setState(() {
        _futureUser = UserApiService.getProfile(widget.userId);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Update failed: $e")),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showImagePickerSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
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
      backgroundColor: Colors.grey.shade100,
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
            return const Center(child: Text("No profile data"));
          }

          final user = snapshot.data!;

          _nameCtrl = TextEditingController(text: user.name);
          _addressCtrl = TextEditingController(text: user.address);

          // 👇 load image once
          if (_profileImageUrl == null) {
            _loadProfileImage(user.id);
          }

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 180,
                pinned: true,
                backgroundColor: AppColors.primary,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: const Text("My Profile",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  background: Container(
                    decoration: BoxDecoration(
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
                              label: "Email Address",
                              value: user.email,
                              readOnly: true,
                            ),
                            const SizedBox(height: 12),
                            _InfoField(
                              label: "Mobile Number",
                              value: user.mobile,
                              readOnly: true,
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

                      const SizedBox(height: 12),

                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("Sign Out",
                            style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w600)),
                      ),

                      const SizedBox(height: 20),
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
          child: Stack(
            children: [
              CircleAvatar(radius: 54, backgroundImage: imageProvider),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  height: 34,
                  width: 34,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt,
                      color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(user.name,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _errorView(String msg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 12),
            const Text("Failed to load profile",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(msg, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _futureUser = UserApiService.getProfile(widget.userId);
                });
              },
              child: const Text("Retry"),
            )
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 6),
        TextField(
          controller: controller ?? TextEditingController(text: value),
          readOnly: readOnly,
          decoration: InputDecoration(
            suffixIcon: readOnly ? null : const Icon(Icons.edit, size: 18),
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
