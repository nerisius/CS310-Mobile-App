import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_spacing.dart';
import '../../providers/books_provider.dart';

/// StatsScreen - Displays reading statistics with charts
///
/// Features:
/// - Time filter tabs (This Month, This Year, All)
/// - Stats cards (Total Books, Finished, Pages Read, Reading Now)
/// - Pie chart showing books by status
/// - Top authors list
/// - All data comes from BooksProvider (Firestore)
class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int _selectedTabIndex = 0;
  final List<String> _tabLabels = ['This Month', 'This Year', 'All'];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.accent,
        title: const Text(
          'Reading Stats',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer<BooksProvider>(
        builder: (context, booksProvider, child) {
          // Calculate stats from actual Firestore data
          final totalBooks = booksProvider.books.length;
          final finishedBooks = booksProvider.finishedBooks.length;
          final totalPagesRead = booksProvider.totalPagesRead;
          final readingNow = booksProvider.readingBooks.length;

          // Get top authors
          final authorCounts = <String, int>{};
          for (var book in booksProvider.books) {
            authorCounts[book.author] = (authorCounts[book.author] ?? 0) + 1;
          }
          final topAuthors = authorCounts.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Time Filter Tabs
                _buildTimeFilterTabs(),

                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? AppSpacing.xl : AppSpacing.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppSpacing.verticalMedium,

                      // Stat Cards Row 1
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              label: 'Total Books',
                              value: totalBooks.toString(),
                              isTablet: isTablet,
                            ),
                          ),
                          AppSpacing.horizontalMedium,
                          Expanded(
                            child: _buildStatCard(
                              label: 'Finished',
                              value: finishedBooks.toString(),
                              isTablet: isTablet,
                            ),
                          ),
                        ],
                      ),

                      AppSpacing.verticalMedium,

                      // Stat Cards Row 2
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              label: 'Pages Read',
                              value: totalPagesRead.toString(),
                              isTablet: isTablet,
                            ),
                          ),
                          AppSpacing.horizontalMedium,
                          Expanded(
                            child: _buildStatCard(
                              label: 'Reading Now',
                              value: readingNow.toString(),
                              isTablet: isTablet,
                            ),
                          ),
                        ],
                      ),

                      AppSpacing.verticalLarge,

                      // Chart Section
                      if (booksProvider.books.isNotEmpty)
                        _buildChartSection(booksProvider),

                      AppSpacing.verticalLarge,

                      // Top Authors Section
                      if (topAuthors.isNotEmpty)
                        _buildTopAuthorsSection(topAuthors.take(5).toList()),

                      AppSpacing.verticalLarge,
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Build time filter tabs
  Widget _buildTimeFilterTabs() {
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: List.generate(_tabLabels.length, (index) {
          final isSelected = _selectedTabIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTabIndex = index),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                margin: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.accent : AppColors.background,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                ),
                child: Text(
                  _tabLabels[index],
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isSelected ? AppColors.white : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  /// Build stat card
  Widget _buildStatCard({
    required String label,
    required String value,
    required bool isTablet,
  }) {
    return Container(
      padding: EdgeInsets.all(isTablet ? AppSpacing.lg : AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.statLabel),
          AppSpacing.verticalSmall,
          Text(
            value,
            style: AppTextStyles.statValue.copyWith(
              fontSize: isTablet ? 36 : 28,
              color: AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }

  /// Build pie chart section
  Widget _buildChartSection(BooksProvider booksProvider) {
    // Create chart data from books
    final reading = booksProvider.readingBooks.length.toDouble();
    final finished = booksProvider.finishedBooks.length.toDouble();
    final planning = booksProvider.planningBooks.length.toDouble();

    // Don't show chart if all values are 0
    if (reading == 0 && finished == 0 && planning == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Books by Status', style: AppTextStyles.heading3),
          AppSpacing.verticalMedium,
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: [
                  if (reading > 0)
                    PieChartSectionData(
                      value: reading,
                      color: Colors.blue,
                      title: 'Reading\n${reading.toInt()}',
                      radius: 60,
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  if (finished > 0)
                    PieChartSectionData(
                      value: finished,
                      color: AppColors.success,
                      title: 'Done\n${finished.toInt()}',
                      radius: 60,
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  if (planning > 0)
                    PieChartSectionData(
                      value: planning,
                      color: Colors.orange,
                      title: 'Plan\n${planning.toInt()}',
                      radius: 60,
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
                centerSpaceRadius: 40,
                sectionsSpace: 2,
              ),
            ),
          ),

          // Legend
          AppSpacing.verticalMedium,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Reading', Colors.blue),
              const SizedBox(width: 16),
              _buildLegendItem('Finished', AppColors.success),
              const SizedBox(width: 16),
              _buildLegendItem('Planning', Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  /// Build legend item for chart
  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  /// Build top authors section
  Widget _buildTopAuthorsSection(List<MapEntry<String, int>> topAuthors) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Top Authors', style: AppTextStyles.heading3),
          AppSpacing.verticalMedium,
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: topAuthors.length,
            separatorBuilder: (_, __) => Divider(
              height: AppSpacing.md * 2,
              color: AppColors.lightGrey,
            ),
            itemBuilder: (context, index) {
              final author = topAuthors[index];
              return Row(
                children: [
                  // Rank circle
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.accent.withOpacity(0.1),
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  AppSpacing.horizontalMedium,

                  // Author info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          author.key,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${author.value} ${author.value == 1 ? 'book' : 'books'}',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),

                  // Book count badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                    ),
                    child: Text(
                      '${author.value}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.accent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}