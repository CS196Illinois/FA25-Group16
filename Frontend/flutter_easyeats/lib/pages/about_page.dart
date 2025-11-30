import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About EasyEats'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset(
                'assets/images/Logo.png',
                height: 100,
              ),
            ),
            const SizedBox(height: 30),

            const Center(
              child: Text(
                'EasyEats',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ),
            const Center(
              child: Text(
                'Version 1.0.0',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 30),

            const Text(
              'About',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'EasyEats is a meal planning and nutrition tracking application designed specifically for university dining halls. Our mission is to help students make informed decisions about their nutrition and achieve their health goals.',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 20),

            const Text(
              'Features',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildFeatureItem(Icons.restaurant_menu, 'Browse dining hall menus'),
            _buildFeatureItem(Icons.analytics, 'Track your nutrition'),
            _buildFeatureItem(Icons.favorite, 'Save favorite meals'),
            _buildFeatureItem(Icons.emoji_events, 'Set and achieve goals'),
            _buildFeatureItem(Icons.dining, 'Dietary restriction support'),
            const SizedBox(height: 20),

            const Text(
              'Developed by',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'CS196 Fall 2025 Group 16\nUniversity of Illinois',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 30),

            Center(
              child: TextButton(
                onPressed: () {},
                child: const Text('View Licenses'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.green, size: 20),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
