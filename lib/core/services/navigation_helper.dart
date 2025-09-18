import 'package:flutter/material.dart';
import 'package:absence_kasau_app/core/services/camera_manager.dart';

/// Helper class for safe navigation with camera cleanup
class NavigationHelper {
  static final CameraManager _cameraManager = CameraManager();

  /// Navigate to a page with proper camera cleanup
  static Future<T?> navigateWithCameraCleanup<T extends Object?>(
    BuildContext context,
    Widget page, {
    bool shouldDisposeCamera = false,
  }) async {
    try {
      // Stop camera stream before navigation
      if (_cameraManager.isStreaming) {
        await _cameraManager.stopImageStream();
        // Small delay to ensure stream stops completely
        await Future.delayed(const Duration(milliseconds: 100));
      }

      // Navigate to the page
      final result = await Navigator.of(context).push<T>(
        MaterialPageRoute(builder: (context) => page),
      );

      // Restart camera stream when returning (if camera is still initialized)
      if (_cameraManager.isInitialized && !_cameraManager.isStreaming) {
        // Small delay before restarting
        await Future.delayed(const Duration(milliseconds: 200));
      }

      return result;
    } catch (e) {
      debugPrint('Navigation error: $e');
      rethrow;
    }
  }

  /// Navigate with camera disposal (for final cleanup)
  static Future<T?> navigateWithCameraDisposal<T extends Object?>(
    BuildContext context,
    Widget page,
  ) async {
    try {
      // Stop and dispose camera completely
      await _cameraManager.dispose();
      
      // Navigate to the page
      return await Navigator.of(context).push<T>(
        MaterialPageRoute(builder: (context) => page),
      );
    } catch (e) {
      debugPrint('Navigation with disposal error: $e');
      rethrow;
    }
  }

  /// Replace current page with proper camera cleanup
  static Future<T?> pushReplacementWithCameraCleanup<T extends Object?, TO extends Object?>(
    BuildContext context,
    Widget page, {
    TO? result,
    bool shouldDisposeCamera = false,
  }) async {
    try {
      // Stop camera stream before navigation
      if (_cameraManager.isStreaming) {
        await _cameraManager.stopImageStream();
        await Future.delayed(const Duration(milliseconds: 100));
      }

      // Replace current page
      return await Navigator.of(context).pushReplacement<T, TO>(
        MaterialPageRoute(builder: (context) => page),
        result: result,
      );
    } catch (e) {
      debugPrint('Push replacement error: $e');
      rethrow;
    }
  }

  /// Pop current page with camera cleanup
  static Future<void> popWithCameraCleanup<T extends Object?>(
    BuildContext context, {
    T? result,
    bool shouldDisposeCamera = false,
  }) async {
    try {
      if (shouldDisposeCamera) {
        await _cameraManager.dispose();
      } else if (_cameraManager.isStreaming) {
        await _cameraManager.stopImageStream();
      }

      Navigator.of(context).pop<T>(result);
    } catch (e) {
      debugPrint('Pop with cleanup error: $e');
      rethrow;
    }
  }
}
