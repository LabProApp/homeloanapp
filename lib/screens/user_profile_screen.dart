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

  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<UserModel> _futureUser;

  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  File? _selectedImage;
  String? _profileImageUrl;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _futureUser = _loadUser();
    _loadProfileImage();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<UserModel> _loadUser() async {
    final user = await UserApiService.getProfile(widget.userId);
    _nameCtrl.text = user.name;
    _addressCtrl.text = user.address;
    return user;
  }

  Future<void> _loadProfileImage() async {
    try {
      final docs = await DocumentApiService.getDocuments(
        objectType: 'USER',
        objectId: widget.userId,
      );
      if (docs.isNotEmpty && mounted) {
        setState(() => _profileImageUrl = docs.first.docUrl);
      }
    } catch (_) {}
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await ImagePicker()
        .pickImage(source: source, imageQuality: 70);
    if (picked != null && mounted) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  Future<void> _saveProfile(UserModel user) async {
    setState(() => _loading = true);
    try {
      await UserApiService.updateProfile(
        userId: user.id,
        name: _nameCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
      );

      if (_selectedImage != null) {
        await DocumentApiService.uploadDocuments(
          objectType: 'USER',
          objectId: user.id,
          files: [_selectedImage!],
        );
        await _loadProfileImage();
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.success,
          content: Text('Profile updated successfully'),
        ),
      );
      setState(() => _futureUser = _loadUser());
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.error,
          content: Text('Update failed: $e'),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showImagePickerSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 4),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded,
                  color: AppColors.primary),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded,
                  color: AppColors.primary),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
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
          if (snapshot.hasError || !snapshot.hasData) {
            return _errorView(snapshot.error?.toString() ?? 'No profile data found.');
          }

          final user = snapshot.data!;
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── AppBar ────────────────────────────────────────────────
              SliverAppBar(
                expandedHeight: 170,
                pinned: true,
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                iconTheme: const IconThemeData(color: Colors.white),
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  titlePadding: const EdgeInsets.only(bottom: 14),
                  title: const Text(
                    'My Profile',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        shadows: [
                          Shadow(offset: Offset(0, 1), blurRadius: 3)
                        ]),
                  ),
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
                      // ── Avatar + name + badges ─────────────────────
                      _profileHeader(user),

                      const SizedBox(height: 20),

                      // ── Personal Information ───────────────────────
                      _SectionCard(
                        icon: Icons.person_outline_rounded,
                        title: 'Personal Information',
                        children: [
                          _EditableField(
                            label: 'Full Name',
                            controller: _nameCtrl,
                            icon: Icons.badge_outlined,
                          ),
                          const SizedBox(height: 12),
                          _ReadOnlyField(
                            label: 'Email',
                            value: user.email,
                            icon: Icons.email_outlined,
                          ),
                          const SizedBox(height: 12),
                          _ReadOnlyField(
                            label: 'Mobile',
                            value: user.mobile,
                            icon: Icons.phone_outlined,
                          ),
                          const SizedBox(height: 12),
                          _EditableField(
                            label: 'Address',
                            controller: _addressCtrl,
                            icon: Icons.home_outlined,
                            maxLines: 2,
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // ── Account Details ────────────────────────────
                      _SectionCard(
                        icon: Icons.manage_accounts_outlined,
                        title: 'Account Details',
                        children: [
                          _ReadOnlyField(
                            label: 'Role',
                            value: _formatRole(user.userRole),
                            icon: Icons.work_outline_rounded,
                          ),
                          const SizedBox(height: 12),
                          _ReadOnlyField(
                            label: 'Plan',
                            value: user.userPackage.isNotEmpty
                                ? user.userPackage
                                : 'Free',
                            icon: Icons.workspace_premium_outlined,
                          ),
                          const SizedBox(height: 12),
                          _ReadOnlyField(
                            label: 'Status',
                            value: user.isVerified
                                ? 'Verified'
                                : 'Pending Verification',
                            icon: user.isVerified
                                ? Icons.verified_outlined
                                : Icons.pending_outlined,
                            valueColor: user.isVerified
                                ? AppColors.success
                                : AppColors.warning,
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // ── Save button ────────────────────────────────
                      AppButton(
                        text: 'Save Profile',
                        isLoading: _loading,
                        onTap: _loading ? null : () => _saveProfile(user),
                      ),

                      const SizedBox(height: 32),
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

  // ── Profile Header ────────────────────────────────────────────────────────

  Widget _profileHeader(UserModel user) {
    final imageUrl = _profileImageUrl ?? user.imageUrl;
    final hasNetworkImage = imageUrl.isNotEmpty;

    return Column(
      children: [
        // Avatar with camera overlay
        GestureDetector(
          onTap: _showImagePickerSheet,
          child: Stack(
            children: [
              CircleAvatar(
                radius: 54,
                backgroundColor: AppColors.primary.withOpacity(0.15),
                backgroundImage: _selectedImage != null
                    ? FileImage(_selectedImage!) as ImageProvider
                    : hasNetworkImage
                        ? NetworkImage(imageUrl)
                        : null,
                child: (_selectedImage == null && !hasNetworkImage)
                    ? Text(
                        user.name.isNotEmpty
                            ? user.name[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary),
                      )
                    : null,
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 4)
                    ],
                  ),
                  child: const Icon(Icons.camera_alt_rounded,
                      size: 14, color: Colors.white),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        Text(
          user.name,
          style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary),
        ),
        const SizedBox(height: 6),
        Text(
          user.email,
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),

        const SizedBox(height: 10),

        // Badges row
        Wrap(
          spacing: 8,
          runSpacing: 6,
          alignment: WrapAlignment.center,
          children: [
            _badge(
              icon: Icons.work_rounded,
              label: _formatRole(user.userRole),
              color: AppColors.primary,
            ),
            if (user.userPackage.isNotEmpty && user.userPackage != 'Free')
              _badge(
                icon: Icons.workspace_premium_rounded,
                label: user.userPackage,
                color: AppColors.warning,
              ),
          ],
        ),
      ],
    );
  }

  Widget _badge(
      {required IconData icon,
      required String label,
      required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _formatRole(String role) {
    switch (role.toUpperCase()) {
      case 'ADMIN':
        return 'Admin';
      case 'AGENT':
        return 'Agent';
      case 'OWNER':
        return 'Owner / Broker';
      case 'CUSTOMER':
        return 'Customer';
      default:
        return role.isEmpty ? 'User' : role;
    }
  }

  Widget _errorView(String msg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person_off_outlined,
                size: 64, color: AppColors.textMuted),
            const SizedBox(height: 16),
            const Text(
              "Couldn't load profile",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            const Text(
              'Check your connection and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              onPressed: () => setState(() => _futureUser = _loadUser()),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared Section Card ───────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;

  const _SectionCard(
      {required this.icon, required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
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
                Text(title,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

// ── Editable Field ────────────────────────────────────────────────────────────

class _EditableField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final int maxLines;

  const _EditableField({
    required this.label,
    required this.controller,
    required this.icon,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textMuted),
        prefixIcon: Icon(icon, size: 20, color: AppColors.textMuted),
        filled: true,
        fillColor: Colors.white,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}

// ── Read-only Field ───────────────────────────────────────────────────────────

class _ReadOnlyField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  const _ReadOnlyField({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textMuted),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textMuted)),
                const SizedBox(height: 2),
                Text(
                  value.isEmpty ? '—' : value,
                  style: TextStyle(
                      fontSize: 14,
                      color: valueColor ?? AppColors.textPrimary,
                      fontWeight: valueColor != null
                          ? FontWeight.w600
                          : FontWeight.normal),
                ),
              ],
            ),
          ),
          const Icon(Icons.lock_outline_rounded,
              size: 14, color: AppColors.textMuted),
        ],
      ),
    );
  }
}
