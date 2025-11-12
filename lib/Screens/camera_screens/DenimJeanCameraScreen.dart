import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:measuremate/Screens/results/denimjean_result.dart';

class DenimJeanCameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  final Map<String, double> actualSize;
  final String selectedSize;
  final Map<String, double> selectedMeasurements;

  const DenimJeanCameraScreen({
    super.key,
    required this.cameras,
    required this.actualSize,
    required this.selectedSize,
    required this.selectedMeasurements,
  });

  @override
  _DenimJeanCameraScreenState createState() => _DenimJeanCameraScreenState();
}

class _DenimJeanCameraScreenState extends State<DenimJeanCameraScreen> {
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

  Future<String> _getUniqueImagePath() async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'denim_${DateTime.now().millisecondsSinceEpoch}.jpg';
    return path.join(directory.path, fileName);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Capture Denim Jean Measurement"),
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

              // Generate unique path & save image with unique name
              final uniquePath = await _getUniqueImagePath();
              final savedImage = await File(image.path).copy(uniquePath);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DenimJeanMeasurementResult(
                    actualSizes: widget.actualSize,
                    selectedSize: widget.selectedSize,
                    selectedMeasurements: widget.selectedMeasurements,
                    capturedImagePath: savedImage.path, // Use unique path
                  ),
                ),
              );
            } catch (e) {
              print("Error capturing image: $e");
            }
          },
          child: const Icon(Icons.camera),
        ),
      ),
    );
  }
}
