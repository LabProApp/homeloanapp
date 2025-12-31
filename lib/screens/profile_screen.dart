import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: CustomScrollView(
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
                  /// PROFILE HEADER
                  _profileHeader(),

                  const SizedBox(height: 24),

                  /// PERSONAL INFO
                  _sectionCard(
                    title: "Personal Information",
                    icon: Icons.person,
                    child: Column(
                      children: const [
                        _InfoField(label: "Full Name", value: "John Anderson"),
                        SizedBox(height: 12),
                        _InfoField(
                            label: "Email Address",
                            value: "john.anderson@email.com"),
                        SizedBox(height: 12),
                        _InfoField(
                            label: "Mobile Number",
                            value: "+1 (555) 123-4567"),
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
                              label: const Text("Premium"),
                              backgroundColor:
                              Colors.orange.shade100,
                              labelStyle: TextStyle(
                                  color: Colors.orange.shade900,
                                  fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            const Text(
                              "Active",
                              style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold),
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
                              "Next billing: Jan 15, 2025",
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                            const Spacer(),
                            Text(
                              "Change Plan",
                              style: TextStyle(
                                  color: Colors.orange.shade700,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// RECENT ACTIVITY
                  _sectionTitle("Recent Activity"),
                  const SizedBox(height: 8),
                  _activityItem(
                      Icons.favorite_border, "Liked “Modern Villa”", "2 hours ago"),
                  const SizedBox(height: 10),
                  _activityItem(Icons.share,
                      "Shared “Downtown Apartment”", "1 day ago"),

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
                            fontSize: 16, fontWeight: FontWeight.bold),
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
                          fontWeight: FontWeight.w600),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ---------------- HEADER ----------------
  Widget _profileHeader() {
    return Column(
      children: [
        Stack(
          children: [
            const CircleAvatar(
              radius: 54,
              backgroundImage: AssetImage("assets/user.png"),
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
        const Text(
          "John Anderson",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          "Premium Member",
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

  /// ---------------- SECTION TITLE ----------------
  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  /// ---------------- ACTIVITY ITEM ----------------
  Widget _activityItem(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.orange.shade700),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(subtitle,
                  style: TextStyle(color: Colors.grey.shade600)),
            ],
          ),
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
