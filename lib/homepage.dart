import 'package:flutter/material.dart';
import 'sessions/widgets/create_session_form.dart';
import 'sessions/services/session_service.dart';
import 'users/services/auth_service.dart';
import 'sessions/widgets/session_list.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final sessionService = SessionService();
    final user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('GymTrack'),
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
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('New session'),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SessionFormPage(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(200, 48),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Your sessions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
