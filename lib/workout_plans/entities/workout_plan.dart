class WorkoutPlan {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final DateTime createdAt;
  final List<PlannedExercise> exercises;

  WorkoutPlan({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.createdAt,
    required this.exercises,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'description': description,
      'createdAt': createdAt,
      'exercises': exercises.map((e) => e.toMap()).toList(),
    };
  }

  factory WorkoutPlan.fromMap(String id, Map<String, dynamic> data) {
    return WorkoutPlan(
      id: id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      description: data['description'],
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
      exercises: (data['exercises'] as List<dynamic>?)
              ?.map((e) => PlannedExercise.fromMap(e))
              .toList() ??
          [],
    );
  }
}

class PlannedExercise {
  final String name;
  final String category;
  final String unitType; // "reps_weight" or "time_distance"
  final int? targetSets;
  final int? targetReps;
  final double? targetWeight;
  final int? targetTime; // in seconds
  final double? targetDistance; // in km

  PlannedExercise({
    required this.name,
    required this.category,
    required this.unitType,
    this.targetSets,
    this.targetReps,
    this.targetWeight,
    this.targetTime,
    this.targetDistance,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'unitType': unitType,
      'targetSets': targetSets,
      'targetReps': targetReps,
      'targetWeight': targetWeight,
      'targetTime': targetTime,
      'targetDistance': targetDistance,
    };
  }

  factory PlannedExercise.fromMap(Map<String, dynamic> data) {
    return PlannedExercise(
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      unitType: data['unitType'] ?? '',
      targetSets: data['targetSets'],
      targetReps: data['targetReps'],
      targetWeight: data['targetWeight']?.toDouble(),
      targetTime: data['targetTime'],
      targetDistance: data['targetDistance']?.toDouble(),
    );
  }
}