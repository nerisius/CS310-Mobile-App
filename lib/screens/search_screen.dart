import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../providers/books_provider.dart';
import '../models/book.dart';

/// SearchScreen - Search books in user's library
///
/// Features:
/// - Search by title or author
/// - Shows search results from user's books
/// - Displays book status and progress
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Search',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
        ),
      ),
      body: Consumer<BooksProvider>(
        builder: (context, booksProvider, child) {
          final results = booksProvider.searchBooks(_query);

          Widget body;

          // Empty query state
          if (_query.trim().isEmpty) {
            body = Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text(
                    "Search your library",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Find books by title or author",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          // No results state
          else if (results.isEmpty) {
            body = Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text(
                    "No results found",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No books match "$_query"',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          // Results list
          else {
            body = ListView.separated(
              padding: const EdgeInsets.all(14),
              itemCount: results.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) => _BookSearchItem(book: results[i]),
            );
          }

          return Column(
            children: [
              // Search input
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
                child: TextField(
                  controller: _controller,
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: "Search books or authors...",
                    prefixIcon: Icon(Icons.search, color: AppColors.accent),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _controller.clear();
                        setState(() => _query = '');
                      },
                    )
                        : null,
                    filled: true,
                    fillColor: const Color(0xFFF2F3F6),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              // Results count
              if (_query.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    children: [
                      Text(
                        '${results.length} result${results.length == 1 ? '' : 's'}',
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 4),

              // Results body
              Expanded(child: body),
            ],
          );
        },
      ),
    );
  }
}

/// Search result item widget
class _BookSearchItem extends StatelessWidget {
  final Book book;

  const _BookSearchItem({required this.book});

  String _getStatusText(String status) {
    switch (status) {
      case 'reading':
        return 'Reading';
      case 'finished':
        return 'Finished';
      case 'planning':
        return 'Want to Read';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'reading':
        return Colors.blue;
      case 'finished':
        return AppColors.success;
      case 'planning':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEDEFF3)),
      ),
      child: Row(
        children: [
          // Book cover
          Container(
            width: 55,
            height: 75,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F3F6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: book.coverUrl != null
                ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                book.coverUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.menu_book,
                  color: AppColors.accent,
                  size: 28,
                ),
              ),
            )
                : Icon(Icons.menu_book, color: AppColors.accent, size: 28),
          ),

          const SizedBox(width: 12),

          // Book info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  book.author,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getStatusColor(book.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _getStatusText(book.status),
                        style: TextStyle(
                          fontSize: 10,
                          color: _getStatusColor(book.status),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    // Favorite icon
                    if (book.isFavorite) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.favorite, color: Colors.red, size: 14),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Progress
          Column(
            children: [
              Text(
                '${book.percentage}%',
                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.accent),
              ),
              const SizedBox(height: 4),
              Icon(Icons.chevron_right, color: AppColors.accent),
            ],
          ),
        ],
      ),
    );
  }
}