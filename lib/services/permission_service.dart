import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import '../config/constants.dart';

class PermissionService {
  // Map of feature to required permissions
  static const Map<String, List<Permission>> _featurePermissions = {
    'calendar': [Permission.calendar],
    'contacts': [Permission.contacts],
    'camera': [Permission.camera],
    'location': [Permission.location, Permission.locationWhenInUse],
    'microphone': [Permission.microphone],
    'storage': [Permission.storage],
    'phone': [Permission.phone],
    'sms': [Permission.sms],
    'notifications': [Permission.notification],
  };

  // Request permission for a specific feature
  Future<bool> requestPermission(String feature) async {
    final permissions = _featurePermissions[feature];
    if (permissions == null) return false;

    final statuses = await permissions.request();
    return statuses.values.every((status) => status.isGranted);
  }

  // Request multiple permissions
  Future<Map<String, bool>> requestMultiplePermissions(List<String> features) async {
    final results = <String, bool>{};
    
    for (final feature in features) {
      results[feature] = await requestPermission(feature);
    }
    
    return results;
  }

  // Check if permission is granted
  Future<bool> isPermissionGranted(String feature) async {
    final permissions = _featurePermissions[feature];
    if (permissions == null) return false;

    for (final permission in permissions) {
      final status = await permission.status;
      if (!status.isGranted) return false;
    }
    
    return true;
  }

  // Check multiple permissions status
  Future<Map<String, bool>> checkPermissionsStatus(List<String> features) async {
    final results = <String, bool>{};
    
    for (final feature in features) {
      results[feature] = await isPermissionGranted(feature);
    }
    
    return results;
  }

  // Show permission rationale dialog
  Future<bool> showPermissionRationale(
    BuildContext context,
    String feature,
  ) async {
    final message = AppConstants.permissionMessages[feature] ??
        'This app needs permission to access $feature to provide better assistance.';

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Permission Required'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Grant Permission'),
          ),
        ],
      ),
    );

    if (result == true) {
      return await requestPermission(feature);
    }
    
    return false;
  }

  // Handle permanently denied permissions
  Future<void> handlePermanentlyDenied(
    BuildContext context,
    String feature,
  ) async {
    final message = AppConstants.permissionMessages[feature] ??
        'This app needs permission to access $feature.';

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Permission Denied'),
        content: Text(
          '$message\n\nPlease enable it in your device settings to use this feature.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  // Request permission with UI handling
  Future<bool> requestPermissionWithUI(
    BuildContext context,
    String feature,
  ) async {
    // Check if already granted
    if (await isPermissionGranted(feature)) {
      return true;
    }

    // Check if permanently denied
    final permissions = _featurePermissions[feature]!;
    for (final permission in permissions) {
      final status = await permission.status;
      if (status.isPermanentlyDenied) {
        await handlePermanentlyDenied(context, feature);
        return false;
      }
    }

    // Show rationale and request
    return await showPermissionRationale(context, feature);
  }

  // Get all permissions status
  Future<Map<String, PermissionStatus>> getAllPermissionsStatus() async {
    final results = <String, PermissionStatus>{};
    
    for (final entry in _featurePermissions.entries) {
      // Use the first permission's status as representative
      final status = await entry.value.first.status;
      results[entry.key] = status;
    }
    
    return results;
  }
}