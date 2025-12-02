import 'package:flutter/material.dart';
import 'pages/questionnaire_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "EasyEats - Test Questionnaire",
      theme: ThemeData(primarySwatch: Colors.green),
      debugShowCheckedModeBanner: false,
      // TEMPORARY: Go directly to questionnaire for testing
      home: const QuestionnaireScreen(userId: 999),
    );
  }
}
