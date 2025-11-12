import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:measuremate/Screens/results/sweatshirt_result.dart';

class SweatshirtCameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  final Map<String, double?> selectedMeasurements;
  final String selectedSize;

  const SweatshirtCameraScreen({
    super.key,
    required this.cameras,
    required this.selectedMeasurements,
    required this.selectedSize,
  });

  @override
  _SweatshirtCameraScreenState createState() => _SweatshirtCameraScreenState();
}


class _SweatshirtCameraScreenState extends State<SweatshirtCameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.cameras[0], ResolutionPreset.high);
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Capture Sweatshirt Measurement"),
          backgroundColor: Colors.teal,
        ),
        body: FutureBuilder<void>(
          future: _initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return CameraPreview(_controller);
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            try {
              await _initializeControllerFuture;
              final image = await _controller.takePicture();
              if (context.mounted) {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => SweatshirtMeasurementResult(
                //       actualSize: widget.actualSize,
                //       selectedSize: widget.selectedSize,
                //       capturedImagePath: image.path,
                //     ),
                //   ),
                // );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SweatshirtMeasurementResult(
                        actualSize: widget.selectedMeasurements,
                        selectedMeasurements: widget.selectedMeasurements,
                        selectedSize: widget.selectedSize,
                        capturedImagePath: image.path,
                      ),
                  ),
                );

              }
            } catch (e) {
              print(e);
            }
          },
          child: const Icon(Icons.camera),
        ),
      ),
    );
  }
}
