class Session {
  final String id;
  final String userId;
  final DateTime date;
  final List<dynamic> exercises; // Remplacer dynamic par Exercise plus tard

  Session({
    required this.id,
    required this.userId,
    required this.date,
    required this.exercises,
  });
}