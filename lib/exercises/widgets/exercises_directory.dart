import 'package:flutter/material.dart';
import '../services/exercise_service.dart';
import 'add_custom_exercise_dialog.dart';
import '../../users/services/auth_service.dart';

class ExercisesDirectory extends StatefulWidget {
  const ExercisesDirectory({super.key});

  @override
  State<ExercisesDirectory> createState() => _ExercisesDirectoryState();
}

class _ExercisesDirectoryState extends State<ExercisesDirectory> {
  final _exerciseService = ExerciseService();
  final _authService = AuthService();
  List<Map<String, dynamic>> _exercises = [];

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    final userId = _authService.currentUser?.uid;
    if (userId != null) {
      final exercises = await _exerciseService.getAllExercises(userId);
      setState(() {
        _exercises = exercises;
      });
    }
  }

  Future<void> _showAddExerciseDialog() async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) return;

    await showDialog<void>(
      context: context,
      builder: (context) => AddCustomExerciseDialog(
        onExerciseAdded: (exercise) async {
          await _exerciseService.addCustomExercise(userId, exercise);
          _loadExercises(); // Recharger la liste
        },
      ),
    );
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

          // On enveloppe le Card avec un Dismissible seulement si c'est un exercice personnalisé
          if (exercise['isCustom'] == true) {
            return Dismissible(
              key: Key(exercise['id']),
              direction: DismissDirection.endToStart,
              background: Container(
                color: Theme.of(context).colorScheme.error,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 16.0),
                child: Icon(
                  Icons.delete,
                  color: Theme.of(context).colorScheme.onError,
                ),
              ),
              confirmDismiss: (direction) async {
                return await showDialog<bool>(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: const Text('Supprimer l\'exercice'),
                        content: const Text(
                            'Êtes-vous sûr de vouloir supprimer cet exercice ?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Annuler'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text(
                              'Supprimer',
                              style: TextStyle(color: Theme.of(context).colorScheme.error),
                            ),
                          ),
                        ],
                      ),
                    ) ??
                    false;
              },
              onDismissed: (direction) async {
                final userId = _authService.currentUser?.uid;
                if (userId != null) {
                  await _exerciseService.deleteCustomExercise(
                    userId,
                    exercise['id'],
                  );
                  _loadExercises(); // Recharger la liste
                }
              },
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(
                    exercise['name'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Category: ${exercise['category']} • Type: ${exercise['unitType'] == 'reps_weight' ? 'Weight training' : 'Cardio'}',
                  ),
                  trailing: Icon(Icons.person, color: Theme.of(context).colorScheme.secondary),
                ),
              ),
            );
          }

          // Retourne un Card simple pour les exercices non personnalisés
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddExerciseDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
