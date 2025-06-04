import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/comment.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CommentService {
  final CollectionReference posts = FirebaseFirestore.instance.collection(
    'posts',
  );

  Future<List<Comment>> getComments(String postId) async {
    try {
      final commentsSnapshot =
          await posts
              .doc(postId)
              .collection('comments')
              .orderBy('createdAt', descending: false)
              .get();

      return commentsSnapshot.docs.map((doc) {
        final data = doc.data();
        return Comment(
          id: doc.id,
          content: data['content'],
          authorId: data['authorId'],
          postId: postId,
          createdAt:
              (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to load comments: $e');
    }
  }

  Future<Comment> addComment(String content, String postId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) throw Exception('No user logged in');
    final authorId = currentUser.uid;
    try {
      final commentData = {
        'content': content,
        'authorId': authorId,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      };

      final docRef = await posts
          .doc(postId)
          .collection('comments')
          .add(commentData);

      return Comment(
        id: docRef.id,
        content: content,
        authorId: authorId,
        postId: postId,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Failed to add comment: $e');
    }
  }

  Future<int> getCommentCount(String postId) async {
    try {
      final commentsSnapshot =
          await posts.doc(postId).collection('comments').get();

      return commentsSnapshot.docs.length;
    } catch (e) {
      throw Exception('Failed to get comment count: $e');
    }
  }

  // Stream version for real-time updates
  Stream<List<Comment>> getCommentsStream(String postId) {
    return posts
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return Comment(
              id: doc.id,
              content: data['content'],
              authorId: data['authorId'],
              postId: postId,
              createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
            );
          }).toList();
        });
  }
}
