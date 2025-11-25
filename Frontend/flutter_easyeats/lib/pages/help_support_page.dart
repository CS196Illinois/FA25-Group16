import 'package:flutter/material.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Frequently Asked Questions',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          _buildFAQItem(
            'How do I track my meals?',
            'Navigate to a dining hall, select a meal, and tap on the items you\'ve eaten. Your nutrition data will be automatically tracked.',
          ),
          _buildFAQItem(
            'How do I set my nutrition goals?',
            'Go to Settings > Profile and enter your daily calorie target and other nutritional goals.',
          ),
          _buildFAQItem(
            'Can I save my favorite meals?',
            'Yes! Tap the heart icon on any meal item to add it to your favorites. Access them anytime from Settings > Favorites.',
          ),
          _buildFAQItem(
            'How do I add dietary restrictions?',
            'Go to Settings > Dietary Restrictions and select all that apply. We\'ll help filter menu items based on your preferences.',
          ),
          _buildFAQItem(
            'Is my data secure?',
            'Yes! Your data is stored securely and we never share your personal information. See our Privacy Policy for details.',
          ),

          const SizedBox(height: 30),
          const Text(
            'Need More Help?',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          Card(
            child: ListTile(
              leading: const Icon(Icons.email, color: Colors.green),
              title: const Text('Email Support'),
              subtitle: const Text('support@easyeats.com'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.bug_report, color: Colors.orange),
              title: const Text('Report a Bug'),
              subtitle: const Text('Help us improve EasyEats'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.lightbulb, color: Colors.blue),
              title: const Text('Feature Request'),
              subtitle: const Text('Suggest new features'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.description, color: Colors.grey),
              title: const Text('Documentation'),
              subtitle: const Text('Learn how to use EasyEats'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          ),

          const SizedBox(height: 30),
          const Center(
            child: Text(
              'EasyEats v1.0.0',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            answer,
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
        ),
      ],
    );
  }
}
