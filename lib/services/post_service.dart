import 'package:cloud_firestore/cloud_firestore.dart';

class PostService {
  final CollectionReference posts = FirebaseFirestore.instance.collection('posts');

  Stream<List<Map<String, dynamic>>> getPostsStream() {
    return posts.orderBy('createdAt', descending: true).snapshots().asyncMap(
      (QuerySnapshot snapshot) async {
        final List<Map<String, dynamic>> postsWithImages = [];

        for (var postDoc in snapshot.docs) {
          final postData = postDoc.data() as Map<String, dynamic>;

          final imagesSnapshot = await postDoc.reference.collection('images').orderBy('number', descending: false).get();
          final images = imagesSnapshot.docs.map((doc) => doc.data()).toList();

          postsWithImages.add({
            'postId': postDoc.id,
            ...postData,
            'images': images,
          });
        }

        return postsWithImages;
      },
    );
  }
}