import 'dart:io';
import 'package:flutter/material.dart';

class OtherUserProfilePage extends StatefulWidget {
  final String userName;
  final bool isCoach;

  const OtherUserProfilePage({
    Key? key,
    required this.userName,
    required this.isCoach,
  }) : super(key: key);

  @override
  State<OtherUserProfilePage> createState() => _OtherUserProfilePageState();
}

class _OtherUserProfilePageState extends State<OtherUserProfilePage> {
  // Dummy images and posts (replace with real network or DB later)
  File? _profileImage;
  File? _backgroundImage;
  List<File> _mediaPosts = [];

  // Example user details (these will later come from DB/API)
  String bio = "Professional Coach | Mentor";
  String location = "Los Angeles, USA";
  String email = "jane.smith@example.com";
  String phone = "+1 987 654 3210";
  int followers = 500;
  int following = 230;
  bool isFollowing = false;

  List<String> achievements = ["Olympic Coach", "10+ Years Experience", "Author of Sports Guide"];
  List<String> skills = ["Coaching", "Fitness", "Team Building"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Top background + profile picture
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 220,
                    width: double.infinity,
                    // decoration: BoxDecoration(
                    //   image: DecorationImage(
                    //     image: _backgroundImage != null
                    //         ? FileImage(_backgroundImage!)
                    //         : const AssetImage("assets/bg_placeholder.jpg") as ImageProvider,
                    //     fit: BoxFit.cover,
                    //   ),
                    // ),
                  ),
                  Positioned(
                    top: 160,
                    left: MediaQuery.of(context).size.width / 2 - 60,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2))
                        ],
                      ),
                      padding: const EdgeInsets.all(2),
                      child: CircleAvatar(
                        radius: 60,
                        // backgroundImage: _profileImage != null
                        //     ? FileImage(_profileImage!)
                        //     : const AssetImage("assets/profile_placeholder.png") as ImageProvider,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 70),

              // Info card
              _infoCard(),

              // Followers / Following
              _followersRow(),

              // Action Buttons
              _actionButtons(),

              // Achievements
              _buildChips(achievements, "Achievements"),

              // Skills
              _buildChips(skills, "Skills"),

              // Media Gallery
              _postGallery(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.userName,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(bio),
            const SizedBox(height: 6),
            Text("📍 $location"),
            Text("📧 $email"),
            Text("📞 $phone"),
          ],
        ),
      ),
    );
  }

  Widget _followersRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text("$followers",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Text("Followers"),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text("$following",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Text("Following"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() => isFollowing = !isFollowing);
              },
              icon: Icon(isFollowing ? Icons.check : Icons.person_add),
              label: Text(isFollowing ? "Following" : "Follow"),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Open chat with this user")),
                );
              },
              icon: const Icon(Icons.chat_bubble),
              label: const Text("Message"),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                if (widget.isCoach) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Request session with this coach")),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Calling this user")),
                  );
                }
              },
              icon: const Icon(Icons.phone),
              label: Text(widget.isCoach ? "Request" : "Call"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChips(List<String> list, String title) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              children: list
                  .map((item) => Chip(label: Text(item)))
                  .toList(),
            )
          ],
        ),
      ),
    );
  }

  Widget _postGallery() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Media Posts",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _mediaPosts.isEmpty
              ? const Text("No posts yet.")
              : GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: _mediaPosts.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemBuilder: (_, i) => Image.file(
              _mediaPosts[i],
              fit: BoxFit.cover,
            ),
          )
        ],
      ),
    );
  }
}
