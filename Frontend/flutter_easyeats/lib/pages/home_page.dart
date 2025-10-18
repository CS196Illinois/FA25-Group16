import 'package:flutter/material.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.block_outlined), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_outlined), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_none_outlined), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: ''),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              const SizedBox(height: 10),
              // Logo at the top
              Center(
                child: Image.asset(
                  'assets/images/Logo.png',
                  height: 60, // adjust as needed
                ),
              ),
              const SizedBox(height: 16),

              // Search bar
              TextField(
                decoration: InputDecoration(
                  hintText: "Search",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                ),
              ),
              const SizedBox(height: 16),

              // Top Buttons Row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildTopButton(Icons.favorite_border, "Favorites"),
                    _buildTopButton(Icons.history, "History"),
                    _buildTopButton(Icons.person_add_alt_1_outlined, "Following"),
                    _buildTopButton(Icons.qr_code_scanner_outlined, "QR"),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Image banner with text overlay
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    Image.asset(
                      'assets/images/Grillworks.jpg',
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Container(
                      height: 150,
                      width: double.infinity,
                      color: Colors.black.withOpacity(0.3),
                      padding: const EdgeInsets.all(16),
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        "Next Meal: Grillworks, ISR",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Serving section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text("Serving:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Icon(Icons.chevron_right),
                ],
              ),
              const SizedBox(height: 10),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFoodItem('Grilled_Chicken.jpg', 'Chicken'),
                    _buildFoodItem('Assorted_Veg.jpg', 'Assorted Vegetables'),
                    _buildFoodItem('Rice.webp', 'Jasmine Rice'),
                    _buildFoodItem('mixed_fruit.jpg', 'Fruit Mix'),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // Goals section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text("Goals", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Icon(Icons.chevron_right),
                ],
              ),
              const SizedBox(height: 10),

              _buildProgressBar("Calories", 1000, 2500, "kcal"),
              const SizedBox(height: 8),
              _buildProgressBar("Protein", 50, 100, "g"),
              const SizedBox(height: 8),
              _buildProgressBar("Carbohydrates", 100, 500, "g"),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget for top buttons
  static Widget _buildTopButton(IconData icon, String label) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          side: BorderSide(color: Colors.grey[300]!),
        ),
      ),
    );
  }

  // Helper widget for food items
static Widget _buildFoodItem(String assetName, String name) {
  return Container(
    margin: const EdgeInsets.only(right: 16),
    child: Column(
      children: [
        CircleAvatar(
          backgroundImage: AssetImage('assets/images/$assetName'),
          radius: 35,
        ),
        const SizedBox(height: 8),
        Text(name, style: const TextStyle(fontSize: 14)),
      ],
    ),
  );
}

  // Helper widget for progress bars
  static Widget _buildProgressBar(String label, double current, double goal, String unit) {
    double progress = current / goal;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$label: ${current.toInt()}/${goal.toInt()} $unit"),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[200],
          color: Colors.blueAccent,
          minHeight: 4,
        ),
      ],
    );
  }
}
