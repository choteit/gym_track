import 'package:cloud_firestore/cloud_firestore.dart';
import '../entities/workout_plan.dart';

class WorkoutPlanService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String collectionName = 'workout_plans';

  Future<String> createWorkoutPlan(WorkoutPlan workoutPlan) async {
    final docRef = await _firestore.collection(collectionName).add(workoutPlan.toMap());
    return docRef.id;
  }

  Stream<QuerySnapshot> getUserWorkoutPlans(String userId) {
    return _firestore
        .collection(collectionName)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Stream<DocumentSnapshot> getWorkoutPlanById(String planId) {
    return _firestore.collection(collectionName).doc(planId).snapshots();
  }

  Future<void> updateWorkoutPlan(String planId, WorkoutPlan workoutPlan) async {
    await _firestore.collection(collectionName).doc(planId).update(workoutPlan.toMap());
  }

  Future<void> deleteWorkoutPlan(String planId) async {
    await _firestore.collection(collectionName).doc(planId).delete();
  }

  Future<WorkoutPlan?> getWorkoutPlanOnce(String planId) async {
    final doc = await _firestore.collection(collectionName).doc(planId).get();
    if (doc.exists) {
      return WorkoutPlan.fromMap(doc.id, doc.data() as Map<String, dynamic>);
    }
    return null;
  }
}