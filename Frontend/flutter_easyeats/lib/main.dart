import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "EasyEats",
      theme: ThemeData(primarySwatch: Colors.green),
      debugShowCheckedModeBanner: false,
      home: const AuthScreen(),
    );
  }
}

// =================== AUTH SCREEN ===================

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});
  @override
  build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Welcome to EasyEats")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Go to sign-in page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignInScreen()),
                );
              },
              child: const Text('Sign In'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Go to sign-up page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignUpScreen()),
                );
              },
              child: const Text("Sign Up"),
            ),
          ],
        ),
      ),
    );
  }
}

// =================== SIGN UP SCREEN ===================

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // After signing up, go to questionnaire
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const QuestionnaireScreen(),
              ),
            );
          },
          child: const Text('Continue to Questionnaire'),
        ),
      ),
    );
  }
}

// =================== SIGN IN SCREEN ===================

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Go directly to home after sign in
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          },
          child: const Text('Sign In'),
        ),
      ),
    );
  }
}

// =================== QUESTIONNAIRE SCREEN ===================

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
                // For now, just print data
                print('Goal: $goal, Sex: $sex, Age: $age, Calories: $calories');
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
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

// =================== HOME SCREEN ===================

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('EasyEats Home')),
      body: const Center(
        child: Text('Welcome to your personalized meal plan!'),
      ),
    );
  }
}
