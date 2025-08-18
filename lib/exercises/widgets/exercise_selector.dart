import 'package:flutter/material.dart';
import '../services/exercise_service.dart';
import '../../users/services/auth_service.dart';

class ExerciseSelector extends StatefulWidget {
  final Function(Map<String, dynamic>) onExerciseSelected;
  final String? title;
  final String? emptyMessage;
  final bool showCustomIndicator;

  const ExerciseSelector({
    required this.onExerciseSelected,
    this.title,
    this.emptyMessage,
    this.showCustomIndicator = true,
    super.key,
  });

  @override
  State<ExerciseSelector> createState() => _ExerciseSelectorState();
}

class _ExerciseSelectorState extends State<ExerciseSelector> {
  final _exerciseService = ExerciseService();
  final _authService = AuthService();
  List<Map<String, dynamic>> _exercises = [];
  bool _loading = true;

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
        _loading = false;
      });
    }
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return "${text[0].toUpperCase()}${text.substring(1).toLowerCase()}";
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title != null)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              widget.title!,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        if (_exercises.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text(
                widget.emptyMessage ?? 'No exercises available',
                style: const TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              itemCount: _exercises.length,
              itemBuilder: (context, index) {
                final exercise = _exercises[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ListTile(
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _capitalizeFirst(exercise['name']),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (widget.showCustomIndicator &&
                            exercise['isCustom'] == true)
                          const Icon(Icons.person,
                              color: Colors.blue, size: 16),
                      ],
                    ),
                    subtitle: Text(
                      'Category: ${exercise['category']} • Type: ${exercise['unitType'] == 'reps_weight' ? 'Weight training' : 'Cardio'}',
                    ),
                    trailing: const Icon(Icons.add_circle_outline),
                    onTap: () => widget.onExerciseSelected(exercise),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
