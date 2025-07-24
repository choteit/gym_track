import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../services/session_service.dart';
import '../../exercises/widgets/add_exercise_dialog.dart';
import '../../exercises/widgets/exercises_list.dart';

class SessionDetailPage extends StatefulWidget {
  final String sessionId;
  final SessionService sessionService;

  const SessionDetailPage({
    required this.sessionId,
    required this.sessionService,
    super.key,
  });

  @override
  State<SessionDetailPage> createState() => _SessionDetailPageState();
}

class _SessionDetailPageState extends State<SessionDetailPage> {
  late Stream<DocumentSnapshot> _sessionStream;
  final dateFormat = DateFormat('MMMM d, y');

  @override
  void initState() {
    super.initState();
    _sessionStream = widget.sessionService.getSessionById(widget.sessionId);
  }

  Future<void> _addExerciseDialog() async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) => AddExerciseDialog(
        onExerciseAdded: (exercise) async {
          await widget.sessionService.addExerciseToSession(
            widget.sessionId,
            exercise,
          );
        },
      ),
    );
  }

  Future<void> _deleteSession() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Delete session'),
        content: const Text('Are you sure you want to delete this session?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await widget.sessionService.deleteSession(widget.sessionId);
      if (mounted) {
        Navigator.pop(context); // Retour à la page d'accueil
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream: _sessionStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Session not found'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final date = (data['date'] as Timestamp).toDate();
          final exercises =
              List<Map<String, dynamic>>.from(data['exercises'] ?? []);

          return Scaffold(
            appBar: AppBar(
              title: Text('Session of ${dateFormat.format(date)}'),
              actions: [
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    if (value == 'delete') {
                      _deleteSession();
                    }
                  },
                  position: PopupMenuPosition.under,
                  offset: const Offset(0, 0),
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text(
                            'Delete session',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Exercises',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Add exercise'),
                        onPressed: _addExerciseDialog,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ExercisesList(exercises: exercises),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
