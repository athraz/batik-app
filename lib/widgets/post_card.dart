import 'package:batik_app/models/post.dart';
import 'package:flutter/material.dart';

class PostCard extends StatefulWidget {
  const PostCard({
    super.key,
    required this.post,
    required this.index,
  });

  final Post post;
  final String index;

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  int _currentPage = 0;
  final Map<int, bool> _expandedStates = {};

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
  Widget build(BuildContext context) {
    final post = widget.post;
    // TODO: get the real username
    final username = post.userId;
    final images = post.images ?? [];

    final currentCaption = post.caption;

    return Card(
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
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
            child: (images.isNotEmpty)
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
                                errorBuilder: (_, __, ___) =>
                                    const Center(child: Icon(Icons.broken_image)),
                                loadingBuilder: (context, child, progress) {
                                  if (progress == null) return child;
                                  return const Center(child: CircularProgressIndicator());
                                },
                              ),

                              if (imageType.isNotEmpty)
                                Positioned(
                                  top: 8,
                                  left: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Type: $imageType',
                                      style: const TextStyle(color: Colors.white, fontSize: 12),
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
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${_currentPage + 1}/${images.length}',
                              style: const TextStyle(color: Colors.white, fontSize: 12),
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
                                margin: const EdgeInsets.symmetric(horizontal: 3),
                                width: _currentPage == index ? 10 : 6,
                                height: _currentPage == index ? 10 : 6,
                                decoration: BoxDecoration(
                                  color: _currentPage == index ? Colors.white : Colors.white54,
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
              children: const [
                Icon(Icons.favorite_border, size: 28),
                SizedBox(width: 16),
                Icon(Icons.comment_outlined, size: 28),
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
                      overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
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
