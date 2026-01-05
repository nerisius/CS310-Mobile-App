import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/posts_provider.dart';
import '../models/post.dart';
import '../models/comment.dart';
import '../services/firestore_service.dart';

/// HomeScreen - Social feed showing posts from all users
///
/// Features:
/// - Real-time posts from Firestore
/// - Pull to refresh
/// - Create new posts
/// - Like/unlike posts
/// - Comment on posts
/// - Delete own posts
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.accent,
        title: const Text(
          'BookMate',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications coming soon!')),
              );
            },
          ),
        ],
      ),
      body: Consumer<PostsProvider>(
        builder: (context, postsProvider, child) {
          // Loading state
          if (postsProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error state
          if (postsProvider.state == PostsState.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(postsProvider.errorMessage ?? 'An error occurred'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => postsProvider.initPosts(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Empty state
          if (postsProvider.posts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.feed_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text(
                    'No posts yet',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Be the first to share your reading journey!',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // Posts list
          return RefreshIndicator(
            onRefresh: () async => postsProvider.initPosts(),
            child: ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: postsProvider.posts.length,
              itemBuilder: (context, index) {
                return _PostCard(
                  post: postsProvider.posts[index],
                  currentUserId: authProvider.userId,
                  currentUsername: authProvider.username,
                );
              },
            ),
          );
        },
      ),
      // Floating action button to create new post
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPostDialog(context),
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  /// Show dialog to create a new post
  void _showAddPostDialog(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final postsProvider = context.read<PostsProvider>();
    final contentController = TextEditingController();
    final bookTitleController = TextEditingController();
    String selectedType = 'progress';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Share Your Reading Update',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Activity type chips
                  Wrap(
                    spacing: 8,
                    children: ['progress', 'finished', 'started', 'quote'].map((type) {
                      return ChoiceChip(
                        label: Text(type[0].toUpperCase() + type.substring(1)),
                        selected: selectedType == type,
                        selectedColor: AppColors.accent,
                        labelStyle: TextStyle(
                          color: selectedType == type ? Colors.white : AppColors.textPrimary,
                        ),
                        onSelected: (selected) {
                          setState(() => selectedType = type);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Book title field
                  TextField(
                    controller: bookTitleController,
                    decoration: InputDecoration(
                      labelText: 'Book Title (optional)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Content field
                  TextField(
                    controller: contentController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'What\'s on your mind?',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Share button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () async {
                      if (contentController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please write something')),
                        );
                        return;
                      }

                      final success = await postsProvider.addPost(
                        content: contentController.text.trim(),
                        username: authProvider.username,
                        bookTitle: bookTitleController.text.trim().isNotEmpty
                            ? bookTitleController.text.trim()
                            : null,
                        activityType: selectedType,
                      );

                      if (success) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Post shared!'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      }
                    },
                    child: const Text(
                      'Share',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

/// Widget for displaying a single post
class _PostCard extends StatelessWidget {
  final Post post;
  final String? currentUserId;
  final String currentUsername;

  const _PostCard({
    required this.post,
    required this.currentUserId,
    required this.currentUsername,
  });

  /// Get activity text based on type
  String _getActivityText() {
    switch (post.activityType) {
      case 'finished':
        return 'finished reading "${post.bookTitle ?? 'a book'}"';
      case 'started':
        return 'started reading "${post.bookTitle ?? 'a book'}"';
      case 'quote':
        return 'shared a quote${post.bookTitle != null ? ' from "${post.bookTitle}"' : ''}';
      default:
        return post.bookTitle != null ? 'is reading "${post.bookTitle}"' : 'shared an update';
    }
  }

  /// Get time ago string
  String _getTimeAgo() {
    final diff = DateTime.now().difference(post.createdAt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${post.createdAt.day}/${post.createdAt.month}/${post.createdAt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final postsProvider = context.read<PostsProvider>();
    final isLiked = currentUserId != null && post.likes.contains(currentUserId);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                // User avatar
                CircleAvatar(
                  backgroundColor: AppColors.accent,
                  backgroundImage: post.userPhotoUrl != null
                      ? NetworkImage(post.userPhotoUrl!)
                      : null,
                  child: post.userPhotoUrl == null
                      ? Text(
                    post.username.isNotEmpty
                        ? post.username[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  )
                      : null,
                ),
                const SizedBox(width: 12),

                // Username and activity
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.username,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _getActivityText(),
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),

                // Time ago
                Text(
                  _getTimeAgo(),
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),

            // Content
            if (post.content.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(post.content),
            ],

            const SizedBox(height: 12),

            // Actions row
            Row(
              children: [
                // Like button
                InkWell(
                  onTap: () {
                    if (post.id != null) {
                      postsProvider.toggleLike(post.id!);
                    }
                  },
                  child: Row(
                    children: [
                      Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.redAccent : Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${post.likeCount}',
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),

                // Comment button - NOW FUNCTIONAL
                InkWell(
                  onTap: () => _showCommentsSheet(context),
                  child: Row(
                    children: [
                      const Icon(Icons.comment_outlined, color: Colors.grey, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '${post.commentCount}',
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Delete button (only for own posts)
                if (currentUserId == post.userId)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 20),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Delete Post'),
                          content: const Text('Are you sure you want to delete this post?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text(
                                'Delete',
                                style: TextStyle(color: AppColors.error),
                              ),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true && post.id != null) {
                        postsProvider.deletePost(post.id!);
                      }
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Show comments bottom sheet
  void _showCommentsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _CommentsSheet(
        post: post,
        currentUserId: currentUserId,
        currentUsername: currentUsername,
      ),
    );
  }
}

/// Bottom sheet for viewing and adding comments
class _CommentsSheet extends StatefulWidget {
  final Post post;
  final String? currentUserId;
  final String currentUsername;

  const _CommentsSheet({
    required this.post,
    required this.currentUserId,
    required this.currentUsername,
  });

  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  /// Add a new comment
  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;
    if (widget.currentUserId == null) return;

    setState(() => _isSubmitting = true);

    try {
      final comment = Comment(
        postId: widget.post.id!,
        userId: widget.currentUserId!,
        username: widget.currentUsername,
        content: _commentController.text.trim(),
      );

      await _firestoreService.addComment(comment);
      _commentController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Comment added!'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }

    setState(() => _isSubmitting = false);
  }

  /// Delete a comment
  Future<void> _deleteComment(Comment comment) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Comment'),
        content: const Text('Are you sure you want to delete this comment?'),
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

    if (confirm == true && comment.id != null) {
      await _firestoreService.deleteComment(comment.id!, widget.post.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
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
              children: [
                const Text(
                  'Comments',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Comments list
          Expanded(
            child: StreamBuilder<List<Comment>>(
              stream: _firestoreService.getCommentsStream(widget.post.id!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                final comments = snapshot.data ?? [];

                if (comments.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 12),
                        const Text(
                          'No comments yet',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Be the first to comment!',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    return _CommentTile(
                      comment: comment,
                      isOwn: comment.userId == widget.currentUserId,
                      onDelete: () => _deleteComment(comment),
                    );
                  },
                );
              },
            ),
          ),

          // Add comment input
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.accent,
                    child: Text(
                      widget.currentUsername.isNotEmpty
                          ? widget.currentUsername[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Text field
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: 'Write a comment...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Send button
                  _isSubmitting
                      ? const SizedBox(
                    width: 36,
                    height: 36,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : IconButton(
                    icon: Icon(Icons.send, color: AppColors.accent),
                    onPressed: _addComment,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Single comment tile
class _CommentTile extends StatelessWidget {
  final Comment comment;
  final bool isOwn;
  final VoidCallback onDelete;

  const _CommentTile({
    required this.comment,
    required this.isOwn,
    required this.onDelete,
  });

  String _getTimeAgo() {
    final diff = DateTime.now().difference(comment.createdAt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${comment.createdAt.day}/${comment.createdAt.month}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.accent,
            backgroundImage: comment.userPhotoUrl != null
                ? NetworkImage(comment.userPhotoUrl!)
                : null,
            child: comment.userPhotoUrl == null
                ? Text(
              comment.username.isNotEmpty
                  ? comment.username[0].toUpperCase()
                  : 'U',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            )
                : null,
          ),
          const SizedBox(width: 12),

          // Comment content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.username,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getTimeAgo(),
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment.content,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),

          // Delete button (only for own comments)
          if (isOwn)
            IconButton(
              icon: Icon(Icons.delete_outline, size: 18, color: Colors.grey[400]),
              onPressed: onDelete,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
}