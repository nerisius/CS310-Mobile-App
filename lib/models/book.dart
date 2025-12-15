import 'package:cloud_firestore/cloud_firestore.dart';

/// Book model for Firestore - represents a user's book in their library
/// This is different from book_item.dart - this one connects to Firebase
class Book {
  final String? id;           // Firestore document ID
  final String title;         // Book title
  final String author;        // Author name
  final String? coverUrl;     // Book cover image URL (optional)
  final int totalPages;       // Total pages in book
  final int readPages;        // Pages user has read
  final String status;        // 'reading', 'finished', or 'planning'
  final bool isFavorite;      // Is this a favorite book?
  final String createdBy;     // User ID who owns this book
  final DateTime createdAt;   // When book was added
  final DateTime? updatedAt;  // When book was last updated

  Book({
    this.id,
    required this.title,
    required this.author,
    this.coverUrl,
    required this.totalPages,
    this.readPages = 0,
    this.status = 'planning',
    this.isFavorite = false,
    required this.createdBy,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Calculate progress as decimal (0.0 to 1.0)
  double get progress => totalPages == 0 ? 0 : readPages / totalPages;

  // Calculate progress as percentage (0 to 100)
  int get percentage => (progress * 100).round();

  // Check if book is finished
  bool get isFinished => status == 'finished' || readPages >= totalPages;

  /// Convert Firestore document to Book object
  /// This is called when we READ data FROM Firebase
  factory Book.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Book(
      id: doc.id,
      title: data['title'] ?? '',
      author: data['author'] ?? '',
      coverUrl: data['coverUrl'],
      totalPages: data['totalPages'] ?? 0,
      readPages: data['readPages'] ?? 0,
      status: data['status'] ?? 'planning',
      isFavorite: data['isFavorite'] ?? false,
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Convert Book object to Firestore map
  /// This is called when we WRITE data TO Firebase
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'author': author,
      'coverUrl': coverUrl,
      'totalPages': totalPages,
      'readPages': readPages,
      'status': status,
      'isFavorite': isFavorite,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : FieldValue.serverTimestamp(),
    };
  }

  /// Create a copy of this book with some fields changed
  /// Useful for updating book data
  Book copyWith({
    String? id,
    String? title,
    String? author,
    String? coverUrl,
    int? totalPages,
    int? readPages,
    String? status,
    bool? isFavorite,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      coverUrl: coverUrl ?? this.coverUrl,
      totalPages: totalPages ?? this.totalPages,
      readPages: readPages ?? this.readPages,
      status: status ?? this.status,
      isFavorite: isFavorite ?? this.isFavorite,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}