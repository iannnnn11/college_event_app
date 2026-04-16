import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login.dart';
import 'join_event.dart';
import 'event_detail_page.dart'; // ✅ NEW IMPORT

class StudentHome extends StatefulWidget {
  const StudentHome({super.key});

  @override
  State<StudentHome> createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  String selectedCategory = "All";

  final List<String> categories = [
    "All",
    "Hackathon",
    "Coding Challenge",
    "Talks and Other",
    "Inter-College Events"
  ];

  Future<void> likeEvent(String eventId, int currentLikes) async {
    try {
      await FirebaseFirestore.instance
          .collection("events")
          .doc(eventId)
          .update({"likes": currentLikes + 1});
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Failed to like event: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Eventify"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),

          // CATEGORY FILTER
          SizedBox(
            height: 45,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = selectedCategory == category;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory = category;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue : Colors.white,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      category,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          // EVENTS LIST
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection("events").snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allEvents = snapshot.data!.docs;

                final events = selectedCategory == "All"
                    ? allEvents
                    : allEvents
                        .where((e) =>
                            (e.data() as Map<String, dynamic>)
                                .containsKey("category") &&
                            e["category"] == selectedCategory)
                        .toList();

                if (events.isEmpty) {
                  return const Center(child: Text("No events found"));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(15),
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    var event = events[index];
                    final data = event.data() as Map<String, dynamic>;

                    final category =
                        data.containsKey("category") ? data["category"] : "";

                    final isPaid =
                        data.containsKey("isPaid") ? data["isPaid"] : false;

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EventDetailPage(
                              data: data,
                              eventId: event.id,
                            ),
                          ),
                        );
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                if (event["image"] != "")
                                  Image.memory(
                                    base64Decode(event["image"]),
                                    height: 200,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),

                                // CATEGORY
                                Positioned(
                                  top: 10,
                                  left: 10,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    color: Colors.blue,
                                    child: Text(category,
                                        style: const TextStyle(
                                            color: Colors.white)),
                                  ),
                                ),

                                // PAID / FREE
                                Positioned(
                                  top: 10,
                                  right: 10,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    color: isPaid ? Colors.red : Colors.green,
                                    child: Text(
                                      isPaid ? "PAID" : "FREE",
                                      style:
                                          const TextStyle(color: Colors.white),
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
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    data["description"],
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.favorite,
                                                color: Colors.red),
                                            onPressed: () => likeEvent(
                                                event.id, event["likes"]),
                                          ),
                                          Text("${event["likes"]}"),
                                        ],
                                      ),
                                      const Text("Tap to view ➜"),
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
          ),
        ],
      ),
    );
  }
}
