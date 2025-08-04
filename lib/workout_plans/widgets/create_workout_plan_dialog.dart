import 'package:flutter/material.dart';
import '../services/workout_plan_service.dart';
import '../entities/workout_plan.dart';
import '../../exercises/services/exercise_service.dart';

class CreateWorkoutPlanDialog extends StatefulWidget {
  final String userId;
  final WorkoutPlanService workoutPlanService;

  const CreateWorkoutPlanDialog({
    required this.userId,
    required this.workoutPlanService,
    super.key,
  });

  @override
  State<CreateWorkoutPlanDialog> createState() => _CreateWorkoutPlanDialogState();
}

class _CreateWorkoutPlanDialogState extends State<CreateWorkoutPlanDialog> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final List<PlannedExercise> _plannedExercises = [];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _addExerciseToplan() async {
    final exerciseService = ExerciseService();
    final exercises = await exerciseService.getAllExercises(widget.userId);

    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) => AddPlannedExerciseDialog(
        exercises: exercises,
        onExerciseAdded: (plannedExercise) {
          setState(() {
            _plannedExercises.add(plannedExercise);
          });
        },
      ),
    );
  }

  Future<void> _createPlan() async {
    if (!_formKey.currentState!.validate()) return;

    final plan = WorkoutPlan(
      id: '', // Will be set by Firestore
      userId: widget.userId,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty 
          ? null 
          : _descriptionController.text.trim(),
      createdAt: DateTime.now(),
      exercises: _plannedExercises,
    );

    try {
      await widget.workoutPlanService.createWorkoutPlan(plan);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Workout plan created successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating plan: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxHeight: 600, maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create Workout Plan',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Plan Name',
                      hintText: 'e.g., Upper Body Strength',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a plan name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description (optional)',
                      hintText: 'Brief description of the plan',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Exercises (${_plannedExercises.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: _addExerciseToplan,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Exercise'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Flexible(
              child: _plannedExercises.isEmpty
                  ? const Center(
                      child: Text(
                        'No exercises added yet.\nTap "Add Exercise" to get started.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: _plannedExercises.length,
                      itemBuilder: (context, index) {
                        final exercise = _plannedExercises[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(exercise.name),
                            subtitle: Text(_getExerciseTargetText(exercise)),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                setState(() {
                                  _plannedExercises.removeAt(index);
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _plannedExercises.isNotEmpty ? _createPlan : null,
                  child: const Text('Create Plan'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getExerciseTargetText(PlannedExercise exercise) {
    if (exercise.unitType == 'reps_weight') {
      final setsText = exercise.targetSets != null ? '${exercise.targetSets} sets' : '';
      final repsText = exercise.targetReps != null ? '${exercise.targetReps} reps' : '';
      final weightText = exercise.targetWeight != null ? '${exercise.targetWeight}kg' : '';
      
      return [setsText, repsText, weightText].where((s) => s.isNotEmpty).join(' × ');
    } else {
      final timeText = exercise.targetTime != null 
          ? '${(exercise.targetTime! / 60).toStringAsFixed(0)}min' 
          : '';
      final distanceText = exercise.targetDistance != null 
          ? '${exercise.targetDistance}km' 
          : '';
      
      return [timeText, distanceText].where((s) => s.isNotEmpty).join(' × ');
    }
  }
}

class AddPlannedExerciseDialog extends StatefulWidget {
  final List<Map<String, dynamic>> exercises;
  final Function(PlannedExercise) onExerciseAdded;

  const AddPlannedExerciseDialog({
    required this.exercises,
    required this.onExerciseAdded,
    super.key,
  });

  @override
  State<AddPlannedExerciseDialog> createState() => _AddPlannedExerciseDialogState();
}

class _AddPlannedExerciseDialogState extends State<AddPlannedExerciseDialog> {
  Map<String, dynamic>? selectedExercise;
  final _setsController = TextEditingController();
  final _repsController = TextEditingController();
  final _weightController = TextEditingController();
  final _timeController = TextEditingController();
  final _distanceController = TextEditingController();

  @override
  void dispose() {
    _setsController.dispose();
    _repsController.dispose();
    _weightController.dispose();
    _timeController.dispose();
    _distanceController.dispose();
    super.dispose();
  }

  bool get isRepsWeight => selectedExercise?['unitType'] == 'reps_weight';

  void _addExercise() {
    if (selectedExercise == null) return;

    final plannedExercise = PlannedExercise(
      name: selectedExercise!['name'],
      category: selectedExercise!['category'],
      unitType: selectedExercise!['unitType'],
      targetSets: isRepsWeight ? int.tryParse(_setsController.text) : null,
      targetReps: isRepsWeight ? int.tryParse(_repsController.text) : null,
      targetWeight: isRepsWeight ? double.tryParse(_weightController.text) : null,
      targetTime: !isRepsWeight ? int.tryParse(_timeController.text) : null,
      targetDistance: !isRepsWeight ? double.tryParse(_distanceController.text) : null,
    );

    widget.onExerciseAdded(plannedExercise);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxHeight: 500, maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Exercise to Plan',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Map<String, dynamic>>(
              decoration: const InputDecoration(
                labelText: 'Select Exercise',
                border: OutlineInputBorder(),
              ),
              value: selectedExercise,
              items: widget.exercises.map((exercise) {
                return DropdownMenuItem(
                  value: exercise,
                  child: Text(exercise['name']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedExercise = value;
                  // Clear all fields when exercise changes
                  _setsController.clear();
                  _repsController.clear();
                  _weightController.clear();
                  _timeController.clear();
                  _distanceController.clear();
                });
              },
            ),
            const SizedBox(height: 16),
            if (selectedExercise != null) ...[
              Text(
                'Target Values:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              if (isRepsWeight) ...[
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _setsController,
                        decoration: const InputDecoration(
                          labelText: 'Sets',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _repsController,
                        decoration: const InputDecoration(
                          labelText: 'Reps',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _weightController,
                  decoration: const InputDecoration(
                    labelText: 'Weight (kg)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _timeController,
                        decoration: const InputDecoration(
                          labelText: 'Time (minutes)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _distanceController,
                        decoration: const InputDecoration(
                          labelText: 'Distance (km)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
              ],
            ],
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: selectedExercise != null ? _addExercise : null,
                  child: const Text('Add'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}