import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status == PermissionStatus.granted;
  }
  
  static Future<bool> requestStoragePermission() async {
    final status = await Permission.storage.request();
    return status == PermissionStatus.granted;
  }
  
  static Future<bool> requestPhotosPermission() async {
    final status = await Permission.photos.request();
    return status == PermissionStatus.granted;
  }
  
  static Future<bool> requestAllPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.storage,
      Permission.photos,
    ].request();
    
    return statuses[Permission.camera] == PermissionStatus.granted &&
           (statuses[Permission.storage] == PermissionStatus.granted ||
            statuses[Permission.photos] == PermissionStatus.granted);
  }
  
  static Future<bool> checkCameraPermission() async {
    final status = await Permission.camera.status;
    return status == PermissionStatus.granted;
  }
  
  static Future<bool> checkStoragePermission() async {
    final status = await Permission.storage.status;
    return status == PermissionStatus.granted;
  }
  
  static Future<void> openSettings() async {
    await openAppSettings();
  }
}