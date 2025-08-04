import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart' as firebase_ui_auth;
import '../../main_navigation.dart';
import 'user_service.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData) {
          // Utilise le widget de connexion de firebase_ui_auth
          return firebase_ui_auth.SignInScreen(
            providers: [firebase_ui_auth.EmailAuthProvider()],
          );
        }

        // Utilisateur connecté, vérifier/créer dans Firestore
        return FutureBuilder<void>(
          future: UserService().ensureUserExists(snapshot.data!),
          builder: (context, futureSnapshot) {
            if (futureSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Loading up your account...'),
                    ],
                  ),
                ),
              );
            }

            if (futureSnapshot.hasError) {
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      const Text('Error setting up account'),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          // Force rebuild to retry
                          (context as Element).markNeedsBuild();
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Tout est bon, afficher MainNavigation
            return const MainNavigation();
          },
        );
      },
    );
  }
}
