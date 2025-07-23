import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/session_service.dart';

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
    return StreamBuilder<QuerySnapshot>(
      stream: sessionService.getUserSessions(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'No session yet.',
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
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title:
                    Text('Session of ${date.day}/${date.month}/${date.year}'),
                subtitle: Text('ID: ${session.id}'),
              ),
            );
          },
        );
      },
    );
  }
}
