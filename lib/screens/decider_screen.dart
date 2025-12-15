import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/books_provider.dart';
import '../providers/posts_provider.dart';
import '../services/preferences_service.dart';
import '../utils/app_colors.dart';

/// DeciderScreen - Decides which screen to show based on app state
///
/// This screen checks:
/// 1. Is this the first time opening the app? → Show Onboarding
/// 2. Is user logged in? → Show Home (MainScreen)
/// 3. Not logged in? → Show Login
///
/// This is the first screen that loads when app starts
class DeciderScreen extends StatefulWidget {
  const DeciderScreen({super.key});

  @override
  State<DeciderScreen> createState() => _DeciderScreenState();
}

class _DeciderScreenState extends State<DeciderScreen> {
  final PreferencesService _prefsService = PreferencesService();
  bool _isChecking = true;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _checkInitialRoute();
  }

  /// Check where to navigate based on app state
  Future<void> _checkInitialRoute() async {
    await _prefsService.init();

    // Check if first time opening app
    final isFirstTime = await _prefsService.isFirstTime();

    if (isFirstTime && mounted) {
      // First time - show onboarding
      Navigator.pushReplacementNamed(context, '/onboarding');
      return;
    }

    // Not first time - let the build method handle auth state
    if (mounted) {
      setState(() {
        _isChecking = false;
      });
    }
  }

  void _navigateBasedOnAuth(AuthProvider authProvider) {
    if (_hasNavigated) return;

    // Wait for auth to be ready
    if (authProvider.state == AuthState.initial) return;

    _hasNavigated = true;

    if (authProvider.isAuthenticated) {
      // Initialize providers for the logged-in user
      final userId = authProvider.userId;
      if (userId != null) {
        context.read<BooksProvider>().initForUser(userId);
        final postsProvider = context.read<PostsProvider>();
        postsProvider.setCurrentUserId(userId);
        postsProvider.initPosts();
      }

      // Navigate to home
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // Navigate to login
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading while checking first time status
    if (_isChecking) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.menu_book_rounded,
                size: 80,
                color: AppColors.accent,
              ),
              SizedBox(height: 24),
              Text(
                'BookMate',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accent,
                ),
              ),
              SizedBox(height: 24),
              CircularProgressIndicator(
                color: AppColors.accent,
              ),
            ],
          ),
        ),
      );
    }

    // Use Consumer to listen to auth state changes
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Schedule navigation after build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _navigateBasedOnAuth(authProvider);
        });

        // Show loading screen while deciding
        return const Scaffold(
          backgroundColor: AppColors.background,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.menu_book_rounded,
                  size: 80,
                  color: AppColors.accent,
                ),
                SizedBox(height: 24),
                Text(
                  'BookMate',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accent,
                  ),
                ),
                SizedBox(height: 24),
                CircularProgressIndicator(
                  color: AppColors.accent,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}