import 'package:flutter/material.dart';

class ExercisesList extends StatelessWidget {
  final List<Map<String, dynamic>> exercises;
  final Function(int) onExerciseDeleted;

  const ExercisesList({
    required this.exercises,
    required this.onExerciseDeleted,
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
              return Dismissible(
                key: Key(index.toString()),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16.0),
                  color: Colors.red,
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                confirmDismiss: (direction) async {
                  return await showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text('Delete exercise'),
                      content: const Text(
                          'Are you sure you want to delete this exercise?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                onDismissed: (direction) {
                  onExerciseDeleted(index);
                },
                child: Card(
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
                ),
              );
            },
          );
  }
}
