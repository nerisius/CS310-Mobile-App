import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import 'favourite_books_screen.dart';

/// book model
class BookItem {
  final String title;
  final String author;
  final String? coverUrl;
  final String filePath;

  BookItem({
    required this.title,
    required this.author,
    required this.filePath,
    this.coverUrl,
  });
}

/// Rosette/Badge modeli 
class RosetteItem {
  final String title;
  final IconData icon;
  final Color bg;

  RosetteItem({required this.title, required this.icon, required this.bg});
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ===== dummy user data =====
    const String username = "Ardıl"; // profil foto altında isim
    const String bio =
        "Electronics & Communication Eng. student.\nCaving, bouldering, metal & folk music.";

    const int readHistory = 12;
    const int readingNow = 3;
    const int wantToRead = 25;

    // monthly goal
    const int monthlyGoalTarget = 5;
    const int monthlyGoalDone = 2;
    final double monthlyProgress =
        monthlyGoalTarget == 0 ? 0 : monthlyGoalDone / monthlyGoalTarget;

    // rosettes dummy
    final rosettes = <RosetteItem>[
      RosetteItem(title: "1st Book", icon: Icons.auto_stories, bg: const Color(0xFFFFEFE6)),
      RosetteItem(title: "3-Day Streak", icon: Icons.local_fire_department, bg: const Color(0xFFFFF2F2)),
      RosetteItem(title: "Night Owl", icon: Icons.nightlight_round, bg: const Color(0xFFEFF4FF)),
      RosetteItem(title: "Explorer", icon: Icons.explore, bg: const Color(0xFFEFFFF6)),
    ];

    // favourite books dummy
    final favourites = <BookItem>[
      BookItem(title: "Atomic Habits", author: "James Clear", filePath: "x"),
      BookItem(title: "The Midnight Library", author: "Matt Haig", filePath: "y"),
      BookItem(title: "Dune", author: "Frank Herbert", filePath: "z"),
      BookItem(title: "Sapiens", author: "Yuval N. Harari", filePath: "w"),
    ];

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
            onPressed: () {
              // TODO: settings route
              // Navigator.pushNamed(context, "/settings");
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          children: [
            const SizedBox(height: 8),

            // ========== Profile header card ==========
            _Card(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 48,
                    backgroundColor: Color(0xFFEDEFF3),
                    child: Icon(Icons.person, size: 60, color: Colors.grey),
                    // TODO: real image:
                    // backgroundImage: NetworkImage(user.photoUrl),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    username,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    bio,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ========== Rosettes / Badges ==========
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
                        return Container(
                          width: 120,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: r.bg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE1E3E8)),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(r.icon, color: AppColors.accent),
                              const SizedBox(height: 6),
                              Text(
                                r.title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ========== Stats row ==========
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  Expanded(
                    child: _MiniStatChip(
                      label: "Read\nHistory",
                      value: readHistory.toString(),
                      onTap: () {
                        // TODO: history page
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MiniStatChip(
                      label: "Reading",
                      value: readingNow.toString(),
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MiniStatChip(
                      label: "Want\nto Read",
                      value: wantToRead.toString(),
                      onTap: () {},
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ========== Favourite books preview ==========
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(child: _SectionTitle("Favourite Books")),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  FavouriteBooksScreen(favourites: favourites),
                            ),
                          );
                        },
                        child: Text(
                          "See all",
                          style: TextStyle(color: AppColors.accent),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 150,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: favourites.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, i) {
                        final b = favourites[i];
                        return _BookThumb(book: b);
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ========== Monthly Reading Goal ==========
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionTitle("Monthly Reading Goal"),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        "$monthlyGoalDone / $monthlyGoalTarget books",
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: monthlyProgress.clamp(0, 1),
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
                    monthlyGoalDone >= monthlyGoalTarget
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

/// UI helpers  

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

class _MiniStatChip extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _MiniStatChip({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
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
      ),
    );
  }
}

class _BookThumb extends StatelessWidget {
  final BookItem book;
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
          Expanded(
            child: book.coverUrl == null
                ? Center(
                    child: Icon(Icons.menu_book,
                        color: AppColors.accent, size: 36),
                  )
                : ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Image.network(book.coverUrl!,
                        width: double.infinity, fit: BoxFit.cover),
                  ),
          ),
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
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700),
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
          )
        ],
      ),
    );
  }
}
