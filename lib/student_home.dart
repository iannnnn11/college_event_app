import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login.dart';
import 'join_event.dart';

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
  // Like function
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
            (route) => false);
      },
    ),
  ],
),
      body: Column(
  children: [
    const SizedBox(height: 10),

    // 🔥 CATEGORY FILTER
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
                color: isSelected ? Colors.blueAccent : Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                  )
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                category,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    ),

    const SizedBox(height: 10),

    // 🔥 EVENTS LIST
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
    (e.data() as Map<String, dynamic>).containsKey("category") &&
    e["category"] == selectedCategory)
                  .toList();

          if (events.isEmpty) {
            return const Center(child: Text("No events found"));
          }

          return ListView.builder(
            padding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            itemCount: events.length,
            itemBuilder: (context, index) {
              var event = events[index];
              final data = event.data() as Map<String, dynamic>; // ✅ HERE

            final category =data.containsKey("category") ? data["category"] : "";

              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("events")
                    .doc(event.id)
                    .collection("joinedUsers")
                    .snapshots(),
                builder: (context, joinSnapshot) {
                  List joinedUsers = [];
                  bool joined = false;

                  if (joinSnapshot.hasData) {
                    joinedUsers = joinSnapshot.data!.docs;
                    joined = joinedUsers.any((u) => u.id == uid);
                  }

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
        // 🔥 IMAGE + CATEGORY BADGE
        Stack(
          children: [
            if (event["image"] != "")
              Image.memory(
                base64Decode(event["image"]),
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),

            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  category,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
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
                style: const TextStyle(color: Colors.black87),
              ),
              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 👍 Like
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.favorite,
                            color: Colors.redAccent),
                        onPressed: () =>
                            likeEvent(event.id, event["likes"]),
                      ),
                      Text("${event["likes"]}"),
                    ],
                  ),

                  // 🚀 Join Button
                  ElevatedButton(
                    onPressed: joined
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    JoinEventPage(eventId: event.id),
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          joined ? Colors.grey : Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                    ),
                    child: Text(joined ? "Joined ✅" : "Join Now"),
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
          );
        },
      ),
    ),
  ],
),
    );
  }
}
