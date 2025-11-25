import 'package:flutter/material.dart';
import 'home_page.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';


class QuestionnaireScreen extends StatefulWidget {
  final int userId;

  const QuestionnaireScreen({super.key, required this.userId});

  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  String? goal;
  int? age;
  String? sex;
  int? calories;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Personalize Your Plan')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const SizedBox(height: 10),
            // Logo at the top
            Center(
              child: Image.asset(
                'assets/images/Logo.png',
                height: 60,
              ),
            ),
            const SizedBox(height: 30),

            const Text('What is your goal?', style: TextStyle(fontSize: 18)),
            DropdownButton<String>(
              value: goal,
              hint: const Text('Select goal'),
              items: [
                'Losing weight',
                'Gaining weight',
                'Becoming fit',
              ].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
              onChanged: (value) => setState(() => goal = value),
            ),
            const SizedBox(height: 16),
            const Text('Sex:', style: TextStyle(fontSize: 18)),
            DropdownButton<String>(
              value: sex,
              hint: const Text('Select sex'),
              items: [
                'Male',
                'Female',
                'Other',
              ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (value) => setState(() => sex = value),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(labelText: 'Age'),
              keyboardType: TextInputType.number,
              onChanged: (val) => age = int.tryParse(val),
            ),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Daily calorie goal',
              ),
              keyboardType: TextInputType.number,
              onChanged: (val) => calories = int.tryParse(val),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : () async {
                setState(() {
                  _isLoading = true;
                });

                // Update profile on backend
                final result = await AuthService.updateProfile(
                  widget.userId,
                  goal,
                  age,
                  sex,
                  calories,
                );

                setState(() {
                  _isLoading = false;
                });

                if (result['success']) {
                  // Store user data (with persistent storage)
                  await UserService.setCurrentUser(widget.userId, result['data']['user']);

                  if (mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const MainPage()),
                    );
                  }
                } else{
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(result['error'])),
                    );
                  }
                }
              },
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Finish'),
            ),
          ],
        ),
      ),
    );
  }
}