import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../providers/books_provider.dart';
import '../providers/auth_provider.dart';
import '../models/book.dart';
import '../services/google_books_service.dart';

/// LibraryScreen - Displays user's books from Firestore
///
/// Features:
/// - Real-time book list from Firestore
/// - Filter by: All, Reading, Finished, Favorites
/// - Search books in library
/// - Add new books from Google Books API
/// - Update reading progress
/// - Delete books
class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = ["All Books", "Reading", "Finished", "Favorites"];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Get filtered books based on selected filter and search query
  List<Book> _getFilteredBooks(BooksProvider booksProvider) {
    List<Book> books;
    switch (_selectedFilterIndex) {
      case 1:
        books = booksProvider.readingBooks;
        break;
      case 2:
        books = booksProvider.finishedBooks;
        break;
      case 3:
        books = booksProvider.favoriteBooks;
        break;
      default:
        books = booksProvider.books;
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      books = books.where((b) =>
      b.title.toLowerCase().contains(query) ||
          b.author.toLowerCase().contains(query)
      ).toList();
    }

    return books;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBackground,
      body: Consumer<BooksProvider>(
        builder: (context, booksProvider, child) {
          final displayedBooks = _getFilteredBooks(booksProvider);
          final readingBooks = booksProvider.readingBooks;

          // Loading state
          if (booksProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error state
          if (booksProvider.state == BooksState.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(booksProvider.errorMessage ?? 'An error occurred'),
                  ElevatedButton(
                    onPressed: () {
                      final authProvider = context.read<AuthProvider>();
                      if (authProvider.userId != null) {
                        booksProvider.initForUser(authProvider.userId!);
                      }
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "My Library",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _showAddBookBottomSheet(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text(
                          "Add Book",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Search Bar (for library)
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.inputFill,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) => setState(() => _searchQuery = value),
                      decoration: const InputDecoration(
                        hintText: "Search your library...",
                        hintStyle: TextStyle(color: AppColors.textSecondary),
                        prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Filter Chips
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _filters.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final isSelected = _selectedFilterIndex == index;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedFilterIndex = index),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : AppColors.cardBackground,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? AppColors.primary : AppColors.lightGrey,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                _filters[index],
                                style: TextStyle(
                                  color: isSelected ? AppColors.white : AppColors.textSecondary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Continue Reading Section
                  if ((_selectedFilterIndex == 0 || _selectedFilterIndex == 1) && readingBooks.isNotEmpty) ...[
                    const Text(
                      "Continue Reading",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 140,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: readingBooks.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 16),
                        itemBuilder: (context, index) => _ContinueReadingCard(
                          book: readingBooks[index],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],

                  // Book Grid
                  Text(
                    _filters[_selectedFilterIndex],
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Empty state
                  if (displayedBooks.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          children: [
                            Icon(Icons.library_books_outlined, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            const Text(
                              'No books found',
                              style: TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Add a book to get started!',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,          // Changed from 2 to 4 (more books per row)
                        childAspectRatio: 0.55,     // Adjusted ratio
                        crossAxisSpacing: 12,       // Smaller spacing
                        mainAxisSpacing: 16,        // Smaller spacing
                      ),
                      itemCount: displayedBooks.length,
                      itemBuilder: (context, index) => _BookGridItem(
                        book: displayedBooks[index],
                      ),
                    ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Show bottom sheet to add a new book with Google Books search
  void _showAddBookBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _AddBookBottomSheet(),
    );
  }
}

/// Bottom sheet for adding books with Google Books search
class _AddBookBottomSheet extends StatefulWidget {
  const _AddBookBottomSheet();

  @override
  State<_AddBookBottomSheet> createState() => _AddBookBottomSheetState();
}

class _AddBookBottomSheetState extends State<_AddBookBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  final GoogleBooksService _googleBooksService = GoogleBooksService();

  List<GoogleBook> _searchResults = [];
  bool _isSearching = false;
  bool _showManualEntry = false;

  // Manual entry controllers
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _pagesController = TextEditingController();
  String _selectedStatus = 'planning';

  @override
  void dispose() {
    _searchController.dispose();
    _titleController.dispose();
    _authorController.dispose();
    _pagesController.dispose();
    super.dispose();
  }

  /// Search for books using Google Books API
  Future<void> _searchBooks(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    final results = await _googleBooksService.searchBooks(query);

    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  /// Add a book from Google Books to user's library
  Future<void> _addGoogleBook(GoogleBook googleBook) async {
    final booksProvider = context.read<BooksProvider>();

    // Show status selection dialog
    final status = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add to Library'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              googleBook.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('Choose reading status:'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'planning'),
            child: const Text('Want to Read'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'reading'),
            child: const Text('Reading'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'finished'),
            child: const Text('Finished'),
          ),
        ],
      ),
    );

    if (status == null) return;

    final totalPages = googleBook.pageCount ?? 0;
    final success = await booksProvider.addBook(
      title: googleBook.title,
      author: googleBook.author,
      coverUrl: googleBook.coverUrl,
      totalPages: totalPages,
      // If finished, set readPages to totalPages (100%)
      readPages: status == 'finished' ? totalPages : 0,
      status: status,
    );

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${googleBook.title}" added to your library!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  /// Add book manually
  Future<void> _addManualBook() async {
    if (_titleController.text.isEmpty || _authorController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter title and author')),
      );
      return;
    }

    final booksProvider = context.read<BooksProvider>();
    final success = await booksProvider.addBook(
      title: _titleController.text.trim(),
      author: _authorController.text.trim(),
      totalPages: int.tryParse(_pagesController.text) ?? 0,
      status: _selectedStatus,
    );

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Book added!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Add Book',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => setState(() => _showManualEntry = !_showManualEntry),
                  child: Text(_showManualEntry ? 'Search Books' : 'Enter Manually'),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _showManualEntry ? _buildManualEntry() : _buildSearchView(),
          ),
        ],
      ),
    );
  }

  /// Build the search view with Google Books
  Widget _buildSearchView() {
    return Column(
      children: [
        // Search input
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Search books by title or author...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchResults = []);
                },
              )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: AppColors.inputFill,
            ),
            onChanged: (value) {
              // Debounce search
              Future.delayed(const Duration(milliseconds: 500), () {
                if (_searchController.text == value) {
                  _searchBooks(value);
                }
              });
            },
            onSubmitted: _searchBooks,
          ),
        ),

        const SizedBox(height: 16),

        // Results
        Expanded(
          child: _isSearching
              ? const Center(child: CircularProgressIndicator())
              : _searchResults.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  _searchController.text.isEmpty
                      ? 'Search for books to add'
                      : 'No books found',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final book = _searchResults[index];
              return _GoogleBookListItem(
                book: book,
                onAdd: () => _addGoogleBook(book),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Build manual entry form
  Widget _buildManualEntry() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Book Title *',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _authorController,
            decoration: InputDecoration(
              labelText: 'Author *',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _pagesController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Total Pages',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 12),

          DropdownButtonFormField<String>(
            value: _selectedStatus,
            decoration: InputDecoration(
              labelText: 'Status',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            items: const [
              DropdownMenuItem(value: 'planning', child: Text('Want to Read')),
              DropdownMenuItem(value: 'reading', child: Text('Currently Reading')),
              DropdownMenuItem(value: 'finished', child: Text('Finished')),
            ],
            onChanged: (value) => setState(() => _selectedStatus = value!),
          ),
          const SizedBox(height: 24),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _addManualBook,
            child: const Text(
              'Add Book',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

/// List item for Google Books search results
class _GoogleBookListItem extends StatelessWidget {
  final GoogleBook book;
  final VoidCallback onAdd;

  const _GoogleBookListItem({required this.book, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onAdd,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Book cover
              Container(
                width: 60,
                height: 90,
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: book.coverUrl != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    book.coverUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.book),
                  ),
                )
                    : Icon(Icons.menu_book, color: AppColors.accent),
              ),
              const SizedBox(width: 12),

              // Book info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book.author,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (book.pageCount != null)
                      Text(
                        '${book.pageCount} pages',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ),

              // Add button
              IconButton(
                icon: Icon(Icons.add_circle, color: AppColors.accent, size: 32),
                onPressed: onAdd,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Card for "Continue Reading" section
class _ContinueReadingCard extends StatelessWidget {
  final Book book;
  const _ContinueReadingCard({required this.book});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightGrey),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Book cover
          Container(
            width: 70,
            height: 100,
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
                errorBuilder: (_, __, ___) => const Icon(Icons.book),
              ),
            )
                : Icon(Icons.menu_book, color: AppColors.accent, size: 28),
          ),
          const SizedBox(width: 12),

          // Book info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  book.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  book.author,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${book.readPages}/${book.totalPages}",
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      "${book.percentage}%",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: book.progress,
                    backgroundColor: AppColors.lightGrey,
                    color: AppColors.primary,
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Grid item for displaying a book
class _BookGridItem extends StatelessWidget {
  final Book book;
  const _BookGridItem({required this.book});

  @override
  Widget build(BuildContext context) {
    final booksProvider = context.read<BooksProvider>();

    return GestureDetector(
      onTap: () => _showBookDetailsDialog(context, book),
      onLongPress: () => _showBookOptionsDialog(context, book, booksProvider),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Book cover
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Cover image or placeholder
                    book.coverUrl != null
                        ? Image.network(
                      book.coverUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.lightGrey,
                        child: const Icon(Icons.book, size: 40),
                      ),
                    )
                        : Container(
                      color: AppColors.lightGrey,
                      child: Icon(Icons.menu_book, size: 40, color: AppColors.accent),
                    ),

                    // Progress badge
                    if (book.isFinished || book.readPages > 0)
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "${book.percentage}%",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                    // Favorite badge
                    if (book.isFavorite)
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.favorite, color: Colors.red, size: 16),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Title
          Text(
            book.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 4),

          // Author
          Text(
            book.author,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),

          // Progress bar for reading books
          if (!book.isFinished && book.readPages > 0) ...[
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: book.progress,
                backgroundColor: AppColors.lightGrey,
                color: AppColors.primary,
                minHeight: 4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Show book details and update progress
  void _showBookDetailsDialog(BuildContext context, Book book) {
    final pagesController = TextEditingController(text: book.readPages.toString());

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                book.title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(book.author, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),
              Text(
                'Progress: ${book.readPages}/${book.totalPages} pages (${book.percentage}%)',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: pagesController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Update pages read',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  minimumSize: const Size.fromHeight(50),
                ),
                onPressed: () async {
                  final newPages = int.tryParse(pagesController.text) ?? book.readPages;
                  await context.read<BooksProvider>().updateProgress(book.id!, newPages);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Progress updated!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
                child: const Text('Update Progress', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  /// Show options for book (favorite, delete)
  void _showBookOptionsDialog(BuildContext context, Book book, BooksProvider booksProvider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Toggle favorite
              ListTile(
                leading: Icon(
                  book.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: Colors.red,
                ),
                title: Text(book.isFavorite ? 'Remove from Favorites' : 'Add to Favorites'),
                onTap: () {
                  booksProvider.toggleFavorite(book.id!, !book.isFavorite);
                  Navigator.pop(context);
                },
              ),

              // Delete book
              ListTile(
                leading: const Icon(Icons.delete_outline, color: AppColors.error),
                title: const Text('Delete Book'),
                onTap: () async {
                  Navigator.pop(context);
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Delete Book'),
                      content: Text('Are you sure you want to delete "${book.title}"?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Delete', style: TextStyle(color: AppColors.error)),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    booksProvider.deleteBook(book.id!);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}