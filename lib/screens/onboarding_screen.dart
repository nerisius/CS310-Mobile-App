import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';

class OnboardingScreen extends StatefulWidget{
  const OnboardingScreen({super.key});
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();

}

class _OnboardingScreenState extends State<OnboardingScreen>{
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'title': 'Welcome to BookMate',
      'description': 'Your personal reading companion for tracking books, sharing progress, and discovering your next great read.',
      'icon': Icons.auto_stories,
      'color': AppColors.accent,
    },
    {
      'title': 'Home Feed',
      'description': 'Share your reading journey with friends! Post updates, celebrate milestones, and get inspired by what others are reading.',
      'icon': Icons.home_rounded,
      'color': AppColors.accent,
    },
    {
      'title': 'Library',
      'description': 'Organize your entire book collection in one place. Track your reading progress, mark favorites, and never lose track of what to read next.',
      'icon': Icons.library_books_rounded,
      'color': AppColors.accent,
    },
    {
      'title': 'Search',
      'description': 'Discover millions of books and find your next favorite. Search by title, author, or genre and add them to your reading list instantly.',
      'icon': Icons.search_rounded,
      'color': AppColors.accent,
    },
    {
      'title': 'Stats',
      'description': 'Visualize your reading habits with beautiful charts. Track pages read, books completed, and watch your reading streak grow!',
      'icon': Icons.bar_chart_rounded,
      'color': AppColors.accent,
    },
    {
      'title': 'Profile',
      'description': 'Showcase your reading personality. Earn rosettes for achievements, build your reading lists, and connect with fellow book lovers.',
      'icon': Icons.person_rounded,
      'color': AppColors.accent,
    },
  ];

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTime', false);
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button (top right)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _finishOnboarding,
                  child: Text(
                    "Skip",
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            // Main PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon with gradient background
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.accent,
                                AppColors.primary,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accent.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Icon(
                            page['icon'] as IconData,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 50),

                        // Title
                        Text(
                          page['title']!,
                          style: AppTextStyles.heading1.copyWith(
                            color: AppColors.textPrimary,
                            fontSize: 28,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),

                        // Description
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            page['description']!,
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 16,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Indicator dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: _currentPage == index ? 24 : 8,
                  decoration: BoxDecoration(
                    gradient: _currentPage == index
                        ? LinearGradient(
                            colors: [AppColors.accent, AppColors.primary],
                          )
                        : null,
                    color: _currentPage == index ? null : AppColors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                );
              }),
            ),

            const SizedBox(height: 30),

            // Next / Get Started button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  shadowColor: AppColors.accent.withOpacity(0.4),
                ),
                onPressed: () {
                  if (_currentPage == _pages.length - 1) {
                    _finishOnboarding();
                  } else {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                      style: AppTextStyles.buttonText.copyWith(fontSize: 18),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      _currentPage == _pages.length - 1
                          ? Icons.check_circle_outline
                          : Icons.arrow_forward,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
