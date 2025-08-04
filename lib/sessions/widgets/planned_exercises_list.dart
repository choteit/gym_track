import 'package:flutter/material.dart';
import '../../workout_plans/entities/workout_plan.dart';

class PlannedExercisesList extends StatefulWidget {
  final List<PlannedExercise> plannedExercises;
  final List<Map<String, dynamic>> completedExercises;
  final Function(PlannedExercise, int) onExerciseCompleted;

  const PlannedExercisesList({
    required this.plannedExercises,
    required this.completedExercises,
    required this.onExerciseCompleted,
    super.key,
  });

  @override
  State<PlannedExercisesList> createState() => _PlannedExercisesListState();
}

class _PlannedExercisesListState extends State<PlannedExercisesList> {
  Set<int> _completedIndices = {};

  @override
  void initState() {
    super.initState();
    _updateCompletedIndices();
  }

  @override
  void didUpdateWidget(PlannedExercisesList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.completedExercises != widget.completedExercises) {
      _updateCompletedIndices();
    }
  }

  void _updateCompletedIndices() {
    _completedIndices.clear();
    for (int i = 0; i < widget.completedExercises.length; i++) {
      final completedExercise = widget.completedExercises[i];
      if (completedExercise['isPlanned'] == true) {
        final plannedIndex = completedExercise['plannedIndex'] as int?;
        if (plannedIndex != null && plannedIndex < widget.plannedExercises.length) {
          _completedIndices.add(plannedIndex);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.plannedExercises.isEmpty) {
      return const Center(
        child: Text(
          'No exercises in this plan',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.plannedExercises.length,
      itemBuilder: (context, index) {
        final exercise = widget.plannedExercises[index];
        final isCompleted = _completedIndices.contains(index);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Checkbox(
                  value: isCompleted,
                  onChanged: (value) {
                    if (value == true && !isCompleted) {
                      widget.onExerciseCompleted(exercise, index);
                    }
                  },
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              exercise.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    decoration: isCompleted 
                                        ? TextDecoration.lineThrough 
                                        : null,
                                    color: isCompleted 
                                        ? Colors.grey 
                                        : null,
                                  ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: exercise.category == 'cardio'
                                  ? Colors.orange.withOpacity(0.1)
                                  : Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              exercise.category,
                              style: TextStyle(
                                color: exercise.category == 'cardio'
                                    ? Colors.orange[700]
                                    : Colors.blue[700],
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (exercise.unitType == 'reps_weight') ...[
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            if (exercise.targetSets != null)
                              _buildTargetChip('${exercise.targetSets} sets', isCompleted),
                            if (exercise.targetReps != null)
                              _buildTargetChip('${exercise.targetReps} reps', isCompleted),
                            if (exercise.targetWeight != null)
                              _buildTargetChip('${exercise.targetWeight}kg', isCompleted),
                          ],
                        ),
                      ] else ...[
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            if (exercise.targetTime != null)
                              _buildTargetChip(
                                  '${(exercise.targetTime! / 60).toStringAsFixed(0)}min', 
                                  isCompleted),
                            if (exercise.targetDistance != null)
                              _buildTargetChip('${exercise.targetDistance}km', isCompleted),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTargetChip(String text, bool isCompleted) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isCompleted 
            ? Colors.grey.withOpacity(0.1)
            : Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isCompleted 
              ? Colors.grey
              : Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}