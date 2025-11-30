import 'storage_service.dart';

class UserService {
  static int? _currentUserId;
  static Map<String, dynamic>? _currentUserData;

  // Set current user and save to persistent storage
  static Future<void> setCurrentUser(int userId, Map<String, dynamic>? userData) async {
    _currentUserId = userId;
    _currentUserData = userData;

    // Save to persistent storage
    if (userData != null) {
      await StorageService.saveUserSession(userId, userData);
    }
  }

  // Load user session from storage (call on app startup)
  static Future<bool> loadSavedSession() async {
    final session = await StorageService.getSavedSession();

    if (session != null) {
      _currentUserId = session['userId'];
      _currentUserData = session['userData'];
      return true;
    }

    return false;
  }

  static int? getCurrentUserId() {
    return _currentUserId;
  }

  static Map<String, dynamic>? getCurrentUserData() {
    return _currentUserData;
  }

  // Clear current user and remove from storage
  static Future<void> clearCurrentUser() async {
    _currentUserId = null;
    _currentUserData = null;
    await StorageService.clearSession();
  }

  static bool isLoggedIn() {
    return _currentUserId != null;
  }

  // Get current user with ID and data combined
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    // Try to load from memory first
    if (_currentUserId != null && _currentUserData != null) {
      return {
        'id': _currentUserId,
        ..._currentUserData!,
      };
    }

    // Try to load from storage
    final session = await StorageService.getSavedSession();
    if (session != null) {
      _currentUserId = session['userId'];
      _currentUserData = session['userData'];

      return {
        'id': _currentUserId,
        ..._currentUserData!,
      };
    }

    return null;
  }

  // Update stored user data when profile changes
  static Future<void> updateStoredUserData(Map<String, dynamic> userData) async {
    _currentUserData = userData;
    await StorageService.updateUserData(userData);
  }

  // Get days remaining in current session
  static Future<int> getSessionDaysRemaining() async {
    return await StorageService.getDaysRemaining();
  }
}
