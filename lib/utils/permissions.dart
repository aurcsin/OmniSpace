// File: lib/services/permission_service.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// Centralized service to request and handle necessary permissions for the app.
class PermissionService {
  PermissionService._();
  static final PermissionService instance = PermissionService._();

  /// Requests all permissions needed for camera, audio, and media access.
  /// On iOS: camera, microphone, and photo library.
  /// On Android: camera, microphone, photos, videos, audio, and storage.
  Future<void> requestAllNecessaryPermissions(BuildContext context) async {
    final List<Permission> permissions = [];
    if (Platform.isIOS) {
      permissions.addAll([
        Permission.camera,
        Permission.microphone,
        Permission.photos,
      ]);
    } else if (Platform.isAndroid) {
      permissions.addAll([
        Permission.camera,
        Permission.microphone,
        Permission.photos,
        Permission.videos,
        Permission.audio,
        Permission.storage,
      ]);
    }

    for (final permission in permissions) {
      try {
        await _request(permission, context);
      } catch (_) {
        // Permission not supported on this platform
      }
    }
  }

  /// Helper to request a single [permission].
  /// Shows an alert if permanently denied, guiding user to settings.
  static Future<void> _request(
      Permission permission, BuildContext context) async {
    final status = await permission.request();
    if (status.isPermanentlyDenied) {
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Permission Required'),
          content: Text(
            'The app needs the ${permission.toString().split('.').last} permission to function properly. Please enable it in Settings.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                openAppSettings();
                Navigator.pop(context);
              },
              child: const Text('Open Settings'),
            ),
          ],
        ),
      );
    } else if (status.isDenied || status.isRestricted) {
      // Show a brief explanation when denied (not permanent)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Permission ${permission.toString().split('.').last} denied',
          ),
        ),
      );
    }
  }
}
