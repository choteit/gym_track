import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../services/session_service.dart';
import 'session_detail_page.dart';

class SessionList extends StatelessWidget {
  final String userId;
  final SessionService sessionService;

  const SessionList({
    required this.userId,
    required this.sessionService,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMMM d, y');

    return StreamBuilder<QuerySnapshot>(
      stream: sessionService.getUserSessions(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'No session yet',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        final sessions = snapshot.data!.docs;
        return ListView.builder(
          itemCount: sessions.length,
          itemBuilder: (context, index) {
            final session = sessions[index];
            final date = (session['date'] as Timestamp).toDate();
            final exercises =
                List<Map<String, dynamic>>.from(session['exercises'] ?? []);

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(dateFormat.format(date)),
                subtitle: exercises.isEmpty
                    ? const Text(
                        'No exercise',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      )
                    : Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: exercises.map((exercise) {
                          return Chip(
                            label: Text(
                              exercise['name'] as String,
                              style: const TextStyle(fontSize: 10),
                            ),
                            backgroundColor:
                                Theme.of(context).primaryColor.withOpacity(0.1),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          );
                        }).toList(),
                      ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SessionDetailPage(
                        sessionId: session.id,
                        sessionService: sessionService,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
