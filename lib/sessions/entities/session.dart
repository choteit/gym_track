class Session {
  final String id;
  final String userId;
  final DateTime date;
  final List<dynamic> exercises; // Remplacer dynamic par Exercise plus tard
  final String? workoutPlanId; // Reference to workout plan if following one

  Session({
    required this.id,
    required this.userId,
    required this.date,
    required this.exercises,
    this.workoutPlanId,
  });
}