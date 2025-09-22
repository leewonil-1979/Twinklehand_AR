import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class GalleryService {
  Future<bool> savePhoto(String imagePath) async {
    try {
      final docs = await getApplicationDocumentsDirectory();
      final appGalleryDir = Directory(path.join(docs.path, 'TwinkleHands_Gallery'));
      if (!await appGalleryDir.exists()) {
        await appGalleryDir.create(recursive: true);
      }
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'handwash_$timestamp.jpg';
      final dest = path.join(appGalleryDir.path, fileName);
      await File(imagePath).copy(dest);
      return true;
    } catch (e) {
      print('Error saving photo: $e');
      return false;
    }
  }
  
  Future<bool> saveVideo(String videoPath) async {
    try {
      final docs = await getApplicationDocumentsDirectory();
      final appGalleryDir = Directory(path.join(docs.path, 'TwinkleHands_Gallery'));
      if (!await appGalleryDir.exists()) {
        await appGalleryDir.create(recursive: true);
      }
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'handwash_$timestamp.mp4';
      final dest = path.join(appGalleryDir.path, fileName);
      await File(videoPath).copy(dest);
      return true;
    } catch (e) {
      print('Error saving video: $e');
      return false;
    }
  }
}