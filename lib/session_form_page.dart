import 'package:flutter/material.dart';

class SessionFormPage extends StatelessWidget {
  const SessionFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvelle séance'),
      ),
      body: const Center(
        child: Text('Formulaire de création de séance à implémenter'),
      ),
    );
  }
}