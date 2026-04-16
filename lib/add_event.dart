import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class AddEvent extends StatefulWidget {
  const AddEvent({super.key});

  @override
  State<AddEvent> createState() => _AddEventState();
}

class _AddEventState extends State<AddEvent> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  File? imageFile;
  bool loading = false;

  final picker = ImagePicker();
  String? selectedCategory;

  final List<String> categories = [
    "Hackathon",
    "Coding Challenge",
    "Talks and Other",
    "Inter-College Events"
  ];
  // Pick image from gallery
  Future<void> pickImage() async {
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);

    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
  }
  

  // Add event to Firestore
  Future<void> addEvent() async {
  if (titleController.text.isEmpty ||
  descriptionController.text.isEmpty ||
  selectedCategory == null) {
ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(content: Text("All fields are required")),
);
return;
}

    setState(() {
      loading = true;
    });

    try {
      String imageBase64 = "";

      if (imageFile != null) {
        List<int> imageBytes = await imageFile!.readAsBytes();
        imageBase64 = base64Encode(imageBytes);
      }

      await FirebaseFirestore.instance.collection("events").add({
      "title": titleController.text,
      "description": descriptionController.text,
      "image": imageBase64,
      "category": selectedCategory, // ✅ NEW
      "likes": 0,
      "comments": [],
      "joinedUsers": []
    });
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Event added successfully")));
      Navigator.pop(context);
    } catch (e) {
      print("Error adding event: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Failed to add event")));
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Add Event"),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: "Event Title",
                prefixIcon: const Icon(Icons.title),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: "Description",
                prefixIcon: const Icon(Icons.description),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 15),

            DropdownButtonFormField<String>(
              value: selectedCategory,
              items: categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value;
                });
              },
              decoration: InputDecoration(
                labelText: "Select Category",
                prefixIcon: const Icon(Icons.category),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: pickImage,
              child: Container(
                width: double.infinity,
                height: 220,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: imageFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          imageFile!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Center(
                        child: Text(
                        "Tap to select image",
                        style: TextStyle(color: Colors.black54),
                      )),
              ),
            ),
            const SizedBox(height: 25),
            loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
  onPressed: addEvent,
  style: ElevatedButton.styleFrom(
    elevation: 5,
    backgroundColor: Colors.blueAccent,
    shadowColor: Colors.blue.withOpacity(0.4),
    minimumSize: const Size(double.infinity, 55),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    ),
  ),
  child: const Text(
    "🚀 Add Event",
    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  ),
),
          ],
        ),
      ),
    );
  }
}
