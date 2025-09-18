import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

/// Singleton camera manager to handle camera lifecycle across multiple pages
/// This prevents camera controller conflicts and disposal race conditions
class CameraManager {
  static final CameraManager _instance = CameraManager._internal();
  factory CameraManager() => _instance;
  CameraManager._internal();

  CameraController? _controller;
  FaceDetector? _detector;
  bool _isInitialized = false;
  bool _isDisposing = false;

  /// Get the current camera controller
  CameraController? get controller => _controller;

  /// Check if camera is initialized
  bool get isInitialized => _isInitialized && _controller != null && _controller!.value.isInitialized;

  /// Check if camera is currently streaming images
  bool get isStreaming => _controller?.value.isStreamingImages ?? false;

  /// Initialize camera with specified direction
  Future<void> initializeCamera(CameraLensDirection direction) async {
    if (_isDisposing) {
      if (kDebugMode) {
        debugPrint('CameraManager: Cannot initialize while disposing');
      }
      return;
    }

    // If already initialized with same direction, return
    if (_isInitialized && _controller?.description.lensDirection == direction) {
      return;
    }

    try {
      // Dispose existing controller first
      await _safeDispose();

      // Get available cameras
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw Exception('No cameras available');
      }

      // Find camera with specified direction
      CameraDescription? camera;
      try {
        camera = cameras.firstWhere((c) => c.lensDirection == direction);
      } catch (e) {
        camera = cameras.first; // Fallback to first available camera
      }

      // Create new controller
      _controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      // Initialize controller
      await _controller!.initialize();

      // Initialize face detector if not already done
      _detector ??= FaceDetector(
        options: FaceDetectorOptions(performanceMode: FaceDetectorMode.fast),
      );

      _isInitialized = true;

      if (kDebugMode) {
        debugPrint('CameraManager: Camera initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('CameraManager: Failed to initialize camera: $e');
      }
      await _safeDispose();
      rethrow;
    }
  }

  /// Start image stream with callback
  Future<void> startImageStream(Function(CameraImage) onImage) async {
    if (!isInitialized) {
      throw Exception('Camera not initialized');
    }

    if (isStreaming) {
      if (kDebugMode) {
        debugPrint('CameraManager: Image stream already running');
      }
      return;
    }

    try {
      await _controller!.startImageStream(onImage);
      if (kDebugMode) {
        debugPrint('CameraManager: Image stream started');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('CameraManager: Failed to start image stream: $e');
      }
      rethrow;
    }
  }

  /// Stop image stream
  Future<void> stopImageStream() async {
    if (_controller == null || !isStreaming) {
      return;
    }

    try {
      await _controller!.stopImageStream();
      if (kDebugMode) {
        debugPrint('CameraManager: Image stream stopped');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('CameraManager: Failed to stop image stream: $e');
      }
      // Don't rethrow - this is cleanup operation
    }
  }

  /// Switch camera direction
  Future<void> switchCameraDirection(CameraLensDirection newDirection) async {
    if (_controller?.description.lensDirection == newDirection) {
      return; // Already using the requested direction
    }

    await initializeCamera(newDirection);
  }

  /// Get face detector instance
  FaceDetector get faceDetector {
    _detector ??= FaceDetector(
      options: FaceDetectorOptions(performanceMode: FaceDetectorMode.fast),
    );
    return _detector!;
  }

  /// Safe disposal of camera resources
  Future<void> _safeDispose() async {
    if (_controller == null) return;

    _isDisposing = true;

    try {
      // Stop image stream first
      if (isStreaming) {
        await _controller!.stopImageStream();
        // Small delay to ensure stream stops completely
        await Future.delayed(const Duration(milliseconds: 100));
      }

      // Dispose controller
      if (_controller!.value.isInitialized) {
        await _controller!.dispose();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('CameraManager: Error during camera disposal: $e');
      }
      // Continue with cleanup even if disposal fails
    } finally {
      _controller = null;
      _isInitialized = false;
      _isDisposing = false;
    }
  }

  /// Dispose all camera resources
  Future<void> dispose() async {
    await _safeDispose();
    
    // Dispose face detector
    try {
      await _detector?.close();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('CameraManager: Error disposing face detector: $e');
      }
    } finally {
      _detector = null;
    }

    if (kDebugMode) {
      debugPrint('CameraManager: All resources disposed');
    }
  }

  /// Reset manager state (useful for testing or complete restart)
  Future<void> reset() async {
    await dispose();
    _isInitialized = false;
    _isDisposing = false;
  }
}
