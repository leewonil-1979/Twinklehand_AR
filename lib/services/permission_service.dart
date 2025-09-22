import 'dart:io' show Platform;
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status == PermissionStatus.granted;
  }
  
  static Future<bool> requestStoragePermission() async {
    // Not required on Android when using app-internal storage; keep for iOS photos access
    if (Platform.isAndroid) return true;
    final status = await Permission.storage.request();
    return status == PermissionStatus.granted;
  }

  static Future<bool> requestPhotosPermission() async {
    // Only relevant on iOS
    if (Platform.isAndroid) return true;
    final status = await Permission.photos.request();
    return status == PermissionStatus.granted;
  }
  
  static Future<bool> requestAllPermissions() async {
    // Request only what's needed per platform
    if (Platform.isAndroid) {
      final cam = await Permission.camera.request();
      return cam == PermissionStatus.granted;
    } else {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.camera,
        Permission.photos,
      ].request();
      return statuses[Permission.camera] == PermissionStatus.granted &&
             statuses[Permission.photos] == PermissionStatus.granted;
    }
  }
  
  static Future<bool> checkCameraPermission() async {
    final status = await Permission.camera.status;
    return status == PermissionStatus.granted;
  }
  
  static Future<bool> checkStoragePermission() async {
    if (Platform.isAndroid) return true;
    final status = await Permission.storage.status;
    return status == PermissionStatus.granted;
  }
  
  static Future<void> openSettings() async {
    await openAppSettings();
  }
}