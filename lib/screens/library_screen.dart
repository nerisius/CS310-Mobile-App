import 'package:flutter/material.dart';

// --- Dummy Data Model for Library ---
class LibraryBook {
  final String title;
  final String author;
  final String coverUrl;
  final int totalPages;
  final int readPages;
  final bool isFinished;

  LibraryBook({
    required this.title,
    required this.author,
    required this.coverUrl,
    required this.totalPages,
    required this.readPages,
    this.isFinished = false,
  });

  double get progress => totalPages == 0 ? 0 : readPages / totalPages;
  int get percentage => (progress * 100).round();
}

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = ["All Books", "Reading", "Finished", "Favorites"];

  // Dummy Book Data
  final List<LibraryBook> _allBooks = [
    LibraryBook(
      title: "The Midnight Library",
      author: "Matt Haig",
      coverUrl: "https://m.media-amazon.com/images/I/71X0885M6HL._AC_UF1000,1000_QL80_.jpg",
      totalPages: 304,
      readPages: 152,
    ),
    LibraryBook(
      title: "Atomic Habits",
      author: "James Clear",
      coverUrl: "https://m.media-amazon.com/images/I/81wgcld4wxL.jpg",
      totalPages: 320,
      readPages: 240,
    ),
    LibraryBook(
      title: "Zero to One",
      author: "Peter Thiel",
      coverUrl: "https://m.media-amazon.com/images/I/71uAI28kJuL.jpg",
      totalPages: 224,
      readPages: 224,
      isFinished: true,
    ),
    LibraryBook(
      title: "Milk and Honey",
      author: "Rupi Kaur",
      coverUrl: "https://m.media-amazon.com/images/I/71e7d9FM8ZL.jpg",
      totalPages: 204,
      readPages: 102,
    ),
    LibraryBook(
      title: "The Great Gatsby",
      author: "F. Scott Fitzgerald",
      coverUrl: "https://m.media-amazon.com/images/I/71FTb9X6wsL.jpg",
      totalPages: 180,
      readPages: 0,
    ),
    LibraryBook(
      title: "1984",
      author: "George Orwell",
      coverUrl: "https://m.media-amazon.com/images/I/71rpa1-kyvL.jpg",
      totalPages: 328,
      readPages: 45,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    List<LibraryBook> displayedBooks = _allBooks;
    if (_selectedFilterIndex == 1) {
      displayedBooks = _allBooks.where((b) => !b.isFinished && b.readPages > 0).toList();
    } else if (_selectedFilterIndex == 2) {
      displayedBooks = _allBooks.where((b) => b.isFinished).toList();
    }

    final readingBooks = _allBooks.where((b) => !b.isFinished && b.readPages > 0).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "My Library",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B00),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    icon: const Icon(Icons.upload_file, size: 18),
                    label: const Text("Upload Book", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // --- Search Bar ---
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F6F8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const TextField(
                        decoration: InputDecoration(
                          hintText: "Search books or authors...",
                          hintStyle: TextStyle(color: Colors.grey),
                          prefixIcon: Icon(Icons.search, color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.filter_list, color: Colors.black87),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // --- Filter Chips ---
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final isSelected = _selectedFilterIndex == index;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedFilterIndex = index;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFFF6B00) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? const Color(0xFFFF6B00) : Colors.grey.shade300,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _filters[index],
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.grey.shade700,
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

              // --- "Continue Reading" Horizontal List ---
              // Only show if we are on "All Books" or "Reading" tab AND have data
              if ((_selectedFilterIndex == 0 || _selectedFilterIndex == 1) && readingBooks.isNotEmpty) ...[
                const Text(
                  "Continue Reading",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 140,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: readingBooks.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      return _buildContinueReadingCard(readingBooks[index]);
                    },
                  ),
                ),
                const SizedBox(height: 32),
              ],

              // --- Main Book Grid ---
              Text(
                _filters[_selectedFilterIndex],
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.65, // Adjusts height relative to width
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 24,
                ),
                itemCount: displayedBooks.length,
                itemBuilder: (context, index) {
                  return _buildBookGridItem(displayedBooks[index]);
                },
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildContinueReadingCard(LibraryBook book) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE1E3E8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Book Cover
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              book.coverUrl,
              width: 70,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Container(width: 70, height: 100, color: Colors.grey[300], child: const Icon(Icons.book)),
            ),
          ),
          const SizedBox(width: 12),
          // Details
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
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const Spacer(),
                // Progress Text
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${book.readPages}/${book.totalPages}",
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      "${book.percentage}%",
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFFF6B00)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: book.progress,
                    backgroundColor: const Color(0xFFEDEFF3),
                    color: const Color(0xFFFF6B00),
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

  Widget _buildBookGridItem(LibraryBook book) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black,
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
                  Image.network(
                    book.coverUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(color: Colors.grey[300], child: const Icon(Icons.book, size: 40)),
                  ),
                  // "100%" Badge if finished
                  if (book.isFinished)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B00),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          "100%",
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  // Percentage Badge if reading
                  if (!book.isFinished && book.readPages > 0)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B00),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "${book.percentage}%",
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          book.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          book.author,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        if(!book.isFinished) ...[
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: book.progress,
              backgroundColor: const Color(0xFFEDEFF3),
              color: Colors.black,
              minHeight: 4,
            ),
          ),
        ]
      ],
    );
  }
}