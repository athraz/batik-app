
class Post {
  final String? id;
  final String caption;
  final String userId;
  final String? thumbnailUrl;
  final DateTime? createdAt;
  final List<Map<String, dynamic>>? images;

  Post({
    this.id,
    required this.caption,
    required this.userId,
    this.thumbnailUrl,
    this.createdAt,
    this.images,
  });
}
