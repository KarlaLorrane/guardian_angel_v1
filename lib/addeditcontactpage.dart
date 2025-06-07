import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'contact_model.dart';

class AddEditContactPage extends StatefulWidget {
  final Contact? contact; // se for edição
  const AddEditContactPage({Key? key, this.contact}) : super(key: key);

  @override
  State<AddEditContactPage> createState() => _AddEditContactPageState();
}

class _AddEditContactPageState extends State<AddEditContactPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late String _relationship;
  late List<bool> _notificationPrefs;
  late Box<Contact> _box;

  @override
  void initState() {
    super.initState();
    _box = Hive.box<Contact>('contactsBox');
    if (widget.contact != null) {
      _nameController = TextEditingController(text: widget.contact!.name);
      _phoneController = TextEditingController(text: widget.contact!.phone);
      _emailController = TextEditingController(text: widget.contact!.email);
      _relationship = widget.contact!.relationship;
      _notificationPrefs = List.from(widget.contact!.notificationPrefs);
    } else {
      _nameController = TextEditingController();
      _phoneController = TextEditingController();
      _emailController = TextEditingController();
      _relationship = '';
      _notificationPrefs = [true, false, false];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _saveContact() {
    if (_formKey.currentState!.validate()) {
      final newContact = Contact(
        name: _nameController.text,
        phone: _phoneController.text,
        email: _emailController.text,
        relationship: _relationship,
        notificationPrefs: _notificationPrefs,
      );
      if (widget.contact != null) {
        widget.contact!
          ..name = newContact.name
          ..phone = newContact.phone
          ..email = newContact.email
          ..relationship = newContact.relationship
          ..notificationPrefs = newContact.notificationPrefs
          ..save();
      } else {
        _box.add(newContact);
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: Text(
          widget.contact != null ? 'Edit Contact' : 'Add Contact',
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
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
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Enter contact name',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
              ),

              const SizedBox(height: 20),
              _buildSectionHeader('Phone Number'),
              TextFormField(
                controller: _phoneController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: '+1 (000) 000-0000',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Please enter a phone number' : null,
              ),

              const SizedBox(height: 20),
              _buildSectionHeader('Email'),
              TextFormField(
                controller: _emailController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'example@email.com',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Please enter an email address' : null,
              ),

              const SizedBox(height: 20),
              _buildSectionHeader('Relationship'),
              DropdownButtonFormField<String>(
                dropdownColor: Colors.grey[900],
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Select relationship',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: const OutlineInputBorder(),
                ),
                value: _relationship.isNotEmpty ? _relationship : null,
                items: const [
                  DropdownMenuItem(value: 'Parent', child: Text('Parent', style: TextStyle(color: Colors.white))),
                  DropdownMenuItem(value: 'Spouse', child: Text('Spouse', style: TextStyle(color: Colors.white))),
                  DropdownMenuItem(value: 'Friend', child: Text('Friend', style: TextStyle(color: Colors.white))),
                  DropdownMenuItem(value: 'Doctor', child: Text('Doctor', style: TextStyle(color: Colors.white))),
                ],
                onChanged: (value) => setState(() => _relationship = value!),
                validator: (value) => value == null ? 'Please select a relationship' : null,
              ),

              const SizedBox(height: 20),
              _buildSectionHeader('Notification Preferences'),
              Theme(
                data: Theme.of(context).copyWith(unselectedWidgetColor: Colors.white70),
                child: Column(
                  children: [
                    CheckboxListTile(
                      title: const Text('SMS', style: TextStyle(color: Colors.white)),
                      activeColor: Colors.blue,
                      checkColor: Colors.white,
                      value: _notificationPrefs[0],
                      onChanged: (val) => setState(() => _notificationPrefs[0] = val!),
                    ),
                    CheckboxListTile(
                      title: const Text('Email', style: TextStyle(color: Colors.white)),
                      activeColor: Colors.blue,
                      checkColor: Colors.white,
                      value: _notificationPrefs[2],
                      onChanged: (val) => setState(() => _notificationPrefs[2] = val!),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _saveContact,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text('Save Contact', style: TextStyle(color: Colors.white)),
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
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }
}
