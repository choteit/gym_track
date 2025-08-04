import 'package:flutter/material.dart';
import '../services/session_service.dart';
import 'session_detail_page.dart';
import '../../workout_plans/services/workout_plan_service.dart';
import '../../workout_plans/entities/workout_plan.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateSessionDialog extends StatefulWidget {
  final String userId;
  final SessionService sessionService;

  const CreateSessionDialog({
    required this.userId,
    required this.sessionService,
    super.key,
  });

  @override
  State<CreateSessionDialog> createState() => _CreateSessionDialogState();
}

class _CreateSessionDialogState extends State<CreateSessionDialog> {
  DateTime selectedDate = DateTime.now();
  String workoutMode = 'as_you_go'; // 'as_you_go' or 'follow_plan'
  WorkoutPlan? selectedPlan;
  final WorkoutPlanService _workoutPlanService = WorkoutPlanService();
  List<WorkoutPlan> availablePlans = [];

  @override
  void initState() {
    super.initState();
    _loadUserPlans();
  }

  Future<void> _loadUserPlans() async {
    try {
      final snapshot = await _workoutPlanService.getUserWorkoutPlans(widget.userId).first;
      setState(() {
        availablePlans = snapshot.docs
            .map((doc) => WorkoutPlan.fromMap(doc.id, doc.data() as Map<String, dynamic>))
            .toList();
      });
    } catch (e) {
      // Handle error silently or show message
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 600), // Hauteur fixe
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Create new session',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text('Select session date:'),
              Flexible(
                // Wrap in Flexible
                child: CalendarDatePicker(
                  initialDate: selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                  onDateChanged: (DateTime value) {
                    setState(() {
                      selectedDate = value;
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),
              const Text('Workout type:'),
              const SizedBox(height: 8),
              Column(
                children: [
                  RadioListTile<String>(
                    title: const Text('Train as you go'),
                    subtitle: const Text('Add exercises as you perform them'),
                    value: 'as_you_go',
                    groupValue: workoutMode,
                    onChanged: (value) {
                      setState(() {
                        workoutMode = value!;
                        selectedPlan = null;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Follow a workout plan'),
                    subtitle: Text(availablePlans.isEmpty 
                        ? 'No plans available' 
                        : 'Choose from your saved plans'),
                    value: 'follow_plan',
                    groupValue: workoutMode,
                    onChanged: availablePlans.isNotEmpty ? (value) {
                      setState(() {
                        workoutMode = value!;
                      });
                    } : null,
                  ),
                ],
              ),
              if (workoutMode == 'follow_plan' && availablePlans.isNotEmpty) ...[
                const SizedBox(height: 12),
                DropdownButtonFormField<WorkoutPlan>(
                  decoration: const InputDecoration(
                    labelText: 'Select Plan',
                    border: OutlineInputBorder(),
                  ),
                  value: selectedPlan,
                  items: availablePlans.map((plan) {
                    return DropdownMenuItem(
                      value: plan,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plan.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${plan.exercises.length} exercises',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (plan) {
                    setState(() {
                      selectedPlan = plan;
                    });
                  },
                ),
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
                    onPressed: _canCreateSession() ? () => _createSession(context) : null,
                    child: const Text('Create'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _canCreateSession() {
    if (workoutMode == 'as_you_go') return true;
    if (workoutMode == 'follow_plan') return selectedPlan != null;
    return false;
  }

  Future<void> _createSession(BuildContext context) async {
    final sessionId = await widget.sessionService.createSession(
      widget.userId,
      selectedDate,
      workoutPlanId: selectedPlan?.id,
    );

    if (!mounted) return;

    Navigator.pop(context); // Ferme la popin

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SessionDetailPage(
          sessionId: sessionId,
          sessionService: widget.sessionService,
        ),
      ),
    );
  }
}
