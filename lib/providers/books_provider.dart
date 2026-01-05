import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/book.dart';
import '../services/firestore_service.dart';

/// Possible states for books
enum BooksState {
  initial,  // Not yet loaded
  loading,  // Currently loading
  loaded,   // Data loaded successfully
  error,    // Something went wrong
}

/// BooksProvider - Manages the user's book library
///
/// This provider:
/// - Loads books from Firestore in real-time
/// - Handles adding, updating, deleting books
/// - Provides filtered lists (favorites, reading, finished)
/// - Notifies the app when books change
class BooksProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  // Current state
  BooksState _state = BooksState.initial;

  // List of all user's books
  List<Book> _books = [];

  // Error message if something goes wrong
  String? _errorMessage;

  // Current user's ID
  String? _userId;

  // Stream subscription for real-time updates
  StreamSubscription? _booksSubscription;

  // ==================== GETTERS ====================

  BooksState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == BooksState.loading;

  /// Get all books
  List<Book> get books => _books;

  /// Get only favorite books
  List<Book> get favoriteBooks => _books.where((b) => b.isFavorite).toList();

  /// Get books currently being read
  List<Book> get readingBooks => _books.where((b) => b.status == 'reading').toList();

  /// Get finished books
  List<Book> get finishedBooks => _books.where((b) => b.status == 'finished').toList();

  /// Get books planned to read
  List<Book> get planningBooks => _books.where((b) => b.status == 'planning').toList();

  /// Get total number of books
  int get totalBooks => _books.length;

  /// Get total finished books count
  int get totalFinished => finishedBooks.length;

  /// Get total currently reading count
  int get totalReading => readingBooks.length;

  /// Get total pages read across all books
  int get totalPagesRead => _books.fold(0, (sum, book) => sum + book.readPages);

  // ==================== INITIALIZE ====================

  /// Initialize the provider for a specific user
  ///
  /// This starts listening to the user's books in real-time
  /// Call this when user logs in
  void initForUser(String userId) {
    // Cancel any existing subscription
    _booksSubscription?.cancel();

    _userId = userId;
    _state = BooksState.loading;
    notifyListeners();

    // Listen to real-time updates from Firestore
    _booksSubscription = _firestoreService.getBooksStream(userId).listen(
          (books) {
        _books = books;
        _state = BooksState.loaded;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        _state = BooksState.error;
        _errorMessage = error.toString();
        notifyListeners();
      },
    );
  }

  // ==================== ADD BOOK ====================

  /// Add a new book to the library
  ///
  /// Returns true if successful
  Future<bool> addBook({
    required String title,
    required String author,
    String? coverUrl,
    required int totalPages,
    int readPages = 0,
    String status = 'planning',
  }) async {
    if (_userId == null) return false;

    try {
      final book = Book(
        title: title,
        author: author,
        coverUrl: coverUrl,
        totalPages: totalPages,
        readPages: readPages,
        status: status,
        createdBy: _userId!,
      );

      await _firestoreService.addBook(_userId!, book);
      // Real-time listener will automatically update the list
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ==================== UPDATE BOOK ====================

  /// Update an existing book
  Future<bool> updateBook(Book book) async {
    if (_userId == null || book.id == null) return false;

    try {
      await _firestoreService.updateBook(_userId!, book);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Update book reading progress
  Future<bool> updateProgress(String bookId, int readPages) async {
    if (_userId == null) return false;

    try {
      await _firestoreService.updateBookProgress(_userId!, bookId, readPages);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Toggle book favorite status
  Future<bool> toggleFavorite(String bookId, bool isFavorite) async {
    if (_userId == null) return false;

    try {
      await _firestoreService.toggleFavorite(_userId!, bookId, isFavorite);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Update book status (reading, finished, planning)
  Future<bool> updateStatus(String bookId, String status) async {
    if (_userId == null) return false;

    try {
      await _firestoreService.updateBookStatus(_userId!, bookId, status);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ==================== DELETE BOOK ====================

  /// Delete a book from the library
  Future<bool> deleteBook(String bookId) async {
    if (_userId == null) return false;

    try {
      await _firestoreService.deleteBook(_userId!, bookId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ==================== HELPER METHODS ====================

  /// Get a specific book by ID
  Book? getBookById(String bookId) {
    try {
      return _books.firstWhere((b) => b.id == bookId);
    } catch (e) {
      return null;
    }
  }

  /// Search books by title or author
  List<Book> searchBooks(String query) {
    if (query.isEmpty) return _books;

    final lowerQuery = query.toLowerCase();
    return _books.where((book) =>
    book.title.toLowerCase().contains(lowerQuery) ||
        book.author.toLowerCase().contains(lowerQuery)
    ).toList();
  }

  /// Clear all data (call on logout)
  void clear() {
    _booksSubscription?.cancel();
    _books = [];
    _userId = null;
    _state = BooksState.initial;
    _errorMessage = null;
    notifyListeners();
  }

  // ==================== CLEANUP ====================

  @override
  void dispose() {
    _booksSubscription?.cancel();
    super.dispose();
  }
}