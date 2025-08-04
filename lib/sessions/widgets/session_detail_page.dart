import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../services/session_service.dart';
import '../../exercises/widgets/add_exercise_dialog.dart';
import '../../exercises/widgets/exercises_list.dart';
import '../../workout_plans/services/workout_plan_service.dart';
import '../../workout_plans/entities/workout_plan.dart';
import 'planned_exercises_list.dart';

class SessionDetailPage extends StatefulWidget {
  final String sessionId;
  final SessionService sessionService;

  const SessionDetailPage({
    required this.sessionId,
    required this.sessionService,
    super.key,
  });

  @override
  State<SessionDetailPage> createState() => _SessionDetailPageState();
}

class _SessionDetailPageState extends State<SessionDetailPage> {
  late Stream<DocumentSnapshot> _sessionStream;
  final dateFormat = DateFormat('MMMM d, y');
  final WorkoutPlanService _workoutPlanService = WorkoutPlanService();
  WorkoutPlan? _workoutPlan;

  @override
  void initState() {
    super.initState();
    _sessionStream = widget.sessionService.getSessionById(widget.sessionId);
  }

  Future<void> _loadWorkoutPlan(String planId) async {
    try {
      final plan = await _workoutPlanService.getWorkoutPlanOnce(planId);
      if (mounted) {
        setState(() {
          _workoutPlan = plan;
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _completeExercise(PlannedExercise exercise, int plannedIndex) async {
    final completedExercise = {
      'name': exercise.name,
      'category': exercise.category,
      'unitType': exercise.unitType,
      'isPlanned': true,
      'plannedIndex': plannedIndex,
      'sets': <Map<String, dynamic>>[],
      'targetSets': exercise.targetSets,
      'targetReps': exercise.targetReps,
      'targetWeight': exercise.targetWeight,
      'targetTime': exercise.targetTime,
      'targetDistance': exercise.targetDistance,
      'completedAt': DateTime.now(),
    };

    await widget.sessionService.addExerciseToSession(
      widget.sessionId,
      completedExercise,
    );
  }

  Future<void> _addExerciseDialog() async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) => AddExerciseDialog(
        onExerciseAdded: (exercise) async {
          await widget.sessionService.addExerciseToSession(
            widget.sessionId,
            exercise,
          );
        },
      ),
    );
  }

  Future<void> _deleteSession() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Delete session'),
        content: const Text('Are you sure you want to delete this session?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await widget.sessionService.deleteSession(widget.sessionId);
      if (mounted) {
        Navigator.pop(context); // Retour à la page d'accueil
      }
    }
  }

  Future<void> _editSessionDate() async {
    DateTime selectedDate = DateTime.now();

    final DateTime? pickedDate = await showDialog<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Edit session date',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 300,
                  child: CalendarDatePicker(
                    initialDate: selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                    onDateChanged: (DateTime value) {
                      selectedDate = value;
                    },
                  ),
                ),
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
                      onPressed: () => Navigator.pop(context, selectedDate),
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (pickedDate != null) {
      await widget.sessionService
          .updateSessionDate(widget.sessionId, pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream: _sessionStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Session not found'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final date = (data['date'] as Timestamp).toDate();
          final exercises =
              List<Map<String, dynamic>>.from(data['exercises'] ?? []);
          final workoutPlanId = data['workoutPlanId'] as String?;

          // Load workout plan if it exists and we haven't loaded it yet
          if (workoutPlanId != null && _workoutPlan == null) {
            _loadWorkoutPlan(workoutPlanId);
          }

          return Scaffold(
            appBar: AppBar(
              title: Text('Session of ${dateFormat.format(date)}'),
              actions: [
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        _editSessionDate();
                        break;
                      case 'delete':
                        _deleteSession();
                        break;
                    }
                  },
                  position: PopupMenuPosition.under,
                  offset: const Offset(0, 0),
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem<String>(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit,
                              color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 8),
                          const Text('Edit session'),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete,
                              color: Theme.of(context).colorScheme.error),
                          const SizedBox(width: 8),
                          Text(
                            'Delete session',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.error),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_workoutPlan != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.assignment,
                                color: Theme.of(context).colorScheme.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Following Plan: ${_workoutPlan!.name}',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          if (_workoutPlan!.description != null && _workoutPlan!.description!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              _workoutPlan!.description!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Planned Exercises',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    PlannedExercisesList(
                      plannedExercises: _workoutPlan!.exercises,
                      completedExercises: exercises,
                      onExerciseCompleted: _completeExercise,
                    ),
                    const SizedBox(height: 24),
                  ],
                  Row(
                    children: [
                      Text(
                        _workoutPlan != null ? 'Additional Exercises' : 'Exercises',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      if (_workoutPlan != null) ...[
                        const SizedBox(width: 8),
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ],
                    ],
                  ),
                  if (_workoutPlan != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Exercises added beyond your planned workout',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Expanded(
                    child: ExercisesList(
                      exercises: exercises.where((ex) => ex['isPlanned'] != true).toList(),
                      onExerciseDeleted: (index) async {
                        // Find the actual index in the full exercises list
                        final nonPlannedExercises = exercises.where((ex) => ex['isPlanned'] != true).toList();
                        final exerciseToDelete = nonPlannedExercises[index];
                        final actualIndex = exercises.indexOf(exerciseToDelete);
                        
                        await widget.sessionService.removeExerciseFromSession(
                          widget.sessionId,
                          actualIndex,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: _addExerciseDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add exercise'),
            ),
          );
        },
      ),
    );
  }
}
