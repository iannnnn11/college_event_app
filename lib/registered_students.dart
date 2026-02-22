import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisteredStudentsPage extends StatelessWidget {
  final String eventId;
  final String eventTitle;

  const RegisteredStudentsPage({
    super.key,
    required this.eventId,
    required this.eventTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Registered Students - $eventTitle"),
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("events")
            .doc(eventId)
            .collection("joinedUsers")
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text("Error loading students:\n${snapshot.error}"),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final students = snapshot.data!.docs;
          if (students.isEmpty) {
            return const Center(child: Text("No students have registered yet"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index].data() as Map<String, dynamic>;
              final name = student["name"] ?? "N/A";
              final department = student["department"] ?? "N/A";
              final year = student["year"] ?? "N/A";
              final paymentScreenshot = student["paymentScreenshot"];
              final joinedAtTimestamp = student["joinedAt"] as Timestamp?;

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: paymentScreenshot != null
                      ? GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => Scaffold(
                                  appBar: AppBar(
                                    title: const Text("Payment Screenshot"),
                                    backgroundColor: Colors.blue,
                                  ),
                                  body: Center(
                                    child: Image.memory(
                                      base64Decode(paymentScreenshot),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.memory(
                              base64Decode(paymentScreenshot),
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      : const Icon(Icons.person),
                  title: Text(name),
                  subtitle: Text("$department, Year: $year"),
                  trailing: joinedAtTimestamp != null
                      ? Text(
                          joinedAtTimestamp
                              .toDate()
                              .toLocal()
                              .toString()
                              .substring(0, 16),
                          style: const TextStyle(fontSize: 12),
                        )
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
