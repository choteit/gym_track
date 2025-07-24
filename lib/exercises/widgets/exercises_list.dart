import 'package:flutter/material.dart';

class ExercisesList extends StatelessWidget {
  final List<Map<String, dynamic>> exercises;

  const ExercisesList({
    required this.exercises,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return exercises.isEmpty
        ? const Center(
            child: Text(
              'No exercises added yet',
              style: TextStyle(color: Colors.grey),
            ),
          )
        : ListView.builder(
            itemCount: exercises.length,
            itemBuilder: (context, index) {
              final exercise = exercises[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text(
                    exercise['name'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      if (exercise['unitType'] == 'reps_weight')
                        Text(
                          '${exercise['sets']} x ${exercise['reps']} reps @ ${exercise['weight']}kg',
                          style: const TextStyle(fontSize: 16),
                        )
                      else if (exercise['unitType'] == 'time_distance')
                        Text(
                          '${exercise['distance']}km in ${exercise['time']} minutes',
                          style: const TextStyle(fontSize: 16),
                        ),
                      const SizedBox(height: 4),
                    ],
                  ),
                ),
              );
            },
          );
  }
}
