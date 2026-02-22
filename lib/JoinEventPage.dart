import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class JoinEventPage extends StatefulWidget {
  final String eventId;
  const JoinEventPage({super.key, required this.eventId});

  @override
  State<JoinEventPage> createState() => _JoinEventPageState();
}

class _JoinEventPageState extends State<JoinEventPage> {
  final nameController = TextEditingController();
  final deptController = TextEditingController();
  final collegeController = TextEditingController();
  final yearController = TextEditingController();
  File? paymentScreenshot;
  bool loading = false;
  final picker = ImagePicker();

  Future<void> pickScreenshot() async {
    final picked =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked != null) {
      setState(() {
        paymentScreenshot = File(picked.path);
      });
    }
  }

  Future<void> submitJoin() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please login before joining")));
      return;
    }

    if (nameController.text.isEmpty ||
        deptController.text.isEmpty ||
        collegeController.text.isEmpty ||
        yearController.text.isEmpty ||
        paymentScreenshot == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Fill all fields and upload screenshot")));
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      // Convert image to Base64
      String screenshotBase64 =
          base64Encode(await paymentScreenshot!.readAsBytes());

      // Write to Firestore under events/{eventId}/joinedUsers/{uid}
      await FirebaseFirestore.instance
          .collection("events")
          .doc(widget.eventId)
          .collection("joinedUsers")
          .doc(uid)
          .set({
        "name": nameController.text.trim(),
        "department": deptController.text.trim(),
        "college": collegeController.text.trim(),
        "year": yearController.text.trim(),
        "paymentScreenshot": screenshotBase64,
        "joinedAt": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Joined successfully!")));
      Navigator.pop(context); // back to student home
    } catch (e) {
      print("Join failed: $e"); // <-- debug console
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Failed to join event: $e")));
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text("Join Event"), backgroundColor: Colors.blue),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: deptController,
              decoration: const InputDecoration(labelText: "Department"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: collegeController,
              decoration: const InputDecoration(labelText: "College"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: yearController,
              decoration: const InputDecoration(labelText: "Year"),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: pickScreenshot,
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12)),
                child: paymentScreenshot != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child:
                            Image.file(paymentScreenshot!, fit: BoxFit.cover))
                    : const Center(child: Text("Upload Payment Screenshot")),
              ),
            ),
            const SizedBox(height: 20),
            loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: submitJoin,
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50)),
                    child: const Text("Submit and Join"),
                  ),
          ],
        ),
      ),
    );
  }
}
