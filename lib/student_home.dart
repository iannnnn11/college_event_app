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
        title: const Text("College Events"),
        backgroundColor: Colors.blue,
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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("events").snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final events = snapshot.data!.docs;
          if (events.isEmpty) return const Center(child: Text("No events yet"));

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            itemCount: events.length,
            itemBuilder: (context, index) {
              var event = events[index];

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
                    color: joined ? Colors.green[50] : Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Event Image
                          if (event["image"] != "")
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.memory(
                                base64Decode(event["image"]),
                                height: 220,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          const SizedBox(height: 10),
                          Text(event["title"],
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 5),
                          Text(event["description"]),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.thumb_up,
                                    color: Colors.blue),
                                onPressed: () =>
                                    likeEvent(event.id, event["likes"]),
                              ),
                              Text("${event["likes"]} Likes"),
                              const SizedBox(width: 15),
                              ElevatedButton(
                                onPressed: joined
                                    ? null
                                    : () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) => JoinEventPage(
                                                  eventId: event.id)),
                                        );
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      joined ? Colors.grey : Colors.green,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                                child: Text(joined ? "Joined ✅" : "Join"),
                              ),
                              const SizedBox(width: 10),
                              Text("${joinedUsers.length} Joined"),
                            ],
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
    );
  }
}
