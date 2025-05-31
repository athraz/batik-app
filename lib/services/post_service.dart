import 'dart:io';

import 'package:batik_app/models/post.dart';
import 'package:batik_app/services/image_service.dart';
import 'package:batik_app/services/type_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PostService {
  final CollectionReference posts = FirebaseFirestore.instance.collection('posts');

  Future<String> addPost(Post post, List<File> imageFiles) async {
    List<Map<String, dynamic>> imageDataList = [];
    for (int i = 0; i < imageFiles.length; i++) {
      File imageFile = imageFiles[i];

      String? typeId = await TypeService().checkType(imageFile);
      if (typeId == null || typeId.isEmpty) {
        throw Exception('Cannot check image type at index $i');
      }

      String? imageUrl = await ImageService().uploadImage(imageFile);
      if (imageUrl == null || imageUrl.isEmpty) {
        throw Exception('Failed to upload image at index $i');
      }

      imageDataList.add({
        'imageUrl': imageUrl,
        'typeId': typeId,
        'number': i + 1,
      });
    }
    
    DocumentReference docRef = await posts.add({
      'caption': post.caption,
      'userId': post.userId,
      'thumbnailUrl': imageDataList.first['imageUrl'],
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    });

    for (var image in imageDataList) {
      await docRef.collection('images').add({
        'imageUrl': image['imageUrl'],
        'typeId': image['typeId'],
        'number': image['number'],
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });
    }

    return docRef.id;
  }

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