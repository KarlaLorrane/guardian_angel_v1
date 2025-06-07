import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'addeditcontactpage.dart';
import 'contact_model.dart';

class EmergencyContactsPage extends StatelessWidget {
  const EmergencyContactsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Emergency Contacts', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey[900],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Contact>('contactsBox').listenable(),
        builder: (context, Box<Contact> box, _) {
          final contacts = box.values.toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ...contacts.map((contact) => _buildContactCard(context, contact)),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddEditContactPage(),
                    ),
                  );
                },
                child: const Text('Add New Contact', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContactCard(BuildContext context, Contact contact) {
    return Card(
      color: Colors.grey[850],
      child: ListTile(
        leading: const Icon(Icons.person, size: 40, color: Colors.white),
        title: Text(contact.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        subtitle: Text(contact.relationship, style: const TextStyle(color: Colors.white70)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddEditContactPage(contact: contact),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: () {
                contact.delete();
              },
            ),
          ],
        ),
      ),
    );
  }
}
