import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/post.dart';
import '../services/firestore_service.dart';

/// Possible states for posts
enum PostsState {
  initial,  // Not yet loaded
  loading,  // Currently loading
  loaded,   // Data loaded successfully
  error,    // Something went wrong
}

/// PostsProvider - Manages the social feed posts
///
/// This provider:
/// - Loads posts from Firestore in real-time
/// - Handles creating and deleting posts
/// - Handles liking and unliking posts
/// - Notifies the app when posts change
class PostsProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  // Current state
  PostsState _state = PostsState.initial;

  // List of all posts
  List<Post> _posts = [];

  // Error message if something goes wrong
  String? _errorMessage;

  // Current user's ID (needed for liking posts)
  String? _currentUserId;

  // Stream subscription for real-time updates
  StreamSubscription? _postsSubscription;

  // ==================== GETTERS ====================

  PostsState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == PostsState.loading;

  /// Get all posts
  List<Post> get posts => _posts;

  // ==================== INITIALIZE ====================

  /// Set the current user's ID
  ///
  /// This is needed to know which posts the user has liked
  void setCurrentUserId(String? userId) {
    _currentUserId = userId;
  }

  /// Initialize and start listening to posts
  ///
  /// Call this when the app starts or user logs in
  void initPosts() {
    // Cancel any existing subscription
    _postsSubscription?.cancel();

    _state = PostsState.loading;
    notifyListeners();

    // Listen to real-time updates from Firestore
    _postsSubscription = _firestoreService.getPostsStream().listen(
          (posts) {
        _posts = posts;
        _state = PostsState.loaded;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        _state = PostsState.error;
        _errorMessage = error.toString();
        notifyListeners();
      },
    );
  }

  // ==================== ADD POST ====================

  /// Create a new post
  ///
  /// Returns true if successful
  Future<bool> addPost({
    required String content,
    required String username,
    String? userPhotoUrl,
    String? bookTitle,
    String? bookAuthor,
    String activityType = 'progress',
  }) async {
    if (_currentUserId == null) return false;

    try {
      final post = Post(
        userId: _currentUserId!,
        username: username,
        userPhotoUrl: userPhotoUrl,
        content: content,
        bookTitle: bookTitle,
        bookAuthor: bookAuthor,
        activityType: activityType,
        createdBy: _currentUserId!,
      );

      await _firestoreService.addPost(post);
      // Real-time listener will automatically update the list
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ==================== DELETE POST ====================

  /// Delete a post
  ///
  /// Only the post owner should be able to delete
  Future<bool> deletePost(String postId) async {
    try {
      await _firestoreService.deletePost(postId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ==================== LIKE / UNLIKE ====================

  /// Like a post
  Future<bool> likePost(String postId) async {
    if (_currentUserId == null) return false;

    try {
      await _firestoreService.likePost(postId, _currentUserId!);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Unlike a post
  Future<bool> unlikePost(String postId) async {
    if (_currentUserId == null) return false;

    try {
      await _firestoreService.unlikePost(postId, _currentUserId!);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Toggle like status on a post
  ///
  /// If already liked, unlike. If not liked, like.
  Future<bool> toggleLike(String postId) async {
    if (_currentUserId == null) return false;

    // Find the post
    final post = _posts.firstWhere(
          (p) => p.id == postId,
      orElse: () => Post(userId: '', username: '', content: '', createdBy: ''),
    );

    if (post.likes.contains(_currentUserId)) {
      return await unlikePost(postId);
    } else {
      return await likePost(postId);
    }
  }

  /// Check if current user has liked a post
  bool isLikedByCurrentUser(String postId) {
    if (_currentUserId == null) return false;

    try {
      final post = _posts.firstWhere((p) => p.id == postId);
      return post.likes.contains(_currentUserId);
    } catch (e) {
      return false;
    }
  }

  // ==================== CLEAR ====================

  /// Clear all data (call on logout)
  void clear() {
    _postsSubscription?.cancel();
    _posts = [];
    _currentUserId = null;
    _state = PostsState.initial;
    _errorMessage = null;
    notifyListeners();
  }

  // ==================== CLEANUP ====================

  @override
  void dispose() {
    _postsSubscription?.cancel();
    super.dispose();
  }
}