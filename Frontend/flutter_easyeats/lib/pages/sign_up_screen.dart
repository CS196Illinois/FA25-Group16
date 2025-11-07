import 'package:flutter/material.dart';
import 'questionnaire_screen.dart';
import '../widgets/app_logo.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AppLogo(), // 👈 logo added
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const QuestionnaireScreen(),
                  ),
                );
              },
              child: const Text('Continue to Questionnaire'),
            ),
          ],
        ),
      ),
    );
  }
}