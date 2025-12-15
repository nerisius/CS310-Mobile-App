import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/books_provider.dart';
import '../providers/posts_provider.dart';
import '../services/preferences_service.dart';

/// SettingsScreen - App settings with SharedPreferences
///
/// Features:
/// - User info display
/// - Push notifications toggle (SharedPreferences)
/// - Reading reminders toggle (SharedPreferences)
/// - Reading goal setting (SharedPreferences)
/// - Logout functionality
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final PreferencesService _prefsService = PreferencesService();

  // Settings state (saved to SharedPreferences)
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _friendActivity = false;
  bool _readingReminders = true;
  int _readingGoal = 5;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  /// Load saved preferences from SharedPreferences
  Future<void> _loadPreferences() async {
    await _prefsService.init();

    final notifications = await _prefsService.areNotificationsEnabled();
    final readingReminders = await _prefsService.areReadingRemindersEnabled();
    final readingGoal = await _prefsService.getReadingGoal();

    setState(() {
      _pushNotifications = notifications;
      _readingReminders = readingReminders;
      _readingGoal = readingGoal;
    });
  }

  /// Handle logout
  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Log Out', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      // Clear providers
      context.read<BooksProvider>().clear();
      context.read<PostsProvider>().clear();

      // Sign out from Firebase
      await context.read<AuthProvider>().signOut();

      if (mounted) {
        // Navigate to login and clear navigation stack
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Settings",
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        children: [
          // User Info Card
          Container(
            color: AppColors.cardBackground,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.accent,
                  child: Text(
                    authProvider.username.isNotEmpty
                        ? authProvider.username[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        authProvider.username,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        authProvider.firebaseUser?.email ?? '',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ACCOUNT SECTION
          _buildSectionHeader("ACCOUNT"),
          _buildListTile(
            icon: Icons.person_outline,
            title: "Account Settings",
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Coming soon!')),
              );
            },
          ),
          _buildListTile(
            icon: Icons.language,
            title: "Language",
            trailingText: "English",
            onTap: () {},
          ),

          // NOTIFICATIONS SECTION
          _buildSectionHeader("NOTIFICATIONS"),
          _buildSwitchTile(
            icon: Icons.notifications_none,
            title: "Push Notifications",
            value: _pushNotifications,
            onChanged: (val) async {
              setState(() => _pushNotifications = val);
              await _prefsService.setNotificationsEnabled(val);
            },
          ),
          _buildSwitchTile(
            icon: Icons.email_outlined,
            title: "Email Notifications",
            value: _emailNotifications,
            onChanged: (val) => setState(() => _emailNotifications = val),
          ),
          _buildSwitchTile(
            icon: Icons.notifications_active_outlined,
            title: "Friend Activity",
            value: _friendActivity,
            onChanged: (val) => setState(() => _friendActivity = val),
          ),

          // READING SECTION (SharedPreferences)
          _buildSectionHeader("READING"),
          _buildListTile(
            icon: Icons.track_changes,
            title: "Reading Challenge",
            trailingText: "$_readingGoal books/month",
            onTap: _showReadingGoalDialog,
          ),
          _buildSwitchTile(
            icon: Icons.alarm,
            title: "Reading Reminders",
            value: _readingReminders,
            onChanged: (val) async {
              setState(() => _readingReminders = val);
              await _prefsService.setReadingReminders(val);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    val ? 'Reading reminders enabled' : 'Reading reminders disabled',
                  ),
                  backgroundColor: AppColors.success,
                ),
              );
            },
          ),

          // PRIVACY SECTION
          _buildSectionHeader("PRIVACY & SECURITY"),
          _buildListTile(
            icon: Icons.lock_outline,
            title: "Privacy Settings",
            onTap: () {},
          ),
          _buildListTile(
            icon: Icons.block,
            title: "Blocked Users",
            onTap: () {},
          ),

          // SUPPORT SECTION
          _buildSectionHeader("SUPPORT"),
          _buildListTile(
            icon: Icons.help_outline,
            title: "Help Center",
            onTap: () {},
          ),
          _buildListTile(
            icon: Icons.support_agent,
            title: "Contact Support",
            onTap: () {},
          ),

          const SizedBox(height: 20),

          // LOG OUT BUTTON
          Container(
            color: AppColors.cardBackground,
            child: ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: const Text(
                "Log Out",
                style: TextStyle(
                  color: AppColors.error,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: _handleLogout,
            ),
          ),

          const SizedBox(height: 40),

          // App Version
          Center(
            child: Text(
              'BookMate v1.0.0',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// Show dialog to update reading goal (saved to SharedPreferences)
  void _showReadingGoalDialog() {
    int tempGoal = _readingGoal;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Monthly Reading Goal'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('How many books do you want to read per month?'),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          if (tempGoal > 1) setState(() => tempGoal--);
                        },
                        icon: const Icon(Icons.remove_circle_outline, size: 32),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$tempGoal',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          if (tempGoal < 50) setState(() => tempGoal++);
                        },
                        icon: const Icon(Icons.add_circle_outline, size: 32),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'books per month',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
                  onPressed: () async {
                    // Save to SharedPreferences
                    await _prefsService.setReadingGoal(tempGoal);

                    if (mounted) {
                      this.setState(() => _readingGoal = tempGoal);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Reading goal set to $tempGoal books/month'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    }
                  },
                  child: const Text('Save', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ==================== HELPER WIDGETS ====================

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? trailingText,
    required VoidCallback onTap,
  }) {
    return Container(
      color: AppColors.cardBackground,
      margin: const EdgeInsets.only(bottom: 1),
      child: ListTile(
        leading: Icon(icon, color: AppColors.textPrimary),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: AppColors.textPrimary,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (trailingText != null)
              Text(
                trailingText,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
            if (trailingText != null) const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: AppColors.grey),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      color: AppColors.cardBackground,
      margin: const EdgeInsets.only(bottom: 1),
      child: SwitchListTile(
        secondary: Icon(icon, color: AppColors.textPrimary),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: AppColors.textPrimary,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.accent,
      ),
    );
  }
}