import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart' as firebase_ui_auth;
import '../../main_navigation.dart';

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
        // Utilisateur connecté, affiche MainNavigation
        return const MainNavigation();
      },
    );
  }
}
