import 'package:cloud_firestore/cloud_firestore.dart';

class LikeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> likePost(String postId, String userId) async {
    await _firestore
        .collection('posts')
        .doc(postId)
        .collection('likes')
        .doc(userId)
        .set({'likedAt': FieldValue.serverTimestamp()});
  }

  Future<void> unlikePost(String postId, String userId) async {
    await _firestore
        .collection('posts')
        .doc(postId)
        .collection('likes')
        .doc(userId)
        .delete();
  }

  Future<bool> isPostLiked(String postId, String userId) async {
    final doc =
        await _firestore
            .collection('posts')
            .doc(postId)
            .collection('likes')
            .doc(userId)
            .get();
    return doc.exists;
  }
}
