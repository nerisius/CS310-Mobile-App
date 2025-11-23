import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_spacing.dart';
import '../../models/reading_stats.dart';
import '../../models/monthly_data.dart';
import '../../models/author_stats.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int _selectedTabIndex = 0;
  final List<String> _tabLabels = ['This Month', 'This Year', 'All'];

  // Sample data - will be replaced with actual data later
  late ReadingStats _stats;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  void _loadStats() {
    // Sample data based on selected tab
    _stats = ReadingStats(
      pagesPerMonth: 1250,
      pagesChangePercent: 15.5,
      booksPerMonth: 4,
      booksChangePercent: -8.2,
      monthlyData: _getMonthlyData(),
      topAuthors: _getTopAuthors(),
    );
  }

  List<MonthlyData> _getMonthlyData() {
    if (_selectedTabIndex == 0) {
      // This Month - daily data
      return [
        MonthlyData(month: 'W1', bookCount: 1, pageCount: 250),
        MonthlyData(month: 'W2', bookCount: 2, pageCount: 400),
        MonthlyData(month: 'W3', bookCount: 1, pageCount: 300),
        MonthlyData(month: 'W4', bookCount: 0, pageCount: 300),
      ];
    } else if (_selectedTabIndex == 1) {
      // This Year - monthly data
      return [
        MonthlyData(month: 'Jan', bookCount: 3, pageCount: 850),
        MonthlyData(month: 'Feb', bookCount: 5, pageCount: 1200),
        MonthlyData(month: 'Mar', bookCount: 4, pageCount: 1100),
        MonthlyData(month: 'Apr', bookCount: 6, pageCount: 1450),
        MonthlyData(month: 'May', bookCount: 3, pageCount: 900),
        MonthlyData(month: 'Jun', bookCount: 7, pageCount: 1600),
        MonthlyData(month: 'Jul', bookCount: 5, pageCount: 1300),
        MonthlyData(month: 'Aug', bookCount: 4, pageCount: 1050),
        MonthlyData(month: 'Sep', bookCount: 6, pageCount: 1400),
        MonthlyData(month: 'Oct', bookCount: 5, pageCount: 1250),
        MonthlyData(month: 'Nov', bookCount: 4, pageCount: 1100),
        MonthlyData(month: 'Dec', bookCount: 2, pageCount: 600),
      ];
    } else {
      // All time - yearly data
      return [
        MonthlyData(month: '2020', bookCount: 35, pageCount: 10500),
        MonthlyData(month: '2021', bookCount: 42, pageCount: 12600),
        MonthlyData(month: '2022', bookCount: 48, pageCount: 14400),
        MonthlyData(month: '2023', bookCount: 52, pageCount: 15600),
        MonthlyData(month: '2024', bookCount: 45, pageCount: 13500),
      ];
    }
  }

  List<AuthorStats> _getTopAuthors() {
    return [
      AuthorStats(
        id: '1',
        name: 'J.K. Rowling',
        avatarUrl: 'https://i.pravatar.cc/150?img=1',
        bookCount: 7,
      ),
      AuthorStats(
        id: '2',
        name: 'Stephen King',
        avatarUrl: 'https://i.pravatar.cc/150?img=2',
        bookCount: 5,
      ),
      AuthorStats(
        id: '3',
        name: 'Agatha Christie',
        avatarUrl: 'https://i.pravatar.cc/150?img=3',
        bookCount: 4,
      ),
      AuthorStats(
        id: '4',
        name: 'Dan Brown',
        avatarUrl: 'https://i.pravatar.cc/150?img=4',
        bookCount: 3,
      ),
      AuthorStats(
        id: '5',
        name: 'Haruki Murakami',
        avatarUrl: 'https://i.pravatar.cc/150?img=5',
        bookCount: 3,
      ),
    ];
  }

  void _onTabChanged(int index) {
    setState(() {
      _selectedTabIndex = index;
      _loadStats();
    });
  }

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
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
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

                  // Stat Cards Row
                  _buildStatCardsRow(isTablet),

                  AppSpacing.verticalLarge,

                  // Chart Section
                  _buildChartSection(),

                  AppSpacing.verticalLarge,

                  // Top Authors Section
                  _buildTopAuthorsSection(),

                  AppSpacing.verticalLarge,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

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
              onTap: () => _onTabChanged(index),
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

  Widget _buildStatCardsRow(bool isTablet) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            label: 'Pages p/m',
            value: _stats.pagesPerMonth.toString(),
            changePercent: _stats.pagesChangePercent,
            isTablet: isTablet,
          ),
        ),
        AppSpacing.horizontalMedium,
        Expanded(
          child: _buildStatCard(
            label: 'Books p/m',
            value: _stats.booksPerMonth.toString(),
            changePercent: _stats.booksChangePercent,
            isTablet: isTablet,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required double changePercent,
    required bool isTablet,
  }) {
    final isPositive = changePercent >= 0;
    final changeColor = isPositive ? AppColors.success : AppColors.error;

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
              fontSize: isTablet ? 36 : 32,
            ),
          ),
          AppSpacing.verticalSmall,
          Row(
            children: [
              Icon(
                isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                color: changeColor,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                '${changePercent.abs().toStringAsFixed(1)}%',
                style: AppTextStyles.statChange.copyWith(color: changeColor),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  'vs last period',
                  style: AppTextStyles.caption,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection() {
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
          Padding(
            padding: const EdgeInsets.only(left: 45), // Align with chart's y-axis
            child: Text(
              'Books Read Over Time',
              style: AppTextStyles.heading3,
            ),
          ),
          AppSpacing.verticalMedium,
          SizedBox(
            height: 200,
            child: _buildLineChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildLineChart() {
    final spots = _stats.monthlyData.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.bookCount.toDouble());
    }).toList();

    final maxY = _stats.monthlyData
        .map((e) => e.bookCount)
        .reduce((a, b) => a > b ? a : b)
        .toDouble();

    // Calculate proper maxY based on interval to avoid overlapping labels
    final interval = _selectedTabIndex == 2 ? 10.0 : 1.0;
    final calculatedMaxY = ((maxY / interval).ceil() + 1) * interval;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: interval, // Match interval with y-axis labels
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppColors.lightGrey,
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 &&
                    value.toInt() < _stats.monthlyData.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      _stats.monthlyData[value.toInt()].month,
                      style: AppTextStyles.caption.copyWith(
                        fontSize: _selectedTabIndex == 2 ? 10 : 12,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: interval,
              reservedSize: 45, // Consistent reserved size
              getTitlesWidget: (value, meta) {
                return Container(
                  width: 45,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(
                    value.toInt().toString(),
                    style: AppTextStyles.caption.copyWith(
                      fontSize: _selectedTabIndex == 2 ? 11 : 12,
                    ),
                    textAlign: TextAlign.right,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (_stats.monthlyData.length - 1).toDouble(),
        minY: 0,
        maxY: calculatedMaxY, // Use properly calculated maxY
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            gradient: const LinearGradient(
              colors: [
                AppColors.chartLine,
                AppColors.chartLine,
              ],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: AppColors.white,
                  strokeWidth: 2,
                  strokeColor: AppColors.chartLine,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppColors.chartGradientStart.withOpacity(0.3),
                  AppColors.chartGradientEnd.withOpacity(0.1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                final flSpot = barSpot;
                return LineTooltipItem(
                  '${flSpot.y.toInt()} books',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTopAuthorsSection() {
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
          Text(
            'Top Authors',
            style: AppTextStyles.heading3,
          ),
          AppSpacing.verticalMedium,
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _stats.topAuthors.length,
            separatorBuilder: (context, index) => Divider(
              height: AppSpacing.md * 2,
              color: AppColors.lightGrey,
            ),
            itemBuilder: (context, index) {
              final author = _stats.topAuthors[index];
              return _buildAuthorItem(author);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAuthorItem(AuthorStats author) {
    return Row(
      children: [
        // Author Avatar
        CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.lightGrey,
          backgroundImage: NetworkImage(author.avatarUrl),
          onBackgroundImageError: (exception, stackTrace) {
            // Fallback handled by backgroundColor
          },
          child: const Icon(Icons.person, color: AppColors.grey),
        ),
        AppSpacing.horizontalMedium,

        // Author Name
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                author.name,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${author.bookCount} ${author.bookCount == 1 ? 'book' : 'books'}',
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ),

        // Book Count Badge
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
          ),
          child: Text(
            '${author.bookCount}',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.accent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
