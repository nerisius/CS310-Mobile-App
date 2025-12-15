import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/books_provider.dart';
import '../providers/posts_provider.dart';
import '../utils/app_colors.dart';

// Import all tab screens
import 'home_screen.dart';
import 'library_screen.dart';
import 'search_screen.dart';
import 'stats/stats_screen.dart';
import 'profile_screen.dart';

/// MainScreen - The main container with bottom navigation
///
/// This screen:
/// 1. Initializes providers when user logs in
/// 2. Contains 5 tabs: Home, Library, Search, Stats, Profile
/// 3. Uses IndexedStack to keep tab state when switching
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Current selected tab index
  int _currentIndex = 0;

  // List of tab screens
  final List<Widget> _screens = [
    const HomeScreen(),
    const LibraryScreen(),
    const SearchScreen(),
    const StatsScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Initialize providers after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeProviders();
    });
  }

  /// Initialize providers with user data
  /// Initialize providers with user data
  void _initializeProviders() {
    final authProvider = context.read<AuthProvider>();

    // DON'T redirect - providers are already initialized in login_screen
    // Just check if we need to initialize them again
    final userId = authProvider.userId;
    if (userId != null) {
      final booksProvider = context.read<BooksProvider>();
      final postsProvider = context.read<PostsProvider>();

      // Only initialize if not already initialized
      if (booksProvider.state == BooksState.initial) {
        booksProvider.initForUser(userId);
      }
      if (postsProvider.state == PostsState.initial) {
        postsProvider.setCurrentUserId(userId);
        postsProvider.initPosts();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack keeps all tabs in memory
      // So when you switch tabs, they don't reload
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.cardBackground,
          selectedItemColor: AppColors.accent,
          unselectedItemColor: AppColors.grey,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 12,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.library_books_outlined),
              activeIcon: Icon(Icons.library_books),
              label: 'Library',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search_outlined),
              activeIcon: Icon(Icons.search),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart),
              label: 'Stats',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}