import 'package:shared_preferences/shared_preferences.dart';

/// PreferencesService - Handles local storage using SharedPreferences
///
/// SharedPreferences stores simple data ON THE PHONE (not in cloud)
/// Good for: settings, preferences, small data that doesn't need sync
///
/// This is different from Firestore:
/// - SharedPreferences = local storage (only on this phone)
/// - Firestore = cloud storage (synced across devices)
class PreferencesService {
  SharedPreferences? _prefs;

  // Keys for storing data (like variable names)
  static const String _keyIsFirstTime = 'isFirstTime';
  static const String _keyIsLoggedIn = 'isLoggedIn';
  static const String _keyUserId = 'userId';
  static const String _keyUsername = 'username';
  static const String _keyThemeMode = 'themeMode';
  static const String _keyReadingReminders = 'readingReminders';
  static const String _keyLastSelectedTab = 'lastSelectedTab';
  static const String _keyReadingGoal = 'readingGoal';
  static const String _keyNotificationsEnabled = 'notificationsEnabled';

  /// Initialize SharedPreferences
  /// MUST be called before using any other methods
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Ensure prefs is initialized
  Future<SharedPreferences> get _preferences async {
    if (_prefs == null) {
      await init();
    }
    return _prefs!;
  }

  // ==================== FIRST TIME / ONBOARDING ====================

  /// Check if this is user's first time opening the app
  Future<bool> isFirstTime() async {
    final prefs = await _preferences;
    return prefs.getBool(_keyIsFirstTime) ?? true; // Default: true (is first time)
  }

  /// Mark that user has completed onboarding
  Future<void> setFirstTimeDone() async {
    final prefs = await _preferences;
    await prefs.setBool(_keyIsFirstTime, false);
  }

  // ==================== LOGIN STATUS ====================

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await _preferences;
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  /// Set login status
  Future<void> setLoggedIn(bool value) async {
    final prefs = await _preferences;
    await prefs.setBool(_keyIsLoggedIn, value);
  }

  // ==================== USER INFO ====================

  /// Get saved user ID
  Future<String?> getUserId() async {
    final prefs = await _preferences;
    return prefs.getString(_keyUserId);
  }

  /// Save user ID
  Future<void> setUserId(String? userId) async {
    final prefs = await _preferences;
    if (userId != null) {
      await prefs.setString(_keyUserId, userId);
    } else {
      await prefs.remove(_keyUserId);
    }
  }

  /// Get saved username
  Future<String?> getUsername() async {
    final prefs = await _preferences;
    return prefs.getString(_keyUsername);
  }

  /// Save username
  Future<void> setUsername(String? username) async {
    final prefs = await _preferences;
    if (username != null) {
      await prefs.setString(_keyUsername, username);
    } else {
      await prefs.remove(_keyUsername);
    }
  }

  // ==================== THEME ====================

  /// Get theme mode ('light', 'dark', or 'system')
  Future<String> getThemeMode() async {
    final prefs = await _preferences;
    return prefs.getString(_keyThemeMode) ?? 'system';
  }

  /// Set theme mode
  Future<void> setThemeMode(String mode) async {
    final prefs = await _preferences;
    await prefs.setString(_keyThemeMode, mode);
  }

  // ==================== READING SETTINGS ====================

  /// Check if reading reminders are enabled
  Future<bool> areReadingRemindersEnabled() async {
    final prefs = await _preferences;
    return prefs.getBool(_keyReadingReminders) ?? true; // Default: enabled
  }

  /// Set reading reminders on/off
  Future<void> setReadingReminders(bool enabled) async {
    final prefs = await _preferences;
    await prefs.setBool(_keyReadingReminders, enabled);
  }

  /// Get monthly reading goal (number of books)
  Future<int> getReadingGoal() async {
    final prefs = await _preferences;
    return prefs.getInt(_keyReadingGoal) ?? 5; // Default: 5 books per month
  }

  /// Set monthly reading goal
  Future<void> setReadingGoal(int goal) async {
    final prefs = await _preferences;
    await prefs.setInt(_keyReadingGoal, goal);
  }

  // ==================== NAVIGATION ====================

  /// Get last selected tab index
  Future<int> getLastSelectedTab() async {
    final prefs = await _preferences;
    return prefs.getInt(_keyLastSelectedTab) ?? 0;
  }

  /// Save last selected tab index
  Future<void> setLastSelectedTab(int index) async {
    final prefs = await _preferences;
    await prefs.setInt(_keyLastSelectedTab, index);
  }

  // ==================== NOTIFICATIONS ====================

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    final prefs = await _preferences;
    return prefs.getBool(_keyNotificationsEnabled) ?? true; // Default: enabled
  }

  /// Set notifications on/off
  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await _preferences;
    await prefs.setBool(_keyNotificationsEnabled, enabled);
  }

  // ==================== CLEAR DATA ====================

  /// Clear all saved preferences (for logout)
  Future<void> clearAll() async {
    final prefs = await _preferences;
    await prefs.clear();
  }

  /// Clear only user-related data (keep app settings)
  Future<void> clearUserData() async {
    final prefs = await _preferences;
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUsername);
    await prefs.setBool(_keyIsLoggedIn, false);
  }
}