import 'dart:ffi';

import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  final String userId; // email or mobile used during login

  const ProfileScreen({
    super.key,
    required this.userId,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<UserModel> _futureUser;

  @override
  void initState() {
    super.initState();
    _futureUser = UserApiService.getProfile(widget.userId);
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
            return const Center(child: Text("Failed to load profile"));
          }

          final user = snapshot.data!;

          return CustomScrollView(
            slivers: [
              /// ---------------- APP BAR ----------------
              SliverAppBar(
                expandedHeight: 180,
                pinned: true,
                backgroundColor: Colors.orange.shade700,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: const Text(
                    "My Profile",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.orange.shade400,
                          Colors.brown.shade400,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
              ),

              /// ---------------- CONTENT ----------------
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _profileHeader(user),

                      const SizedBox(height: 24),

                      /// PERSONAL INFO
                      _sectionCard(
                        title: "Personal Information",
                        icon: Icons.person,
                        child: Column(
                          children: [
                            _InfoField(label: "Full Name", value: user.name),
                            const SizedBox(height: 12),
                            _InfoField(label: "Email Address", value: user.email),
                            const SizedBox(height: 12),
                            _InfoField(label: "Mobile Number", value: user.mobile),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      /// CURRENT PLAN
                      _sectionCard(
                        title: "Current Plan",
                        icon: Icons.workspace_premium,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Chip(
                                  label: Text(user.plan),
                                  backgroundColor: Colors.orange.shade100,
                                  labelStyle: TextStyle(
                                    color: Colors.orange.shade900,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  user.planStatus,
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Access to all premium features and unlimited property views.",
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  "Next billing: ${user.nextBilling}",
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                                const Spacer(),
                                Text(
                                  "Change Plan",
                                  style: TextStyle(
                                    color: Colors.orange.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      /// ACTION BUTTONS
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade700,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () {},
                          child: const Text(
                            "Save Changes",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          "Sign Out",
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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

  /// ---------------- HEADER ----------------
  Widget _profileHeader(UserModel user) {
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 54,
              backgroundImage: NetworkImage(user.imageUrl),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                height: 32,
                width: 32,
                decoration: BoxDecoration(
                  color: Colors.orange.shade700,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.camera_alt,
                    color: Colors.white, size: 18),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          user.name,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          "${user.plan} Member",
          style: TextStyle(color: Colors.grey.shade600),
        ),
      ],
    );
  }

  /// ---------------- SECTION CARD ----------------
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
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.orange.shade700),
              const SizedBox(width: 8),
              Text(
                title,
                style:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

/// ---------------- INFO FIELD ----------------
class _InfoField extends StatelessWidget {
  final String label;
  final String value;

  const _InfoField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 6),
        TextField(
          controller: TextEditingController(text: value),
          readOnly: true,
          decoration: InputDecoration(
            suffixIcon: const Icon(Icons.edit, size: 18),
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
