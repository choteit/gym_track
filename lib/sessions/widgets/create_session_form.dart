import 'package:flutter/material.dart';

class SessionFormPage extends StatefulWidget {
  const SessionFormPage({super.key});

  @override
  State<SessionFormPage> createState() => _SessionFormPageState();
}

class _SessionFormPageState extends State<SessionFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _userIdController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _idController.dispose();
    _userIdController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // TODO: Créer une instance de Session et la sauvegarder
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session créée (non sauvegardée)')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New session'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              ListTile(
                title: Text(
                  'Date : ${_selectedDate.toLocal()}'.split(' ')[0],
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _pickDate(context),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Create session'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
