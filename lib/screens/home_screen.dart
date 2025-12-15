import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/posts_provider.dart';
import '../models/post.dart';

/// HomeScreen - Social feed showing posts from all users
///
/// Features:
/// - Real-time posts from Firestore
/// - Pull to refresh
/// - Create new posts
/// - Like/unlike posts
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

  const _PostCard({required this.post, required this.currentUserId});

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
                      ? const Icon(Icons.person, color: Colors.white)
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

                // Comment button (placeholder)
                Row(
                  children: [
                    const Icon(Icons.comment_outlined, color: Colors.grey, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      '${post.commentCount}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
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
}