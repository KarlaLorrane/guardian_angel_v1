import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'emergencycontactspage.dart';
import 'addeditcontactpage.dart';
import 'contact_model.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late bool _emergencyAlertsEnabled;
  final Box _settingsBox = Hive.box('settingsBox');

  @override
  void initState() {
    super.initState();
    _emergencyAlertsEnabled = _settingsBox.get('emergencyAlerts', defaultValue: true);
  }

  void _toggleEmergencyAlerts(bool value) {
    setState(() {
      _emergencyAlertsEnabled = value;
    });
    _settingsBox.put('emergencyAlerts', value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: const Text('App Settings', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Notifications'),
          SwitchListTile(
            title: const Text('Emergency alerts', style: TextStyle(color: Colors.white)),
            value: _emergencyAlertsEnabled,
            activeColor: Colors.blue,
            onChanged: _toggleEmergencyAlerts,
          ),

          const SizedBox(height: 32),
          _buildSectionHeader('Emergency Contacts'),
          _buildEmergencyContactsCard(context),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildEmergencyContactsCard(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<Contact>('contactsBox').listenable(),
      builder: (context, Box<Contact> box, _) {
        final contacts = box.values.toList();

        return Card(
          color: Colors.grey[900],
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ...contacts.map((c) => ListTile(
                  leading: const Icon(Icons.person, color: Colors.white),
                  title: Text(c.name, style: const TextStyle(color: Colors.white)),
                  subtitle: Text(c.relationship, style: const TextStyle(color: Colors.white70)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EmergencyContactsPage(),
                      ),
                    );
                  },
                )),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddEditContactPage(),
                      ),
                    );
                  },
                  child: const Text('Add New Contact', style: TextStyle(color: Colors.blue)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
