import 'package:absence_kasau_app/core/ml/recognition_embedded.dart';
import 'package:absence_kasau_app/core/ml/recognizer.dart';
import 'package:absence_kasau_app/core/services/camera_manager.dart';
import 'package:absence_kasau_app/presentation/home/bloc/checkin_attendance/checkin_attendance_bloc.dart';
import 'package:absence_kasau_app/presentation/home/bloc/is_checkin/is_checkin_bloc.dart';
import 'package:absence_kasau_app/presentation/home/pages/attendance_success_page.dart';
import 'package:absence_kasau_app/presentation/home/pages/location_page.dart';
import 'package:absence_kasau_app/presentation/home/widgets/face_detector_painter.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import 'package:image/image.dart' as img;
import 'package:location/location.dart';

import '../../../core/core.dart';

class AttendanceCheckinPage extends StatefulWidget {
  const AttendanceCheckinPage({super.key});

  @override
  State<AttendanceCheckinPage> createState() => _AttendanceCheckinPageState();
}

class _AttendanceCheckinPageState extends State<AttendanceCheckinPage> {
  final CameraManager _cameraManager = CameraManager();
  CameraDescription? description; // Set after fetching available cameras
  bool isBusy = false;
  late List<RecognitionEmbedding> recognitions = [];
  late Size size;
  CameraLensDirection camDirec = CameraLensDirection.front;
  bool isFaceRegistered = false;
  String faceStatusMessage = '';
  DateTime? lastProcessTime;

  //TODO declare face recognizer
  late Recognizer recognizer;

  @override
  void initState() {
    super.initState();

    //TODO initialize face recognizer
    recognizer = Recognizer();

    _initializeCamera();

    getCurrentPosition();
  }

  Future<void> _initializeCamera() async {
    try {
      // Initialize camera using camera manager
      await _cameraManager.initializeCamera(camDirec);
      
      if (!mounted) return;

      // Get the description from the initialized controller
      description = _cameraManager.controller?.description;
      size = _cameraManager.controller?.value.previewSize ?? Size.zero;

      // Start image stream
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

      if (kDebugMode) {
        debugPrint('Camera initialized and image stream started');
      }

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error initializing camera: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Camera initialization failed: $e')),
        );
      }
    }
  }

  //TODO face detection on a frame
  dynamic _scanResults;
  CameraImage? frame;
  Future<void> doFaceDetectionOnFrame() async {
    try {
      // Double-check frame is not null before processing and not disposing
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
        debugPrint('Frame planes: ${frame!.planes.length}');
        for (int i = 0; i < frame!.planes.length; i++) {
          debugPrint('Plane $i: ${frame!.planes[i].bytes.length} bytes, ${frame!.planes[i].bytesPerRow} bytesPerRow');
        }
      }

      InputImage inputImage;
      try {
        // Pass the frame directly to avoid null issues
        inputImage = getInputImage();
        if (kDebugMode) {
          debugPrint('InputImage created successfully, processing with ML Kit...');
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Primary InputImage creation failed, trying simple method: $e');
        }
        try {
          inputImage = getInputImageSimple();
          if (kDebugMode) {
            debugPrint('Simple InputImage created successfully');
          }
        } catch (e2) {
          if (kDebugMode) {
            debugPrint('Both InputImage creation methods failed: $e2');
          }
          setState(() {
            isBusy = false;
          });
          return;
        }
      }

      //TODO pass InputImage to face detection model and detect faces
      List<Face> faces = await _cameraManager.faceDetector.processImage(inputImage);

      for (Face face in faces) {
        if (kDebugMode) {
          debugPrint("Face location \\${face.boundingBox}");
        }
      }

      //TODO perform face recognition on detected faces
      try {
        performFaceRecognition(faces);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Face recognition failed: $e');
        }
        setState(() {
          isBusy = false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Face detection failed: $e');
      }
      if (mounted) {
        setState(() {
          isBusy = false;
        });
      }
    }
  }

  img.Image? image;
  bool register = false;
  // TODO perform Face Recognition
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

        // Memeriksa validitas wajah yang dikenali
        bool isValid = await recognizer.isValidFace(recognition.embedding);

        // Perbarui status wajah dan pesan teks berdasarkan hasil pengenalan
        if (mounted) {
          if (isValid) {
            setState(() {
              isFaceRegistered = true;
              faceStatusMessage = 'Wajah sudah terdaftar';
            });
          } else {
            setState(() {
              isFaceRegistered = false;
              faceStatusMessage = 'Wajah belum terdaftar';
            });
          }
        }
      }

      if (mounted) {
        setState(() {
          isBusy = false;
          _scanResults = recognitions;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Face recognition processing failed: $e');
      }
      if (mounted) {
        setState(() {
          isBusy = false;
        });
      }
    }
  }

  //ketika absen authdata->face_embedding compare dengan yang dari tflite.

  // TODO method to convert CameraImage to Image
  img.Image convertYUV420ToImage(CameraImage cameraImage) {
    final width = cameraImage.width;
    final height = cameraImage.height;

    // Safety check for planes
    if (cameraImage.planes.length < 3) {
      throw Exception('Invalid YUV420 format: expected 3 planes, got ${cameraImage.planes.length}');
    }

    final yRowStride = cameraImage.planes[0].bytesPerRow;
    final uvRowStride = cameraImage.planes[1].bytesPerRow;
    final uvPixelStride = cameraImage.planes[1].bytesPerPixel!;

    final image = img.Image(width: width, height: height);

    for (var w = 0; w < width; w++) {
      for (var h = 0; h < height; h++) {
        final uvIndex =
            uvPixelStride * (w / 2).floor() + uvRowStride * (h / 2).floor();
        final yIndex = h * yRowStride + w;

        // Bounds checking to prevent crashes
        if (yIndex >= 0 && yIndex < cameraImage.planes[0].bytes.length &&
            uvIndex >= 0 && uvIndex < cameraImage.planes[1].bytes.length &&
            uvIndex < cameraImage.planes[2].bytes.length) {
          final y = cameraImage.planes[0].bytes[yIndex];
          final u = cameraImage.planes[1].bytes[uvIndex];
          final v = cameraImage.planes[2].bytes[uvIndex];

          image.data!.setPixelR(w, h, yuv2rgb(y, u, v));
        }
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

  //TODO convert CameraImage to InputImage (robust)
  InputImage getInputImage() {
    if (frame == null) {
      throw Exception('Frame is null - cannot create InputImage');
    }
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

  // Alternative simple method as fallback
  InputImage getInputImageSimple() {
    if (frame == null) {
      throw Exception('Frame is null - cannot create simple InputImage');
    }
    final CameraImage cameraImage = frame!;

    return InputImage.fromBytes(
      bytes: cameraImage.planes[0].bytes,
      metadata: InputImageMetadata(
        size: Size(
          cameraImage.width.toDouble(),
          cameraImage.height.toDouble(),
        ),
        rotation: InputImageRotation.rotation0deg,
        format: InputImageFormat.nv21,
        bytesPerRow: cameraImage.planes[0].bytesPerRow,
      ),
    );
  }

  void _takeAbsen() async {
    if (mounted) {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      try {
        // Check if user is already checked in
        context.read<IsCheckinBloc>().add(const IsCheckinEvent.isCheckIn());

        // Wait for the response
        await Future.delayed(const Duration(milliseconds: 500));

        final isCheckinState = context.read<IsCheckinBloc>().state;

        // Close loading dialog
        if (mounted) Navigator.of(context).pop();

        isCheckinState.maybeWhen(
          orElse: () {
            // If state is not success, proceed with check-in anyway
            _proceedWithCheckin();
          },
          success: (data) {
            if (data.isCheckIn) {
              // User is already checked in, show message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Anda sudah melakukan check-in hari ini'),
                  backgroundColor: Colors.orange,
                  duration: Duration(seconds: 3),
                ),
              );
            } else {
              // User is not checked in, proceed with check-in
              _proceedWithCheckin();
            }
          },
          error: (message) {
            // If there's an error checking status, still allow check-in
            _proceedWithCheckin();
          },
        );
      } catch (e) {
        // Close loading dialog if still open
        if (mounted) Navigator.of(context).pop();
        // Proceed with check-in if there's any error
        _proceedWithCheckin();
      }
    }
  }

  void _proceedWithCheckin() {
    if (mounted) {
      context.read<CheckinAttendanceBloc>().add(
        CheckinAttendanceEvent.checkin(
            latitude.toString(), longitude.toString()),
      );
    }
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

  // TODO Show rectangles around detected faces
  Widget buildResult() {
    if (_scanResults == null || !_cameraManager.isInitialized) {
      return const Center(child: Text('Camera is not initialized'));
    }
    final Size imageSize = Size(
      _cameraManager.controller!.value.previewSize!.height,
      _cameraManager.controller!.value.previewSize!.width,
    );
    CustomPainter painter =
        FaceDetectorPainter(imageSize, _scanResults, camDirec);
    return CustomPaint(
      painter: painter,
    );
  }

  double? latitude;
  double? longitude;

  Future<void> getCurrentPosition() async {
    try {
      Location location = Location();

      bool serviceEnabled;
      PermissionStatus permissionGranted;
      LocationData locationData;

      serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          return;
        }
      }

      permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          return;
        }
      }

      locationData = await location.getLocation();
      latitude = locationData.latitude;
      longitude = locationData.longitude;

      if (mounted) {
        setState(() {});
      }
    } on PlatformException catch (e) {
      if (e.code == 'IO_ERROR') {
        debugPrint(
            'A network error occurred trying to lookup the supplied coordinates: ${e.message}');
      } else {
        debugPrint('Failed to lookup coordinates: ${e.message}');
      }
    } catch (e) {
      debugPrint('An unknown error occurred: $e');
    }
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
              top: 20.0,
              left: 40.0,
              right: 40.0,
              child: Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: isFaceRegistered
                      ? AppColors.primary.withValues(alpha: 0.47)
                      : AppColors.red.withValues(alpha: 0.47),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Text(
                  faceStatusMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
            Positioned(
              bottom: 5.0,
              left: 0.0,
              right: 0.0,
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.47),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Absensi Datang',
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'Kantor',
                                style: TextStyle(
                                  color: AppColors.white,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () async {
                              // Safely pause camera stream before navigating
                              try {
                                if (_cameraManager.isStreaming) {
                                  await _cameraManager.stopImageStream();
                                }
                              } catch (e) {
                                if (kDebugMode) {
                                  debugPrint('Failed to stop image stream before navigation: $e');
                                }
                              }

                              if (!mounted) return;

                              // Debug coordinates before navigation
                              if (kDebugMode) {
                                debugPrint('Navigating to LocationPage with coordinates:');
                                debugPrint('Latitude: $latitude');
                                debugPrint('Longitude: $longitude');
                              }

                              // Navigate to LocationPage without awaiting the Future
                              final navFuture = context.push(LocationPage(
                                latitude: latitude,
                                longitude: longitude,
                              ));

                              // When user returns, restart the camera safely
                              navFuture.whenComplete(() async {
                                try {
                                  if (!mounted) return;
                                  if (_cameraManager.isInitialized && !_cameraManager.isStreaming) {
                                    await _cameraManager.startImageStream((image) {
                                      if (!mounted) return;
                                      if (!isBusy) {
                                        isBusy = true;
                                        frame = image;
                                        doFaceDetectionOnFrame();
                                      }
                                    });
                                  } else if (!_cameraManager.isInitialized) {
                                    // If controller was disposed elsewhere, re-initialize
                                    await _initializeCamera();
                                  }
                                } catch (e) {
                                  if (kDebugMode) {
                                    debugPrint('Failed to restart camera after returning: $e');
                                  }
                                }
                              });
                            },
                            child:
                                Assets.images.seeLocation.image(height: 30.0),
                          ),
                        ],
                      ),
                    ),
                    const SpaceHeight(15.0),
                    const SpaceHeight(15.0),
                    Row(
                      children: [
                        IconButton(
                          onPressed: _reverseCamera,
                          icon: Assets.icons.reverse.svg(width: 48.0),
                        ),
                        const Spacer(),
                        BlocConsumer<CheckinAttendanceBloc,
                            CheckinAttendanceState>(
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
                              loaded: (responseModel) {
                                // Simple navigation like checkout page
                                context.pushReplacement(
                                  const AttendanceSuccessPage(
                                    status: 'Berhasil Checkin',
                                  ),
                                );
                              },
                            );
                          },
                          builder: (context, state) {
                            return state.maybeWhen(
                              orElse: () {
                                return IconButton(
                                  onPressed:
                                      isFaceRegistered ? _takeAbsen : null,
                                  icon: const Icon(
                                    Icons.circle,
                                    size: 70.0,
                                  ),
                                  color: isFaceRegistered
                                      ? AppColors.red
                                      : AppColors.grey,
                                );
                              },
                              loading: () => const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          },
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


  @override
  void dispose() {
    // Camera manager will handle disposal safely
    // Don't dispose here as other pages might need the camera
    super.dispose();
  }
}