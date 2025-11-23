import 'package:flutter/material.dart';
import 'screens/decider_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';
import 'screens/signup.dart';
import 'screens/stats/stats_screen.dart';
import 'utils/app_colors.dart';
import 'utils/app_text_styles.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BookMate',
      theme: ThemeData(
        fontFamily: AppTextStyles.primaryFont,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
        ),
        useMaterial3: true,
      ),
      initialRoute: '/decider',
      routes: {
        '/decider': (context) => const DeciderScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignScreen(),
        '/home': (context) => const MainScreen(),
        '/stats': (context) => const StatsScreen(),
      },
    );
  }
}
