import 'package:flutter/material.dart';
import 'home_page.dart';


class QuestionnaireScreen extends StatefulWidget {
  const QuestionnaireScreen({super.key});

  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  String? goal;
  int? age;
  String? sex;
  int? calories;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Personalize Your Plan')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            
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
              onPressed: () {
                print('Goal: $goal, Sex: $sex, Age: $age, Calories: $calories');
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MainPage()),
                );
              },
              child: const Text('Finish'),
            ),
          ],
        ),
      ),
    );
  }
}