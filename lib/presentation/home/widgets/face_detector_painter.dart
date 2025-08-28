import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:absence_kasau_app/core/ml/recognition_embedded.dart';

class FaceDetectorPainter extends CustomPainter {
  FaceDetectorPainter(
    this.absoluteImageSize,
    this.faces,
    this.camDire2,
  );

  final Size absoluteImageSize;

  final List<RecognitionEmbedding> faces;
  CameraLensDirection camDire2;

  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = size.width / absoluteImageSize.width;
    final double scaleY = size.height / absoluteImageSize.height;

    // Debug print to check if painter is being called
    if (kDebugMode) {
      debugPrint('FaceDetectorPainter: Drawing ${faces.length} faces, canvas size: ${size.width}x${size.height}, image size: ${absoluteImageSize.width}x${absoluteImageSize.height}');
    }

    // Simple blue rectangle paint for face detection (like in the image)
    final Paint facePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.blue;

    for (RecognitionEmbedding face in faces) {
      final Rect faceRect = Rect.fromLTRB(
        camDire2 == CameraLensDirection.front
            ? (absoluteImageSize.width - face.location.right) * scaleX
            : face.location.left * scaleX,
        face.location.top * scaleY,
        camDire2 == CameraLensDirection.front
            ? (absoluteImageSize.width - face.location.left) * scaleX
            : face.location.right * scaleX,
        face.location.bottom * scaleY,
      );

      // Draw simple red rectangle border around the face
      canvas.drawRect(faceRect, facePaint);
    }
  }

  @override
  bool shouldRepaint(FaceDetectorPainter oldDelegate) {
    return true;
  }
}