import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Obtenir l'utilisateur courant
  User? get currentUser => _auth.currentUser;

  // Stream pour suivre l'état de l'authentification
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Déconnexion
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
