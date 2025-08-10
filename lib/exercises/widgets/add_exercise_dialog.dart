import 'package:flutter/material.dart';
import 'exercise_selector.dart';
import '../../utils/number_helper.dart';

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
  Map<String, dynamic>? _selectedExercise;
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs pour les champs de saisie
  final _repsController = TextEditingController();
  final _weightController = TextEditingController();
  final _distanceController = TextEditingController();
  final _timeController = TextEditingController();
  final _setsController = TextEditingController();

  @override
  void dispose() {
    _repsController.dispose();
    _weightController.dispose();
    _distanceController.dispose();
    _timeController.dispose();
    _setsController.dispose();
    super.dispose();
  }

  void _onExerciseSelected(Map<String, dynamic> exercise) {
    setState(() {
      _selectedExercise = exercise;
      // Reset des contrôleurs
      _repsController.clear();
      _weightController.clear();
      _distanceController.clear();
      _timeController.clear();
      _setsController.clear();
    });
  }

  void _submitForm() {
    if (_formKey.currentState!.validate() && _selectedExercise != null) {
      final exercise = Map<String, dynamic>.from(_selectedExercise!);

      if (exercise['unitType'] == 'reps_weight') {
        exercise['sets'] = int.parse(_setsController.text);
        exercise['reps'] = int.parse(_repsController.text);
        exercise['weight'] = NumberHelper.parseDouble(_weightController.text);
      } else {
        exercise['distance'] =
            NumberHelper.parseDouble(_distanceController.text);
        exercise['time'] = int.parse(_timeController.text);
      }

      widget.onExerciseAdded(exercise);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600, maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Add exercise',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            if (_selectedExercise == null) ...[
              Expanded(
                child: ExerciseSelector(
                  onExerciseSelected: _onExerciseSelected,
                  title: 'Select an exercise',
                  showCustomIndicator: true,
                ),
              ),
            ] else ...[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Afficher l'exercice sélectionné
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _selectedExercise!['name'][0].toUpperCase() +
                                      _selectedExercise!['name'].substring(1),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              if (_selectedExercise!['isCustom'] == true)
                                const Icon(Icons.person,
                                    color: Colors.blue, size: 16),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  setState(() {
                                    _selectedExercise = null;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Champs de saisie selon le type d'exercice
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                if (_selectedExercise!['unitType'] ==
                                    'reps_weight') ...[
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: _setsController,
                                          decoration: const InputDecoration(
                                            labelText: 'Sets',
                                          ),
                                          keyboardType: TextInputType.number,
                                          validator: (value) =>
                                              value?.isEmpty ?? true
                                                  ? 'Enter number of sets'
                                                  : null,
                                        ),
                                      ),
                                      const Padding(
                                        padding:
                                            EdgeInsets.symmetric(horizontal: 8),
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
                                          validator: (value) =>
                                              value?.isEmpty ?? true
                                                  ? 'Enter number of reps'
                                                  : null,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _weightController,
                                    decoration: const InputDecoration(
                                      labelText: 'Weight (kg)',
                                    ),
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    validator: (value) {
                                      if (value?.isEmpty ?? true)
                                        return 'Enter weight';
                                      if (!NumberHelper.isValidDouble(value!)) {
                                        return 'Enter a valid number';
                                      }
                                      return null;
                                    },
                                  ),
                                ] else ...[
                                  TextFormField(
                                    controller: _distanceController,
                                    decoration: const InputDecoration(
                                      labelText: 'Distance (km)',
                                    ),
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    validator: (value) {
                                      if (value?.isEmpty ?? true)
                                        return 'Enter distance';
                                      if (!NumberHelper.isValidDouble(value!)) {
                                        return 'Enter a valid number';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _timeController,
                                    decoration: const InputDecoration(
                                      labelText: 'Time (minutes)',
                                    ),
                                    keyboardType: TextInputType.number,
                                    validator: (value) => value?.isEmpty ?? true
                                        ? 'Enter time'
                                        : null,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            // Boutons d'action
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  if (_selectedExercise != null)
                    ElevatedButton(
                      onPressed: _submitForm,
                      child: const Text('Add'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
