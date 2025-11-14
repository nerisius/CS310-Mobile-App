import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeciderScreen extends StatefulWidget {
  const DeciderScreen({super.key});

  @override
  State<DeciderScreen> createState() => _DeciderScreenState();
}

class _DeciderScreenState extends State<DeciderScreen> {
  @override
  void initState() {
    super.initState();
    _decideNextScreen();
  }

  Future<void> _decideNextScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool("seenOnboarding") ?? false;

    if (hasSeenOnboarding) {
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      Navigator.pushReplacementNamed(context, '/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Temporary loading screen while checking SharedPreferences
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
