import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _notificationsEnabled = true;
  bool _mealReminders = true;
  bool _goalAchievements = true;
  bool _weeklyReports = false;
  bool _newMenuItems = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    final userId = UserService.getCurrentUserId();
    if (userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in first')),
        );
        Navigator.pop(context);
      }
      return;
    }

    final result = await AuthService.getProfile(userId);
    if (result['success']) {
      final data = result['data'];
      setState(() {
        _notificationsEnabled = data['notifications_enabled'] ?? true;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveNotificationSettings() async {
    final userId = UserService.getCurrentUserId();
    if (userId == null) return;

    setState(() {
      _isLoading = true;
    });

    final result = await AuthService.updateProfile(
      userId,
      null,
      null,
      null,
      null,
      notificationsEnabled: _notificationsEnabled,
    );

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification settings saved')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['error'])),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (!_isLoading)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveNotificationSettings,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Notification Settings',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Manage how and when you receive notifications',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 30),

                SwitchListTile(
                  title: const Text('Enable Notifications'),
                  subtitle: const Text('Master control for all notifications'),
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                  secondary: const Icon(Icons.notifications_active),
                ),
                const Divider(),

                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Notification Types',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 10),

                SwitchListTile(
                  title: const Text('Meal Reminders'),
                  subtitle: const Text('Get notified before meal times'),
                  value: _mealReminders,
                  onChanged: _notificationsEnabled
                      ? (value) {
                          setState(() {
                            _mealReminders = value;
                          });
                        }
                      : null,
                  secondary: const Icon(Icons.restaurant_menu),
                ),

                SwitchListTile(
                  title: const Text('Goal Achievements'),
                  subtitle: const Text('Celebrate when you hit your nutrition goals'),
                  value: _goalAchievements,
                  onChanged: _notificationsEnabled
                      ? (value) {
                          setState(() {
                            _goalAchievements = value;
                          });
                        }
                      : null,
                  secondary: const Icon(Icons.emoji_events),
                ),

                SwitchListTile(
                  title: const Text('Weekly Reports'),
                  subtitle: const Text('Summary of your weekly nutrition'),
                  value: _weeklyReports,
                  onChanged: _notificationsEnabled
                      ? (value) {
                          setState(() {
                            _weeklyReports = value;
                          });
                        }
                      : null,
                  secondary: const Icon(Icons.calendar_today),
                ),

                SwitchListTile(
                  title: const Text('New Menu Items'),
                  subtitle: const Text('Get notified about new dining hall offerings'),
                  value: _newMenuItems,
                  onChanged: _notificationsEnabled
                      ? (value) {
                          setState(() {
                            _newMenuItems = value;
                          });
                        }
                      : null,
                  secondary: const Icon(Icons.new_releases),
                ),

                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveNotificationSettings,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Save Settings'),
                  ),
                ),
              ],
            ),
    );
  }
}
