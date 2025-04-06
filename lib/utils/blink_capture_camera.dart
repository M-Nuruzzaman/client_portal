import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;

import 'blinking_eye_animation.dart';

class BlinkCaptureCamera extends StatefulWidget {
  final Function(int, File?) onImageSelected;
  final String heading;
  final File? initialImage;
  final int index;

  const BlinkCaptureCamera({super.key, required this.onImageSelected, required this.heading, required this.initialImage, required this.index});

  @override
  _BlinkCaptureCameraState createState() => _BlinkCaptureCameraState();
}

class _BlinkCaptureCameraState extends State<BlinkCaptureCamera> {
  CameraController? _cameraController;
  FaceDetector? _faceDetector;
  bool _isDetecting = false;
  bool _blinkDetected = false;
  File? _capturedImage;

  final double boxSize = 400; // Fixed square size

  @override
  void initState() {
    super.initState();

    // Check if an initial image is provided
    if (widget.initialImage != null) {
      _capturedImage = widget.initialImage!;
    } else {
      _initializeCamera();
    }

    _initializeFaceDetector();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();

    if (cameras.isEmpty) {
      print("❌ No cameras found!");
      return;
    }

    final frontCamera = cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    await _cameraController?.dispose();

    _cameraController = CameraController(
      frontCamera,
      ResolutionPreset.high,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    try {
      await _cameraController?.initialize();
      if (mounted) setState(() {});
      _startFaceDetection();
    } catch (e) {
      print("❌ Error initializing camera: $e");
    }
  }

  void _initializeFaceDetector() {
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(enableClassification: true),
    );
  }

  void _startFaceDetection() {
    _cameraController?.startImageStream((CameraImage image) async {
      if (_isDetecting) return;
      _isDetecting = true;

      final faces = await _processImage(image);
      if (faces.isNotEmpty) {
        final face = faces.first;
        if (face.leftEyeOpenProbability != null && face.rightEyeOpenProbability != null) {
          bool isBlinking = (face.leftEyeOpenProbability! < 0.3 && face.rightEyeOpenProbability! < 0.3);
          if (isBlinking && !_blinkDetected) {
            _blinkDetected = true;
            _captureImage();
          } else if (!isBlinking) {
            _blinkDetected = false;
          }
        }
      }

      _isDetecting = false;
    });
  }

  Future<List<Face>> _processImage(CameraImage image, {int attempt = 0}) async {
    if (_faceDetector == null) {
      print("❌ Face Detector is not initialized");
      return [];
    }

    try {
      print("🔍 Processing image... Attempt: $attempt");
      print("📏 Image dimensions: ${image.width}x${image.height}");

      // Print bytes information to debug
      print("📊 Plane 0 length: ${image.planes[0].bytes.length}");
      print("📊 Plane 1 length: ${image.planes[1].bytes.length}");
      print("📊 Plane 2 length: ${image.planes[2].bytes.length}");

      final convertedImage = _convertYUV420ToNV21(image);

      final metadata = InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: InputImageRotation.rotation270deg,
        format: InputImageFormat.nv21,
        bytesPerRow: image.planes[0].bytesPerRow,
      );

      final inputImage = InputImage.fromBytes(
        bytes: convertedImage,
        metadata: metadata,
      );

      return await _faceDetector!.processImage(inputImage);
    } catch (e) {
      print("❌ Error processing image: $e");
      if (attempt < 5) {
        print("🔄 Retrying (Attempt ${attempt + 1})...");
        return _processImage(image, attempt: attempt + 1);
      } else {
        print("❌ Max retry attempts reached!");
        return [];
      }
    }
  }


  Uint8List _convertYUV420ToNV21(CameraImage image) {
    final int width = image.width;
    final int height = image.height;
    final int ySize = width * height;
    final int uvSize = (width ~/ 2) * (height ~/ 2) * 2;

    final Uint8List nv21 = Uint8List(ySize + uvSize);
    int index = 0;

    for (int row = 0; row < height; row++) {
      int rowStart = row * image.planes[0].bytesPerRow;
      int rowEnd = rowStart + width;
      if (rowEnd > image.planes[0].bytes.length) {
        rowEnd = image.planes[0].bytes.length;
      }
      nv21.setRange(index, index + (rowEnd - rowStart), image.planes[0].bytes.sublist(rowStart, rowEnd));
      index += width;
    }

    for (int row = 0; row < height ~/ 2; row++) {
      int rowStart = row * image.planes[1].bytesPerRow;
      int rowEnd = rowStart + width;
      if (rowEnd > image.planes[1].bytes.length) {
        rowEnd = image.planes[1].bytes.length;
      }
      nv21.setRange(index, index + (rowEnd - rowStart), image.planes[1].bytes.sublist(rowStart, rowEnd));
      index += width;
    }

    return nv21;
  }

  Future<void> _captureImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      print("❌ Camera is not initialized yet!");
      return;
    }

    try {
      final XFile file = await _cameraController!.takePicture();
      final imagePath = file.path;

      print("✅ Captured Image Path: $imagePath");

      final croppedPath = await _cropImage(imagePath);
      // final croppedPath = imagePath;

      setState(() {
        _capturedImage = File(croppedPath);
      });
      widget.onImageSelected(widget.index, _capturedImage);
      await _cameraController?.stopImageStream();
      await _cameraController?.dispose();
      _cameraController = null;

    } catch (e) {
      print("❌ Error capturing image: $e");
    }
  }

  Future<String> _cropImage(String imagePath) async {
    try {
      final imageFile = File(imagePath);
      final imageBytes = await imageFile.readAsBytes();
      img.Image? originalImage = img.decodeImage(imageBytes);

      if (originalImage == null) {
        print("❌ Failed to decode image");
        return imagePath;
      }

      int imageWidth = originalImage.width;
      int imageHeight = originalImage.height;

      // Define the crop size while maintaining the 3:4 aspect ratio
      int cropWidth, cropHeight;

      if (imageWidth / 3 < imageHeight / 4) {
        cropWidth = imageWidth;
        cropHeight = (cropWidth * 4) ~/ 3; // Height = Width * (4/3)
      } else {
        cropHeight = imageHeight;
        cropWidth = (cropHeight * 3) ~/ 4; // Width = Height * (3/4)
      }

      // Ensure the crop size fits within the image dimensions
      if (cropWidth > imageWidth) cropWidth = imageWidth;
      if (cropHeight > imageHeight) cropHeight = imageHeight;

      // Calculate the center crop coordinates
      int cropX = (imageWidth - cropWidth) ~/ 2;
      int cropY = (imageHeight - cropHeight) ~/ 2;

      // Perform the crop
      img.Image cropped = img.copyCrop(
        originalImage,
        x: cropX,
        y: cropY,
        width: cropWidth,
        height: cropHeight,
      );

      // Flip horizontally if using the front camera
      img.Image flippedImage = img.flipHorizontal(cropped);

      // Save the cropped image
      final croppedPath = "${imageFile.parent.path}/cropped_${DateTime.now().millisecondsSinceEpoch}.jpg";
      File(croppedPath).writeAsBytesSync(img.encodeJpg(flippedImage));

      print("✅ Image cropped successfully: $croppedPath");
      return croppedPath;
    } catch (e) {
      print("❌ Error cropping image: $e");
      return imagePath;
    }
  }


  @override
  void dispose() {
    _cameraController?.dispose();
    _faceDetector?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        height: 400,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black45,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(4, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Heading
            Text(
              widget.heading,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 10),

            // Camera Preview or Captured Image inside a Fixed Box
            SizedBox(
              height: 300,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    height: 300,
                    decoration: BoxDecoration(
                      color: Colors.white24.withOpacity(0.84),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.2),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: _capturedImage != null
                          ? Image.file(
                        _capturedImage!,
                        fit: BoxFit.contain,
                      )
                          : _cameraController?.value.isInitialized == true
                          ? Stack(
                        alignment: Alignment.center,
                        children: [
                          Center(
                            child: AspectRatio(
                              aspectRatio: _cameraController!.value.aspectRatio,
                              child: Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()
                                  ..rotateZ(_cameraController!.description.sensorOrientation *
                                      (3.1415927 / 180))
                                  ..scale(
                                    _cameraController!.description.lensDirection ==
                                        CameraLensDirection.front
                                        ? 1.0
                                        : -1.0,
                                    _cameraController!.description.sensorOrientation == 180
                                        ? 1.0
                                        : -1.0,
                                  ),
                                child: CameraPreview(_cameraController!),
                              ),
                            ),
                          ),
                          // 👁️ Add Blinking Eye Animation Over Camera Preview
                          BlinkingEyeAnimation(),
                        ],
                      )
                          : const Center(child: CircularProgressIndicator()),
                    ),
                  ),

                  if (_capturedImage != null)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green, size: 40),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _capturedImage = null;
                              });
                              _initializeCamera();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              "Recapture",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            if(_capturedImage == null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    "Blink your eyes to capture the image automatically!",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
