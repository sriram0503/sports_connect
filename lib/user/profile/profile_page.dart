import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ImagePicker picker = ImagePicker();
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  User? user;
  Map<String, dynamic> userData = {};
  List<String> sportsInterests = [];
  List<String> achievements = [];
  List<String> connections = [];

  File? _profileImage;
  File? _backgroundImage;
  List<File> _mediaPosts = [];

  @override
  void initState() {
    super.initState();
    user = auth.currentUser;
    if (user != null) {
      fetchUserData();
    }
  }

  Future<void> fetchUserData() async {
    try {
      DocumentSnapshot userDoc = await firestore.collection('user').doc(user!.uid).get();
      if (userDoc.exists) {
        setState(() {
          userData = userDoc.data() as Map<String, dynamic>;

          if (userData.containsKey('sports_interests')) {
            sportsInterests = List<String>.from(userData['sports_interests']);
          }
          if (userData.containsKey('achievements')) {
            achievements = List<String>.from(userData['achievements']);
          }
          if (userData.containsKey('connections')) {
            connections = List<String>.from(userData['connections']);
          }
        });
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  Future<void> _pickImage(bool isProfile) async {
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Select Image Source"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, ImageSource.camera), child: const Text("Camera")),
          TextButton(onPressed: () => Navigator.pop(context, ImageSource.gallery), child: const Text("Gallery")),
        ],
      ),
    );
    if (source == null) return;
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        if (isProfile) {
          _profileImage = File(pickedFile.path);
        } else {
          _backgroundImage = File(pickedFile.path);
        }
      });
    }
  }

  Future<void> _pickMediaPost() async {
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Select Media Source"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, ImageSource.camera), child: const Text("Camera")),
          TextButton(onPressed: () => Navigator.pop(context, ImageSource.gallery), child: const Text("Gallery")),
        ],
      ),
    );
    if (source == null) return;
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      bool confirm = await _showConfirmationDialog(File(pickedFile.path));
      if (confirm) {
        setState(() => _mediaPosts.add(File(pickedFile.path)));
      }
    }
  }

  Future<bool> _showConfirmationDialog(File image) async {
    bool? result = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Post"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.file(image, height: 200, fit: BoxFit.cover),
            const SizedBox(height: 20),
            const Text("Do you want to post this image?"),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text("Post")),
        ],
      ),
    );
    return result ?? false;
  }

  void _editInfoPopup() {
    TextEditingController nameCtrl = TextEditingController(
        text: userData['first name'] != null && userData['last name'] != null
            ? '${userData['first name']} ${userData['last name']}'
            : user?.displayName ?? '');
    TextEditingController bioCtrl = TextEditingController(text: userData['bio'] ?? '');
    TextEditingController phoneCtrl = TextEditingController(text: userData['phone number']?.toString() ?? '');
    TextEditingController emailCtrl = TextEditingController(text: user?.email ?? '');
    TextEditingController locCtrl = TextEditingController(text: userData['address'] ?? '');
    TextEditingController ageCtrl = TextEditingController(text: userData['age']?.toString() ?? '');
    TextEditingController heightCtrl = TextEditingController(text: userData['height']?.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Profile Info"),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: "Name", border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: bioCtrl,
                  decoration: const InputDecoration(labelText: "Bio", border: OutlineInputBorder()),
                  maxLines: 2,
                  minLines: 2,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: phoneCtrl,
                  decoration: const InputDecoration(labelText: "Phone", border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(labelText: "Email", border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: locCtrl,
                  decoration: const InputDecoration(labelText: "Location", border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: ageCtrl,
                  decoration: const InputDecoration(labelText: "Age", border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: heightCtrl,
                  decoration: const InputDecoration(labelText: "Height (cm)", border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              setState(() {
                userData['first name'] = nameCtrl.text.split(' ').first;
                userData['last name'] = nameCtrl.text.split(' ').length > 1
                    ? nameCtrl.text.split(' ').sublist(1).join(' ')
                    : '';
                userData['bio'] = bioCtrl.text;
                userData['phone number'] = int.tryParse(phoneCtrl.text);
                userData['email'] = emailCtrl.text;
                userData['address'] = locCtrl.text;
                userData['age'] = int.tryParse(ageCtrl.text);
                userData['height'] = int.tryParse(heightCtrl.text);
              });
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String fullName = '';
    if (userData['first name'] != null && userData['last name'] != null) {
      fullName = '${userData['first name']} ${userData['last name']}';
    } else {
      fullName = user?.displayName ?? 'User';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushNamed(context, '/');
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 220,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: _backgroundImage != null
                            ? FileImage(_backgroundImage!)
                            : const AssetImage("assets/bg_placeholder.jpg") as ImageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 160,
                    left: MediaQuery.of(context).size.width / 2 - 60,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2))],
                      ),
                      padding: const EdgeInsets.all(2),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: _profileImage != null
                            ? FileImage(_profileImage!)
                            : const AssetImage("assets/profile_placeholder.png") as ImageProvider,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () => _pickImage(false),
                          child: _editIcon(),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => _pickImage(true),
                          child: _editIcon(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 70),
              _infoCard(fullName),
              _physicalAttributesCard(),
              _buildEditableChips(connections, "Connections"), // new
              _buildEditableChips(sportsInterests, "Sports Interests"),
              _buildEditableChips(achievements, "Achievements"), // new
              _postGallery(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoCard(String fullName) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(fullName,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ),
                IconButton(onPressed: _editInfoPopup, icon: const Icon(Icons.edit))
              ],
            ),
            Text(userData['bio'] ?? 'No bio provided'),
            const SizedBox(height: 6),
            if (userData['address'] != null) Text("📍 ${userData['address']}"),
            Text("📧 ${user?.email ?? 'No email'}"),
            if (userData['phone number'] != null) Text("📞 ${userData['phone number']}"),
          ],
        ),
      ),
    );
  }

  Widget _physicalAttributesCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("My Physical Info",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                if (userData['age'] != null)
                  Column(
                    children: [
                      Text("${userData['age']}",
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const Text("Age"),
                    ],
                  ),
                if (userData['height'] != null)
                  Column(
                    children: [
                      Text("${userData['height']} cm",
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const Text("Height"),
                    ],
                  ),
                if (userData['gender'] != null)
                  Column(
                    children: [
                      Text("${userData['gender']}",
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const Text("Gender"),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableChips(List<String> list, String title) {
    TextEditingController ctrl = TextEditingController();
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.blue),
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text("Add $title"),
                      content: TextField(
                        controller: ctrl,
                        decoration: const InputDecoration(
                          labelText: "Enter value",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                        ElevatedButton(
                          onPressed: () {
                            if (ctrl.text.trim().isNotEmpty) {
                              setState(() => list.add(ctrl.text.trim()));
                            }
                            Navigator.pop(context);
                          },
                          child: const Text("Add"),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
            Wrap(
              spacing: 6,
              children: list
                  .map((item) => Chip(
                label: Text(item),
                deleteIcon: const Icon(Icons.close),
                onDeleted: () => setState(() => list.remove(item)),
              ))
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Media Posts",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(onPressed: _pickMediaPost, icon: const Icon(Icons.add_a_photo))
            ],
          ),
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
            itemBuilder: (_, i) => Stack(
              fit: StackFit.expand,
              children: [
                Image.file(_mediaPosts[i], fit: BoxFit.cover),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => setState(() => _mediaPosts.removeAt(i)),
                    child: const CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.black54,
                      child: Icon(Icons.close, size: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _editIcon() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
      child: const Icon(Icons.edit, color: Colors.white, size: 20),
    );
  }
}
