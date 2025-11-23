import 'monthly_data.dart';
import 'author_stats.dart';

class ReadingStats {
  final int pagesPerMonth;
  final double pagesChangePercent;
  final int booksPerMonth;
  final double booksChangePercent;
  final List<MonthlyData> monthlyData;
  final List<AuthorStats> topAuthors;

  ReadingStats({
    required this.pagesPerMonth,
    required this.pagesChangePercent,
    required this.booksPerMonth,
    required this.booksChangePercent,
    required this.monthlyData,
    required this.topAuthors,
  });
}
