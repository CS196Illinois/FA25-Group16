import 'package:flutter/material.dart';
import 'lib/pages/questionnaire_screen.dart';

void main() {
  runApp(const TestQuestionnaireApp());
}

class TestQuestionnaireApp extends StatelessWidget {
  const TestQuestionnaireApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test Questionnaire',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const QuestionnaireScreen(userId: 1), // Test with userId 1
    );
  }
}
