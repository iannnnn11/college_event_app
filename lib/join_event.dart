import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class JoinEventPage extends StatefulWidget {
  final String eventId;
  final bool isPaid; // ✅ NEW

  const JoinEventPage({
    super.key,
    required this.eventId,
    required this.isPaid,
  });

  @override
  State<JoinEventPage> createState() => _JoinEventPageState();
}

class _JoinEventPageState extends State<JoinEventPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  String? selectedDepartment;
  String? selectedYear;
  String? paymentBase64;

  final List<String> departments = ["Computer", "Mech", "Extc", "IT"];
  final List<String> years = ["1st Year", "2nd Year", "3rd Year", "4th Year"];

  Future<void> pickPaymentImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        paymentBase64 = base64Encode(bytes);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payment screenshot selected")),
      );
    }
  }

  Future<void> submit() async {
    if (_formKey.currentState!.validate()) {
      if (selectedDepartment == null || selectedYear == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Select Department and Year")),
        );
        return;
      }

      // ✅ ONLY require screenshot if event is paid
      if (widget.isPaid && paymentBase64 == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Upload payment screenshot")),
        );
        return;
      }

      final uid = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance
          .collection("events")
          .doc(widget.eventId)
          .collection("joinedUsers")
          .doc(uid)
          .set({
        "name": _nameController.text,
        "department": selectedDepartment,
        "year": selectedYear,
        "paymentScreenshot": widget.isPaid ? paymentBase64 : null, // ✅ FIX
        "joinedAt": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Joined successfully")));

      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Join Event"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                    labelText: "Name", border: OutlineInputBorder()),
                validator: (val) => val!.isEmpty ? "Enter your name" : null,
              ),

              const SizedBox(height: 15),

              // Department
              DropdownButtonFormField<String>(
                value: selectedDepartment,
                decoration: const InputDecoration(
                  labelText: "Department",
                  border: OutlineInputBorder(),
                ),
                items: departments
                    .map((dept) =>
                        DropdownMenuItem(value: dept, child: Text(dept)))
                    .toList(),
                onChanged: (val) => setState(() => selectedDepartment = val),
              ),

              const SizedBox(height: 15),

              // Year
              DropdownButtonFormField<String>(
                value: selectedYear,
                decoration: const InputDecoration(
                  labelText: "Year",
                  border: OutlineInputBorder(),
                ),
                items: years
                    .map((y) => DropdownMenuItem(value: y, child: Text(y)))
                    .toList(),
                onChanged: (val) => setState(() => selectedYear = val),
              ),

              const SizedBox(height: 20),

              // ✅ SHOW ONLY IF PAID
              if (widget.isPaid) ...[
                const Text(
                  "Upload Payment Screenshot",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: pickPaymentImage,
                  icon: const Icon(Icons.upload_file),
                  label: const Text("Upload Screenshot"),
                ),
                const SizedBox(height: 20),
              ] else ...[
                const Text(
                  "This is a FREE event 🎉",
                  style: TextStyle(
                      color: Colors.green, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
              ],

              ElevatedButton(
                onPressed: submit,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text("Join Event"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
