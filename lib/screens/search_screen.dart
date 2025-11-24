import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../models/book_item.dart';

class SearchScreen extends StatefulWidget {
  /// Import edilen pdf/epub kitapların listesi buradan gelecek.
  final List<BookItem> books;

  const SearchScreen({super.key, required this.books});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';

  List<BookItem> get _filteredBooks {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return widget.books;

    return widget.books.where((b) {
      return b.title.toLowerCase().contains(q) ||
          b.author.toLowerCase().contains(q);
    }).toList();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = _query.trim();
    final results = _filteredBooks;

    Widget body;
    if (q.isEmpty) {
      body = const Center(
        child: Text(
          "Search by title or author",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    } else if (results.isEmpty) {
      body = const Center(
        child: Text(
          "No results found",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    } else {
      body = ListView.separated(
        padding: const EdgeInsets.all(14),
        itemCount: results.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final b = results[i];
          return Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFEDEFF3)),
            ),
            child: Row(
              children: [
                // kapak
                Container(
                  width: 55,
                  height: 75,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F3F6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: b.coverUrl == null
                      ? Icon(Icons.menu_book,
                          color: AppColors.accent, size: 28)
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            b.coverUrl!,
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
                const SizedBox(width: 12),

                // title + author
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        b.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        b.author,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                Icon(Icons.chevron_right, color: AppColors.accent),
              ],
            ),
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Search',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // arama barı
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
            child: TextField(
              controller: _controller,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: "Search books or authors...",
                prefixIcon: Icon(Icons.search, color: AppColors.accent),
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
          const SizedBox(height: 4),
          Expanded(child: body),
        ],
      ),
    );
  }
}

