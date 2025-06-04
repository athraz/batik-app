class Comment {
  final String? id;
  final String content;
  final String authorId;
  final String postId;
  final DateTime? createdAt;

  Comment({
    this.id,
    required this.content,
    required this.authorId,
    required this.postId,
    this.createdAt,
  });
}
