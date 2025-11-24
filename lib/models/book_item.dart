/// Book model used across the application
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
