
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:absence_kasau_app/core/ml/recognition_embedded.dart';
import 'package:absence_kasau_app/core/ml/recognizer.dart';
import 'package:absence_kasau_app/core/services/camera_manager.dart';
import 'package:absence_kasau_app/data/datasources/auth_local_datasource.dart';
import 'package:absence_kasau_app/presentation/home/bloc/update_user_register_face/update_user_register_face_bloc.dart';
import 'package:absence_kasau_app/presentation/home/pages/main_page.dart';
import 'package:absence_kasau_app/presentation/home/widgets/face_detector_painter.dart';

import '../../../core/core.dart';

class RegisterFaceAttendancePage extends StatefulWidget {
  const RegisterFaceAttendancePage({super.key});

  @override
  State<RegisterFaceAttendancePage> createState() =>
      _RegisterFaceAttendancePageState();
}

class _RegisterFaceAttendancePageState
    extends State<RegisterFaceAttendancePage> with TickerProviderStateMixin {
  final CameraManager _cameraManager = CameraManager();
  CameraDescription? description;

  CameraLensDirection camDirec = CameraLensDirection.front;

  bool register = false;
  late Size size;
  late List<RecognitionEmbedding> recognitions = [];

  //TODO declare face recognizer
  late Recognizer recognizer;

  bool isBusy = false;
  DateTime? lastProcessTime;

//   Future<XFile> convertImageToXFile(img.Image image) async {
//   // Get a temporary directory path
//   String tempDir = (await getTemporaryDirectory()).path;

//   // Create a file path within the temporary directory
//   String filePath = '$tempDir/image.jpg';

//   // Save the image to the file path
//   File file = File(filePath);
//   await file.writeAsBytes(img.encodeJpg(image));

//   // Create an XFile from the saved file
//   XFile xFile = XFile(filePath);

//   return xFile;
// }

  @override
  void initState() {
    super.initState();

    //TODO initialize face recognizer
    recognizer = Recognizer();

    if (kDebugMode) {
      debugPrint('Face recognizer initialized');
    }

    _initializeCamera();
  }

  @override
  void dispose() {
    // Camera manager will handle disposal safely
    // Don't dispose here as other pages might need the camera
    super.dispose();
  }

  void _initializeCamera() async {
    try {
      // Initialize camera using camera manager
      await _cameraManager.initializeCamera(camDirec);
      
      if (!mounted) {
        return;
      }

      // Get the description from the initialized controller
      description = _cameraManager.controller?.description;

      // Start image stream
      await _cameraManager.startImageStream((CameraImage image) {
        // Limit processing to ~10 FPS for smooth performance
        final now = DateTime.now();
        if (!isBusy && (lastProcessTime == null ||
            now.difference(lastProcessTime!).inMilliseconds > 100)) {
          isBusy = true;
          lastProcessTime = now;
          frame = image;
          doFaceDetectionOnFrame();
        }
      });

      if (kDebugMode) {
        debugPrint('Camera initialized and image stream started');
      }

      setState(() {});
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error initializing camera: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Camera initialization failed: $e')),
        );
      }
    }
  }

  List<RecognitionEmbedding> _scanResults = [];
  CameraImage? frame;

  InputImage getInputImage() {
    final CameraImage cameraImage = frame!;

    // Create InputImage from CameraImage
    final WriteBuffer allBytes = WriteBuffer();

    // Handle YUV420 format properly
    if (cameraImage.format.group == ImageFormatGroup.yuv420) {
      // For YUV420, concatenate Y, U, V planes in the correct order
      for (final Plane plane in cameraImage.planes) {
        allBytes.putUint8List(plane.bytes);
      }
    } else {
      // For other formats, concatenate all planes
      for (final Plane plane in cameraImage.planes) {
        allBytes.putUint8List(plane.bytes);
      }
    }

    final bytes = allBytes.done().buffer.asUint8List();
    final Size imageSize = Size(
      cameraImage.width.toDouble(),
      cameraImage.height.toDouble()
    );

    // Get camera sensor orientation with proper mapping
    final camera = description;
    final sensorOrientation = camera?.sensorOrientation ?? 0;

    // Map sensor orientation to InputImageRotation
    InputImageRotation rotation;
    switch (sensorOrientation) {
      case 90:
        rotation = InputImageRotation.rotation90deg;
        break;
      case 180:
        rotation = InputImageRotation.rotation180deg;
        break;
      case 270:
        rotation = InputImageRotation.rotation270deg;
        break;
      default:
        rotation = InputImageRotation.rotation0deg;
    }

    // Get input image format with fallback
    InputImageFormat format;
    if (cameraImage.format.group == ImageFormatGroup.yuv420) {
      format = InputImageFormat.nv21;
    } else if (cameraImage.format.group == ImageFormatGroup.bgra8888) {
      format = InputImageFormat.bgra8888;
    } else {
      format = InputImageFormat.nv21; // Default fallback
    }

    // Calculate bytes per row
    final int bytesPerRow = cameraImage.planes.isNotEmpty
        ? cameraImage.planes[0].bytesPerRow
        : cameraImage.width;

    final inputImageMetaData = InputImageMetadata(
      size: imageSize,
      rotation: rotation,
      format: format,
      bytesPerRow: bytesPerRow,
    );

    final inputImage = InputImage.fromBytes(
      bytes: bytes,
      metadata: inputImageMetaData
    );

    return inputImage;
  }

  // Alternative method for creating InputImage - simpler approach
  InputImage getInputImageSimple() {
    final CameraImage cameraImage = frame!;

    // Simple approach - just use the raw format
    final inputImage = InputImage.fromBytes(
      bytes: cameraImage.planes[0].bytes,
      metadata: InputImageMetadata(
        size: Size(cameraImage.width.toDouble(), cameraImage.height.toDouble()),
        rotation: InputImageRotation.rotation0deg,
        format: InputImageFormat.nv21,
        bytesPerRow: cameraImage.planes[0].bytesPerRow,
      ),
    );

    return inputImage;
  }

  img.Image convertYUV420ToImage(CameraImage cameraImage) {
    final width = cameraImage.width;
    final height = cameraImage.height;

    final yRowStride = cameraImage.planes[0].bytesPerRow;
    final uvRowStride = cameraImage.planes[1].bytesPerRow;
    final uvPixelStride = cameraImage.planes[1].bytesPerPixel!;

    final image = img.Image(width: width, height: height);

    for (var w = 0; w < width; w++) {
      for (var h = 0; h < height; h++) {
        final uvIndex =
            uvPixelStride * (w / 2).floor() + uvRowStride * (h / 2).floor();
        final yIndex = h * yRowStride + w;

        final y = cameraImage.planes[0].bytes[yIndex];
        final u = cameraImage.planes[1].bytes[uvIndex];
        final v = cameraImage.planes[2].bytes[uvIndex];

        image.data!.setPixelR(w, h, yuv2rgb(y, u, v)); //= yuv2rgb(y, u, v);
      }
    }
    return image;
  }

  int yuv2rgb(int y, int u, int v) {
    // Convert yuv pixel to rgb
    var r = (y + v * 1436 / 1024 - 179).round();
    var g = (y - u * 46549 / 131072 + 44 - v * 93604 / 131072 + 91).round();
    var b = (y + u * 1814 / 1024 - 227).round();

    // Clipping RGB values to be inside boundaries [ 0 , 255 ]
    r = r.clamp(0, 255);
    g = g.clamp(0, 255);
    b = b.clamp(0, 255);

    return 0xff000000 |
        ((b << 16) & 0xff0000) |
        ((g << 8) & 0xff00) |
        (r & 0xff);
  }

  Future<void> doFaceDetectionOnFrame() async {
    try {
      if (frame == null) {
        if (kDebugMode) {
          debugPrint('Frame is null, skipping face detection');
        }
        setState(() {
          isBusy = false;
        });
        return;
      }

      if (kDebugMode) {
        debugPrint('Processing frame: ${frame!.width}x${frame!.height}, format: ${frame!.format.group}');
      }

      InputImage inputImage;
      try {
        inputImage = getInputImage();
        if (kDebugMode) {
          debugPrint('InputImage created successfully, processing with ML Kit...');
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Primary InputImage creation failed, trying simple method: $e');
        }
        inputImage = getInputImageSimple();
      }

      List<Face> faces = await _cameraManager.faceDetector.processImage(inputImage);

      if (kDebugMode) {
        debugPrint('Face detection: Found ${faces.length} faces');
      }

      // Update face rectangles immediately for smooth tracking
      updateFaceRectangles(faces);

      // Only perform heavy face recognition when needed (e.g., when taking picture)
      if (register && faces.isNotEmpty) {
        performFaceRecognition(faces);
      } else {
        setState(() {
          isBusy = false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error in face detection: $e');
        if (frame != null) {
          debugPrint('Frame details: ${frame!.width}x${frame!.height}, format: ${frame!.format.group}, planes: ${frame!.planes.length}');
        }
      }
      setState(() {
        isBusy = false;
      });
    }
  }

  // Fast method to update face rectangles for smooth tracking
  void updateFaceRectangles(List<Face> faces) {
    recognitions.clear();

    // Convert Face objects to RecognitionEmbedding for display
    for (Face face in faces) {
      // Create a simple RecognitionEmbedding with just the location
      // No heavy processing, just for drawing rectangles
      RecognitionEmbedding recognition = RecognitionEmbedding(
        face.boundingBox,
        [], // Empty embedding for fast tracking
      );
      recognitions.add(recognition);
    }

    if (kDebugMode) {
      debugPrint('Fast face tracking: Updated ${recognitions.length} face rectangles');
    }

    setState(() {
      _scanResults = recognitions;
      isBusy = false;
    });
  }

  img.Image? image;
  Future<void> performFaceRecognition(List<Face> faces) async {
    try {
      recognitions.clear();

      //TODO convert CameraImage to Image and rotate it so that our frame will be in a portrait
      image = convertYUV420ToImage(frame!);
      image = img.copyRotate(image!,
          angle: camDirec == CameraLensDirection.front ? 270 : 90);

      for (Face face in faces) {
        Rect faceRect = face.boundingBox;
        //TODO crop face
        img.Image croppedFace = img.copyCrop(image!,
            x: faceRect.left.toInt(),
            y: faceRect.top.toInt(),
            width: faceRect.width.toInt(),
            height: faceRect.height.toInt());

        //TODO pass cropped face to face recognition model
        RecognitionEmbedding recognition =
            recognizer.recognize(croppedFace, face.boundingBox);

        recognitions.add(recognition);

        //TODO show face registration dialogue
        if (register) {
          showFaceRegistrationDialogue(
            croppedFace,
            recognition,
          );
          register = false;
        }
      }

      if (kDebugMode) {
        debugPrint('Face recognition: Processing ${recognitions.length} recognitions');
      }

      setState(() {
        isBusy = false;
        _scanResults = recognitions;
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error in face recognition: $e');
      }
      setState(() {
        isBusy = false;
      });
    }
  }

  void showFaceRegistrationDialogue(
      img.Image croppedFace, RecognitionEmbedding recognition) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Face Registration", textAlign: TextAlign.center),
        alignment: Alignment.center,
        content: SizedBox(
          height: MediaQuery.of(context).size.height / 3,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 20,
              ),
              Image.memory(
                Uint8List.fromList(img.encodeBmp(croppedFace)),
                width: 200,
                height: 200,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: BlocConsumer<UpdateUserRegisterFaceBloc,
                    UpdateUserRegisterFaceState>(
                  listener: (context, state) {
                    state.maybeWhen(
                      orElse: () {},
                      error: (message) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(message),
                          ),
                        );
                      },
                      success: (data) {
                        // AuthLocalDataSource()
                        //     .reSaveAuthData(responseModel.user!);
                        // Navigator.pop(context);
                        AuthLocalDatasource().updateAuthData(data);
                        context.pushReplacement(const MainPage());
                      },
                    );
                  },
                  builder: (context, state) {
                    return state.maybeWhen(
                      orElse: () {
                        return Button.filled(
                            onPressed: () async {
                              // Trigger the face registration
                              context.read<UpdateUserRegisterFaceBloc>().add(
                                  UpdateUserRegisterFaceEvent
                                      .updateProfileRegisterFace(
                                          recognition.embedding.join(','),
                                          null));
                            },
                            label: 'Register');
                      },
                      loading: () => const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  void _reverseCamera() async {
    if (camDirec == CameraLensDirection.back) {
      camDirec = CameraLensDirection.front;
    } else {
      camDirec = CameraLensDirection.back;
    }

    // Switch camera direction using camera manager
    await _cameraManager.switchCameraDirection(camDirec);
    
    if (mounted) {
      // Update description and restart image stream
      description = _cameraManager.controller?.description;
      await _cameraManager.startImageStream((CameraImage image) {
        final now = DateTime.now();
        if (!isBusy && (lastProcessTime == null ||
            now.difference(lastProcessTime!).inMilliseconds > 100)) {
          isBusy = true;
          lastProcessTime = now;
          frame = image;
          doFaceDetectionOnFrame();
        }
      });
      setState(() {});
    }
  }

  void _takePicture() async {
    if (_cameraManager.controller != null) {
      await _cameraManager.controller!.takePicture();
      if (mounted) {
        setState(() {
          register = true;
        });
      }
    }
  }

  Widget buildResult() {
    if (!_cameraManager.isInitialized || _cameraManager.controller == null) {
      return const SizedBox.shrink(); // Return empty widget instead of debug text
    }

    final Size imageSize = Size(
      _cameraManager.controller!.value.previewSize!.width,
      _cameraManager.controller!.value.previewSize!.height,
    );

    // Face detection overlay with scanning animation
    return Stack(
      children: [
        // Face detection overlay
        CustomPaint(
          painter: FaceDetectorPainter(imageSize, _scanResults, camDirec),
        ),
        // Face detection status overlay
        Positioned(
          top: 50,
          left: 20,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _scanResults.isNotEmpty ? Colors.blue : Colors.white,
                width: 1
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _scanResults.isNotEmpty ? Icons.face : Icons.face_outlined,
                  color: _scanResults.isNotEmpty ? Colors.blue : Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  _scanResults.isNotEmpty
                      ? 'Face Detected'
                      : 'Scanning for faces...',
                  style: TextStyle(
                    color: _scanResults.isNotEmpty ? Colors.blue : Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Debug overlay (only in debug mode)
        if (kDebugMode)
          Positioned(
            top: 100,
            left: 20,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Debug: Faces: ${_scanResults.length}',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    if (!_cameraManager.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            // Full screen camera preview with proper 9:16 aspect ratio
            Positioned.fill(
              child: AspectRatio(
                aspectRatio: 9 / 16, // 9:16 aspect ratio for portrait orientation
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _cameraManager.controller!.value.previewSize!.height,
                    height: _cameraManager.controller!.value.previewSize!.width,
                    child: CameraPreview(_cameraManager.controller!),
                  ),
                ),
              ),
            ),
            Positioned(
                top: 0.0,
                left: 0.0,
                width: size.width,
                height: size.height,
                child: buildResult()),
            Positioned(
              bottom: 5.0,
              left: 0.0,
              right: 0.0,
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: _reverseCamera,
                          icon: Assets.icons.reverse.svg(width: 48.0),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: _takePicture,
                          icon: const Icon(
                            Icons.circle,
                            size: 70.0,
                          ),
                          color: AppColors.red,
                        ),
                        const Spacer(),
                        const SpaceWidth(48.0)
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}