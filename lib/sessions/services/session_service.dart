import 'package:cloud_firestore/cloud_firestore.dart';

class SessionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getUserSessions(String userId) {
    return _firestore
        .collection('sessions')
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots();
  }
}
