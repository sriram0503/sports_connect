import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ImagePicker picker = ImagePicker();
  final cloudinary = CloudinaryPublic('dboltoh0q', 'flutter_present', cache: false);

  String userName = "John Doe";
  String bio = "Coach | Mentor | Athlete";
  String location = "New York, USA";
  String email = "john.doe@example.com";
  String phone = "+1 234 567 890";
  int followers = 350;
  int following = 180;

  List<String> achievements = ["National Level Player", "5+ Years Coaching", "MVP 2022"];
  List<String> skills = ["Basketball", "Leadership", "Strategy"];

  String? _profileImageUrl;
  String? _backgroundImageUrl;
  List<String> _mediaPostsUrl = [];

  final String userId = "user1"; // Firestore document ID

  @override
  void initState() {
    super.initState();
    loadImagesFromFirestore();
  }

  /// Load saved image URLs from Firestore
  Future<void> loadImagesFromFirestore() async {
    DocumentSnapshot doc =
    await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (doc.exists) {
      setState(() {
        _profileImageUrl = doc['profileImage'];
        _backgroundImageUrl = doc['backgroundImage'];
        _mediaPostsUrl = List<String>.from(doc['mediaPosts'] ?? []);
      });
    }
  }

  /// Upload image to Cloudinary and get URL
  Future<String?> uploadToCloudinary(File imageFile) async {
    try {
      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(imageFile.path, folder: 'my_app_images'),
      );
      return response.secureUrl;
    } catch (e) {
      print("Cloudinary upload error: $e");
      return null;
    }
  }

  /// Store image URL in Firestore
  Future<void> storeImageUrlInFirestore(String imageUrl, String type) async {
    final docRef = FirebaseFirestore.instance.collection('users').doc(userId);

    if (type == 'mediaPosts') {
      await docRef.set({
        'mediaPosts': FieldValue.arrayUnion([imageUrl])
      }, SetOptions(merge: true));
    } else {
      await docRef.set({type: imageUrl}, SetOptions(merge: true));
    }
  }

  /// Pick profile/background image
  Future<void> _pickImage(bool isProfile) async {
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Select Image Source"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, ImageSource.camera),
              child: const Text("Camera")),
          TextButton(
              onPressed: () => Navigator.pop(context, ImageSource.gallery),
              child: const Text("Gallery")),
        ],
      ),
    );
    if (source == null) return;

    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      String? imageUrl = await uploadToCloudinary(imageFile);
      if (imageUrl != null) {
        await storeImageUrlInFirestore(imageUrl, isProfile ? "profileImage" : "backgroundImage");
        setState(() {
          if (isProfile) {
            _profileImageUrl = imageUrl;
          } else {
            _backgroundImageUrl = imageUrl;
          }
        });
      }
    }
  }

  /// Pick media post
  Future<void> _pickMediaPost() async {
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Select Media Source"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, ImageSource.camera),
              child: const Text("Camera")),
          TextButton(
              onPressed: () => Navigator.pop(context, ImageSource.gallery),
              child: const Text("Gallery")),
        ],
      ),
    );
    if (source == null) return;

    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      bool confirm = await _showConfirmationDialog(imageFile);
      if (confirm) {
        String? imageUrl = await uploadToCloudinary(imageFile);
        if (imageUrl != null) {
          await storeImageUrlInFirestore(imageUrl, "mediaPosts");
          setState(() {
            _mediaPostsUrl.add(imageUrl);
          });
        }
      }
    }
  }

  /// Confirm before posting
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
    TextEditingController nameCtrl = TextEditingController(text: userName);
    TextEditingController bioCtrl = TextEditingController(text: bio);
    TextEditingController phoneCtrl = TextEditingController(text: phone);
    TextEditingController emailCtrl = TextEditingController(text: email);
    TextEditingController locCtrl = TextEditingController(text: location);

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
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Name", border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: bioCtrl, decoration: const InputDecoration(labelText: "Bio", border: OutlineInputBorder()), maxLines: 2),
                const SizedBox(height: 10),
                TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: "Phone", border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: "Email", border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: locCtrl, decoration: const InputDecoration(labelText: "Location", border: OutlineInputBorder())),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              setState(() {
                userName = nameCtrl.text;
                bio = bioCtrl.text;
                phone = phoneCtrl.text;
                email = emailCtrl.text;
                location = locCtrl.text;
              });
              FirebaseFirestore.instance.collection('users').doc(userId).set({
                'userName': userName,
                'bio': bio,
                'phone': phone,
                'email': email,
                'location': location,
              }, SetOptions(merge: true));
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
    return Scaffold(
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
                      image: _backgroundImageUrl != null
                          ? DecorationImage(image: NetworkImage(_backgroundImageUrl!), fit: BoxFit.cover)
                          : null,
                    ),
                  ),
                  Positioned(
                    top: 160,
                    left: MediaQuery.of(context).size.width / 2 - 60,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: _profileImageUrl != null
                          ? NetworkImage(_profileImageUrl!)
                          : null,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 12,
                    child: Column(
                      children: [
                        GestureDetector(onTap: () => _pickImage(false), child: const Icon(Icons.edit)),
                        const SizedBox(height: 8),
                        GestureDetector(onTap: () => _pickImage(true), child: const Icon(Icons.edit)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 70),
              _infoCard(),
              _followersRow(),
              _buildEditableChips(achievements, "Achievements"),
              _buildEditableChips(skills, "Skills"),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [Expanded(child: Text(userName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold))), IconButton(onPressed: _editInfoPopup, icon: const Icon(Icons.edit))]),
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
              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
              child: Column(children: [Text("$followers", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const Text("Followers")]),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
              child: Column(children: [Text("$following", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const Text("Following")]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableChips(List<String> list, String title) {
    TextEditingController ctrl = TextEditingController();
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                      content: TextField(controller: ctrl, decoration: const InputDecoration(labelText: "Enter value", border: OutlineInputBorder())),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                        ElevatedButton(
                          onPressed: () {
                            if (ctrl.text.trim().isNotEmpty) setState(() => list.add(ctrl.text.trim()));
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
              children: list.map((item) => Chip(label: Text(item), deleteIcon: const Icon(Icons.close), onDeleted: () => setState(() => list.remove(item)))).toList(),
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
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Media Posts", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), IconButton(onPressed: _pickMediaPost, icon: const Icon(Icons.add_a_photo))]),
          const SizedBox(height: 8),
          _mediaPostsUrl.isEmpty
              ? const Text("No posts yet.")
              : GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: _mediaPostsUrl.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 4, mainAxisSpacing: 4),
            itemBuilder: (_, i) => Stack(
              fit: StackFit.expand,
              children: [
                Image.network(_mediaPostsUrl[i], fit: BoxFit.cover),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        FirebaseFirestore.instance.collection('users').doc(userId).set({
                          'mediaPosts': FieldValue.arrayRemove([_mediaPostsUrl[i]])
                        }, SetOptions(merge: true));
                        _mediaPostsUrl.removeAt(i);
                      });
                    },
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
}
