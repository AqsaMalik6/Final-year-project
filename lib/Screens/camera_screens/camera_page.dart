import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';

import '../results/denimjean_result.dart';
import '../results/sweatshirt_result.dart';
import 'detector_service.dart';

class CameraPage extends StatefulWidget {
  const CameraPage(
      {super.key,
        required this.type,
        required this.actualSize,
        required this.selectedSize,
        required this.selectedMeasurements,});
  final String type;
  final Map<String, double?> actualSize;
  final String selectedSize;
  final Map<String, double> selectedMeasurements;

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _controller;
  Detector? _detector;
  StreamSubscription? _subscription;
  List<List<Map<String, double>>> _contours = [];
  List<Map<String, double>> _measurments = [];
  final ScreenshotController _screenshotController = ScreenshotController();
  void _showInstructionDialog() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Instructions"),
            content: const Text(
              "Position garment 50–80 cm away on a flat surface with good lighting.\n\n"
                  "Tap screen to focus if blurry.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Got it"),
              ),
            ],
          );
        },
      );
    });
  }
  String path = '';
  // Future<String> saveImageToAppDirectory(XFile imageFile) async {
  //   final appDir = await getApplicationDocumentsDirectory();
  //   final fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.png';
  //   final savedImage = await File(imageFile.path).copy('${appDir.path}/$fileName');
  //   return savedImage.path;
  // }
  Future<String> saveWithNewName(String originalPath) async {
    final directory = await getTemporaryDirectory();
    final newFileName = 'captured_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final newPath = '${directory.path}/$newFileName';
    final newFile = await File(originalPath).copy(newPath);
    return newFile.path;
  }
  _cameraStream() async {
    Detector.start().then((instance) {
      _detector = instance;
      _subscription = instance.resultsStream.stream.listen((values) {
        if (values['contours'] != null) {
          setState(() {
            _contours = values['contours'];
            _measurments = values['measurments'];
          });
        }
      });
    });
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    _controller = CameraController(
      firstCamera,
      ResolutionPreset.low,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );
    await _controller!.initialize();
    _controller!.startImageStream(onLatestImageAvailable);

    setState(() {});
  }

  /// Callback to receive each frame [CameraImage] perform inference on it
  void onLatestImageAvailable(CameraImage cameraImage) async {
    _detector?.processFrame({'image': cameraImage, 'type': widget.type});
  }

  Future<void> _getSavePath() async {
    final directory = await getApplicationDocumentsDirectory();
    path = directory.path;
  }

  @override
  void initState() {
    super.initState();
    _showInstructionDialog();
    _cameraStream();
    _getSavePath();
  }

  @override
  void dispose() {
    super.dispose();
    _controller!.dispose();
    _detector!.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Contour Detection")),
      body: Center(
        child: _controller == null
            ? Text("Loading")
            : Column(
          children: [
            Expanded(
              child: Screenshot(
                controller: _screenshotController,
                child: Stack(
                  children: [
                    CameraPreview(_controller!),
                    if (_controller != null &&
                        _controller!.value.isInitialized)
                      LayoutBuilder(
                        builder: (context, constraints) {
                          return CustomPaint(
                            size: _controller!.value.previewSize!,
                            painter: ContourPainter(
                              _contours,
                              Size(
                                  MediaQuery.of(context).size.width,
                                  MediaQuery.of(context).size.width *
                                      _controller!.value.aspectRatio),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
            _measurments.isNotEmpty
                ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(_measurments.first.toString()),
            )
                : const SizedBox(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Future.delayed(const Duration(milliseconds: 500));

          _screenshotController
              .captureAndSave(path, fileName: 'image.png')
              .then((savePath) {
            if (savePath != null && path.isNotEmpty) {
              print("Captured Measurments: $_measurments");
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => widget.type == 'sweat'
                      ? SweatshirtMeasurementResult(
                    actualSize: _measurments.first.map((k, v) => MapEntry(k, v)),
                    selectedSize: widget.selectedSize,
                    capturedImagePath: savePath,
                    selectedMeasurements: widget.selectedMeasurements,
                  )
                      : DenimJeanMeasurementResult(
                    actualSizes: _measurments.first.map((k, v) => MapEntry(k, v)),
                    // actualSizes: _measurments.isNotEmpty ? _measurments.first.map((k, v) => MapEntry(k, v)) : {},
                    selectedSize: widget.selectedSize,
                    capturedImagePath: savePath,
                    selectedMeasurements: widget.selectedMeasurements,
                  ),
                ),
                // MaterialPageRoute(
                //   builder: (context) {
                //     if (widget.type == 'sweat') {
                //       return SweatshirtMeasurementResult(
                //         actualSize: _measurments.first.map((k, v) => MapEntry(k, v)),
                //         selectedSize: widget.selectedSize,
                //         capturedImagePath: savePath,
                //         selectedMeasurements: widget.selectedMeasurements,
                //       );
                //     } else if (widget.type == 'jeans') {
                //       return DenimJeanMeasurementResult(
                //         actualSizes: _measurments.first.map((k, v) => MapEntry(k, v)),
                //         selectedSize: widget.selectedSize,
                //         capturedImagePath: savePath,
                //         selectedMeasurements: widget.selectedMeasurements,
                //       );
                //     } else {
                //       return const Scaffold(
                //         body: Center(child: Text("Invalid Type")),
                //       );
                //     }
                //   },
                // ),

              );
            }
          });
        },
        child: const Icon(
          Icons.camera,
        ),
      ),
    );
  }
}

class ContourPainter extends CustomPainter {
  final List<List<Map<String, double>>> contours;

  final Size canvasSize;

  ContourPainter(this.contours, this.canvasSize);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    if (contours.isNotEmpty) {
      for (int j = 0; j < contours.length; j++) {
        var contour = contours[j];
        Path path = Path();
        if (contour.isNotEmpty) {
          // Scale and move the first point

          path.moveTo(
            contour[0]['x']! * canvasSize.height,
            contour[0]['y']! * canvasSize.width,
          );

          // Scale and move remaining points
          for (int i = 1; i < contour.length; i++) {
            path.lineTo(
              contour[i]['x']! * canvasSize.height,
              contour[i]['y']! * canvasSize.width,
            );
          }

          path.close();
          canvas.drawPath(path, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}