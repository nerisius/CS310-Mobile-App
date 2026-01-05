// BookMate - A Social Reading App
// CS310 Mobile Application Development
// Step 3: Firebase Integration

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/books_provider.dart';
import 'providers/posts_provider.dart';

// Screens
import 'screens/decider_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/main_screen.dart';
import 'screens/settings_screen.dart';

// Utils
import 'utils/app_colors.dart';

/// Main entry point of the app
///
/// This file:
/// 1. Initializes Firebase
/// 2. Sets up MultiProvider (makes providers available to entire app)
/// 3. Defines all the routes (screens) in the app
void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (connects app to Firebase services)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Run the app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiProvider wraps the entire app
    // This makes AuthProvider, BooksProvider, and PostsProvider
    // available to ALL screens in the app
    return MultiProvider(
      providers: [
        // Auth provider - manages login state
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        // Books provider - manages user's book library
        ChangeNotifierProvider(create: (_) => BooksProvider()),

        // Posts provider - manages social feed
        ChangeNotifierProvider(create: (_) => PostsProvider()),
      ],
      child: MaterialApp(
        title: 'BookMate',
        debugShowCheckedModeBanner: false,

        // App theme
        theme: ThemeData(
          primaryColor: AppColors.primary,
          scaffoldBackgroundColor: AppColors.background,
          fontFamily: 'Inter',
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.accent,
            primary: AppColors.primary,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        // Starting screen - DeciderScreen decides where to go
        home: const LoginScreen(),

        // Named routes - allows navigation like: Navigator.pushNamed(context, '/login')
        routes: {
          '/decider': (context) => const DeciderScreen(),
          '/onboarding': (context) => const OnboardingScreen(),
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignupScreen(),
          '/home': (context) => const MainScreen(),
          '/settings': (context) => const SettingsScreen(),
        },
      ),
    );
  }
}