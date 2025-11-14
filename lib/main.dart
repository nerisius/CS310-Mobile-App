import 'package:flutter/material.dart';
import 'screens/decider_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/signup.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      initialRoute: '/decider',
      routes: {
        '/decider': (context) => const DeciderScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup' : (context) => const SignScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
