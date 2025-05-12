import 'package:flutter/material.dart';

class AddEditContactPage extends StatefulWidget {
  const AddEditContactPage({super.key});

  @override
  State<AddEditContactPage> createState() => _AddEditContactPageState();
}

class _AddEditContactPageState extends State<AddEditContactPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _relationshipController = TextEditingController();

  List<bool> _notificationPrefs = [true, false, false]; // SMS, WhatsApp, Email

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Contact'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildSectionHeader('Contact Name'),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'Enter contact name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),
              _buildSectionHeader('Phone Number'),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  hintText: '+1 (000) 000-0000',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a phone number';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),
              _buildSectionHeader('Relationship'),
              DropdownButtonFormField<String>(
                items: const [
                  DropdownMenuItem(value: 'Parent', child: Text('Parent')),
                  DropdownMenuItem(value: 'Spouse', child: Text('Spouse')),
                  DropdownMenuItem(value: 'Friend', child: Text('Friend')),
                  DropdownMenuItem(value: 'Doctor', child: Text('Doctor')),
                ],
                onChanged: (value) {
                  _relationshipController.text = value ?? '';
                },
                decoration: const InputDecoration(
                  hintText: 'Select relationship',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a relationship';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),
              _buildSectionHeader('Notification Preferences'),
              CheckboxListTile(
                title: const Text('SMS'),
                value: _notificationPrefs[0],
                onChanged: (value) {
                  setState(() {
                    _notificationPrefs[0] = value ?? false;
                  });
                },
              ),
              CheckboxListTile(
                title: const Text('WhatsApp'),
                value: _notificationPrefs[1],
                onChanged: (value) {
                  setState(() {
                    _notificationPrefs[1] = value ?? false;
                  });
                },
              ),
              CheckboxListTile(
                title: const Text('Email'),
                value: _notificationPrefs[2],
                onChanged: (value) {
                  setState(() {
                    _notificationPrefs[2] = value ?? false;
                  });
                },
              ),

              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Salvar os dados e voltar
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text('Save Contact'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _relationshipController.dispose();
    super.dispose();
  }
}