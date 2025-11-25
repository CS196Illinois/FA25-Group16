import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

class DietaryRestrictionsPage extends StatefulWidget {
  const DietaryRestrictionsPage({super.key});

  @override
  State<DietaryRestrictionsPage> createState() => _DietaryRestrictionsPageState();
}

class _DietaryRestrictionsPageState extends State<DietaryRestrictionsPage> {
  final List<String> _availableRestrictions = [
    'Vegetarian',
    'Vegan',
    'Gluten-Free',
    'Dairy-Free',
    'Nut Allergy',
    'Shellfish Allergy',
    'Egg Allergy',
    'Soy Allergy',
    'Halal',
    'Kosher',
    'Low Sodium',
    'Low Sugar',
    'Keto',
    'Paleo',
  ];

  List<String> _selectedRestrictions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRestrictions();
  }

  Future<void> _loadRestrictions() async {
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
        _selectedRestrictions = List<String>.from(data['dietary_restrictions'] ?? []);
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveRestrictions() async {
    final userId = UserService.getCurrentUserId();
    if (userId == null) return;

    setState(() {
      _isLoading = true;
    });

    final result = await AuthService.updateProfile(
      userId,
      null,
      null,
      null,
      null,
      dietaryRestrictions: _selectedRestrictions,
    );

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dietary restrictions saved')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['error'])),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dietary Restrictions'),
        actions: [
          if (!_isLoading)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveRestrictions,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Dietary Restrictions & Preferences',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Select your dietary restrictions and preferences to get personalized meal recommendations',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 10),
                      if (_selectedRestrictions.isNotEmpty)
                        Wrap(
                          spacing: 8,
                          children: _selectedRestrictions.map((restriction) {
                            return Chip(
                              label: Text(restriction),
                              deleteIcon: const Icon(Icons.close, size: 18),
                              onDeleted: () {
                                setState(() {
                                  _selectedRestrictions.remove(restriction);
                                });
                              },
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    itemCount: _availableRestrictions.length,
                    itemBuilder: (context, index) {
                      final restriction = _availableRestrictions[index];
                      final isSelected = _selectedRestrictions.contains(restriction);

                      return CheckboxListTile(
                        title: Text(restriction),
                        value: isSelected,
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              _selectedRestrictions.add(restriction);
                            } else {
                              _selectedRestrictions.remove(restriction);
                            }
                          });
                        },
                        secondary: _getIconForRestriction(restriction),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveRestrictions,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Save Preferences'),
                  ),
                ),
              ],
            ),
    );
  }

  Icon _getIconForRestriction(String restriction) {
    switch (restriction) {
      case 'Vegetarian':
      case 'Vegan':
        return const Icon(Icons.eco, color: Colors.green);
      case 'Gluten-Free':
      case 'Dairy-Free':
        return const Icon(Icons.no_food, color: Colors.orange);
      case 'Nut Allergy':
      case 'Shellfish Allergy':
      case 'Egg Allergy':
      case 'Soy Allergy':
        return const Icon(Icons.warning, color: Colors.red);
      case 'Halal':
      case 'Kosher':
        return const Icon(Icons.restaurant, color: Colors.blue);
      default:
        return const Icon(Icons.dining, color: Colors.grey);
    }
  }
}
