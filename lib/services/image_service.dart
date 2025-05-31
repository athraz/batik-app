import 'dart:io';
import 'dart:math';

class ImageService {
  Future<String?> uploadImage(File imageFile) async {
    // TODO: uplaod image to cloud storage
    final random = Random();
    final id = random.nextInt(18) + 1;
    return "https://picsum.photos/id/$id/300/300";
  }
}