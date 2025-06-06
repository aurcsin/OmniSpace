import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<void> requestAllNecessaryPermissions() async {
    final permissions = [
      Permission.camera,
      Permission.microphone,
      Permission.photos,     // iOS
      Permission.videos,     // Android 13+
      Permission.audio,      // Android 13+
      Permission.storage,    // Android <13
    ];

    for (var permission in permissions) {
      final status = await permission.request();
      if (status.isDenied || status.isPermanentlyDenied) {
        // Optional: Show dialog or guidance
        print('Permission ${permission.toString()} denied');
      }
    }
  }
}
