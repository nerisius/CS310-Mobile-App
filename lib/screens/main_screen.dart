import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'stats/stats_screen.dart';
import '../utils/app_colors.dart';
import 'library_screen.dart';
import 'profile_screen.dart';
import 'search_screen.dart';
import '../models/book_item.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // Sample books for search screen
  final List<BookItem> _sampleBooks = [
    BookItem(
      title: 'The Midnight Library',
      author: 'Matt Haig',
      filePath: 'path1',
      coverUrl: 'https://covers.openlibrary.org/b/id/10909258-L.jpg',
    ),
    BookItem(
      title: 'Atomic Habits',
      author: 'James Clear',
      filePath: 'path2',
      coverUrl: 'https://covers.openlibrary.org/b/id/10677662-L.jpg',
    ),
    BookItem(
      title: 'Dune',
      author: 'Frank Herbert',
      filePath: 'path3',
      coverUrl: 'https://covers.openlibrary.org/b/id/12583597-L.jpg',
    ),
    BookItem(
      title: 'Sapiens',
      author: 'Yuval Noah Harari',
      filePath: 'path4',
      coverUrl: 'https://covers.openlibrary.org/b/id/8503016-L.jpg',
    ),
    BookItem(
      title: '1984',
      author: 'George Orwell',
      filePath: 'path5',
      coverUrl: 'https://covers.openlibrary.org/b/id/7222246-L.jpg',
    ),
    BookItem(
      title: 'To Kill a Mockingbird',
      author: 'Harper Lee',
      filePath: 'path6',
      coverUrl: 'https://covers.openlibrary.org/b/id/8228691-L.jpg',
    ),
  ];

  // List of screens for each tab
  late final List<Widget> _screens = [
    const HomeScreen(),
    const LibraryScreen(),
    SearchScreen(books: _sampleBooks),
    const StatsScreen(),
    const ProfileScreen(),
  ];
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Library',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Stats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// Placeholder screen for screens that haven't been implemented yet
class PlaceholderScreen extends StatelessWidget {
  final String title;

  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.accent,
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 64,
              color: AppColors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              '$title Screen',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Coming Soon',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
