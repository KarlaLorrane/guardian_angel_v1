import 'package:flutter/material.dart';
import 'emergencycontactspage.dart';
import 'addeditcontactpage.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Location Sharing'),
          _buildSwitchTile('Allow location access', true),

          const SizedBox(height: 24),
          _buildSectionHeader('Notifications'),
          _buildSwitchTile('Emergency alerts', true),

          const SizedBox(height: 24),
          _buildSectionHeader('Cloud Backup'),
          _buildSwitchTile('Auto-sync data', false),

          const SizedBox(height: 32),
          _buildSectionHeader('Emergency Contacts'),
          _buildEmergencyContactsCard(context),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSwitchTile(String title, bool value) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: (bool newValue) {
        // Implementar lógica de mudança
      },
    );
  }

  Widget _buildEmergencyContactsCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('John Doe'),
              subtitle: const Text('Parent'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EmergencyContactsPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Jane Smith'),
              subtitle: const Text('Spouse'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EmergencyContactsPage(),
                  ),
                );
              },
            ),
            TextButton(
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
      ),
    );
  }
}