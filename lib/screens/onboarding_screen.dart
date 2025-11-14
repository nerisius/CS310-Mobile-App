import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  Future<void> _finishOnboarding(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("seenOnboarding", true);

    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Onboarding")),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _finishOnboarding(context),
          child: const Text("Finish Onboarding → Login"),
        ),
      ),
    );
  }
}
