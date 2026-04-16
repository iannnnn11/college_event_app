import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_event.dart';
import 'login.dart';
import 'registered_students.dart'; // ✅ lowercase, must match filename

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  Future<void> deleteEvent(String eventId) async {
    try {
      await FirebaseFirestore.instance
          .collection("events")
          .doc(eventId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Event deleted successfully")));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Failed to delete event: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
   return Scaffold(
  backgroundColor: Colors.grey[100],

  appBar: AppBar(
    title: const Text("Eventify Admin"),
    elevation: 0,
    flexibleSpace: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue, Colors.blueAccent],
        ),
      ),
    ),
    actions: [
      IconButton(
        icon: const Icon(Icons.logout),
        onPressed: () async {
          await FirebaseAuth.instance.signOut();
          if (!mounted) return;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
            (route) => false,
          );
        },
      ),
    ],
  ),

  floatingActionButton: FloatingActionButton.extended(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AddEvent()),
      );
    },
    backgroundColor: Colors.blueAccent,
    icon: const Icon(Icons.add),
    label: const Text("Add Event"),
  ),

  body: StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance.collection("events").snapshots(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }

      final events = snapshot.data!.docs;

      if (events.isEmpty) {
        return const Center(child: Text("No events yet"));
      }

      return ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        itemCount: events.length,
        itemBuilder: (context, index) {
          var event = events[index];

          final data = event.data() as Map<String, dynamic>;
          final category =
              data.containsKey("category") ? data["category"] : "";

          return Card(
            elevation: 6,
            shadowColor: Colors.black26,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: const EdgeInsets.symmetric(vertical: 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔥 IMAGE + CATEGORY
                  Stack(
                    children: [
                      if (data["image"] != "")
                        Image.memory(
                          base64Decode(data["image"]),
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),

                      if (category != "")
                        Positioned(
                          top: 10,
                          left: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.blueAccent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              category,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),

                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data["title"],
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          data["description"],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 12),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // 👥 View Students
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => RegisteredStudentsPage(
                                      eventId: event.id,
                                      eventTitle: data["title"],
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.people),
                              label: const Text("Students"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),

                            // 🗑 Delete
                            IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.red),
                              onPressed: () => deleteEvent(event.id),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  ),
);
  }
}
