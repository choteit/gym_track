import 'package:cloud_firestore/cloud_firestore.dart';

class SessionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String collectionName = 'sessions';

  Future<String> createSession(String userId, DateTime date) async {
    final docRef = await _firestore.collection('sessions').add({
      'userId': userId,
      'date': date,
      'exercises': [],
    });
    return docRef.id;
  }

  Stream<QuerySnapshot> getUserSessions(String userId) {
    return _firestore
        .collection('sessions')
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots();
  }

  Stream<DocumentSnapshot> getSessionById(String sessionId) {
    return _firestore.collection(collectionName).doc(sessionId).snapshots();
  }

  Future<void> addExerciseToSession(
      String sessionId, Map<String, dynamic> exercise) async {
    final sessionRef = _firestore.collection(collectionName).doc(sessionId);
    return _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(sessionRef);
      final exercises =
          List<Map<String, dynamic>>.from(snapshot.get('exercises') ?? []);
      exercises.add(exercise);

      transaction.update(sessionRef, {'exercises': exercises});
    });
  }

  Future<void> deleteSession(String sessionId) async {
    await _firestore.collection('sessions').doc(sessionId).delete();
  }

  Future<void> updateSessionDate(String sessionId, DateTime newDate) async {
    await _firestore.collection('sessions').doc(sessionId).update({
      'date': newDate,
    });
  }

  Future<void> removeExerciseFromSession(
      String sessionId, int exerciseIndex) async {
    final sessionRef = _firestore.collection('sessions').doc(sessionId);

    return _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(sessionRef);
      final exercises =
          List<Map<String, dynamic>>.from(snapshot.get('exercises') ?? []);

      exercises.removeAt(exerciseIndex);

      transaction.update(sessionRef, {'exercises': exercises});
    });
  }
}
