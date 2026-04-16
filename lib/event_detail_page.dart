import 'dart:convert';
import 'package:flutter/material.dart';
import 'join_event.dart';

class EventDetailPage extends StatelessWidget {
  final Map<String, dynamic> data;
  final String eventId;

  const EventDetailPage({
    super.key,
    required this.data,
    required this.eventId,
  });

  @override
  Widget build(BuildContext context) {
    final isPaid = data.containsKey("isPaid") ? data["isPaid"] : false;

    return Scaffold(
      appBar: AppBar(
        title: Text(data["title"]),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            if (data["image"] != "")
              Image.memory(
                base64Decode(data["image"]),
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    data["title"],
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  // Paid / Free
                  Chip(
                    label: Text(isPaid ? "Paid Event" : "Free Event"),
                    backgroundColor:
                        isPaid ? Colors.red[100] : Colors.green[100],
                  ),

                  const SizedBox(height: 20),

                  // FULL DESCRIPTION
                  const Text(
                    "Description",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    data["description"],
                    style: const TextStyle(fontSize: 16),
                  ),

                  const SizedBox(height: 30),

                  // Join Button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => JoinEventPage(
                            eventId: eventId,
                            isPaid: isPaid,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text("Join Event"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
