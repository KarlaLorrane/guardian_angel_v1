import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'profile_model.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _nameController = TextEditingController();
  final _medicalConditionsController = TextEditingController();
  final _vehicleInfoController = TextEditingController();
  String? _selectedBloodType;

  final List<String> _bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    final box = Hive.box<Profile>('profileBox');
    if (box.isNotEmpty) {
      final profile = box.getAt(0)!;
      _nameController.text = profile.name;
      _selectedBloodType = profile.bloodType;
      _medicalConditionsController.text = profile.medicalConditions;
      _vehicleInfoController.text = profile.vehicleInfo;
    }
  }

  Future<void> _saveProfile() async {
    final profile = Profile(
      name: _nameController.text,
      bloodType: _selectedBloodType,
      medicalConditions: _medicalConditionsController.text,
      vehicleInfo: _vehicleInfoController.text,
    );

    final box = Hive.box<Profile>('profileBox');
    if (box.isEmpty) {
      await box.add(profile);
    } else {
      await box.putAt(0, profile);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile saved successfully.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              "Personal Information",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Full Name",
                labelStyle: TextStyle(color: Colors.white),
                hintText: "Enter your name",
                hintStyle: TextStyle(color: Colors.white54),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedBloodType,
              dropdownColor: Colors.grey[850],
              decoration: const InputDecoration(
                labelText: "Blood Type",
                labelStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(color: Colors.white),
              items: _bloodTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
              onChanged: (value) => setState(() => _selectedBloodType = value),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _medicalConditionsController,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Medical Conditions",
                labelStyle: TextStyle(color: Colors.white),
                hintText: "List any medical conditions",
                hintStyle: TextStyle(color: Colors.white54),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Vehicle Information",
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _vehicleInfoController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Make/Model",
                hintStyle: TextStyle(color: Colors.white54),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _saveProfile,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              icon: const Icon(Icons.save),
              label: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}
