import 'package:batik_app/models/post.dart';
import 'package:flutter/material.dart';
import 'package:batik_app/services/comment_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:batik_app/services/like_service.dart';
import 'package:batik_app/widgets/comments_bottom_sheet.dart';

class PostCard extends StatefulWidget {
  const PostCard({
    super.key,
    required this.post,
    required this.index,
    required this.currentUserId,
  });

  final Post post;
  final String index;
  final String currentUserId;

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  int _currentPage = 0;
  final Map<int, bool> _expandedStates = {};
  bool _isLiked = false;
  int _likeCount = 0;
  int _commentCount = 0;
  bool _isLikeLoading = false;

  String timeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inDays < 30) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''} ago';
    }
  }

  @override
  void initState() {
    super.initState();
    _loadPostStats();
  }

  void _loadPostStats() async {
    if (widget.post.id != null) {
      final postId = widget.post.id!;
      final userId = widget.currentUserId;

      // Fetch like status and like count from Firestore
      final likeDoc =
          await FirebaseFirestore.instance
              .collection('posts')
              .doc(postId)
              .collection('likes')
              .doc(userId)
              .get();

      final likeCountSnap =
          await FirebaseFirestore.instance
              .collection('posts')
              .doc(postId)
              .collection('likes')
              .get();

      final commentCount = await CommentService().getCommentCount(postId);

      setState(() {
        _isLiked = likeDoc.exists;
        _likeCount = likeCountSnap.size;
        _commentCount = commentCount;
      });
    }
  }

  Future<void> _toggleLike() async {
    if (widget.post.id == null || _isLikeLoading) return;

    setState(() {
      _isLikeLoading = true;
    });

    try {
      final postId = widget.post.id!;
      final userId = widget.currentUserId;

      if (_isLiked) {
        await FirebaseFirestore.instance
            .collection('posts')
            .doc(postId)
            .collection('likes')
            .doc(userId)
            .delete();
      } else {
        await FirebaseFirestore.instance
            .collection('posts')
            .doc(postId)
            .collection('likes')
            .doc(userId)
            .set({'likedAt': FieldValue.serverTimestamp()});
      }

      // Refresh like status and count
      final likeDoc =
          await FirebaseFirestore.instance
              .collection('posts')
              .doc(postId)
              .collection('likes')
              .doc(userId)
              .get();

      final likeCountSnap =
          await FirebaseFirestore.instance
              .collection('posts')
              .doc(postId)
              .collection('likes')
              .get();

      setState(() {
        _isLiked = likeDoc.exists;
        _likeCount = likeCountSnap.size;
        _isLikeLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLikeLoading = false;
      });
    }
  }

  void _showComments() {
    if (widget.post.id == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => CommentsBottomSheet(
            postId: widget.post.id!,
            currentUserId: widget.currentUserId,
          ),
    ).then((_) {
      // Refresh comment count when bottom sheet closes
      setState(() async {
        _commentCount = await CommentService().getCommentCount(widget.post.id!);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    // TODO: get the real username
    final username = post.userId;
    final images = post.images ?? [];

    final currentCaption = post.caption;

    return Card(
      elevation: 0,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // profile icon + username
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.grey[300],
                  child: Text(
                    username.isNotEmpty ? username[0].toUpperCase() : '?',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  username,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          // Image carousel
          AspectRatio(
            aspectRatio: 1,
            child:
                (images.isNotEmpty)
                    ? Stack(
                      children: [
                        PageView.builder(
                          physics: const ClampingScrollPhysics(),
                          itemCount: images.length,
                          scrollDirection: Axis.horizontal,
                          onPageChanged: (index) {
                            setState(() {
                              _currentPage = index;
                            });
                          },
                          itemBuilder: (context, idx) {
                            final image = images[idx];
                            final imageUrl = image['imageUrl'] ?? '';
                            // TODO: change image type
                            final imageType = image['typeId'] ?? '';

                            return Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (_, __, ___) => const Center(
                                        child: Icon(Icons.broken_image),
                                      ),
                                  loadingBuilder: (context, child, progress) {
                                    if (progress == null) return child;
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  },
                                ),

                                if (imageType.isNotEmpty)
                                  Positioned(
                                    top: 8,
                                    left: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black54,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'Type: $imageType',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),

                        // Current page / total on top right corner
                        if (images.length > 1) ...[
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${_currentPage + 1}/${images.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),

                          // Bottom center dots indicator
                          Positioned(
                            bottom: 8,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(images.length, (index) {
                                return Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 3,
                                  ),
                                  width: _currentPage == index ? 10 : 6,
                                  height: _currentPage == index ? 10 : 6,
                                  decoration: BoxDecoration(
                                    color:
                                        _currentPage == index
                                            ? Colors.white
                                            : Colors.white54,
                                    shape: BoxShape.circle,
                                  ),
                                );
                              }),
                            ),
                          ),
                        ],
                      ],
                    )
                    : Container(
                      color: Colors.grey[300],
                      child: const Center(child: Icon(Icons.image, size: 50)),
                    ),
          ),

          // Like & Comment icons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _toggleLike,
                  child:
                      _isLikeLoading
                          ? const SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : Icon(
                            _isLiked ? Icons.favorite : Icons.favorite_border,
                            size: 28,
                            color: _isLiked ? Colors.red : null,
                          ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: _showComments,
                  child: const Icon(Icons.comment_outlined, size: 28),
                ),
              ],
            ),
          ),

          // Like and comment counts
          if (_likeCount > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_likeCount > 0)
                    Text(
                      '$_likeCount ${_likeCount == 1 ? 'like' : 'likes'}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                ],
              ),
            ),

          // Username + Caption
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxWidth = constraints.maxWidth;

                // Prepare TextPainter to measure the caption length
                final TextSpan textSpan = TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  children: [
                    TextSpan(
                      text: '$username ',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: currentCaption),
                  ],
                );

                final TextPainter textPainter = TextPainter(
                  text: textSpan,
                  maxLines: 1,
                  textDirection: TextDirection.ltr,
                );

                textPainter.layout(maxWidth: maxWidth);

                final isOverflow = textPainter.didExceedMaxLines;

                final isExpanded = _expandedStates[_currentPage] ?? false;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      maxLines: isExpanded ? null : 1,
                      overflow:
                          isExpanded
                              ? TextOverflow.visible
                              : TextOverflow.ellipsis,
                      text: textSpan,
                    ),
                    if (isOverflow)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _expandedStates[_currentPage] = !isExpanded;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            isExpanded ? 'less' : 'more',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          if (_commentCount > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_commentCount > 0)
                    GestureDetector(
                      onTap: _showComments,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          'View all $_commentCount ${_commentCount == 1 ? 'comment' : 'comments'}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    ),
                  // Then likes
                ],
              ),
            ),

          // Timestamp
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              post.createdAt != null ? timeAgo(post.createdAt!) : '',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
