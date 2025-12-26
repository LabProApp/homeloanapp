import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "User Profile Page",
          style: TextStyle(color: Colors.black),
        ),
      ),

      backgroundColor: Colors.white,

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),

            // Profile Image
            Stack(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage("assets/user.png"), // Change your asset
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    height: 28,
                    width: 28,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                  ),
                )
              ],
            ),

            const SizedBox(height: 15),

            const Text(
              "John Anderson",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const Text(
              "Premium Member",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),

            const SizedBox(height: 25),

            // Personal Information Card
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Personal Information",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),

                  const SizedBox(height: 10),
                  infoField("Full Name", "John Anderson"),
                  const SizedBox(height: 15),
                  infoField("Email Address", "john.anderson@email.com"),
                  const SizedBox(height: 15),
                  infoField("Mobile Number", "+1 (555) 123-4567"),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Current Plan
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Current Plan",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),

                  const SizedBox(height: 10),

                  Row(
                    children: const [
                      Icon(Icons.verified, color: Colors.blue),
                      SizedBox(width: 10),
                      Text("Premium Plan",
                          style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                      Spacer(),
                      Text("Active", style: TextStyle(color: Colors.green)),
                    ],
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Access to all premium features and unlimited property views",
                    style: TextStyle(color: Colors.grey),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const Text("Next billing: Jan 15, 2025",
                          style: TextStyle(color: Colors.grey)),
                      const Spacer(),
                      Text("Change Plan",
                          style: TextStyle(color: Colors.blue.shade600)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Recent Activity
            activityItem("Liked “Modern Villa”", "2 hours ago"),
            const SizedBox(height: 10),
            activityItem("Shared “Downtown Apartment”", "1 day ago"),

            const SizedBox(height: 25),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                ),
                onPressed: () {},
                child: const Text("Save Changes"),
              ),
            ),

            const SizedBox(height: 10),

            // Sign out
            TextButton(
              onPressed: () {},
              child: const Text("Sign Out", style: TextStyle(color: Colors.red)),
            )
          ],
        ),
      ),
    );
  }

  // Personal Info Field
  Widget infoField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 13, color: Colors.grey)),
        const SizedBox(height: 5),
        TextField(
          controller: TextEditingController(text: value),
          decoration: const InputDecoration(
            suffixIcon: Icon(Icons.edit, size: 18),
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 10),
          ),
        )
      ],
    );
  }

  // Activity Box
  Widget activityItem(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.favorite_border, color: Colors.black),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 14)),
              Text(subtitle, style: TextStyle(color: Colors.grey.shade600)),
            ],
          )
        ],
      ),
    );
  }
}
