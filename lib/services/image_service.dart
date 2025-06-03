import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class ImageService {
  final storageRef = FirebaseStorage.instance.ref();

  Future<String?> uploadImage(File imageFile, String userId) async {
    try {
      final fileId = const Uuid().v4();
      final fileName = "$fileId.jpg";

      final imageRef = storageRef.child('$userId/$fileName');

      await imageRef.putFile(imageFile);

      final url = await imageRef.getDownloadURL();
      return url;
    } catch (e) {
      print("Upload image failed: $e");
      return null;
    }
  }
}