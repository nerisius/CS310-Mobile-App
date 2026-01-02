import 'package:cloud_firestore/cloud_firestore.dart';

/// Comment model for Firestore - represents a comment on a post
class Comment {
  final String? id;           // Firestore document ID
  final String postId;        // ID of the post this comment belongs to
  final String userId;        // ID of user who wrote the comment
  final String username;      // Username to display
  final String? userPhotoUrl; // Profile photo URL (optional)
  final String content;       // Comment text
  final DateTime createdAt;   // When comment was created

  Comment({
    this.id,
    required this.postId,
    required this.userId,
    required this.username,
    this.userPhotoUrl,
    required this.content,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Convert Firestore document to Comment object
  factory Comment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Comment(
      id: doc.id,
      postId: data['postId'] ?? '',
      userId: data['userId'] ?? '',
      username: data['username'] ?? 'Unknown',
      userPhotoUrl: data['userPhotoUrl'],
      content: data['content'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert Comment object to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'postId': postId,
      'userId': userId,
      'username': username,
      'userPhotoUrl': userPhotoUrl,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}