import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book.dart';
import '../models/post.dart';
import '../models/app_user.dart';
import '../models/comment.dart';

/// FirestoreService - Handles all Firestore database operations (CRUD)
///
/// CRUD means:
/// - Create: Add new data (addBook, addPost, addComment)
/// - Read: Get data (getBooksStream, getPostsStream, getCommentsStream)
/// - Update: Modify data (updateBook, updateBookProgress)
/// - Delete: Remove data (deleteBook, deletePost, deleteComment)
///
/// This service handles books, posts, comments, and user data
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== BOOKS ====================
  // Books are stored in: users/{userId}/books/{bookId}
  // Each user has their own collection of books

  /// Get real-time stream of user's books
  Stream<List<Book>> getBooksStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('books')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Book.fromFirestore(doc)).toList());
  }

  /// Get books filtered by status (reading, finished, planning)
  Stream<List<Book>> getBooksByStatusStream(String userId, String status) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('books')
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Book.fromFirestore(doc)).toList());
  }

  /// Get only favorite books
  Stream<List<Book>> getFavoriteBooksStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('books')
        .where('isFavorite', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Book.fromFirestore(doc)).toList());
  }

  /// Add a new book to user's library (CREATE)
  Future<String> addBook(String userId, Book book) async {
    final docRef = await _firestore
        .collection('users')
        .doc(userId)
        .collection('books')
        .add(book.toFirestore());
    return docRef.id;
  }

  /// Update an existing book (UPDATE)
  Future<void> updateBook(String userId, Book book) async {
    if (book.id == null) return;
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('books')
        .doc(book.id)
        .update(book.toFirestore());
  }

  /// Delete a book from user's library (DELETE)
  Future<void> deleteBook(String userId, String bookId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('books')
        .doc(bookId)
        .delete();
  }

  /// Update book reading progress (how many pages read)
  Future<void> updateBookProgress(String userId, String bookId, int readPages) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('books')
        .doc(bookId)
        .update({
      'readPages': readPages,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Toggle book favorite status
  Future<void> toggleFavorite(String userId, String bookId, bool isFavorite) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('books')
        .doc(bookId)
        .update({'isFavorite': isFavorite});
  }

  /// Update book status (reading, finished, planning)
  Future<void> updateBookStatus(String userId, String bookId, String status) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('books')
        .doc(bookId)
        .update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ==================== POSTS ====================
  // Posts are stored in: posts/{postId}
  // All users can see all posts (social feed)

  /// Get real-time stream of all posts (for home feed)
  Stream<List<Post>> getPostsStream() {
    return _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Post.fromFirestore(doc)).toList());
  }

  /// Get posts by a specific user
  Stream<List<Post>> getUserPostsStream(String userId) {
    return _firestore
        .collection('posts')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Post.fromFirestore(doc)).toList());
  }

  /// Add a new post (CREATE)
  Future<String> addPost(Post post) async {
    final docRef = await _firestore.collection('posts').add(post.toFirestore());
    return docRef.id;
  }

  /// Update a post (UPDATE)
  Future<void> updatePost(Post post) async {
    if (post.id == null) return;
    await _firestore.collection('posts').doc(post.id).update(post.toFirestore());
  }

  /// Delete a post (DELETE)
  Future<void> deletePost(String postId) async {
    // Also delete all comments for this post
    final comments = await _firestore
        .collection('comments')
        .where('postId', isEqualTo: postId)
        .get();

    for (var doc in comments.docs) {
      await doc.reference.delete();
    }

    await _firestore.collection('posts').doc(postId).delete();
  }

  /// Like a post (add user ID to likes array)
  Future<void> likePost(String postId, String userId) async {
    await _firestore.collection('posts').doc(postId).update({
      'likes': FieldValue.arrayUnion([userId]),
    });
  }

  /// Unlike a post (remove user ID from likes array)
  Future<void> unlikePost(String postId, String userId) async {
    await _firestore.collection('posts').doc(postId).update({
      'likes': FieldValue.arrayRemove([userId]),
    });
  }

  // ==================== COMMENTS ====================
  // Comments are stored in: comments/{commentId}
  // Each comment has a postId to link it to its post

  /// Get real-time stream of comments for a specific post
  Stream<List<Comment>> getCommentsStream(String postId) {
    return _firestore
        .collection('comments')
        .where('postId', isEqualTo: postId)
        .orderBy('createdAt', descending: false) // Oldest first
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Comment.fromFirestore(doc)).toList());
  }

  /// Get comment count for a post
  Future<int> getCommentCount(String postId) async {
    final snapshot = await _firestore
        .collection('comments')
        .where('postId', isEqualTo: postId)
        .count()
        .get();
    return snapshot.count ?? 0;
  }

  /// Add a new comment (CREATE)
  Future<String> addComment(Comment comment) async {
    final docRef = await _firestore.collection('comments').add(comment.toFirestore());

    // Update comment count on the post
    await _firestore.collection('posts').doc(comment.postId).update({
      'commentCount': FieldValue.increment(1),
    });

    return docRef.id;
  }

  /// Delete a comment (DELETE)
  Future<void> deleteComment(String commentId, String postId) async {
    await _firestore.collection('comments').doc(commentId).delete();

    // Update comment count on the post
    await _firestore.collection('posts').doc(postId).update({
      'commentCount': FieldValue.increment(-1),
    });
  }

  // ==================== USERS ====================

  /// Get real-time stream of user data
  Stream<AppUser?> getUserStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists ? AppUser.fromFirestore(doc) : null);
  }

  /// Get user data once (not real-time)
  Future<AppUser?> getUser(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    return doc.exists ? AppUser.fromFirestore(doc) : null;
  }

  /// Update user profile
  Future<void> updateUser(AppUser user) async {
    await _firestore.collection('users').doc(user.id).update(user.toFirestore());
  }

  /// Update user reading stats
  Future<void> updateUserStats(String userId, {int? booksRead, int? pagesRead}) async {
    final Map<String, dynamic> updates = {};
    if (booksRead != null) updates['booksRead'] = FieldValue.increment(booksRead);
    if (pagesRead != null) updates['pagesRead'] = FieldValue.increment(pagesRead);

    if (updates.isNotEmpty) {
      await _firestore.collection('users').doc(userId).update(updates);
    }
  }
}