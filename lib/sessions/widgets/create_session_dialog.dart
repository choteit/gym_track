import 'package:flutter/material.dart';
import '../services/session_service.dart';
import 'session_detail_page.dart';

class CreateSessionDialog extends StatefulWidget {
  final String userId;
  final SessionService sessionService;

  const CreateSessionDialog({
    required this.userId,
    required this.sessionService,
    super.key,
  });

  @override
  State<CreateSessionDialog> createState() => _CreateSessionDialogState();
}

class _CreateSessionDialogState extends State<CreateSessionDialog> {
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 500), // Hauteur fixe
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Create new session',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text('Select session date:'),
              Flexible(
                // Wrap in Flexible
                child: CalendarDatePicker(
                  initialDate: selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                  onDateChanged: (DateTime value) {
                    setState(() {
                      selectedDate = value;
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _createSession(context),
                    child: const Text('Create'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createSession(BuildContext context) async {
    final sessionId = await widget.sessionService.createSession(
      widget.userId,
      selectedDate,
    );

    if (!mounted) return;

    Navigator.pop(context); // Ferme la popin

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SessionDetailPage(
          sessionId: sessionId,
          sessionService: widget.sessionService,
        ),
      ),
    );
  }
}
