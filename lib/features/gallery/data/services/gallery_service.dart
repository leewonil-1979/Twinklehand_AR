import 'dart:io';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class GalleryService {
  Future<bool> savePhoto(String imagePath) async {
    try {
      // Get temporary directory
      final directory = await getTemporaryDirectory();
      
      // Create unique filename with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'handwash_$timestamp.jpg';
      final savePath = path.join(directory.path, fileName);
      
      // Copy file to temporary location
      final file = File(imagePath);
      await file.copy(savePath);
      
      // Save to gallery
      final result = await GallerySaver.saveImage(
        savePath,
        albumName: '손반짝',
      );
      
      // Clean up temporary file
      try {
        await File(savePath).delete();
      } catch (_) {}
      
      return result ?? false;
    } catch (e) {
      print('Error saving photo to gallery: $e');
      return false;
    }
  }
  
  Future<bool> saveVideo(String videoPath) async {
    try {
      final result = await GallerySaver.saveVideo(
        videoPath,
        albumName: '손반짝',
      );
      return result ?? false;
    } catch (e) {
      print('Error saving video to gallery: $e');
      return false;
    }
  }
}