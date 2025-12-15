import 'package:cloud_firestore/cloud_firestore.dart';

/// Post model for Firestore - represents a social feed post
/// Used in the Home screen to show what users are reading
class Post {
  final String? id;            // Firestore document ID
  final String userId;         // ID of user who created post
  final String username;       // Username to display
  final String? userPhotoUrl;  // Profile photo URL (optional)
  final String content;        // Post text content
  final String? bookTitle;     // Related book title (optional)
  final String? bookAuthor;    // Related book author (optional)
  final String activityType;   // 'finished', 'started', 'progress', 'quote'
  final List<String> likes;    // List of user IDs who liked this post
  final int commentCount;      // Number of comments
  final String createdBy;      // User ID (same as userId, required by assignment)
  final DateTime createdAt;    // When post was created

  Post({
    this.id,
    required this.userId,
    required this.username,
    this.userPhotoUrl,
    required this.content,
    this.bookTitle,
    this.bookAuthor,
    this.activityType = 'progress',
    this.likes = const [],
    this.commentCount = 0,
    required this.createdBy,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Check if a specific user liked this post
  bool isLikedBy(String oderId) => likes.contains(userId);

  /// Get total number of likes
  int get likeCount => likes.length;

  /// Convert Firestore document to Post object
  /// This is called when we READ data FROM Firebase
  factory Post.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Post(
      id: doc.id,
      userId: data['userId'] ?? '',
      username: data['username'] ?? 'Unknown',
      userPhotoUrl: data['userPhotoUrl'],
      content: data['content'] ?? '',
      bookTitle: data['bookTitle'],
      bookAuthor: data['bookAuthor'],
      activityType: data['activityType'] ?? 'progress',
      likes: List<String>.from(data['likes'] ?? []),
      commentCount: data['commentCount'] ?? 0,
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert Post object to Firestore map
  /// This is called when we WRITE data TO Firebase
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'username': username,
      'userPhotoUrl': userPhotoUrl,
      'content': content,
      'bookTitle': bookTitle,
      'bookAuthor': bookAuthor,
      'activityType': activityType,
      'likes': likes,
      'commentCount': commentCount,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Create a copy of this post with some fields changed
  Post copyWith({
    String? id,
    String? userId,
    String? username,
    String? userPhotoUrl,
    String? content,
    String? bookTitle,
    String? bookAuthor,
    String? activityType,
    List<String>? likes,
    int? commentCount,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return Post(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      content: content ?? this.content,
      bookTitle: bookTitle ?? this.bookTitle,
      bookAuthor: bookAuthor ?? this.bookAuthor,
      activityType: activityType ?? this.activityType,
      likes: likes ?? this.likes,
      commentCount: commentCount ?? this.commentCount,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}