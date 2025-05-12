import 'package:flutter/material.dart';
import 'addeditcontactpage.dart';

class EmergencyContactsPage extends StatelessWidget {
  const EmergencyContactsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Contacts'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildContactCard('John Doe', 'Parent'),
          _buildContactCard('Jane Smith', 'Spouse'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddEditContactPage(),
                ),
              );
            },
            child: const Text('Add New Contact'),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(String name, String relationship) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.person, size: 40),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(relationship),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                // Navegar para edição
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                // Implementar deleção
              },
            ),
          ],
        ),
      ),
    );
  }
}