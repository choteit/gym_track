import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/workout_plan_service.dart';
import '../entities/workout_plan.dart';

class WorkoutPlanDetailPage extends StatefulWidget {
  final String planId;
  final WorkoutPlanService workoutPlanService;

  const WorkoutPlanDetailPage({
    required this.planId,
    required this.workoutPlanService,
    super.key,
  });

  @override
  State<WorkoutPlanDetailPage> createState() => _WorkoutPlanDetailPageState();
}

class _WorkoutPlanDetailPageState extends State<WorkoutPlanDetailPage> {
  late Stream<DocumentSnapshot> _planStream;

  @override
  void initState() {
    super.initState();
    _planStream = widget.workoutPlanService.getWorkoutPlanById(widget.planId);
  }

  Future<void> _deletePlan() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Delete Plan'),
        content: const Text('Are you sure you want to delete this workout plan?'),
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
      await widget.workoutPlanService.deleteWorkoutPlan(widget.planId);
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream: _planStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Plan not found'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final plan = WorkoutPlan.fromMap(widget.planId, data);

          return Scaffold(
            appBar: AppBar(
              title: Text(plan.name),
              actions: [
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    switch (value) {
                      case 'delete':
                        _deletePlan();
                        break;
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete,
                              color: Theme.of(context).colorScheme.error),
                          const SizedBox(width: 8),
                          Text(
                            'Delete plan',
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
                  if (plan.description != null && plan.description!.isNotEmpty) ...[
                    Text(
                      'Description',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      plan.description!,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 24),
                  ],
                  Text(
                    'Exercises (${plan.exercises.length})',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: plan.exercises.isEmpty
                        ? const Center(
                            child: Text(
                              'No exercises in this plan',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: plan.exercises.length,
                            itemBuilder: (context, index) {
                              final exercise = plan.exercises[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
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
                                      const SizedBox(height: 12),
                                      if (exercise.unitType == 'reps_weight') ...[
                                        Row(
                                          children: [
                                            if (exercise.targetSets != null) ...[
                                              _buildTargetChip(
                                                  '${exercise.targetSets} sets'),
                                              const SizedBox(width: 8),
                                            ],
                                            if (exercise.targetReps != null) ...[
                                              _buildTargetChip(
                                                  '${exercise.targetReps} reps'),
                                              const SizedBox(width: 8),
                                            ],
                                            if (exercise.targetWeight != null)
                                              _buildTargetChip(
                                                  '${exercise.targetWeight}kg'),
                                          ],
                                        ),
                                      ] else ...[
                                        Row(
                                          children: [
                                            if (exercise.targetTime != null) ...[
                                              _buildTargetChip(
                                                  '${(exercise.targetTime! / 60).toStringAsFixed(0)}min'),
                                              const SizedBox(width: 8),
                                            ],
                                            if (exercise.targetDistance != null)
                                              _buildTargetChip(
                                                  '${exercise.targetDistance}km'),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTargetChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}