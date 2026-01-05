import 'dart:convert';
import 'package:http/http.dart' as http;

/// Model for a book from Google Books API
class GoogleBook {
  final String id;
  final String title;
  final String author;
  final String? description;
  final String? coverUrl;
  final int? pageCount;
  final String? publishedDate;
  final String? publisher;
  final List<String>? categories;

  GoogleBook({
    required this.id,
    required this.title,
    required this.author,
    this.description,
    this.coverUrl,
    this.pageCount,
    this.publishedDate,
    this.publisher,
    this.categories,
  });

  /// Create GoogleBook from API response
  factory GoogleBook.fromJson(Map<String, dynamic> json) {
    final volumeInfo = json['volumeInfo'] ?? {};
    final imageLinks = volumeInfo['imageLinks'] ?? {};

    // Get authors (can be a list)
    String author = 'Unknown Author';
    if (volumeInfo['authors'] != null && volumeInfo['authors'].isNotEmpty) {
      author = (volumeInfo['authors'] as List).join(', ');
    }

    // Get cover URL (prefer larger image)
    String? coverUrl = imageLinks['thumbnail'] ?? imageLinks['smallThumbnail'];
    // Convert http to https for security
    if (coverUrl != null && coverUrl.startsWith('http://')) {
      coverUrl = coverUrl.replaceFirst('http://', 'https://');
    }

    return GoogleBook(
      id: json['id'] ?? '',
      title: volumeInfo['title'] ?? 'Unknown Title',
      author: author,
      description: volumeInfo['description'],
      coverUrl: coverUrl,
      pageCount: volumeInfo['pageCount'],
      publishedDate: volumeInfo['publishedDate'],
      publisher: volumeInfo['publisher'],
      categories: volumeInfo['categories'] != null
          ? List<String>.from(volumeInfo['categories'])
          : null,
    );
  }
}

/// Service for searching books using Google Books API
///
/// Google Books API is FREE and doesn't require an API key for basic searches
/// Documentation: https://developers.google.com/books/docs/v1/using
class GoogleBooksService {
  static const String _baseUrl = 'https://www.googleapis.com/books/v1/volumes';

  /// Search for books by query (title, author, etc.)
  ///
  /// Returns a list of GoogleBook objects
  /// maxResults: number of results to return (max 40)
  Future<List<GoogleBook>> searchBooks(String query, {int maxResults = 20}) async {
    if (query.trim().isEmpty) {
      return [];
    }

    try {
      // Build the URL with query parameters
      final uri = Uri.parse(_baseUrl).replace(queryParameters: {
        'q': query,
        'maxResults': maxResults.toString(),
        'printType': 'books',
        'orderBy': 'relevance',
      });

      // Make the API request
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Check if there are any results
        if (data['totalItems'] == 0 || data['items'] == null) {
          return [];
        }

        // Parse the results
        final List<dynamic> items = data['items'];
        return items.map((item) => GoogleBook.fromJson(item)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  /// Search for books by title
  Future<List<GoogleBook>> searchByTitle(String title, {int maxResults = 20}) async {
    return searchBooks('intitle:$title', maxResults: maxResults);
  }

  /// Search for books by author
  Future<List<GoogleBook>> searchByAuthor(String author, {int maxResults = 20}) async {
    return searchBooks('inauthor:$author', maxResults: maxResults);
  }

  /// Search for books by ISBN
  Future<List<GoogleBook>> searchByIsbn(String isbn, {int maxResults = 10}) async {
    return searchBooks('isbn:$isbn', maxResults: maxResults);
  }

  /// Get book details by Google Books ID
  Future<GoogleBook?> getBookById(String bookId) async {
    try {
      final uri = Uri.parse('$_baseUrl/$bookId');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return GoogleBook.fromJson(data);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}