import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../entities/session.dart';

class SessionFormPage extends StatefulWidget {
  const SessionFormPage({super.key});

  @override
  State<SessionFormPage> createState() => _SessionFormPageState();
}

class _SessionFormPageState extends State<SessionFormPage> {
  late Session _session;
  bool _loading = true;
  List<Map<String, dynamic>> _availableExercises = [];
  final _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _initSession();
  }

  Future<void> _initSession() async {
    // Charger la liste des exercices
    final String data =
        await rootBundle.loadString('../../lib/assets/exercises.json');
    final List<dynamic> exercisesJson = json.decode(data);

    // Récupérer l'utilisateur connectéS
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Gérer le cas où l'utilisateur n'est pas connecté
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User is not logged in')),
        );
        Navigator.of(context).pop();
      }
      return;
    }

    // Créer la session en base
    final sessionDoc = await _firestore.collection('sessions').add({
      'userId': user.uid,
      'date': DateTime.now(),
      'exercises': [],
    });

    setState(() {
      _session = Session(
        id: sessionDoc.id,
        userId: user.uid,
        date: DateTime.now(),
        exercises: [],
      );
      _availableExercises = exercisesJson.cast<Map<String, dynamic>>();
      _loading = false;
    });
  }

  Future<void> _addExerciseDialog() async {
    String? selectedExerciseName;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Exercise'),
          content: DropdownButtonFormField<String>(
            isExpanded: true,
            items: _availableExercises
                .map((ex) => DropdownMenuItem<String>(
                      value: ex['name'],
                      child: Text(ex['name']),
                    ))
                .toList(),
            onChanged: (value) {
              selectedExerciseName = value;
            },
            decoration: const InputDecoration(
              labelText: 'Exercise',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedExerciseName != null) {
                  Navigator.of(context).pop(selectedExerciseName);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    ).then((selectedName) async {
      if (selectedName != null) {
        final exercise =
            _availableExercises.firstWhere((ex) => ex['name'] == selectedName);
        await _addExerciseToSession(exercise);
      }
    });
  }

  Future<void> _addExerciseToSession(Map<String, dynamic> exercise) async {
    // Ajoute l'exercice à la session en base
    final updatedExercises = List<Map<String, dynamic>>.from(_session.exercises)
      ..add(exercise);

    await _firestore.collection('sessions').doc(_session.id).update({
      'exercises': updatedExercises,
    });

    setState(() {
      _session = Session(
        id: _session.id,
        userId: _session.userId,
        date: _session.date,
        exercises: updatedExercises,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Workout Session'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              title: Text('Date: ${_session.date.toLocal()}'.split(' ')[0]),
              subtitle: Text('User: ${_session.userId}'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Exercises:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add an exercise'),
                  onPressed: _addExerciseDialog,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _session.exercises.isEmpty
                  ? const Center(child: Text('No exercises added yet.'))
                  : ListView.builder(
                      itemCount: _session.exercises.length,
                      itemBuilder: (context, index) {
                        final ex = _session.exercises[index];
                        return Card(
                          child: ListTile(
                            title: Text(ex['name']),
                            subtitle: Text(
                                'Category: ${ex['category']} - Type: ${ex['unitType']}'),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
