import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // State variables for toggles
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _friendActivity = false;
  bool _readingReminders = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context, '/home', (route) => false),
        ),
        title: const Text(
          "Settings",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        children: [
          // --- ACCOUNT SECTION ---
          _buildSectionHeader("ACCOUNT"),
          _buildListTile(
            icon: Icons.person_outline,
            title: "Account Settings",
            onTap: () {},
          ),
          _buildListTile(
            icon: Icons.language,
            title: "Language",
            trailingText: "English",
            onTap: () {},
          ),

          // --- NOTIFICATIONS SECTION ---
          _buildSectionHeader("NOTIFICATIONS"),
          _buildSwitchTile(
            icon: Icons.notifications_none,
            title: "Push Notifications",
            value: _pushNotifications,
            onChanged: (val) => setState(() => _pushNotifications = val),
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

          //READING SECTION
          _buildSectionHeader("READING"),
          _buildListTile(
            icon: Icons.track_changes,
            title: "Reading Challenge",
            trailingText: "24 books",
            onTap: () {},
          ),
          _buildSwitchTile(
            icon: Icons.dark_mode_outlined,
            title: "Reading Reminders",
            value: _readingReminders,
            onChanged: (val) => setState(() => _readingReminders = val),
          ),

          //PRIVACY SECTION
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

          //SUPPORT SECTION
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

          //LOG OUT BUTTON
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
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('isLoggedIn', false);

                if (!context.mounted) return;

                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (route) => false);
              },
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  //Helper Widgets

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
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 14),
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
        activeThumbColor: AppColors.accent,
      ),
    );
  }
}