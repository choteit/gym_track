import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class ExercisesDirectory extends StatefulWidget {
  const ExercisesDirectory({super.key});

  @override
  State<ExercisesDirectory> createState() => _ExercisesDirectoryState();
}

class _ExercisesDirectoryState extends State<ExercisesDirectory> {
  List<Map<String, dynamic>> _exercises = [];

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    final String data =
        await rootBundle.loadString('lib/assets/exercises.json');
    setState(() {
      _exercises = List<Map<String, dynamic>>.from(json.decode(data));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercises'),
      ),
      body: ListView.builder(
        itemCount: _exercises.length,
        itemBuilder: (context, index) {
          final exercise = _exercises[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(
                exercise['name'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Category: ${exercise['category']} • Type: ${exercise['unitType'] == 'reps_weight' ? 'Weight training' : 'Cardio'}',
              ),
            ),
          );
        },
      ),
    );
  }
}
