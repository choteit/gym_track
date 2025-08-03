import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class ExerciseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Récupère tous les exercices (par défaut + personnalisés)
  Future<List<Map<String, dynamic>>> getAllExercises(String userId) async {
    // Charger les exercices par défaut
    final defaultExercises = await _loadDefaultExercises();

    // Charger les exercices personnalisés
    final customExercises = await _firestore
        .collection('users')
        .doc(userId)
        .collection('exercises')
        .get();

    // Créer la liste avec les exercices personnalisés en premier
    return [
      // D'abord les exercices personnalisés
      ...customExercises.docs.map((doc) => {
            ...doc.data(),
            'id': doc.id,
            'isCustom': true,
          }),
      // Ensuite les exercices par défaut
      ...defaultExercises.map((exercise) => {
            ...exercise,
            'isCustom': false,
          }),
    ];
  }

  Future<void> addCustomExercise(
      String userId, Map<String, dynamic> exercise) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('exercises')
        .add(exercise);
  }

  Future<void> deleteCustomExercise(String userId, String exerciseId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('exercises')
        .doc(exerciseId)
        .delete();
  }

  Future<List<Map<String, dynamic>>> _loadDefaultExercises() async {
    final String data =
        await rootBundle.loadString('lib/assets/exercises.json');
    return List<Map<String, dynamic>>.from(json.decode(data));
  }
}
