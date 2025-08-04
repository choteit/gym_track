import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../users/services/auth_service.dart';
import '../services/workout_plan_service.dart';
import '../entities/workout_plan.dart';
import 'create_workout_plan_dialog.dart';
import 'workout_plan_detail_page.dart';

class WorkoutPlansPage extends StatelessWidget {
  const WorkoutPlansPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final workoutPlanService = WorkoutPlanService();
    final user = authService.currentUser;

    Future<void> showCreatePlanDialog() async {
      if (user != null) {
        await showDialog<void>(
          context: context,
          builder: (BuildContext context) => CreateWorkoutPlanDialog(
            userId: user.uid,
            workoutPlanService: workoutPlanService,
          ),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.assignment,
              color: Theme.of(context).colorScheme.primary,
              size: 30,
            ),
            const SizedBox(width: 8),
            Text(
              'Workout Plans',
              style: Theme.of(context).textTheme.displayMedium,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add_circle_outline, size: 24),
              label: const Text('Create New Plan'),
              onPressed: user != null ? showCreatePlanDialog : null,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Icon(
                  Icons.list_alt,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Your Plans',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: user == null
                ? const Center(child: Text('Not authenticated'))
                : StreamBuilder<QuerySnapshot>(
                    stream: workoutPlanService.getUserWorkoutPlans(user.uid),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text(
                            'No workout plans yet.\nCreate your first plan to get started!',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16),
                          ),
                        );
                      }

                      final plans = snapshot.data!.docs;

                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: plans.length,
                        itemBuilder: (context, index) {
                          final planData = plans[index].data() as Map<String, dynamic>;
                          final plan = WorkoutPlan.fromMap(plans[index].id, planData);

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                child: Icon(
                                  Icons.assignment,
                                  color: Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                              title: Text(
                                plan.name,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (plan.description != null && plan.description!.isNotEmpty)
                                    Text(plan.description!),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${plan.exercises.length} exercise${plan.exercises.length != 1 ? 's' : ''}',
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => WorkoutPlanDetailPage(
                                      planId: plan.id,
                                      workoutPlanService: workoutPlanService,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}