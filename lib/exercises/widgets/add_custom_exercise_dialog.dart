import 'package:flutter/material.dart';

class AddCustomExerciseDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onExerciseAdded;

  const AddCustomExerciseDialog({
    required this.onExerciseAdded,
    super.key,
  });

  @override
  State<AddCustomExerciseDialog> createState() =>
      _AddCustomExerciseDialogState();
}

class _AddCustomExerciseDialogState extends State<AddCustomExerciseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _selectedCategory = 'muscu';
  String _selectedUnitType = 'reps_weight';

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Add new exercise',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Exercise name',
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: const [
                  DropdownMenuItem(
                    value: 'muscu',
                    child: Text('Weight training'),
                  ),
                  DropdownMenuItem(
                    value: 'cardio',
                    child: Text('Cardio'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                    _selectedUnitType =
                        value == 'cardio' ? 'time_distance' : 'reps_weight';
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Category',
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        widget.onExerciseAdded({
                          'name': _nameController.text.isEmpty
                              ? ''
                              : "${_nameController.text[0].toUpperCase()}${_nameController.text.substring(1).toLowerCase()}",
                          'category': _selectedCategory,
                          'unitType': _selectedUnitType,
                        });
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Add'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
