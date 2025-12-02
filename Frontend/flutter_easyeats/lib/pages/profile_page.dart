import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _goalController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  String _selectedSex = 'Male';
  bool _isLoading = true;
  String _email = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final userId = UserService.getCurrentUserId();
    if (userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in first')),
        );
        Navigator.pop(context);
      }
      return;
    }

    final result = await AuthService.getProfile(userId);
    if (result['success']) {
      final data = result['data'];
      setState(() {
        _email = data['email'] ?? '';
        _goalController.text = data['goal'] ?? '';
        _ageController.text = data['age']?.toString() ?? '';
        _caloriesController.text = data['calories']?.toString() ?? '';
        _selectedSex = data['sex'] ?? 'Male';
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['error'])),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    final userId = UserService.getCurrentUserId();
    if (userId == null) return;

    setState(() {
      _isLoading = true;
    });

    final result = await AuthService.updateProfile(
      userId,
      _goalController.text.isEmpty ? null : _goalController.text,
      _ageController.text.isEmpty ? null : int.tryParse(_ageController.text),
      _selectedSex,
      _caloriesController.text.isEmpty ? null : int.tryParse(_caloriesController.text),
    );

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['error'])),
        );
      }
    }
  }

  @override
  void dispose() {
    _goalController.dispose();
    _ageController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (!_isLoading)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveProfile,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.green,
                          child: Text(
                            _email.isNotEmpty ? _email[0].toUpperCase() : 'U',
                            style: const TextStyle(fontSize: 40, color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _email,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  const Text(
                    'Personal Information',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: _goalController,
                    decoration: const InputDecoration(
                      labelText: 'Goal',
                      hintText: 'e.g., Lose weight, Build muscle',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.flag),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: _ageController,
                    decoration: const InputDecoration(
                      labelText: 'Age',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.cake),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    initialValue: _selectedSex,
                    decoration: const InputDecoration(
                      labelText: 'Sex',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    items: ['Male', 'Female', 'Other'].map((sex) {
                      return DropdownMenuItem(value: sex, child: Text(sex));
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedSex = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: _caloriesController,
                    decoration: const InputDecoration(
                      labelText: 'Daily Calorie Target',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.local_fire_department),
                      suffixText: 'kcal',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text('Save Changes'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
