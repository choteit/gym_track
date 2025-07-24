import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class AddExerciseDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onExerciseAdded;

  const AddExerciseDialog({
    required this.onExerciseAdded,
    super.key,
  });

  @override
  State<AddExerciseDialog> createState() => _AddExerciseDialogState();
}

class _AddExerciseDialogState extends State<AddExerciseDialog> {
  List<Map<String, dynamic>> _exercises = [];
  Map<String, dynamic>? _selectedExercise;
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs pour les champs de saisie
  final _repsController = TextEditingController();
  final _weightController = TextEditingController();
  final _distanceController = TextEditingController();
  final _timeController = TextEditingController();

  // Ajouter un nouveau contrôleur pour les sets
  final _setsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  @override
  void dispose() {
    _repsController.dispose();
    _weightController.dispose();
    _distanceController.dispose();
    _timeController.dispose();
    _setsController.dispose();
    super.dispose();
  }

  Future<void> _loadExercises() async {
    final String data =
        await rootBundle.loadString('lib/assets/exercises.json');
    setState(() {
      _exercises = List<Map<String, dynamic>>.from(json.decode(data));
    });
  }

  void _submitForm() {
    if (_formKey.currentState!.validate() && _selectedExercise != null) {
      final exercise = Map<String, dynamic>.from(_selectedExercise!);

      if (exercise['unitType'] == 'reps_weight') {
        exercise['sets'] = int.parse(_setsController.text);
        exercise['reps'] = int.parse(_repsController.text);
        exercise['weight'] = double.parse(_weightController.text);
      } else {
        exercise['distance'] = double.parse(_distanceController.text);
        exercise['time'] = int.parse(_timeController.text);
      }

      widget.onExerciseAdded(exercise);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Add exercise',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Map<String, dynamic>>(
                value: _selectedExercise,
                items: _exercises.map((exercise) {
                  final name = exercise['name'] as String;
                  return DropdownMenuItem(
                    value: exercise,
                    child: Text(name[0].toUpperCase() + name.substring(1)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedExercise = value;
                    // Reset des contrôleurs
                    _repsController.clear();
                    _weightController.clear();
                    _distanceController.clear();
                    _timeController.clear();
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Select exercise',
                ),
                validator: (value) =>
                    value == null ? 'Please select an exercise' : null,
              ),
              const SizedBox(height: 16),
              if (_selectedExercise != null) ...[
                if (_selectedExercise!['unitType'] == 'reps_weight') ...[
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _setsController,
                          decoration: const InputDecoration(
                            labelText: 'Sets',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) => value?.isEmpty ?? true
                              ? 'Enter number of sets'
                              : null,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          'x',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: _repsController,
                          decoration: const InputDecoration(
                            labelText: 'Reps',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) => value?.isEmpty ?? true
                              ? 'Enter number of reps'
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _weightController,
                    decoration: const InputDecoration(
                      labelText: 'Weight (kg)',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Enter weight' : null,
                  ),
                ] else ...[
                  TextFormField(
                    controller: _distanceController,
                    decoration: const InputDecoration(
                      labelText: 'Distance (km)',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Enter distance' : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _timeController,
                    decoration: const InputDecoration(
                      labelText: 'Time (minutes)',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Enter time' : null,
                  ),
                ],
              ],
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: const Text('Add'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
