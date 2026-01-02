import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/books_provider.dart';
import '../models/book.dart';
import '../services/preferences_service.dart';

/// Rosette/Badge model
class RosetteItem {
  final String title;
  final IconData icon;
  final Color bg;
  final bool unlocked;

  RosetteItem({
    required this.title,
    required this.icon,
    required this.bg,
    this.unlocked = false,
  });
}

/// ProfileScreen - Displays user profile with data from Firestore
///
/// Features:
/// - User info from Firebase Auth
/// - Reading stats from books collection
/// - Achievement rosettes
/// - Favorite books
/// - Monthly reading goal progress
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with WidgetsBindingObserver {
  final PreferencesService _prefsService = PreferencesService();
  int _readingGoal = 5;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadReadingGoal();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // FIX Issue 4: Reload reading goal when app resumes or screen is revisited
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadReadingGoal();
    }
  }

  // FIX Issue 4: Reload when returning to this screen
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadReadingGoal();
  }

  Future<void> _loadReadingGoal() async {
    await _prefsService.init();
    final goal = await _prefsService.getReadingGoal();
    if (mounted && goal != _readingGoal) {
      setState(() => _readingGoal = goal);
    }
  }

  /// Generate rosettes based on user's achievements
  List<RosetteItem> _generateRosettes(BooksProvider booksProvider) {
    final finished = booksProvider.finishedBooks.length;
    final totalBooks = booksProvider.books.length;

    return [
      RosetteItem(
        title: "1st Book",
        icon: Icons.auto_stories,
        bg: const Color(0xFFFFEFE6),
        unlocked: finished >= 1,
      ),
      RosetteItem(
        title: "5 Books",
        icon: Icons.library_books,
        bg: const Color(0xFFFFF2F2),
        unlocked: finished >= 5,
      ),
      RosetteItem(
        title: "Collector",
        icon: Icons.collections_bookmark,
        bg: const Color(0xFFEFF4FF),
        unlocked: totalBooks >= 10,
      ),
      RosetteItem(
        title: "Bookworm",
        icon: Icons.menu_book,
        bg: const Color(0xFFEFFFF6),
        unlocked: finished >= 10,
      ),
      RosetteItem(
        title: "Explorer",
        icon: Icons.explore,
        bg: const Color(0xFFFFFBE6),
        unlocked: booksProvider.favoriteBooks.length >= 3,
      ),
    ];
  }

  // FIX Issue 4: Navigate to settings and reload goal when returning
  Future<void> _navigateToSettings() async {
    await Navigator.pushNamed(context, "/settings");
    // Reload reading goal when returning from settings
    _loadReadingGoal();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final booksProvider = context.watch<BooksProvider>();

    // FIX Issue 3: Calculate finished books properly
    // This now correctly counts books with status 'finished'
    // INCLUDING those that were updated from 'reading' to 'finished'
    final totalFinished = booksProvider.finishedBooks.length;
    final totalReading = booksProvider.readingBooks.length;
    final totalPlanning = booksProvider.planningBooks.length;
    final favoriteBooks = booksProvider.favoriteBooks;

    // Monthly progress - use finished books count
    final monthlyProgress = _readingGoal > 0
        ? (totalFinished / _readingGoal).clamp(0.0, 1.0)
        : 0.0;

    // Generate rosettes
    final rosettes = _generateRosettes(booksProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        title: const Text(
          "Profile",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: AppColors.accent),
            // FIX Issue 4: Use new navigation method
            onPressed: _navigateToSettings,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          children: [
            const SizedBox(height: 8),

            // Profile Header Card
            _Card(
              child: Column(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: AppColors.accent,
                    child: Text(
                      authProvider.username.isNotEmpty
                          ? authProvider.username[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Username
                  Text(
                    authProvider.username,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),

                  // Email
                  Text(
                    authProvider.firebaseUser?.email ?? '',
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),

                  // Bio
                  if (authProvider.appUser?.bio != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      authProvider.appUser!.bio!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Rosettes / Badges
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionTitle("Rosettes"),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 92,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: rosettes.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, i) {
                        final r = rosettes[i];
                        return Opacity(
                          opacity: r.unlocked ? 1.0 : 0.4,
                          child: Container(
                            width: 100,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: r.bg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE1E3E8)),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  r.icon,
                                  color: r.unlocked ? AppColors.accent : Colors.grey,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  r.title,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: r.unlocked ? Colors.black : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Stats Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  Expanded(
                    child: _MiniStatChip(
                      label: "Finished",
                      value: totalFinished.toString(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MiniStatChip(
                      label: "Reading",
                      value: totalReading.toString(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MiniStatChip(
                      label: "Want\nto Read",
                      value: totalPlanning.toString(),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Favourite Books
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(child: _SectionTitle("Favourite Books")),
                      Text(
                        "${favoriteBooks.length} books",
                        style: TextStyle(color: AppColors.accent, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (favoriteBooks.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text(
                          "No favourite books yet",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    SizedBox(
                      height: 150,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: favoriteBooks.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, i) => _BookThumb(book: favoriteBooks[i]),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Monthly Reading Goal
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionTitle("Monthly Reading Goal"),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        "$totalFinished / $_readingGoal books",
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: monthlyProgress,
                            minHeight: 10,
                            backgroundColor: const Color(0xFFEDEFF3),
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    totalFinished >= _readingGoal
                        ? "Goal completed! 🎉"
                        : "Keep reading to reach your goal!",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card wrapper widget
class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

/// Section title widget
class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
    );
  }
}

/// Mini stat chip widget
class _MiniStatChip extends StatelessWidget {
  final String label;
  final String value;

  const _MiniStatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEDEFF3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}

/// Book thumbnail widget
class _BookThumb extends StatelessWidget {
  final Book book;
  const _BookThumb({required this.book});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFFF2F3F6),
        border: Border.all(color: const Color(0xFFE1E3E8)),
      ),
      child: Column(
        children: [
          // Cover
          Expanded(
            child: book.coverUrl != null
                ? ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                book.coverUrl!,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Center(
                  child: Icon(Icons.menu_book, color: AppColors.accent, size: 36),
                ),
              ),
            )
                : Center(
              child: Icon(Icons.menu_book, color: AppColors.accent, size: 36),
            ),
          ),

          // Info
          Container(
            padding: const EdgeInsets.all(8),
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  book.author,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}