import 'package:flutter/material.dart';
import 'sessions/services/session_service.dart';
import 'users/services/auth_service.dart';
import 'sessions/widgets/session_list.dart';
import 'sessions/widgets/create_session_dialog.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _showCreateSessionDialog(
    BuildContext context,
    String userId,
    SessionService sessionService,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) => CreateSessionDialog(
        userId: userId,
        sessionService: sessionService,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final sessionService = SessionService();
    final user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.fitness_center,
              color: Theme.of(context).colorScheme.primary,
              size: 30,
            ),
            const SizedBox(width: 8),
            Text(
              'GymTrack',
              style: Theme.of(context).textTheme.displayMedium,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.signOut();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add_circle_outline, size: 24),
              label: const Text('Start New Workout'),
              onPressed: user != null
                  ? () => _showCreateSessionDialog(
                      context, user.uid, sessionService)
                  : null,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Icon(
                  Icons.history,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Your Workouts',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: user == null
                ? const Center(child: Text('Non authenticated'))
                : SessionList(
                    userId: user.uid,
                    sessionService: sessionService,
                  ),
          ),
        ],
      ),
    );
  }
}
