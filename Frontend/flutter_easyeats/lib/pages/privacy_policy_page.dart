import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Privacy Policy',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Last updated: November 2025',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 30),

            _buildSection(
              'Introduction',
              'EasyEats ("we", "our", or "us") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, and safeguard your information when you use our mobile application.',
            ),

            _buildSection(
              'Information We Collect',
              'We collect information that you provide directly to us, including:\n\n'
              '• Account information (email address, password)\n'
              '• Profile information (age, sex, nutrition goals)\n'
              '• Dietary restrictions and preferences\n'
              '• Meal tracking data\n'
              '• Favorite meals and menu items',
            ),

            _buildSection(
              'How We Use Your Information',
              'We use the information we collect to:\n\n'
              '• Provide, maintain, and improve our services\n'
              '• Track your nutrition and progress toward goals\n'
              '• Personalize your experience based on dietary restrictions\n'
              '• Send you notifications (if enabled)\n'
              '• Respond to your requests and provide customer support',
            ),

            _buildSection(
              'Data Security',
              'We implement appropriate security measures to protect your personal information. Your password is encrypted using industry-standard hashing algorithms. However, no method of transmission over the internet is 100% secure.',
            ),

            _buildSection(
              'Data Sharing',
              'We do not sell, trade, or rent your personal information to third parties. We may share your information only in the following circumstances:\n\n'
              '• With your consent\n'
              '• To comply with legal obligations\n'
              '• To protect our rights and safety',
            ),

            _buildSection(
              'Your Rights',
              'You have the right to:\n\n'
              '• Access your personal data\n'
              '• Correct inaccurate data\n'
              '• Delete your account and associated data\n'
              '• Opt out of notifications\n'
              '• Export your data',
            ),

            _buildSection(
              'Children\'s Privacy',
              'Our service is intended for users aged 13 and older. We do not knowingly collect information from children under 13.',
            ),

            _buildSection(
              'Changes to This Policy',
              'We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new policy on this page and updating the "Last updated" date.',
            ),

            _buildSection(
              'Contact Us',
              'If you have questions about this Privacy Policy, please contact us at:\n\nsupport@easyeats.com',
            ),

            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('I Understand'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(fontSize: 14, height: 1.6),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
